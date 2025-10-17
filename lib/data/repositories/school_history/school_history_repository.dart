import 'package:my_ufape/domain/entities/school_history.dart';
import 'package:my_ufape/domain/entities/school_history_subject.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class SchoolHistoryRepository {
  AsyncResult<bool> upsertFromSiga(Map<String, dynamic> sigaData);
  AsyncResult<List<SchoolHistory>> getAllSchoolHistories();
  AsyncResult<List<SchoolHistorySubject>> getSchoolHistoriesSubjectByStatus(
      String status);
}
