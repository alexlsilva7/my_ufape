import 'package:flutter/material.dart';
import 'package:my_ufape/core/debug/logarte.dart';
import 'package:my_ufape/data/repositories/scheduled_subject/scheduled_subject_repository.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:my_ufape/data/repositories/subject/subject_repository.dart';
import 'package:my_ufape/data/repositories/school_history/school_history_repository.dart';
import 'package:my_ufape/data/repositories/subject_note/subject_note_repository.dart';
import 'package:my_ufape/data/services/gemini/schedule_extraction_service.dart';
import 'package:my_ufape/domain/entities/subject.dart';
import 'package:my_ufape/domain/entities/subject_note.dart';
import 'package:my_ufape/domain/entities/time_table.dart';
import 'package:my_ufape/domain/entities/school_history_subject.dart';
import 'dart:typed_data';

/// Representa um horário individual de uma turma
class ClassSchedule {
  final String day;
  final String start;
  final String end;

  ClassSchedule({required this.day, required this.start, required this.end});

  factory ClassSchedule.fromJson(Map<String, dynamic> json) {
    return ClassSchedule(
      day: json['day'] ?? '',
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }
}

/// Representa uma turma ofertada no semestre
class AvailableClass {
  final String subjectCode;
  final String subjectName;
  final String professor;
  final String period;
  final String className;
  final String room;
  final List<ClassSchedule> schedules;
  Subject? localSubjectData;

  AvailableClass({
    required this.subjectCode,
    required this.subjectName,
    required this.professor,
    required this.period,
    required this.className,
    required this.room,
    required this.schedules,
  });

