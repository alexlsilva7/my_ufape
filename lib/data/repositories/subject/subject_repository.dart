import 'package:my_ufape/domain/entities/subject.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class SubjectRepository {
  AsyncResult<List<Subject>> getAllSubjects();
  AsyncResult<Subject> getSubjectById(int id);
  AsyncResult<List<Subject>> getSubjectsByName(String name);
  AsyncResult<List<Subject>> getSubjectsByPeriod(String period);
  AsyncResult<List<Subject>> getSubjectsByType(CourseType type);
  AsyncResult<int> addSubject(Subject subject);
  AsyncResult<bool> updateSubject(Subject subject);
  AsyncResult<bool> deleteSubjectById(int id);

  /// Insere ou atualiza a disciplina. Retorna true se operação bem-sucedida.
  AsyncResult<bool> upsertSubject(Subject subject);
}
