import 'course_type.dart';
import 'prerequisite.dart';
import 'workload.dart';

class Course {
  final String code;
  final String name;
  final CourseType type;
  final String period;
  final int credits;
  final Workload workload;
  final List<Prerequisite> prerequisites;
  final List<Prerequisite> corequisites;
  final List<Prerequisite> equivalences;
  final String ementa;

  Course({
    required this.code,
    required this.name,
    required this.type,
    required this.period,
    required this.credits,
    required this.workload,
    required this.prerequisites,
    required this.corequisites,
    required this.equivalences,
    required this.ementa,
  });

  @override
  String toString() {
    return '''
-------------------------------------------
  Disciplina: $name ($code)
  Tipo: $type
  Período: $period
  Créditos: $credits
  C.H: Teórica:${workload.teorica} Prática:${workload.pratica} Ext:${workload.extensao} Total:${workload.total}
  Pré-requisitos: ${prerequisites.map((p) => '${p.code} - ${p.name}').join(', ')}
  Co-requisitos: ${corequisites.map((p) => '${p.code} - ${p.name}').join(', ')}
  Equivalências: ${equivalences.map((p) => '${p.code} - ${p.name}').join(', ')}
  Ementa: ${ementa.isNotEmpty ? ementa.trim() : 'Não encontrada'}
-------------------------------------------''';
  }
}
