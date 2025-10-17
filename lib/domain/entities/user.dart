import 'package:isar_community/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  String name;

  @Index(unique: true)
  String cpf;

  @Index(unique: true)
  String registration;

  String course;
  String entryPeriod;
  String entryType;
  String profile;
  String shift;
  String situation;
  String currentPeriod;

  double? overallAverage;
  double? overallCoefficient;

  User({
    required this.name,
    required this.cpf,
    required this.registration,
    required this.course,
    required this.entryPeriod,
    required this.entryType,
    required this.profile,
    required this.shift,
    required this.situation,
    required this.currentPeriod,
    this.overallAverage,
    this.overallCoefficient,
  });
}
