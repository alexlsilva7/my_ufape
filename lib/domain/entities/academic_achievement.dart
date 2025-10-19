import 'package:isar_community/isar.dart';

part 'academic_achievement.g.dart';

@collection
class AcademicAchievement {
  Id id = Isar.autoIncrement;

  // Esta lista agora conterá apenas os itens raiz (provavelmente só o "Total")
  List<WorkloadSummaryItem> workloadSummary = [];
  List<ComponentSummaryItem> componentSummary = [];
  List<PendingSubject> pendingSubjects = [];

  int? totalPendingHours;
}

@embedded
class WorkloadSummaryItem {
  String? category; // Ex: 'a1.2', 'a1.2.1' (usado para montar a árvore)
  String? name;
  int? integration;
  int? completedHours;
  double? completedPercentage;
  int? waivedHours;
  double? waivedPercentage;
  int? toCompleteHours;
  double? toCompletePercentage;

  // --- ADICIONADO ---
  // Lista de filhos para criar a hierarquia
  List<WorkloadSummaryItem> children = [];
  // --- FIM ADIÇÃO ---
}

@embedded
class ComponentSummaryItem {
  String? category; // Ex: 'obrigatorios_cursados'
  String? description;
  int? hours;
  int? quantity;
}

@embedded
class PendingSubject {
  String? code;
  String? name;
  int? workload;
  int? period;
  int? credits;
}
