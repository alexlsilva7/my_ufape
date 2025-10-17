import 'package:isar_community/isar.dart';
import 'package:my_ufape/core/database/database.dart';
import 'package:my_ufape/core/debug/logarte.dart';
import 'package:my_ufape/domain/entities/school_history.dart';
import 'package:my_ufape/domain/entities/school_history_subject.dart';
import 'package:result_dart/result_dart.dart';

class SchoolHistoryService {
  final Database _database;

  SchoolHistoryService(this._database);

  AsyncResult<bool> upsertSchoolHistoryData(
    List<SchoolHistory> histories,
    List<SchoolHistorySubject> subjects,
  ) async {
    try {
      final db = await _database.connection;
      await db.writeTxn(() async {
        final periods = histories.map((h) => h.period).toList();

        // Limpa dados antigos para os períodos que serão atualizados
        await db.schoolHistorys
            .where()
            .anyOf(periods, (q, p) => q.periodEqualTo(p))
            .deleteAll();
        await db.schoolHistorySubjects
            .where()
            .anyOf(periods, (q, p) => q.periodEqualTo(p))
            .deleteAll();

        // Insere os novos dados
        await db.schoolHistorys.putAll(histories);
        await db.schoolHistorySubjects.putAll(subjects);
      });
      logarte.database(
        source: 'Isar',
        target: 'SchoolHistory',
        value:
            'WRITE - Upserted ${histories.length} periods and ${subjects.length} subjects',
      );
      return const Success(true);
    } catch (e) {
      return Failure(Exception('Failed to upsert school history data: $e'));
    }
  }

  AsyncResult<List<SchoolHistory>> getAllSchoolHistories() async {
    try {
      final db = await _database.connection;
      final histories =
          await db.schoolHistorys.where().sortByPeriodDesc().findAll();
      return Success(histories);
    } catch (e) {
      return Failure(Exception('Failed to fetch school histories: $e'));
    }
  }

  AsyncResult<List<SchoolHistorySubject>> getAllSchoolHistorySubjects() async {
    try {
      final db = await _database.connection;
      final subjects = await db.schoolHistorySubjects.where().findAll();
      return Success(subjects);
    } catch (e) {
      return Failure(Exception('Failed to fetch school history subjects: $e'));
    }
  }

  AsyncResult<List<SchoolHistorySubject>> getSchoolHistoriesSubjectByStatus(
      String status) async {
    try {
      final db = await _database.connection;
      final subjects = await db.schoolHistorySubjects
          .where()
          .filter()
          .statusEqualTo(status)
          .sortByPeriodDesc()
          .findAll();
      return Success(subjects);
    } catch (e) {
      return Failure(
          Exception('Failed to fetch school histories by status: $e'));
    }
  }
}
