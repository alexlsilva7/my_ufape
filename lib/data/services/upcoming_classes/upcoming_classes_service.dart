import 'package:my_ufape/data/repositories/scheduled_subject/scheduled_subject_repository.dart';
import 'package:my_ufape/domain/entities/time_table.dart';
import 'package:my_ufape/domain/entities/upcoming_class_data.dart';
import 'package:result_dart/result_dart.dart';

/// Serviço para calcular as próximas aulas baseado no horário atual.
///
/// Extrai a lógica de cálculo de próximas aulas para ser reutilizada
/// tanto no app Flutter quanto no Home Screen Widget.
class UpcomingClassesService {
  final ScheduledSubjectRepository _scheduledRepo;

  UpcomingClassesService(this._scheduledRepo);

  /// Retorna as próximas aulas ordenadas por proximidade.
  ///
  /// [limit] - número máximo de aulas a retornar (padrão: 3)
  AsyncResult<List<UpcomingClassData>> getUpcomingClasses(
      {int limit = 3}) async {
    try {
      final result = await _scheduledRepo.getAllScheduledSubjects();

      return result.fold(
        (subjects) {
          final upcomingClasses = _calculateUpcomingClasses(subjects, limit);
          return Success(upcomingClasses);
        },
        (error) => Failure(error),
      );
    } catch (e) {
      return Failure(Exception('Erro ao calcular próximas aulas: $e'));
    }
  }

  /// Calcula as próximas aulas a partir da lista de disciplinas.
  List<UpcomingClassData> _calculateUpcomingClasses(
    List<ScheduledSubject> subjects,
    int limit,
  ) {
    final now = DateTime.now();
    final todayIndex = now.weekday; // Monday=1 .. Sunday=7
    final nowMinutes = now.hour * 60 + now.minute;

    // Agrupar slots por disciplina + dia e mesclar horários contíguos
    final grouped = <String, List<TimeSlot>>{};
    final subjectByKey = <String, ScheduledSubject>{};

    for (final s in subjects) {
      for (final slot in s.timeSlots) {
        final key = '${s.code}_${slot.day}';
        subjectByKey[key] = s;
        grouped.putIfAbsent(key, () => []).add(slot);
      }
    }

    final intervals = <_ClassInterval>[];

    for (final entry in grouped.entries) {
      final key = entry.key;
      final slots = entry.value;
      if (slots.isEmpty) continue;

      // ordenar por startTime
      slots.sort((a, b) => a.startTime.compareTo(b.startTime));

      String currentStart = slots.first.startTime;
      String currentEnd = slots.first.endTime;
      final day = slots.first.day;
      final subject = subjectByKey[key]!;

      for (var i = 1; i < slots.length; i++) {
        final s = slots[i];
        // se o próximo começa exatamente quando o atual termina, mesclar
        if (s.startTime == currentEnd) {
          currentEnd = s.endTime;
        } else {
          // finalizar intervalo atual
          final mergedSlot = TimeSlot.create(
              day: day, startTime: currentStart, endTime: currentEnd);
          intervals.add(_ClassInterval(subject: subject, slot: mergedSlot));
          // iniciar novo intervalo
          currentStart = s.startTime;
          currentEnd = s.endTime;
        }
      }

      // adicionar último intervalo
      final lastMerged = TimeSlot.create(
          day: day, startTime: currentStart, endTime: currentEnd);
      intervals.add(_ClassInterval(subject: subject, slot: lastMerged));
    }

    // Para cada intervalo, calcular score de proximidade (em minutos)
    final upcoming = <_ScoredClass>[];

    for (final it in intervals) {
      final sDayIndex = _dayIndex(it.slot.day);
      if (sDayIndex == 0) continue;

      final offsetDays = (sDayIndex - todayIndex + 7) % 7;
      final startMinutes = _parseMinutes(it.slot.startTime);
      final endMinutes = _parseMinutes(it.slot.endTime);

      bool isOngoing = false;
      int effectiveOffset;

      // Se é hoje e está em andamento (já começou mas não terminou)
      if (offsetDays == 0 &&
          startMinutes <= nowMinutes &&
          endMinutes > nowMinutes) {
        isOngoing = true;
        effectiveOffset = 0;
      } else if (offsetDays == 0 && endMinutes <= nowMinutes) {
        // Se é hoje mas já passou, empurra para próxima semana
        effectiveOffset = 7;
      } else {
        effectiveOffset = offsetDays;
      }

      final score = effectiveOffset * 24 * 60 + startMinutes;
      upcoming.add(_ScoredClass(
        subject: it.subject,
        slot: it.slot,
        score: score,
        isOngoing: isOngoing,
        dayName: _dayName(it.slot.day),
        daysUntil: effectiveOffset,
      ));
    }

    // ordenar por score (menor = próximo)
    upcoming.sort((a, b) => a.score.compareTo(b.score));

    // Converter para UpcomingClassData e limitar
    return upcoming
        .take(limit)
        .map((e) => UpcomingClassData(
              subject: e.subject,
              slot: e.slot,
              isOngoing: e.isOngoing,
              dayName: e.dayName,
              daysUntil: e.daysUntil,
            ))
        .toList();
  }

  int _dayIndex(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.segunda:
        return 1;
      case DayOfWeek.terca:
        return 2;
      case DayOfWeek.quarta:
        return 3;
      case DayOfWeek.quinta:
        return 4;
      case DayOfWeek.sexta:
        return 5;
      case DayOfWeek.sabado:
        return 6;
      case DayOfWeek.domingo:
        return 7;
      default:
        return 0;
    }
  }

  String _dayName(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.segunda:
        return 'Segunda';
      case DayOfWeek.terca:
        return 'Terça';
      case DayOfWeek.quarta:
        return 'Quarta';
      case DayOfWeek.quinta:
        return 'Quinta';
      case DayOfWeek.sexta:
        return 'Sexta';
      case DayOfWeek.sabado:
        return 'Sábado';
      case DayOfWeek.domingo:
        return 'Domingo';
      default:
        return '';
    }
  }

  int _parseMinutes(String hhmm) {
    try {
      final parts = hhmm.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      return h * 60 + m;
    } catch (_) {
      return 0;
    }
  }
}

/// Classe auxiliar interna para intervalo de aula
class _ClassInterval {
  final ScheduledSubject subject;
  final TimeSlot slot;

  _ClassInterval({required this.subject, required this.slot});
}

/// Classe auxiliar interna para aula com score de proximidade
class _ScoredClass {
  final ScheduledSubject subject;
  final TimeSlot slot;
  final int score;
  final bool isOngoing;
  final String dayName;
  final int daysUntil;

  _ScoredClass({
    required this.subject,
    required this.slot,
    required this.score,
    required this.isOngoing,
    required this.dayName,
    required this.daysUntil,
  });
}
