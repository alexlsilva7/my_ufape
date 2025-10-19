import 'dart:convert';
import 'package:my_ufape/core/debug/logarte.dart';
import 'package:my_ufape/data/services/academic_achievement/academic_achievement_service.dart';
import 'package:my_ufape/domain/entities/academic_achievement.dart';
import 'package:result_dart/result_dart.dart';
import 'academic_achievement_repository.dart';

class AcademicAchievementRepositoryImpl
    implements AcademicAchievementRepository {
  final AcademicAchievementService _service;

  AcademicAchievementRepositoryImpl(this._service);

  @override
  AsyncResult<AcademicAchievement> getAcademicAchievement() {
    return _service.getAcademicAchievement();
  }

  @override
  AsyncResult<Unit> upsertFromSiga(Map<String, dynamic> sigaData) async {
    final achievement = AcademicAchievement();

    // Função recursiva para converter o JSON da árvore em entidades
    WorkloadSummaryItem parseWorkloadNode(Map<String, dynamic> node) {
      final item = node;
      final workloadItem = WorkloadSummaryItem()
        ..category = item['id'] // Usando o ID como category para referência
        ..name = item['name']
        ..integration = item['integration']
        ..completedHours = (item['completed_hours'] as num?)?.toInt()
        ..completedPercentage =
            (item['completed_percentage'] as num?)?.toDouble()
        ..waivedHours = (item['waived_hours'] as num?)?.toInt()
        ..waivedPercentage = (item['waived_percentage'] as num?)?.toDouble()
        ..toCompleteHours = (item['to_complete_hours'] as num?)?.toInt()
        ..toCompletePercentage =
            (item['to_complete_percentage'] as num?)?.toDouble();

      final childrenNodes =
          (item['children'] as List).cast<Map<String, dynamic>>();
      for (var childNode in childrenNodes) {
        workloadItem.children.add(parseWorkloadNode(childNode));
      }
      return workloadItem;
    }

    // Processa a árvore de carga horária
    final workloadTreeJson =
        sigaData['workload_summary_tree'] as List; // Usa a árvore
    achievement.workloadSummary = workloadTreeJson
        .map((node) => parseWorkloadNode(node as Map<String, dynamic>))
        .toList();

    // Parse Component Summary (Permanece igual, usando a lista)
    final componentJson =
        sigaData['component_summary'] as List<dynamic>; // Agora é lista
    achievement.componentSummary = componentJson.map((value) {
      final item = value as Map<String, dynamic>;
      return ComponentSummaryItem()
        ..description = item['description']
        ..hours = (item['hours'] as num?)?.toInt()
        ..quantity = (item['quantity'] as num?)?.toInt();
    }).toList();

    // Parse Pending Components (Permanece igual)
    final pendingJson = sigaData['pending_components'] as Map<String, dynamic>;
    final subjectsList = pendingJson['subjects'] as List; // Já era lista
    achievement.pendingSubjects = subjectsList.map((item) {
      final subjectMap = item as Map<String, dynamic>; // Cast para Map
      return PendingSubject()
        ..code = subjectMap['code']
        ..name = subjectMap['name']
        ..workload = (subjectMap['workload'] as num?)?.toInt()
        ..period = (subjectMap['period'] as num?)?.toInt()
        ..credits = (subjectMap['credits'] as num?)?.toInt();
    }).toList();
    achievement.totalPendingHours =
        (pendingJson['total_pending_hours'] as num?)?.toInt();

    return _service.upsertAcademicAchievement(achievement);
  }
}

// Helper para capitalizar a primeira letra
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
