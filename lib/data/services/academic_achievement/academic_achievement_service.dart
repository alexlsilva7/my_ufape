import 'package:isar_community/isar.dart';
import 'package:my_ufape/core/database/database.dart';
import 'package:my_ufape/core/debug/logarte.dart';
import 'package:my_ufape/domain/entities/academic_achievement.dart';
import 'package:result_dart/result_dart.dart';

class AcademicAchievementService {
  final Database _database;

  AcademicAchievementService(this._database);

  AsyncResult<Unit> upsertAcademicAchievement(AcademicAchievement data) async {
    try {
      final db = await _database.connection;
      await db.writeTxn(() async {
        await db.academicAchievements.clear(); // Só haverá um registro
        await db.academicAchievements.put(data);
      });
      logarte.database(
        source: 'Isar',
        target: 'AcademicAchievement',
        value: 'WRITE - Upserted academic achievement data',
      );
      return Success(unit);
    } catch (e) {
      return Failure(Exception('Failed to upsert academic achievement: $e'));
    }
  }

  AsyncResult<AcademicAchievement> getAcademicAchievement() async {
    try {
      final db = await _database.connection;
      final achievement = await db.academicAchievements.where().findFirst();
      logarte.database(
        source: 'Isar',
        target: 'AcademicAchievement',
        value:
            achievement == null ? 'READ - No data found' : 'READ - Data found',
      );
      if (achievement == null) {
        return Failure(Exception('No academic achievement data found'));
      }
      return Success(achievement);
    } catch (e) {
      return Failure(Exception('Failed to fetch academic achievement: $e'));
    }
  }
}
