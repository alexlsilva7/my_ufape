import 'package:isar_community/isar.dart';

part 'time_table.g.dart';

// Representa um bloco de horário de uma disciplina
@embedded
class TimeSlot {
  @Enumerated(EnumType.ordinal32)
  late DayOfWeek day;

  late String startTime;
  late String endTime;

  TimeSlot();

  TimeSlot.create({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot.create(
      day: DayOfWeek.fromString(json['day'] ?? ''),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
    );
  }

  @override
  String toString() {
    return 'TimeSlot(day: $day, startTime: $startTime, endTime: $endTime)';
  }
}

// Representa uma disciplina na grade horária
@collection
class ScheduledSubject {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String code;

  @Index(type: IndexType.value, caseSensitive: false)
  late String name;

  late String className; // Turma
  late String room;
  late String status;

  List<TimeSlot> timeSlots = [];

  ScheduledSubject();

  ScheduledSubject.create({
    required this.code,
    required this.name,
    required this.className,
    required this.room,
    required this.status,
    this.timeSlots = const [],
  });

  factory ScheduledSubject.fromJson(Map<String, dynamic> json) {
    return ScheduledSubject.create(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      className: json['className'] ?? '',
      room: json['room'] ?? '',
      status: json['status'] ?? '',
      timeSlots: (json['timeSlots'] as List<dynamic>? ?? [])
          .map((slot) => TimeSlot.fromJson(slot as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'ScheduledSubject(code: $code, name: $name, className: $className, room: $room, status: $status, timeSlots: $timeSlots)';
  }
}

// Enum para os dias da semana para facilitar o manuseio
enum DayOfWeek {
  segunda,
  terca,
  quarta,
  quinta,
  sexta,
  sabado,
  domingo,
  desconhecido;

  static DayOfWeek fromString(String day) {
    switch (day.toUpperCase()) {
      case 'SEG':
        return DayOfWeek.segunda;
      case 'TER':
        return DayOfWeek.terca;
      case 'QUA':
        return DayOfWeek.quarta;
      case 'QUI':
        return DayOfWeek.quinta;
      case 'SEX':
        return DayOfWeek.sexta;
      case 'SAB':
      case 'SÁB':
        return DayOfWeek.sabado;
      default:
        return DayOfWeek.desconhecido;
    }
  }

  String toShortString() {
    switch (this) {
      case DayOfWeek.segunda:
        return 'SEG';
      case DayOfWeek.terca:
        return 'TER';
      case DayOfWeek.quarta:
        return 'QUA';
      case DayOfWeek.quinta:
        return 'QUI';
      case DayOfWeek.sexta:
        return 'SEX';
      case DayOfWeek.sabado:
        return 'SÁB';
      default:
        return '';
    }
  }
}
