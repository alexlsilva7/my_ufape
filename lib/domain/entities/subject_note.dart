import 'package:isar_community/isar.dart';

part 'subject_note.g.dart';

@collection
class SubjectNote {
  Id id = Isar.autoIncrement;

  @Index()
  String nome;

  @Index()
  String semestre;

  String situacao;

  List<String> notasKeys = [];
  List<String> notasValues = [];

  String teacher;

  SubjectNote({
    required this.nome,
    required this.semestre,
    required this.situacao,
    required this.teacher,
  });

  // Helpers para trabalhar com notas
  @ignore
  Map<String, String> get notas {
    final map = <String, String>{};
    for (int i = 0; i < notasKeys.length && i < notasValues.length; i++) {
      map[notasKeys[i]] = notasValues[i];
    }
    return map;
  }

  set notas(Map<String, String> value) {
    notasKeys = value.keys.toList();
    notasValues = value.values.toList();
  }

  void addNota(String key, String value) {
    final map = notas;
    map[key] = value;
    notas = map;
  }

  factory SubjectNote.fromJson(Map<String, dynamic> json) {
    final notasMap = (json['notas'] as Map)
        .map((key, value) => MapEntry(key.toString(), value.toString()));

    return SubjectNote(
        nome: json['nome'] ?? '',
        semestre: json['semestre'] ?? '',
        situacao: json['situacao'] ?? '',
        teacher: json['teacher'] ?? '')
      ..notas = notasMap;
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'semestre': semestre,
        'situacao': situacao,
        'notas': notas,
        'teacher': teacher,
      };
}
