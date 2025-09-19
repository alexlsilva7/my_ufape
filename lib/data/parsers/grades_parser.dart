import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import '../../domain/entities/grades_model.dart';

class GradesParser {
  /// Analisa o conteúdo HTML da página de notas do SIGA para extrair os períodos e disciplinas.
  /// Esta versão é mais robusta, focando diretamente no container principal das notas.
  List<Periodo> parse(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    final List<Periodo> periodos = [];

    // 1. Encontra o container principal que agrupa todos os períodos.
    final mainContainer = document.getElementById('form-corpo');
    if (mainContainer == null) {
      debugPrint(
          "Parser Error: Não foi possível encontrar o container 'form-corpo'.");
      return []; // Retorna lista vazia se o container principal não for encontrado.
    }

    // 2. Itera sobre os filhos diretos do container principal.
    // A estrutura é uma sequência de <table> (cabeçalho do período) e <div> (conteúdo do período).
    for (final element in mainContainer.children) {
      // 3. Procuramos por um <div> cujo ID corresponde ao padrão de período (ex: "2024.2").
      if (element.localName == 'div' &&
          RegExp(r'^\d{4}\.\d$').hasMatch(element.id)) {
        final periodDiv = element;
        final periodName = periodDiv.id;
        final List<Disciplina> disciplinas = [];

        // 4. Dentro do div do período, a lógica para encontrar as disciplinas permanece a mesma.
        final subjectHeaderTables =
            periodDiv.querySelectorAll('table[id="tagrodape"]');

        for (final headerTable in subjectHeaderTables) {
          try {
            final nameElement = headerTable.querySelector('font.editPesquisa');
            if (nameElement == null) continue;
            final nome =
                nameElement.text.trim().replaceAll(RegExp(r'\s+'), ' ');

            final detailsDiv = headerTable.nextElementSibling;
            if (detailsDiv == null || detailsDiv.localName != 'div') continue;

            final statusElement =
                detailsDiv.querySelector('font.editPesquisa > u');
            final situacao = statusElement?.text.trim() ?? 'Cursando';

            final notas = <String, String>{};
            final headerCells =
                detailsDiv.querySelectorAll('td[bgcolor="#FAEBD7"]');

            if (headerCells.isNotEmpty) {
              final headerRow = headerCells.first.parent!;
              final valueRow = headerRow.nextElementSibling;

              if (valueRow != null) {
                final headers =
                    headerRow.children.map((cell) => cell.text.trim()).toList();
                final values =
                    valueRow.children.map((cell) => cell.text.trim()).toList();

                for (int i = 1; i < headers.length && i < values.length; i++) {
                  final key = headers[i];
                  final value = values[i];
                  if (key.isNotEmpty && value.isNotEmpty && value != '-') {
                    notas[key] = value;
                  }
                }
              }
            }

            final disciplina = Disciplina(
              nome: nome,
              situacao: situacao,
              notas: notas,
            );
            disciplinas.add(disciplina);
          } catch (e) {
            debugPrint(
                'Erro ao analisar uma disciplina no período $periodName: $e');
          }
        }

        if (disciplinas.isNotEmpty) {
          periodos.add(Periodo(nome: periodName, disciplinas: disciplinas));
        }
      }
    }

    // 5. Ordena os períodos do mais recente para o mais antigo.
    periodos.sort((a, b) => b.nome.compareTo(a.nome));

    return periodos;
  }
}
