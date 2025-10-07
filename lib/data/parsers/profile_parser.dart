import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:my_ufape/domain/entities/block.dart';
import 'package:my_ufape/domain/entities/course.dart';
import 'package:my_ufape/domain/entities/course_type.dart';
import 'package:my_ufape/domain/entities/prerequisite.dart';
import 'package:my_ufape/domain/entities/workload.dart';

class ProfileParser {
  final Document _document;

  ProfileParser(String htmlContent) : _document = parse(htmlContent);

  List<Block> parseProfile() {
    print('ProfileParser.parse: Iniciando parsing.');
    final List<Block> blocks = [];

    final mainTable =
        _document.querySelector('#formDetalharPerfilCurricular\\:tabelas');
    if (mainTable == null) {
      print('ProfileParser.parse: Tabela principal não encontrada.');
      return blocks;
    }

    final blockRows = mainTable.querySelectorAll('tbody > tr');
    print(
        'ProfileParser.parse: Encontrados ${blockRows.length} elementos <tr> na tabela de blocos.');

    for (final blockRow in blockRows) {
      final blockNameElement = blockRow.querySelector('span.editBold');
      if (blockNameElement == null) continue;

      final blockName = blockNameElement.text.trim();
      print("ProfileParser.parse: Processando bloco '$blockName'");
      final block = Block(name: blockName);

      final courseTable =
          blockRow.querySelector('table[id*=":tabelaComponentePerfil"]');
      if (courseTable == null) continue;

      final allRows = courseTable.querySelectorAll('tbody > tr');

      for (var courseRow in allRows) {
        if (courseRow.children.length != 8) {
          continue;
        }

        final cells = courseRow.children;
        final courseNameRaw =
            cells[0].querySelector('span.edit')?.text.trim() ?? '';
        if (!courseNameRaw.contains(' - ')) continue;

        final nameParts = courseNameRaw.split(' - ');
        final code = nameParts[0].trim();
        final name = nameParts.sublist(1).join(' - ').trim();

        final type = CourseType.fromString(cells[1].text.trim());
        final period = cells[2].text.trim();
        final chTeorica = int.tryParse(cells[3].text.trim()) ?? 0;
        final chPratica = int.tryParse(cells[4].text.trim()) ?? 0;
        final chExt = int.tryParse(cells[5].text.trim()) ?? 0;
        final chTotal = int.tryParse(cells[6].text.trim()) ?? 0;
        final credits = (double.tryParse(cells[7].text.trim()) ?? 0.0).toInt();

        List<Prerequisite> prerequisites = [];
        List<Prerequisite> corequisites = [];
        List<Prerequisite> equivalences = [];
        String ementa = '';

        final detailButton = courseRow
            .querySelector('input.botao[id*="btDetalhar_detalhesComponente"]');
        if (detailButton != null) {
          final buttonId = detailButton.attributes['id']!;
          final detailCellId = buttonId.replaceFirst(
              'btDetalhar_detalhesComponente', 'detalhesComponente');

          final detailCell = courseTable.querySelector('[id="$detailCellId"]');

          if (detailCell != null) {
            prerequisites = _extractDetail(detailCell, 'preRequisitos');
            corequisites = _extractDetail(detailCell, 'coRequisitos');
            equivalences = _extractDetail(detailCell, 'equivalencias');

            final ementaTextarea =
                detailCell.querySelector('textarea[id*=":descricaoEmenta"]');
            ementa = ementaTextarea?.text ?? 'Não encontrada';
          }
        }

        block.courses.add(Course(
          code: code,
          name: name,
          type: type,
          period: period,
          credits: credits,
          workload: Workload(
            teorica: chTeorica,
            pratica: chPratica,
            extensao: chExt,
            total: chTotal,
          ),
          prerequisites: prerequisites,
          corequisites: corequisites,
          equivalences: equivalences,
          ementa: ementa,
        ));
      }
      blocks.add(block);
    }
    print(
        'ProfileParser.parse: parsing concluído. Total de blocos extraídos: ${blocks.length}');
    return blocks;
  }

  List<Prerequisite> _extractDetail(Element detailCell, String idSuffix) {
    final List<Prerequisite> results = [];
    Element? targetRow;
    final allRows = detailCell.querySelectorAll('table > tbody > tr');
    String label = '';
    switch (idSuffix) {
      case 'preRequisitos':
        label = 'Pré-Requisitos:';
        break;
      case 'coRequisitos':
        label = 'Co-Requisitos:';
        break;
      case 'equivalencias':
        label = 'Equivalências:';
        break;
    }

    for (final row in allRows) {
      final labelSpan = row.querySelector('span.edit');
      if (labelSpan != null && labelSpan.text.trim() == label) {
        targetRow = row;
        break;
      }
    }

    if (targetRow == null) return results;

    final detailTable =
        targetRow.nextElementSibling?.querySelector('table[id\$=":$idSuffix"]');
    if (detailTable != null) {
      final textSpan = detailTable.querySelector('span.editPesquisa');
      if (textSpan != null && textSpan.text.trim().isNotEmpty) {
        final content =
            textSpan.innerHtml.replaceAll(RegExp(r'\s+'), ' ').trim();
        final items = content.split(RegExp(r'<br\s*/?>'));

        for (final item in items) {
          if (item.contains(' - ')) {
            final parts = item.split(' - ');
            final code = parts[0].trim();
            final name = parts.sublist(1).join(' - ').trim();
            if (code.isNotEmpty && name.isNotEmpty) {
              results.add(Prerequisite(code: code, name: name));
            }
          }
        }
        return results;
      }
    }

    return results; // Retorna lista vazia se não encontrar nada
  }
}
