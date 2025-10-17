import 'package:isar_community/isar.dart';

part 'school_history_subject.g.dart';

@collection
class SchoolHistorySubject {
  Id id = Isar.autoIncrement;

  @Index()
  String period;

  String? code;
  String? name;
  int? absences;
  int? workload;
  int? credits;
  double? finalGrade;
  String? status;

  SchoolHistorySubject({required this.period});

  factory SchoolHistorySubject.fromJson(
      Map<String, dynamic> json, String period) {
    return SchoolHistorySubject(period: period)
      ..code = json['code']
      ..name = json['name']
      ..absences = json['absences']
      ..workload = json['workload']
      ..credits = json['credits']
      ..finalGrade = (json['finalGrade'] as num?)?.toDouble()
      ..status = json['status'];
  }
}
