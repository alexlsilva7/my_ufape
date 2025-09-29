// Representa um período letivo (ex: "2025.1")
class Periodo {
  final String nome;
  final List<Disciplina> disciplinas;

  Periodo({required this.nome, required this.disciplinas});

  factory Periodo.fromJson(Map<String, dynamic> json) {
    var disciplinasList = json['disciplinas'] as List;
    List<Disciplina> disciplinas =
        disciplinasList.map((i) => Disciplina.fromJson(i)).toList();
    return Periodo(
      nome: json['nome'],
      disciplinas: disciplinas,
    );
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'disciplinas': disciplinas.map((d) => d.toJson()).toList(),
      };
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

  factory Disciplina.fromJson(Map<String, dynamic> json) {
    // Converte o mapa de notas para o tipo correto Map<String, String>
    final notasMap = (json['notas'] as Map)
        .map((key, value) => MapEntry(key.toString(), value.toString()));

    return Disciplina(
      nome: json['nome'],
      situacao: json['situacao'],
      notas: notasMap,
    );
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'situacao': situacao,
        'notas': notas,
      };
}
