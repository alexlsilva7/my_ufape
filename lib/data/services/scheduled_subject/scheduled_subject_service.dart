import 'package:isar_community/isar.dart';
import 'package:my_ufape/core/database/database.dart';
import 'package:my_ufape/core/debug/logarte.dart';
import 'package:my_ufape/domain/entities/time_table.dart';
import 'package:result_dart/result_dart.dart';

class ScheduledSubjectService {
  final Database _database;

  ScheduledSubjectService(this._database);

  AsyncResult<List<ScheduledSubject>> getAllScheduledSubjects() async {
    try {
      final db = await _database.connection;
      final subjects = await db.scheduledSubjects.where().findAll();
      logarte.database(
        source: 'Isar',
        target: 'ScheduledSubject',
        value: 'READ - Fetched ${subjects.length} items',
      );
      return Success(subjects.toList());
    } catch (e) {
      logarte.database(
        source: 'Isar',
        target: 'ScheduledSubject',
        value: 'READ - Error: $e',
      );
      return Failure(Exception('Failed to fetch scheduled subjects: $e'));
    }
  }

  AsyncResult<ScheduledSubject> getScheduledSubjectById(int id) async {
    try {
      final db = await _database.connection;
      final subject = await db.scheduledSubjects.get(id);
      if (subject != null) {
        logarte.database(
          source: 'Isar',
          target: 'ScheduledSubject',
          value: 'READ - ID $id found',
        );
        return Success(subject);
      } else {
        return Failure(Exception('Scheduled subject not found'));
      }
    } catch (e) {
      logarte.database(
        source: 'Isar',
        target: 'ScheduledSubject',
        value: 'READ - Error getting ID $id: $e',
      );
      return Failure(Exception('Failed to fetch scheduled subject by ID: $e'));
    }
  }

  AsyncResult<ScheduledSubject> getScheduledSubjectByCode(String code) async {
    try {
      final db = await _database.connection;
      final subject =
          await db.scheduledSubjects.filter().codeEqualTo(code).findFirst();
      if (subject != null) {
        logarte.database(
          source: 'Isar',
          target: 'ScheduledSubject',
          value: 'READ - Code $code found',
        );
        return Success(subject);
      } else {
        return Failure(Exception('Scheduled subject not found'));
      }
    } catch (e) {
      logarte.database(
        source: 'Isar',
        target: 'ScheduledSubject',
        value: 'READ - Error getting code $code: $e',
      );
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
      logarte.database(
        source: 'Isar',
        target: 'ScheduledSubject',
        value: 'WRITE - Added new subject with ID $id',
      );
      return Success(id);
    } catch (e) {
      logarte.database(
        source: 'Isar',
        target: 'ScheduledSubject',
        value: 'WRITE - Error adding subject: $e',
      );
      return Failure(Exception('Failed to add scheduled subject: $e'));
    }
  }

  AsyncResult<bool> updateScheduledSubject(ScheduledSubject subject) async {
    try {
      final db = await _database.connection;
      final success = await db.writeTxn(() async {
        return await db.scheduledSubjects.put(subject) > 0;
      });
      logarte.database(
        source: 'Isar',
        target: 'ScheduledSubject',
        value: 'WRITE - Updated subject with ID ${subject.id}',
      );
      return Success(success);
    } catch (e) {
      logarte.database(
        source: 'Isar',
        target: 'ScheduledSubject',
        value: 'WRITE - Error updating subject ID ${subject.id}: $e',
      );
      return Failure(Exception('Failed to update scheduled subject: $e'));
    }
  }

  AsyncResult<bool> deleteScheduledSubjectById(int id) async {
    try {
      final db = await _database.connection;
      final success = await db.writeTxn(() async {
        return await db.scheduledSubjects.delete(id);
      });
      logarte.database(
        source: 'Isar',
        target: 'ScheduledSubject',
        value: 'DELETE - Deleted subject with ID $id',
      );
      return Success(success);
    } catch (e) {
      logarte.database(
        source: 'Isar',
        target: 'ScheduledSubject',
        value: 'DELETE - Error deleting subject ID $id: $e',
      );
      return Failure(Exception('Failed to delete scheduled subject: $e'));
    }
  }

  AsyncResult<bool> deleteAllScheduledSubjects() async {
    try {
      final db = await _database.connection;
      await db.writeTxn(() async {
        await db.scheduledSubjects.clear();
      });
      logarte.database(
        source: 'Isar',
        target: 'ScheduledSubject',
        value: 'DELETE - Cleared all scheduled subjects',
      );
      return Success(true);
    } catch (e) {
      logarte.database(
        source: 'Isar',
        target: 'ScheduledSubject',
        value: 'DELETE - Error clearing all subjects: $e',
      );
      return Failure(Exception('Failed to delete all scheduled subjects: $e'));
    }
  }
}
