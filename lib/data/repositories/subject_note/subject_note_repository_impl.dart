import 'package:my_ufape/data/services/subject_note/subject_note_service.dart';
import 'package:my_ufape/domain/entities/subject_note.dart';

import 'package:result_dart/src/types.dart';

import './subject_note_repository.dart';

class SubjectNoteRepositoryImpl implements SubjectNoteRepository {
  final SubjectNoteService _subjectNoteService;
  SubjectNoteRepositoryImpl(this._subjectNoteService);

  @override
  AsyncResult<int> addSubjectNote(SubjectNote note) {
    return _subjectNoteService.addSubjectNote(note);
  }

  @override
  AsyncResult<bool> deleteSubjectNoteById(int id) {
    return _subjectNoteService.deleteSubjectNoteById(id);
  }

  @override
  AsyncResult<List<SubjectNote>> getAllSubjectNotes() {
    return _subjectNoteService.getAllSubjectNotes();
  }

  @override
  AsyncResult<SubjectNote> getSubjectNoteById(int id) {
    return _subjectNoteService.getSubjectNoteById(id);
  }

  @override
  AsyncResult<bool> updateSubjectNote(SubjectNote note) {
    return _subjectNoteService.updateSubjectNote(note);
  }
}
