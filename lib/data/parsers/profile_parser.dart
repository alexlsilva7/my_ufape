import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:my_ufape/domain/entities/block_of_profile.dart';
import 'package:my_ufape/domain/entities/subject.dart';
import 'package:my_ufape/domain/entities/prerequisite.dart';
import 'package:my_ufape/domain/entities/workload.dart';

class ProfileParser {
  final Document _document;

  ProfileParser(String htmlContent) : _document = parse(htmlContent);

  List<BlockOfProfile> parseProfile() {
    final List<BlockOfProfile> blocks = [];

    final mainTable =
        _document.querySelector('#formDetalharPerfilCurricular\\:tabelas');
    if (mainTable == null) {
      return blocks;
    }

    final blockRows = mainTable.querySelectorAll('tbody > tr');
    for (final blockRow in blockRows) {
      final blockNameElement = blockRow.querySelector('span.editBold');
      if (blockNameElement == null) continue;

      final blockName = blockNameElement.text.trim();
      final block = BlockOfProfile(name: blockName);

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

        var workload = Workload();
        workload.teorica = chTeorica;
        workload.pratica = chPratica;
        workload.extensao = chExt;
        workload.total = chTotal;

        var subject = Subject(
          code: code,
          name: name,
          period: period,
          credits: credits,
          workload: workload,
        );

        subject.type = type;

        subject.workload = workload;
        subject.prerequisites = prerequisites;
        subject.corequisites = corequisites;
        subject.equivalences = equivalences;
        subject.ementa = ementa;

        block.subjectList.add(subject);
      }
      blocks.add(block);
    }
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
              var prerequisite = Prerequisite();
              prerequisite.code = code;
              prerequisite.name = name;
              results.add(prerequisite);
            }
          }
        }
        return results;
      }
    }

    return results;
  }
}
