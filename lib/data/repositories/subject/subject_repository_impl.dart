import 'package:my_ufape/data/services/subject/subject_service.dart';
import 'package:my_ufape/domain/entities/subject.dart';
import 'package:result_dart/result_dart.dart';

import './subject_repository.dart';

class SubjectRepositoryImpl implements SubjectRepository {
  final SubjectService _subjectService;
  SubjectRepositoryImpl(this._subjectService);

  @override
  AsyncResult<int> addSubject(Subject subject) {
    return _subjectService.addSubject(subject);
  }

  @override
  AsyncResult<bool> deleteSubjectById(int id) {
    return _subjectService.deleteSubjectById(id);
  }

  @override
  AsyncResult<List<Subject>> getAllSubjects() {
    return _subjectService.getAllSubjects();
  }

  @override
  AsyncResult<Subject> getSubjectById(int id) {
    return _subjectService.getSubjectById(id);
  }

  @override
  AsyncResult<List<Subject>> getSubjectsByName(String name) {
    return _subjectService.getSubjectsByName(name);
  }

  @override
  AsyncResult<List<Subject>> getSubjectsByPeriod(String period) {
    return _subjectService.getSubjectsByPeriod(period);
  }

  @override
  AsyncResult<List<Subject>> getSubjectsByType(CourseType type) {
    return _subjectService.getSubjectsByType(type);
  }

  @override
  AsyncResult<bool> updateSubject(Subject subject) {
    return _subjectService.updateSubject(subject);
  }

  @override
  AsyncResult<bool> upsertSubject(Subject subject) async {
    try {
      Subject? existingSubject;

      await _subjectService.getSubjectsByName(subject.name).onSuccess((list) {
        for (final s in list) {
          if (s.code == subject.code ||
              (s.name == subject.name && s.period == subject.period)) {
            existingSubject = s;
            break;
          }
        }
      });

      if (existingSubject != null) {
        // verificar se há diferenças relevantes
        bool needsUpdate = false;
        if (existingSubject!.credits != subject.credits ||
            existingSubject!.period != subject.period ||
            existingSubject!.type != subject.type ||
            existingSubject!.workload.toString() !=
                subject.workload.toString() ||
            existingSubject!.ementa != subject.ementa) {
          needsUpdate = true;
        }

        if (needsUpdate) {
          // Atualiza campos necessários mantendo o mesmo id
          existingSubject!.credits = subject.credits;
          existingSubject!.period = subject.period;
          existingSubject!.type = subject.type;
          existingSubject!.workload = subject.workload;
          existingSubject!.ementa = subject.ementa;
          existingSubject!.prerequisites = subject.prerequisites;
          existingSubject!.corequisites = subject.corequisites;
          existingSubject!.equivalences = subject.equivalences;
          return _subjectService.updateSubject(existingSubject!);
        } else {
          return Success(true);
        }
      } else {
        // Insere nova disciplina
        return _subjectService.addSubject(subject).map((_) => true);
      }
    } catch (e) {
      return Failure(Exception('Failed to upsert subject: $e'));
    }
  }
}
