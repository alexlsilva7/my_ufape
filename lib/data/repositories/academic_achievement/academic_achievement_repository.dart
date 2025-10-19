import 'package:my_ufape/domain/entities/academic_achievement.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class AcademicAchievementRepository {
  AsyncResult<Unit> upsertFromSiga(Map<String, dynamic> sigaData);
  AsyncResult<AcademicAchievement> getAcademicAchievement();
}
