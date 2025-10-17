import 'package:my_ufape/data/services/school_history/school_history_service.dart';
import 'package:my_ufape/domain/entities/school_history.dart';
import 'package:my_ufape/domain/entities/school_history_subject.dart';
import 'package:result_dart/result_dart.dart';
import 'school_history_repository.dart';

class SchoolHistoryRepositoryImpl implements SchoolHistoryRepository {
  final SchoolHistoryService _service;

  SchoolHistoryRepositoryImpl(this._service);

  @override
  AsyncResult<bool> upsertFromSiga(Map<String, dynamic> sigaData) async {
    try {
      final periodsData = sigaData['periods'] as List<dynamic>;

      final List<SchoolHistory> histories = [];
      final List<SchoolHistorySubject> allSubjects = [];

      for (var periodJson in periodsData) {
        final history = SchoolHistory.fromJson(periodJson);
        histories.add(history);

        final subjectsJson = periodJson['subjects'] as List<dynamic>? ?? [];
        for (var subjectJson in subjectsJson) {
          allSubjects
              .add(SchoolHistorySubject.fromJson(subjectJson, history.period));
        }
      }
      final result = _service.upsertSchoolHistoryData(histories, allSubjects);

      return result;
    } catch (e) {
      return Failure(Exception('Failed to parse and upsert data: $e'));
    }
  }

  @override
  AsyncResult<List<SchoolHistory>> getAllSchoolHistories() async {
    final historiesResult = await _service.getAllSchoolHistories();
    final subjectsResult = await _service.getAllSchoolHistorySubjects();

    return historiesResult.fold(
      (histories) {
        return subjectsResult.fold(
          (subjects) {
            final subjectsByPeriod = <String, List<SchoolHistorySubject>>{};
            for (final subject in subjects) {
              subjectsByPeriod
                  .putIfAbsent(subject.period, () => [])
                  .add(subject);
            }

            for (final history in histories) {
              history.subjects = subjectsByPeriod[history.period] ?? [];
            }

            return Success(histories);
          },
          (error) => Failure(error),
        );
      },
      (error) => Failure(error),
    );
  }

  @override
  AsyncResult<List<SchoolHistorySubject>> getSchoolHistoriesSubjectByStatus(
      String status) async {
    final historiesSubjectsResult =
        await _service.getSchoolHistoriesSubjectByStatus(status);
    final subjectsResult = await _service.getAllSchoolHistorySubjects();

    return historiesSubjectsResult.fold(
      (historiesSubjects) {
        return subjectsResult.fold(
          (subjects) {
            final subjectsByPeriod = <String, List<SchoolHistorySubject>>{};
            for (final subject in subjects) {
              subjectsByPeriod
                  .putIfAbsent(subject.period, () => [])
                  .add(subject);
            }

            for (final historySubject in historiesSubjects) {
              historySubject.period = historySubject.period;
            }

            return Success(historiesSubjects);
          },
          (error) => Failure(error),
        );
      },
      (error) => Failure(error),
    );
  }
}
