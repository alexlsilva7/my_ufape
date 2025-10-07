import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:my_ufape/domain/entities/curricular_profile.dart';

/// Analisa o HTML da página de "Perfil Curricular" do SIGA para extrair os blocos curriculares e suas disciplinas.
class ProfileParser {
  List<CurriculumBlock> parse(String htmlContent) {
    debugPrint("ProfileParser.parse: Iniciando parsing.");
    final document = html_parser.parse(htmlContent);
    final List<CurriculumBlock> blocks = [];

    // --- CORRECTION ---
    // The previous selector was failing. This one is more specific and targets
    // the exact <tbody> that holds all the curriculum block <tr> elements.
    final mainTableBody =
        document.querySelector('tbody[id*=":tabelaBlocoPerfil:tb"]');

    if (mainTableBody == null) {
      debugPrint(
          "ProfileParser.parse: ERRO - Tabela principal de blocos (tbody[id*=':tabelaBlocoPerfil:tb']) não encontrada. A estrutura do HTML pode ter mudado.");
      return [];
    }

    // Each direct 'tr' child of this tbody represents a curriculum block.
    final blockRows =
        mainTableBody.children.where((e) => e.localName == 'tr').toList();
    debugPrint(
        "ProfileParser.parse: Encontrados ${blockRows.length} elementos <tr> na tabela de blocos.");

    for (final blockRow in blockRows) {
      // Find the title element WITHIN the current block row.
      final titleElement = blockRow.querySelector('span.editBold');
      if (titleElement == null) {
        continue; // Not a block title row
      }
      final title = titleElement.text.trim();
      debugPrint("ProfileParser.parse: Processando bloco '$title'");

      // Find the table of subjects within the SAME block row.
      final subjectsTableBody =
          blockRow.querySelector('table[id*="tabelaComponentePerfil"] > tbody');
      if (subjectsTableBody == null) {
        debugPrint(
            "ProfileParser.parse: AVISO - Tabela de disciplinas não encontrada para o bloco '$title'.");
        continue;
      }

      final List<SubjectProfile> subjects = [];
      final allRows =
          subjectsTableBody.children.where((e) => e.localName == 'tr').toList();

      for (int i = 0; i < allRows.length; i++) {
        final subjectRow = allRows[i];
        final cells = subjectRow.querySelectorAll('td.rich-table-cell');

        // A valid subject row has at least 8 columns.
        if (cells.length < 8) continue;

        try {
          final nameAndCodeText =
              cells[0].text.trim().replaceAll(RegExp(r'\s+'), ' ');
          final parts = nameAndCodeText.split(' - ');
          if (parts.length < 2) continue;
          final code = parts.first.trim();
          final name = parts.skip(1).join(' - ').trim();

          final type = cells[1].text.trim();
          final semester = cells[2].text.trim();
          final workloadTheoretical = cells[3].text.trim();
          final workloadPractical = cells[4].text.trim();
          final workloadExtension = cells[5].text.trim();
          final workloadTotal = cells[6].text.trim();
          final credits = cells[7].text.trim();

          String syllabus = '';
          List<String> prerequisites = [];
          List<String> corequisites = [];
          List<String> equivalences = [];

          // The detail row is the next 'tr' element if it exists.
          if (i + 1 < allRows.length) {
            final detailRow = allRows[i + 1];
            final detailCell =
                detailRow.querySelector('td[id*=":detalhesComponente"]');

            if (detailCell != null) {
              final syllabusElement =
                  detailCell.querySelector('textarea[id*=":descricaoEmenta"]');
              syllabus = syllabusElement?.text.trim() ?? '';

              // Helper to extract prerequisites, corequisites, etc.
              List<String> extractList(String tableIdPart) {
                final element = detailCell.querySelector(
                    'table[id*=":$tableIdPart"] span.editPesquisa');
                if (element == null) return [];

                return element.innerHtml
                    .split(RegExp(r'<br\s*/?>'))
                    .map((e) => html_parser
                        .parse(e)
                        .body!
                        .text
                        .trim()
                        .replaceAll(RegExp(r'\s+-\s+'), ' - '))
                    .where((e) => e.isNotEmpty)
                    .toList();
              }

              prerequisites = extractList('preRequisitos');
              corequisites = extractList('coRequisitos');
              equivalences = extractList('equivalencias');

              // Increment i to skip the detail row in the next iteration.
              i++;
            }
          }

          subjects.add(SubjectProfile(
            code: code,
            name: name,
            type: type,
            semester: semester,
            workloadTheoretical: workloadTheoretical,
            workloadPractical: workloadPractical,
            workloadExtension: workloadExtension,
            workloadTotal: workloadTotal,
            credits: credits,
            prerequisites: prerequisites,
            corequisites: corequisites,
            equivalences: equivalences,
            syllabus: syllabus,
          ));
        } catch (e, s) {
          debugPrint(
              "ProfileParser.parse: Erro ao analisar uma linha de disciplina no bloco '$title'. $e\n$s");
        }
      }

      if (subjects.isNotEmpty) {
        blocks.add(CurriculumBlock(title: title, subjects: subjects));
      } else {
        debugPrint(
            "ProfileParser.parse: Nenhuma disciplina encontrada para o bloco '$title'.");
      }
    }

    debugPrint(
        "ProfileParser.parse: parsing concluído. Total de blocos extraídos: ${blocks.length}");

    print(blocks);
    if (blocks.isEmpty && blockRows.isNotEmpty) {
      debugPrint(
          "ProfileParser.parse: AVISO - Blocos foram encontrados, mas nenhuma disciplina foi extraída. Verifique a lógica de parsing das disciplinas.");
    }
    return blocks;
  }
}
