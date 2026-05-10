import 'package:isar_community/isar.dart';
import 'package:my_ufape/core/database/database.dart';
import 'package:my_ufape/data/repositories/teaching_plan/teaching_plan_repository.dart';
import 'package:my_ufape/domain/entities/teaching_plan.dart';

class TeachingPlanRepositoryImpl implements TeachingPlanRepository {
  final Database _database;

  TeachingPlanRepositoryImpl(this._database);

  Future<Isar> get _isar => _database.connection;

  @override
  Future<void> savePlan(
      String subjectCode, Map<String, dynamic> jsonPlan) async {
    final topicsList = jsonPlan['topics'] as List;

    final topics = topicsList.map((t) {
      final topic = ClassTopic()
        ..content = t['content']
        ..type = t['type'];

      if (t['date'] != null) {
        topic.date = DateTime.tryParse(t['date']);
      }

      return topic;
    }).toList();

    final plan = TeachingPlan()
      ..subjectCode = subjectCode
      ..uploadedAt = DateTime.now()
      ..topics = topics;

    final isar = await _isar;
    await isar.writeTxn(() async {
      // Remove anterior se existir
      await isar.teachingPlans
          .filter()
          .subjectCodeEqualTo(subjectCode)
          .deleteAll();
      await isar.teachingPlans.put(plan);
    });
  }

  @override
  Future<TeachingPlan?> getBySubject(String subjectCode) async {
    final isar = await _isar;
    return await isar.teachingPlans
        .filter()
        .subjectCodeEqualTo(subjectCode)
        .findFirst();
  }
}
