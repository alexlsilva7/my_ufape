import 'package:isar_community/isar.dart';
import 'package:my_ufape/core/database/database.dart';
import 'package:my_ufape/domain/entities/subject.dart';
import 'package:result_dart/result_dart.dart';

class SubjectService {
  final Database _database;

  SubjectService(this._database);

  AsyncResult<List<Subject>> getAllSubjects() async {
    try {
      final db = await _database.connection;
      final subjects = await db.subjects.where().findAll();
      return Success(subjects.toList());
    } catch (e) {
      return Failure(Exception('Failed to fetch subjects: $e'));
    }
  }

  AsyncResult<Subject> getSubjectById(int id) async {
    try {
      final db = await _database.connection;
      final subject = await db.subjects.get(id);
      if (subject != null) {
        return Success(subject);
      } else {
        return Failure(Exception('Subject not found'));
      }
    } catch (e) {
      return Failure(Exception('Failed to fetch subject by ID: $e'));
    }
  }

  AsyncResult<List<Subject>> getSubjectsByName(String name) async {
    try {
      final db = await _database.connection;
      final subjects = await db.subjects
          .filter()
          .nameContains(name, caseSensitive: false)
          .findAll();
      return Success(subjects.toList());
    } catch (e) {
      return Failure(Exception('Failed to fetch subjects by name: $e'));
    }
  }

  AsyncResult<List<Subject>> getSubjectsByPeriod(String period) async {
    try {
      final db = await _database.connection;
      final subjects =
          await db.subjects.filter().periodEqualTo(period).findAll();
      return Success(subjects.toList());
    } catch (e) {
      return Failure(Exception('Failed to fetch subjects by period: $e'));
    }
  }

  AsyncResult<List<Subject>> getSubjectsByType(CourseType type) async {
    try {
      final db = await _database.connection;
      final subjects = await db.subjects.filter().typeEqualTo(type).findAll();
      return Success(subjects.toList());
    } catch (e) {
      return Failure(Exception('Failed to fetch subjects by type: $e'));
    }
  }

  AsyncResult<int> addSubject(Subject subject) async {
    try {
      final db = await _database.connection;
      final id = await db.writeTxnSync(() async {
        return db.subjects.putSync(subject);
      });
      return Success(id);
    } catch (e) {
      return Failure(Exception('Failed to add subject: $e'));
    }
  }

  AsyncResult<bool> updateSubject(Subject subject) async {
    try {
      final db = await _database.connection;
      final success = await db.writeTxn(() async {
        return await db.subjects.put(subject) > 0;
      });
      return Success(success);
    } catch (e) {
      return Failure(Exception('Failed to update subject: $e'));
    }
  }

  AsyncResult<bool> deleteSubjectById(int id) async {
    try {
      final db = await _database.connection;
      final success = await db.writeTxn(() async {
        return await db.subjects.delete(id);
      });
      return Success(success);
    } catch (e) {
      return Failure(Exception('Failed to delete subject: $e'));
    }
  }
}
