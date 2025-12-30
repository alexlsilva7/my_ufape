import 'package:my_ufape/domain/entities/subject_note.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class SubjectNoteRepository {
  AsyncResult<List<SubjectNote>> getAllSubjectNotes();
  AsyncResult<SubjectNote> getSubjectNoteById(int id);
  AsyncResult<int> addSubjectNote(SubjectNote note);
  AsyncResult<bool> upsertSubjectNote(SubjectNote note);
  AsyncResult<bool> updateSubjectNote(SubjectNote note);
  AsyncResult<bool> deleteSubjectNoteById(int id);
  AsyncResult<SubjectNote> getSubjectNoteByNameAndSemester(
      String name, String semester);
}
