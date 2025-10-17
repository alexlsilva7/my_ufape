import 'package:flutter/foundation.dart';
import 'package:my_ufape/data/repositories/school_history/school_history_repository.dart';
import 'package:my_ufape/data/repositories/subject/subject_repository.dart';
import 'package:my_ufape/data/repositories/subject_note/subject_note_repository.dart';
import 'package:my_ufape/domain/entities/school_history_subject.dart';
import 'package:my_ufape/domain/entities/subject.dart';
import 'package:my_ufape/domain/entities/subject_note.dart';

// Modelo para combinar os dados
class EnrichedSubject {
  final Subject subject;
  // Renomeado de 'note' para 'completionNote' para maior clareza.
  // Pode ser a nota da própria disciplina ou de uma equivalente.
  final SubjectNote? completionNote;
  final bool isFulfilledByEquivalence;

  EnrichedSubject({
    required this.subject,
    this.completionNote,
    this.isFulfilledByEquivalence = false,
  });

  bool get isWaived =>
      completionNote?.situacao.toUpperCase().contains('DISPENSADO') ?? false;

  bool get isApproved =>
      (completionNote?.situacao.toUpperCase().contains('APROVADO') ?? false) ||
      isWaived;
  bool get isFailed =>
      completionNote?.situacao.toUpperCase().contains('REPROVADO') ?? false;
  // O status 'cursando' só se aplica à própria disciplina, não a uma equivalência
  bool get isTaking =>
      !isFulfilledByEquivalence &&
      completionNote != null &&
      !isApproved &&
      !isFailed;
}

class SubjectsViewModel extends ChangeNotifier {
  final SubjectRepository _subjectRepository;
  final SubjectNoteRepository _subjectNoteRepository;
  final SchoolHistoryRepository _schoolHistoryRepository;

  SubjectsViewModel(this._subjectRepository, this._subjectNoteRepository,
      this._schoolHistoryRepository);

  Map<String, List<EnrichedSubject>> _groupedSubjects = {};
  Map<String, List<EnrichedSubject>> get groupedSubjects => _groupedSubjects;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get hasWaivedSubjects {
    for (final subjects in _groupedSubjects.values) {
      if (subjects.any((subject) => subject.isWaived)) {
        return true;
      }
    }
    return false;
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final subjectsResult = await _subjectRepository.getAllSubjects();
    final notesResult = await _subjectNoteRepository.getAllSubjectNotes();
    final waivedSubjectsResult = await _schoolHistoryRepository
        .getSchoolHistoriesSubjectByStatus('DISPENSADO');

    subjectsResult.fold(
      (subjects) {
        notesResult.fold(
          (notes) {
            waivedSubjectsResult.fold((waivedSubjects) {
              _processAndGroupData(subjects, notes, waivedSubjects);
            }, (error) {
              // Se dispensadas falharem, continua sem elas
              _processAndGroupData(subjects, notes, []);
            });
          },
          (error) {
            // Se notas falharem, ainda mostramos as disciplinas
            _processAndGroupData(subjects, [], []);
          },
        );
      },
      (error) {
        _errorMessage = "Erro ao carregar disciplinas: $error";
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  void _processAndGroupData(List<Subject> subjects, List<SubjectNote> notes,
      List<SchoolHistorySubject> waivedSubjects) {
    // Converte disciplinas dispensadas para SubjectNote e as adiciona na lista principal
    final List<SubjectNote> allNotes = [...notes];
    for (final waived in waivedSubjects) {
      if (waived.code != null && waived.name != null) {
        allNotes.add(SubjectNote(
          nome: '${waived.code} - ${waived.name}',
          semestre: '', // Não disponível no histórico
          situacao: waived.status ?? 'DISPENSADO',
          teacher: '', // Não disponível no histórico
        ));
      }
    }

    // Mapa para busca rápida de notas pelo código da disciplina.
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

    final List<EnrichedSubject> enrichedList = [];
    for (final subject in subjects) {
      // 1. Verificar se a própria disciplina foi cursada
      final directNote = notesMapByCode[subject.code];

      // Se foi aprovado diretamente, adiciona e vai para a próxima
      if (directNote != null &&
          directNote.situacao.toUpperCase().contains('APROVADO')) {
        enrichedList
            .add(EnrichedSubject(subject: subject, completionNote: directNote));
        continue;
      }

      // 2. Se não foi aprovado diretamente, procurar por equivalências aprovadas
      SubjectNote? equivalentApprovedNote;
      for (final equivalence in subject.equivalences) {
        if (equivalence.code != null) {
          final potentialNote = notesMapByCode[equivalence.code!];
          if (potentialNote != null &&
              potentialNote.situacao.toUpperCase().contains('APROVADO')) {
            equivalentApprovedNote = potentialNote;
            break; // Encontrou uma equivalência aprovada, pode parar de procurar
          }
        }
      }

      if (equivalentApprovedNote != null) {
        // Aprovado por equivalência
        enrichedList.add(EnrichedSubject(
          subject: subject,
          completionNote: equivalentApprovedNote,
          isFulfilledByEquivalence: true,
        ));
      } else {
        // Não foi aprovado nem por equivalência. Adiciona com a nota direta (se houver, ex: reprovado/cursando)
        enrichedList.add(EnrichedSubject(
          subject: subject,
          completionNote: directNote,
        ));
      }
    }

    // O resto da lógica de agrupamento e ordenação permanece a mesma...
    final Map<String, List<EnrichedSubject>> grouped = {};
    for (final enrichedSubject in enrichedList) {
      final period = enrichedSubject.subject.period;
      final key = period == '0' ? 'Optativas' : '$periodº Período';

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(enrichedSubject);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 'Optativas') return 1;
        if (b == 'Optativas') return -1;
        return int.parse(a.replaceAll('º Período', ''))
            .compareTo(int.parse(b.replaceAll('º Período', '')));
      });

    _groupedSubjects = {for (var key in sortedKeys) key: grouped[key]!};
  }
}
