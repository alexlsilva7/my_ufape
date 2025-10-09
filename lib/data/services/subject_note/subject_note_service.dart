import 'package:isar_community/isar.dart';
import 'package:my_ufape/core/database/database.dart';
import 'package:my_ufape/domain/entities/subject_note.dart';
import 'package:result_dart/result_dart.dart';

class SubjectNoteService {
  final Database _database;

  SubjectNoteService(this._database);

  AsyncResult<List<SubjectNote>> getAllSubjectNotes() async {
    try {
      final db = await _database.connection;
      final notes = await db.subjectNotes.where().findAll();
      return Success(notes.toList());
    } catch (e) {
      return Failure(Exception('Failed to fetch subject notes: $e'));
    }
  }

  AsyncResult<SubjectNote> getSubjectNoteById(int id) async {
    try {
      final db = await _database.connection;
      final note = await db.subjectNotes.get(id);
      if (note != null) {
        return Success(note);
      } else {
        return Failure(Exception('Subject note not found'));
      }
    } catch (e) {
      return Failure(Exception('Failed to fetch subject note by ID: $e'));
    }
  }

  AsyncResult<int> addSubjectNote(SubjectNote note) async {
    try {
      final db = await _database.connection;
      final id = await db.writeTxnSync(() async {
        return db.subjectNotes.putSync(note);
      });
      return Success(id);
    } catch (e) {
      return Failure(Exception('Failed to add subject note: $e'));
    }
  }

  AsyncResult<bool> updateSubjectNote(SubjectNote note) async {
    try {
      final db = await _database.connection;
      final success = await db.writeTxn(() async {
        return await db.subjectNotes.put(note) > 0;
      });
      return Success(success);
    } catch (e) {
      return Failure(Exception('Failed to update subject note: $e'));
    }
  }

  AsyncResult<bool> deleteSubjectNoteById(int id) async {
    try {
      final db = await _database.connection;
      final success = await db.writeTxn(() async {
        return await db.subjectNotes.delete(id);
      });
      return Success(success);
    } catch (e) {
      return Failure(Exception('Failed to delete subject note: $e'));
    }
  }
}
