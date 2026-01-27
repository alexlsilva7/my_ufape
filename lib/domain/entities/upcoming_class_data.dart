import 'package:my_ufape/domain/entities/time_table.dart';

/// Representa uma próxima aula calculada a partir do horário.
///
/// Modelo imutável usado para exibir próximas aulas na home e
/// no Home Screen Widget.
class UpcomingClassData {
  /// Disciplina agendada
  final ScheduledSubject subject;

  /// Slot de horário específico
  final TimeSlot slot;

  /// Se a aula está acontecendo agora
  final bool isOngoing;

  /// Nome do dia da semana (ex: "Segunda", "Terça")
  final String dayName;

  /// Quantos dias até a aula (0 = hoje, 1 = amanhã, etc.)
  final int daysUntil;

  final String? type; // "teorica", "pratica", etc.
  final String? classContent; // Assunto da aula (do plano de ensino)

  const UpcomingClassData({
    required this.subject,
    required this.slot,
    required this.isOngoing,
    required this.dayName,
    required this.daysUntil,
    this.type,
    this.classContent,
  });

  /// Label amigável para exibição (AGORA, Hoje, Amanhã, ou nome do dia)
  String get dayLabel {
    if (daysUntil == 0) {
      return isOngoing ? 'AGORA' : 'Hoje';
    } else if (daysUntil == 1) {
      return 'Amanhã';
    } else {
      return dayName;
    }
  }

  /// Converte para Map para serialização (usado no Home Widget)
  Map<String, dynamic> toJson() => {
        'subjectName': subject.name,
        'subjectCode': subject.code,
        'className': subject.className,
        'room': subject.room,
        'startTime': slot.startTime,
        'endTime': slot.endTime,
        'isOngoing': isOngoing,
        'dayName': dayName,
        'dayLabel': dayLabel,
        'daysUntil': daysUntil,
        'classContent': classContent ?? '',
      };

  @override
  String toString() =>
      'UpcomingClassData(subject: ${subject.name}, slot: ${slot.startTime}-${slot.endTime}, dayLabel: $dayLabel)';
}
