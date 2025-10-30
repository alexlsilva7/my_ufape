import 'package:isar_community/isar.dart';

part 'user.g.dart';

enum SyncStatus {
  idle,
  inProgress,
  success,
  failed,
}

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

  @Enumerated(EnumType.name)
  SyncStatus lastSyncStatus;
  DateTime? lastSyncAttempt;
  DateTime? lastSyncSuccess;
  String? lastSyncMessage;
  DateTime? nextSyncTimestamp;

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
    this.lastSyncStatus = SyncStatus.idle,
    this.lastSyncAttempt,
    this.lastSyncSuccess,
    this.lastSyncMessage,
    this.nextSyncTimestamp,
    this.overallAverage,
    this.overallCoefficient,
  });
}
