// lib/grades_model.dart

// Representa um período letivo (ex: "2025.1")
class Periodo {
  final String nome;
  final List<Disciplina> disciplinas;

  Periodo({required this.nome, required this.disciplinas});
}

// Representa uma disciplina com suas notas e situação
class Disciplina {
  final String nome;
  final String situacao;
  final Map<String, String> notas; // Ex: {"VA1": "9.0", "Média": "9.5"}

  Disciplina({
    required this.nome,
    required this.situacao,
    required this.notas,
  });
}
