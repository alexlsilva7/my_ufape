import 'package:isar_community/isar.dart';
import 'package:my_ufape/domain/entities/school_history_subject.dart';

part 'school_history.g.dart';

@collection
class SchoolHistory {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String period;

  @ignore
  List<SchoolHistorySubject> subjects = []; // Apenas para uso na UI

  double? periodAverage;
  double? periodCoefficient;

  SchoolHistory({required this.period});

  factory SchoolHistory.fromJson(Map<String, dynamic> json) {
    var history = SchoolHistory(period: json['period'] ?? 'N/A');
    history.periodAverage = (json['periodAverage'] as num?)?.toDouble();
    history.periodCoefficient = (json['periodCoefficient'] as num?)?.toDouble();
    return history;
  }
}
