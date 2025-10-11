import 'package:my_ufape/data/services/subject_note/subject_note_service.dart';
import 'package:my_ufape/domain/entities/subject_note.dart';
import 'package:result_dart/result_dart.dart';

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

  @override
  AsyncResult<bool> upsertSubjectNote(SubjectNote note) async {
    try {
      SubjectNote? existingNote;

      await _subjectNoteService
          .getSubjectNoteByNameAndSemester(note.nome, note.semestre)
          .onSuccess((fetchedNote) {
        existingNote = fetchedNote;
      });

      if (existingNote != null) {
        //comparar informações e atualizar se necessário
        bool needsUpdate = false;
        if (existingNote!.situacao != note.situacao ||
            existingNote!.teacher != note.teacher ||
            existingNote!.notas.toString() != note.notas.toString()) {
          needsUpdate = true;
        }

        if (needsUpdate) {
          // Manter o mesmo ID para atualização
          existingNote!.situacao = note.situacao;
          existingNote!.teacher = note.teacher;
          existingNote!.notas = note.notas;
          return _subjectNoteService.updateSubjectNote(existingNote!);
        } else {
          // Nenhuma atualização necessária
          return Success(true);
        }
      } else {
        // Adicionar nova nota
        return _subjectNoteService.addSubjectNote(note).map((_) => true);
      }
    } catch (e) {
      return Failure(Exception('Failed to upsert subject note: $e'));
    }
  }
}
