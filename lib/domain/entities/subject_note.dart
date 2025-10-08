class SubjectNote {
  final String nome;
  final String situacao;
  final Map<String, String> notas; // Ex: {"VA1": "9.0", "Média": "9.5"}

  SubjectNote({
    required this.nome,
    required this.situacao,
    required this.notas,
  });

  factory SubjectNote.fromJson(Map<String, dynamic> json) {
    // Converte o mapa de notas para o tipo correto Map<String, String>
    final notasMap = (json['notas'] as Map)
        .map((key, value) => MapEntry(key.toString(), value.toString()));

    return SubjectNote(
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
