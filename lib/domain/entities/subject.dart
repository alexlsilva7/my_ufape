import 'package:isar_community/isar.dart';
import 'prerequisite.dart';
import 'workload.dart';

part 'subject.g.dart';

@collection
class Subject {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String code;

  @Index(type: IndexType.value, caseSensitive: false)
  String name;

  @Enumerated(EnumType.ordinal32)
  CourseType type = CourseType.desconhecido;

  String period;
  int credits = 0;

  Workload workload;

  List<Prerequisite> prerequisites = [];
  List<Prerequisite> corequisites = [];
  List<Prerequisite> equivalences = [];

  String ementa = '';

  Subject({
    required this.code,
    required this.name,
    required this.period,
    required this.credits,
    required this.workload,
  });

  @override
  String toString() {
    return '''
-------------------------------------------
  Disciplina: $name ($code)
  Tipo: $type
  Período: $period
  Créditos: $credits
  C.H: Teórica:${workload.teorica ?? -1} Prática:${workload.pratica ?? -1} Ext:${workload.extensao ?? -1} Total:${workload.total ?? -1}
  Pré-requisitos: ${prerequisites.map((p) => '${p.code} - ${p.name}').join(', ')}
  Co-requisitos: ${corequisites.map((p) => '${p.code} - ${p.name}').join(', ')}
  Equivalências: ${equivalences.map((p) => '${p.code} - ${p.name}').join(', ')}
  Ementa: ${ementa.isNotEmpty ? ementa.trim() : 'Não encontrada'}
-------------------------------------------''';
  }
}

enum CourseType {
  obrigatorio,
  optativo,
  eletivo,
  desconhecido;

  static CourseType fromString(String type) {
    switch (type.toUpperCase()) {
      case 'OBRIGATÓRIO':
        return CourseType.obrigatorio;
      case 'OPTATIVO':
        return CourseType.optativo;
      case 'ELETIVO':
        return CourseType.eletivo;
      default:
        return CourseType.desconhecido;
    }
  }

  @override
  String toString() {
    switch (this) {
      case CourseType.obrigatorio:
        return 'Obrigatório';
      case CourseType.optativo:
        return 'Optativo';
      case CourseType.eletivo:
        return 'Eletivo';
      case CourseType.desconhecido:
        return 'Desconhecido';
    }
  }
}
