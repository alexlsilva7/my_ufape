import 'package:isar_community/isar.dart';
import 'package:my_ufape/core/database/database.dart';
import 'package:my_ufape/domain/entities/time_table.dart';
import 'package:result_dart/result_dart.dart';

class ScheduledSubjectService {
  final Database _database;

  ScheduledSubjectService(this._database);

  AsyncResult<List<ScheduledSubject>> getAllScheduledSubjects() async {
    try {
      final db = await _database.connection;
      final subjects = await db.scheduledSubjects.where().findAll();
      return Success(subjects.toList());
    } catch (e) {
      return Failure(Exception('Failed to fetch scheduled subjects: $e'));
    }
  }

  AsyncResult<ScheduledSubject> getScheduledSubjectById(int id) async {
    try {
      final db = await _database.connection;
      final subject = await db.scheduledSubjects.get(id);
      if (subject != null) {
        return Success(subject);
      } else {
        return Failure(Exception('Scheduled subject not found'));
      }
    } catch (e) {
      return Failure(Exception('Failed to fetch scheduled subject by ID: $e'));
    }
  }

  AsyncResult<ScheduledSubject> getScheduledSubjectByCode(String code) async {
    try {
      final db = await _database.connection;
      final subject =
          await db.scheduledSubjects.filter().codeEqualTo(code).findFirst();
      if (subject != null) {
        return Success(subject);
      } else {
        return Failure(Exception('Scheduled subject not found'));
      }
    } catch (e) {
      return Failure(
          Exception('Failed to fetch scheduled subject by code: $e'));
    }
  }

  AsyncResult<int> addScheduledSubject(ScheduledSubject subject) async {
    try {
      final db = await _database.connection;
      final id = await db.writeTxnSync(() async {
        return db.scheduledSubjects.putSync(subject);
      });
      return Success(id);
    } catch (e) {
      return Failure(Exception('Failed to add scheduled subject: $e'));
    }
  }

  AsyncResult<bool> updateScheduledSubject(ScheduledSubject subject) async {
    try {
      final db = await _database.connection;
      final success = await db.writeTxn(() async {
        return await db.scheduledSubjects.put(subject) > 0;
      });
      return Success(success);
    } catch (e) {
      return Failure(Exception('Failed to update scheduled subject: $e'));
    }
  }

  AsyncResult<bool> deleteScheduledSubjectById(int id) async {
    try {
      final db = await _database.connection;
      final success = await db.writeTxn(() async {
        return await db.scheduledSubjects.delete(id);
      });
      return Success(success);
    } catch (e) {
      return Failure(Exception('Failed to delete scheduled subject: $e'));
    }
  }

  AsyncResult<bool> deleteAllScheduledSubjects() async {
    try {
      final db = await _database.connection;
      await db.writeTxn(() async {
        await db.scheduledSubjects.clear();
      });
      return Success(true);
    } catch (e) {
      return Failure(Exception('Failed to delete all scheduled subjects: $e'));
    }
  }
}
