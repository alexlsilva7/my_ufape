// Representa um semestre letivo (ex: "2025.1")
import 'package:my_ufape/domain/entities/subject_note.dart';

class Semester {
  final String nome;
  final List<SubjectNote> disciplinas;

  Semester({required this.nome, required this.disciplinas});

  factory Semester.fromJson(Map<String, dynamic> json) {
    var disciplinasList = json['disciplinas'] as List;
    List<SubjectNote> disciplinas =
        disciplinasList.map((i) => SubjectNote.fromJson(i)).toList();
    return Semester(
      nome: json['nome'],
      disciplinas: disciplinas,
    );
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'disciplinas': disciplinas.map((d) => d.toJson()).toList(),
      };
}
