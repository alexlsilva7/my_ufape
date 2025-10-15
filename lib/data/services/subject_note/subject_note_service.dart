import 'package:isar_community/isar.dart';
import 'package:my_ufape/core/database/database.dart';
import 'package:my_ufape/core/debug/logarte.dart';
import 'package:my_ufape/domain/entities/subject_note.dart';
import 'package:result_dart/result_dart.dart';

class SubjectNoteService {
  final Database _database;

  SubjectNoteService(this._database);

  AsyncResult<List<SubjectNote>> getAllSubjectNotes() async {
    try {
      final db = await _database.connection;
      final notes = await db.subjectNotes.where().findAll();
      logarte.database(
        source: 'Isar',
        target: 'SubjectNote',
        value: 'READ - Fetched ${notes.length} items',
      );
      return Success(notes.toList());
    } catch (e) {
      logarte.database(
        source: 'Isar',
        target: 'SubjectNote',
        value: 'READ - Error: $e',
      );
      return Failure(Exception('Failed to fetch subject notes: $e'));
    }
  }

  AsyncResult<SubjectNote> getSubjectNoteById(int id) async {
    try {
      final db = await _database.connection;
      final note = await db.subjectNotes.get(id);
      if (note != null) {
        logarte.database(
          source: 'Isar',
          target: 'SubjectNote',
          value: 'READ - ID $id found',
        );
        return Success(note);
      } else {
        return Failure(Exception('Subject note not found'));
      }
    } catch (e) {
      logarte.database(
        source: 'Isar',
        target: 'SubjectNote',
        value: 'READ - Error getting ID $id: $e',
      );
      return Failure(Exception('Failed to fetch subject note by ID: $e'));
    }
  }

  AsyncResult<SubjectNote> getSubjectNoteByNameAndSemester(
      String name, String semester) async {
    try {
      final db = await _database.connection;
      final note = await db.subjectNotes
          .filter()
          .nomeEqualTo(name)
          .and()
          .semestreEqualTo(semester)
          .findFirst();
      if (note != null) {
        logarte.database(
          source: 'Isar',
          target: 'SubjectNote',
          value: 'READ - Found note "$name" for semester $semester',
        );
        return Success(note);
      } else {
        return Failure(Exception('Subject note not found'));
      }
    } catch (e) {
      logarte.database(
        source: 'Isar',
        target: 'SubjectNote',
        value: 'READ - Error finding note "$name": $e',
      );
      return Failure(
          Exception('Failed to fetch subject note by name and semester: $e'));
    }
  }

  AsyncResult<int> addSubjectNote(SubjectNote note) async {
    try {
      final db = await _database.connection;
      final id = await db.writeTxnSync(() async {
        return db.subjectNotes.putSync(note);
      });
      logarte.database(
        source: 'Isar',
        target: 'SubjectNote',
        value: 'WRITE - Added new note with ID $id',
      );
      return Success(id);
    } catch (e) {
      logarte.database(
        source: 'Isar',
        target: 'SubjectNote',
        value: 'WRITE - Error adding note: $e',
      );
      return Failure(Exception('Failed to add subject note: $e'));
    }
  }

  AsyncResult<bool> updateSubjectNote(SubjectNote note) async {
    try {
      final db = await _database.connection;
      final success = await db.writeTxn(() async {
        return await db.subjectNotes.put(note) > 0;
      });
      logarte.database(
        source: 'Isar',
        target: 'SubjectNote',
        value: 'WRITE - Updated note with ID ${note.id}',
      );
      return Success(success);
    } catch (e) {
      logarte.database(
        source: 'Isar',
        target: 'SubjectNote',
        value: 'WRITE - Error updating note ID ${note.id}: $e',
      );
      return Failure(Exception('Failed to update subject note: $e'));
    }
  }

  AsyncResult<bool> deleteSubjectNoteById(int id) async {
    try {
      final db = await _database.connection;
      final success = await db.writeTxn(() async {
        return await db.subjectNotes.delete(id);
      });
      logarte.database(
        source: 'Isar',
        target: 'SubjectNote',
        value: 'DELETE - Deleted note with ID $id',
      );
      return Success(success);
    } catch (e) {
      logarte.database(
        source: 'Isar',
        target: 'SubjectNote',
        value: 'DELETE - Error deleting note ID $id: $e',
      );
      return Failure(Exception('Failed to delete subject note: $e'));
    }
  }
}
