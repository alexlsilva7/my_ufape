import 'package:my_ufape/data/services/scheduled_subject/scheduled_subject_service.dart';
import 'package:my_ufape/domain/entities/time_table.dart';
import 'package:result_dart/result_dart.dart';

import './scheduled_subject_repository.dart';

class ScheduledSubjectRepositoryImpl implements ScheduledSubjectRepository {
  final ScheduledSubjectService _scheduledSubjectService;

  ScheduledSubjectRepositoryImpl(this._scheduledSubjectService);

  @override
  AsyncResult<int> addScheduledSubject(ScheduledSubject subject) {
    return _scheduledSubjectService.addScheduledSubject(subject);
  }

  @override
  AsyncResult<bool> deleteScheduledSubjectById(int id) {
    return _scheduledSubjectService.deleteScheduledSubjectById(id);
  }

  @override
  AsyncResult<bool> deleteAllScheduledSubjects() {
    return _scheduledSubjectService.deleteAllScheduledSubjects();
  }

  @override
  AsyncResult<List<ScheduledSubject>> getAllScheduledSubjects() {
    return _scheduledSubjectService.getAllScheduledSubjects();
  }

  @override
  AsyncResult<ScheduledSubject> getScheduledSubjectById(int id) {
    return _scheduledSubjectService.getScheduledSubjectById(id);
  }

  @override
  AsyncResult<bool> updateScheduledSubject(ScheduledSubject subject) {
    return _scheduledSubjectService.updateScheduledSubject(subject);
  }

  @override
  AsyncResult<bool> upsertScheduledSubject(ScheduledSubject subject) async {
    try {
      ScheduledSubject? existingSubject;

      await _scheduledSubjectService
          .getScheduledSubjectByCode(subject.code)
          .onSuccess((fetchedSubject) {
        existingSubject = fetchedSubject;
      });

      if (existingSubject != null) {
        // Comparar informações e atualizar se necessário
        bool needsUpdate = false;

        if (existingSubject!.name != subject.name ||
            existingSubject!.className != subject.className ||
            existingSubject!.room != subject.room ||
            existingSubject!.status != subject.status ||
            _timeSlotsDiffer(existingSubject!.timeSlots, subject.timeSlots)) {
          needsUpdate = true;
        }

        if (needsUpdate) {
          // Manter o mesmo ID para atualização
          existingSubject!.name = subject.name;
          existingSubject!.className = subject.className;
          existingSubject!.room = subject.room;
          existingSubject!.status = subject.status;
          existingSubject!.timeSlots = subject.timeSlots;
          return _scheduledSubjectService
              .updateScheduledSubject(existingSubject!);
        } else {
          // Nenhuma atualização necessária
          return Success(true);
        }
      } else {
        // Adicionar nova disciplina
        return _scheduledSubjectService
            .addScheduledSubject(subject)
            .map((_) => true);
      }
    } catch (e) {
      return Failure(Exception('Failed to upsert scheduled subject: $e'));
    }
  }

  /// Compara duas listas de TimeSlots para verificar se são diferentes
  bool _timeSlotsDiffer(List<TimeSlot> list1, List<TimeSlot> list2) {
    if (list1.length != list2.length) return true;

    for (int i = 0; i < list1.length; i++) {
      if (list1[i].day != list2[i].day ||
          list1[i].startTime != list2[i].startTime ||
          list1[i].endTime != list2[i].endTime) {
        return true;
      }
    }

    return false;
  }
}
