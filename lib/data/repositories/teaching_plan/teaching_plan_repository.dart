import 'package:my_ufape/domain/entities/teaching_plan.dart';

abstract class TeachingPlanRepository {
  Future<void> savePlan(String subjectCode, Map<String, dynamic> jsonPlan);
  Future<TeachingPlan?> getBySubject(String subjectCode);
}
