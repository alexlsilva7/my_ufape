import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:my_ufape/domain/entities/curricular_profile.dart';

/// Analisa o HTML da página de "Perfil Curricular" do SIGA para extrair os blocos curriculares e suas disciplinas.
class ProfileParser {
  List<CurriculumBlock> parse(String htmlContent) {
    debugPrint("ProfileParser.parse: Iniciando parsing.");
    final document = html_parser.parse(htmlContent);
    final List<CurriculumBlock> blocks = [];

    // 1. Find the main table body that contains all the curriculum blocks.
    final mainTableBody =
        document.querySelector('table[id*="tabelaBlocoPerfil"] > tbody');
    if (mainTableBody == null) {
      debugPrint(
          "ProfileParser.parse: ERRO - Tabela principal de blocos 'tabelaBlocoPerfil' não encontrada.");
      return [];
    }

    // 2. Each direct 'tr' child of this tbody represents a block.
    final blockRows =
        mainTableBody.children.where((e) => e.localName == 'tr').toList();
    debugPrint(
        "ProfileParser.parse: Encontrados ${blockRows.length} blocos curriculares.");

    for (final blockRow in blockRows) {
      // 3. Find the title element within the block row.
      final titleElement = blockRow.querySelector('span.editBold');
      if (titleElement == null) {
        debugPrint(
            "ProfileParser.parse: AVISO - Título do bloco não encontrado em uma das linhas.");
        continue;
      }
      final title = titleElement.text.trim();
      debugPrint("ProfileParser.parse: Processando bloco '$title'");

      // 4. Find the table of subjects within the same block row.
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

          // The detail row is the next 'tr' element if it exists and contains the detail cell.
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

                // Using innerHtml and splitting by <br> is more reliable.
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

              // Since we processed the detail row, skip it in the next iteration.
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
      }
    }

    debugPrint(
        "ProfileParser.parse: parsing concluído. Total de blocos extraídos: ${blocks.length}");
    return blocks;
  }
}
