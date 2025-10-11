import 'package:my_ufape/domain/entities/time_table.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class ScheduledSubjectRepository {
  AsyncResult<List<ScheduledSubject>> getAllScheduledSubjects();
  AsyncResult<ScheduledSubject> getScheduledSubjectById(int id);
  AsyncResult<int> addScheduledSubject(ScheduledSubject subject);
  AsyncResult<bool> upsertScheduledSubject(ScheduledSubject subject);
  AsyncResult<bool> updateScheduledSubject(ScheduledSubject subject);
  AsyncResult<bool> deleteScheduledSubjectById(int id);
  AsyncResult<bool> deleteAllScheduledSubjects();
}
