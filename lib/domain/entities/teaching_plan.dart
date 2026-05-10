import 'package:isar_community/isar.dart';

part 'teaching_plan.g.dart';

@collection
class TeachingPlan {
  Id id = Isar.autoIncrement;

  @Index()
  late String subjectCode; // Para linkar com a disciplina (ex: "CC5")

  late DateTime uploadedAt;

  List<ClassTopic> topics = [];
}

@embedded
class ClassTopic {
  late DateTime? date; // Pode ser nulo se o PDF não tiver datas precisas
  late String content;
  late String? type; // "teorica", "pratica", "prova"
}