  factory AvailableClass.fromJson(Map<String, dynamic> json) {
    return AvailableClass(
      subjectCode: json['subjectCode'] ?? '',
      subjectName: json['subjectName'] ?? '',
      professor: json['professor'] ?? '',
      period: json['period'] ?? '',
      className: json['className'] ?? '',
      room: json['room'] ?? '',
      schedules: (json['schedules'] as List<dynamic>? ?? [])
          .map((s) => ClassSchedule.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TimetableBuilderViewModel extends ChangeNotifier {
  final ScheduleExtractionService _extractionService;
  final SettingsRepository _settings;
  final SubjectRepository _subjectRepository;
  final ScheduledSubjectRepository _scheduledSubjectRepository;
  final SchoolHistoryRepository _schoolHistoryRepository;
  final SubjectNoteRepository _subjectNoteRepository;

  Map<String, SubjectNote> _notesMapByCode = {};

  TimetableBuilderViewModel(
    this._extractionService,
    this._settings,
    this._subjectRepository,
    this._scheduledSubjectRepository,
    this._schoolHistoryRepository,
    this._subjectNoteRepository,
  ) {
    _loadPassedSubjectsData();
  }

  Future<void> _loadPassedSubjectsData() async {
    final notesResult = await _subjectNoteRepository.getAllSubjectNotes();
    final waivedSubjectsResult = await _schoolHistoryRepository
        .getSchoolHistoriesSubjectByStatus('DISPENSADO');

    List<SubjectNote> allNotes = [];

    notesResult.fold(
      (notes) => allNotes.addAll(notes),
      (error) => null,
    );

    waivedSubjectsResult.fold(
      (waivedSubjects) {
        for (final waived in waivedSubjects) {
          if (waived.code != null && waived.name != null) {
            allNotes.add(SubjectNote(
              nome: '${waived.code} - ${waived.name}',
              semestre: '',
              situacao: waived.status ?? 'DISPENSADO',
              teacher: '',
            ));
          }
        }
      },
      (error) => null,
    );

    final Map<String, SubjectNote> notesMapByCode = {};
    for (final note in allNotes) {
      final parts = note.nome.split(' - ');
      if (parts.isNotEmpty) {
        final code = parts[0].trim();
        if (notesMapByCode.containsKey(code)) {
          final existingNote = notesMapByCode[code]!;
          if (note.situacao.toUpperCase().contains('APROVADO') &&
              !existingNote.situacao.toUpperCase().contains('APROVADO')) {
            notesMapByCode[code] = note;
          }
        } else {
          notesMapByCode[code] = note;
        }
      }
    }
    _notesMapByCode = notesMapByCode;
    notifyListeners();
  }

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  String? selectedPeriodFilter;

  List<AvailableClass> _allClasses = [];
  List<AvailableClass> get allClasses => _allClasses;
  List<AvailableClass> selectedClasses = [];

  /// Classes filtradas pelo período selecionado e que ainda NÃO foram aprovadas
  List<AvailableClass> get availableClasses {
    // Filtra removendo as disciplinas que o aluno já passou
    Iterable<AvailableClass> unpassedClasses =
        _allClasses.where((c) => !isPassed(c));

    if (selectedPeriodFilter == null || selectedPeriodFilter!.isEmpty) {
      return unpassedClasses.toList();
    }
    return unpassedClasses
        .where((c) =>
            c.period.toLowerCase() == selectedPeriodFilter!.toLowerCase())
        .toList();
  }

  /// Períodos disponíveis para filtro (apenas de disciplinas não cursadas)
  List<String> get availablePeriods {
    final periods = _allClasses
        .where((c) =>
            !isPassed(c)) // Considera apenas os períodos das matérias pendentes
        .map((c) => c.period)
        .toSet()
        .toList();
    periods.sort();
    return periods;
  }

  /// Total de créditos das disciplinas selecionadas
  int get totalCredits {
    int total = 0;
    for (var c in selectedClasses) {
      total += c.localSubjectData?.credits ?? 0;
    }
    return total;
  }

  void setFilter(String? period) {
    selectedPeriodFilter = period;
    notifyListeners();
  }

  /// Processa o PDF de horários com Gemini
  Future<void> processSchedulePdf(Uint8List pdfBytes) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final apiKey = await _settings.getGeminiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception(
            "Configure a chave da API do Gemini nas Configurações.");
      }

      // Buscar disciplinas conhecidas
      List<String> knownSubjectsContext = [];
      List<Subject> allLocalSubjects = [];
      try {
        final allSubjectsResult = await _subjectRepository.getAllSubjects();
        allSubjectsResult.fold(
          (subjects) {
            allLocalSubjects = subjects;
            knownSubjectsContext =
                subjects.map((s) => '${s.code} - ${s.name}').toList();
          },
          (error) {
            logarte.log('Erro ao carregar disciplinas: $error',
                source: 'TimetableBuilderViewModel');
          },
        );
      } catch (e) {
        logarte.log('Falha ao obter lista de disciplinas para contexto: $e',
            source: 'TimetableBuilderViewModel');
      }

      logarte.log(
          'Enviando ${knownSubjectsContext.length} disciplinas conhecidas para o Gemini. ${knownSubjectsContext.join("\n")}',
          source: 'TimetableBuilderViewModel');

      final rawClasses = await _extractionService.extractSchedule(
        apiKey: apiKey,
        pdfBytes: pdfBytes,
        knownSubjectsContext: knownSubjectsContext,
      );

      List<AvailableClass> parsedClasses = [];
      for (var json in rawClasses) {
        var aClass = AvailableClass.fromJson(json);

        // Enriquecimento: busca a matéria na lista local carregada
        try {
          // Busca primeiro pelo código retornado
          Subject? matchedSubject;
          if (aClass.subjectCode.isNotEmpty) {
            try {
              matchedSubject = allLocalSubjects
                  .firstWhere((s) => s.code == aClass.subjectCode);
            } catch (_) {}
          }

          // Fallback para buscar pelo nome
          if (matchedSubject == null) {
            try {
              matchedSubject = allLocalSubjects.firstWhere((s) =>
                  s.name.toLowerCase() == aClass.subjectName.toLowerCase());
            } catch (_) {}
          }

          if (matchedSubject != null) {
            aClass.localSubjectData = matchedSubject;
          }
        } catch (_) {
          // Ignora erro de enriquecimento — dados da extração são suficientes
        }

        parsedClasses.add(aClass);
      }

      _allClasses = parsedClasses;
      selectedClasses = [];
      selectedPeriodFilter = null;
    } catch (e) {
      logarte.log('Erro ao processar PDF: $e',
          source: 'TimetableBuilderViewModel');
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Verifica se há conflito de horário com as disciplinas já selecionadas
  String? checkConflict(AvailableClass newClass) {
    for (var schedule in newClass.schedules) {
      final newStart = _timeToMinutes(schedule.start);
      final newEnd = _timeToMinutes(schedule.end);

      for (var selected in selectedClasses) {
        for (var selSchedule in selected.schedules) {
          if (selSchedule.day == schedule.day) {
            final selStart = _timeToMinutes(selSchedule.start);
            final selEnd = _timeToMinutes(selSchedule.end);

            // Intersecção: newStart < selEnd && newEnd > selStart
            if (newStart < selEnd && newEnd > selStart) {
              return "Conflito com: ${selected.subjectName} "
                  "(${selSchedule.start} - ${selSchedule.end})";
            }
          }
        }
      }
    }
    return null;
  }

  /// Adiciona uma turma à grade. Lança exceção se houver conflito.
  void addClass(AvailableClass newClass) {
    // Verifica se já foi adicionada
    if (selectedClasses.contains(newClass)) {
      throw Exception("Disciplina já adicionada.");
    }

    final conflict = checkConflict(newClass);
    if (conflict != null) {
      throw Exception(conflict);
    }
    selectedClasses.add(newClass);
    notifyListeners();
  }

  /// Remove uma turma da grade
  void removeClass(AvailableClass c) {
    selectedClasses.remove(c);
    notifyListeners();
  }

  /// Verifica se uma turma já está selecionada
  bool isSelected(AvailableClass c) {
    return selectedClasses.contains(c);
  }

  /// Verifica se o usuário já passou na disciplina
  bool isPassed(AvailableClass c) {
    if (c.localSubjectData == null) return false;
    final subject = c.localSubjectData!;

    final directNote = _notesMapByCode[subject.code];
    if (directNote != null &&
        (directNote.situacao.toUpperCase().contains('APROVADO') ||
            directNote.situacao.toUpperCase().contains('DISPENSADO'))) {
      return true;
    }

    for (final equivalence in subject.equivalences) {
      if (equivalence.code != null) {
        final potentialNote = _notesMapByCode[equivalence.code!];
        if (potentialNote != null &&
            (potentialNote.situacao.toUpperCase().contains('APROVADO') ||
                potentialNote.situacao.toUpperCase().contains('DISPENSADO'))) {
          return true;
        }
      }
    }

    return false;
  }

  /// Salva a grade montada no banco de dados (substitui a existente)
  Future<bool> saveToDatabase() async {
    if (selectedClasses.isEmpty) return false;

    isSaving = true;
    notifyListeners();

    try {
      // Limpa a grade existente
      await _scheduledSubjectRepository.deleteAllScheduledSubjects();

      // Converte cada AvailableClass em ScheduledSubject
      for (var aClass in selectedClasses) {
        final scheduledSubject = ScheduledSubject.create(
          code: aClass.localSubjectData?.code ??
              aClass.subjectName.hashCode.toString(),
          name: aClass.subjectName,
          className: aClass.className,
          room: aClass.room,
          status: 'Montada via IA',
          timeSlots: aClass.schedules.map((s) {
            return TimeSlot.create(
              day: _dayFromString(s.day),
              startTime: s.start,
              endTime: s.end,
            );
          }).toList(),
        );

        await _scheduledSubjectRepository
            .upsertScheduledSubject(scheduledSubject);
      }

      return true;
    } catch (e) {
      logarte.log('Erro ao salvar grade: $e',
          source: 'TimetableBuilderViewModel');
      errorMessage = 'Erro ao salvar: ${e.toString()}';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  DayOfWeek _dayFromString(String day) {
    switch (day.toLowerCase()) {
      case 'segunda':
        return DayOfWeek.segunda;
      case 'terca':
        return DayOfWeek.terca;
      case 'quarta':
        return DayOfWeek.quarta;
      case 'quinta':
        return DayOfWeek.quinta;
      case 'sexta':
        return DayOfWeek.sexta;
      case 'sabado':
        return DayOfWeek.sabado;
      default:
        return DayOfWeek.desconhecido;
    }
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  static const dayOrder = [
    DayOfWeek.segunda,
    DayOfWeek.terca,
    DayOfWeek.quarta,
    DayOfWeek.quinta,
    DayOfWeek.sexta,
    DayOfWeek.sabado,
  ];

  Map<DayOfWeek, List<AvailableClass>> groupByDay() {
    final map = <DayOfWeek, List<AvailableClass>>{};
    for (final day in dayOrder) {
      map[day] = [];
    }

    for (final c in selectedClasses) {
      for (final schedule in c.schedules) {
        final day = _dayFromString(schedule.day);
        if (map.containsKey(day)) {
          if (!map[day]!.contains(c)) {
            map[day]!.add(c);
          }
        }
      }
    }

    for (final day in map.keys) {
      map[day]!.sort((a, b) {
        final aSlotsForDay = a.schedules.where((s) => _dayFromString(s.day) == day).toList();
        final bSlotsForDay = b.schedules.where((s) => _dayFromString(s.day) == day).toList();

        if (aSlotsForDay.isEmpty && bSlotsForDay.isEmpty) return 0;
        if (aSlotsForDay.isEmpty) return 1;
        if (bSlotsForDay.isEmpty) return -1;

        final aStart = _timeToMinutes(aSlotsForDay.first.start);
        final bStart = _timeToMinutes(bSlotsForDay.first.start);
        return aStart.compareTo(bStart);
      });
    }

    return map;
  }
}
