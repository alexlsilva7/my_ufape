import 'package:flutter/material.dart';
import '../../domain/entities/grades_model.dart';

class GradesPage extends StatefulWidget {
  final List<Periodo> periodos;

  const GradesPage({super.key, required this.periodos});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  static const Color _primary = Color(0xFF004D40);
  static const Color _secondary = Color(0xFF00695C);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final bool _showOnlyCurrentSemester = false;
  String _sortBy = 'recente'; // recente | antigo | disciplina
  final bool _groupByStatus = false;
  final Set<String> _expandedPeriods = {};

  List<Periodo> get _preparedPeriodos {
    List<Periodo> base = List<Periodo>.from(widget.periodos);

    if (_sortBy == 'recente') {
      base.sort((a, b) => b.nome.compareTo(a.nome));
    } else if (_sortBy == 'antigo') {
      base.sort((a, b) => a.nome.compareTo(b.nome));
    }

    if (_showOnlyCurrentSemester && base.isNotEmpty) {
      base = [base.first];
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      base = base
          .map((p) {
            final ds = p.disciplinas
                .where((d) => d.nome.toLowerCase().contains(q))
                .toList();
            return ds.isNotEmpty
                ? Periodo(nome: p.nome, disciplinas: ds)
                : null;
          })
          .where((p) => p != null)
          .cast<Periodo>()
          .toList();
    }

    if (_sortBy == 'disciplina') {
      base = base.map((p) {
        final ds = [...p.disciplinas]..sort((a, b) => a.nome.compareTo(b.nome));
        return Periodo(nome: p.nome, disciplinas: ds);
      }).toList();
    }

    return base;
  }

  double _computePeriodoAverage(Periodo periodo) {
    // Tenta extrair a "média" de cada disciplina quando disponível.
    final medias = <double>[];
    for (final d in periodo.disciplinas) {
      for (final e in d.notas.entries) {
        if (_isMediaKey(e.key)) {
          final v = double.tryParse(e.value.replaceAll(',', '.'));
          if (v != null) medias.add(v);
        }
      }
    }
    if (medias.isEmpty) return 0.0;
    return medias.reduce((a, b) => a + b) / medias.length;
  }

  double _computeOverallAverage(List<Periodo> periodos) {
    final medias = <double>[];
    for (final p in periodos) {
      final m = _computePeriodoAverage(p);
      if (m > 0) medias.add(m);
    }
    if (medias.isEmpty) return 0.0;
    return medias.reduce((a, b) => a + b) / medias.length;
  }

  Color _chipColorFor(String key, String value) {
    final lowerKey = key.toLowerCase();
    // Não tratar "faltas" ou "freq" como nota negativa
    if (lowerKey.contains('falt') || lowerKey.contains('freq')) {
      // neutro para zero, aviso suave para outros valores
      final numeric = double.tryParse(value.replaceAll(',', '.'));
      if (numeric == null) return Colors.blue.shade700;
      if (numeric == 0) return Colors.grey.shade700;
      if (numeric < 3) return Colors.orange.shade700;
      return Colors.green.shade700;
    }

    // Se for média, dar destaque azul
    if (_isMediaKey(key)) return Colors.blue.shade700;

    // Senão cair para cor por valor
    return _getGradeColor(value);
  }

  @override
  Widget build(BuildContext context) {
    final periodos = _preparedPeriodos;

    final totalDisciplinas =
        widget.periodos.expand((p) => p.disciplinas).length;
    final totalAprovadas = widget.periodos
        .expand((p) => p.disciplinas)
        .where((d) => d.situacao.toUpperCase().contains('APROVADO'))
        .length;
    final totalReprovadas = widget.periodos
        .expand((p) => p.disciplinas)
        .where((d) => d.situacao.toUpperCase().contains('REPROVADO'))
        .length;
    final totalCursando = totalDisciplinas - totalAprovadas - totalReprovadas;
    final overallMedia = _computeOverallAverage(widget.periodos);

    // Quando há busca, mostra disciplinas individualmente
    final isSearching = _searchQuery.isNotEmpty;
    final allMatchingDisciplines = isSearching
        ? periodos
            .expand((p) => p.disciplinas.map((d) => {
                  'disciplina': d,
                  'periodo': p.nome,
                }))
            .toList()
        : [];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Minhas Notas'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: 80,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _sortBy = _sortBy == 'recente' ? 'antigo' : 'recente';
              });
            },
            icon: Icon(
              _sortBy == 'recente' ? Icons.arrow_downward : Icons.arrow_upward,
              color: Colors.white,
            ),
            tooltip: _sortBy == 'recente'
                ? 'Ordenado: Mais recente primeiro'
                : 'Ordenado: Mais antigo primeiro',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(148),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primary, _secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                // Estatísticas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                        'Total', totalDisciplinas.toString(), Icons.school),
                    _dividerLine(),
                    _buildStatItem('Aprovadas', totalAprovadas.toString(),
                        Icons.check_circle),
                    _dividerLine(),
                    _buildStatItem(
                        'Períodos',
                        widget.periodos.length.toString(),
                        Icons.calendar_today),
                    _dividerLine(),
                    _buildStatItem('Média', overallMedia.toStringAsFixed(2),
                        Icons.analytics),
                  ],
                ),
                const SizedBox(height: 10),
                // Legenda rápida
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendDot(
                        Colors.green.shade600, 'Aprovadas: $totalAprovadas'),
                    const SizedBox(width: 12),
                    _legendDot(
                        Colors.orange.shade600, 'Cursando: $totalCursando'),
                    const SizedBox(width: 12),
                    _legendDot(
                        Colors.red.shade600, 'Reprovadas: $totalReprovadas'),
                  ],
                ),
                const SizedBox(height: 12),
                // Barra de pesquisa (compacta)
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Pesquisar disciplinas...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon:
                                Icon(Icons.clear, color: Colors.grey.shade500),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Lista de períodos ou disciplinas individuais
          Expanded(
            child: isSearching
                ? (allMatchingDisciplines.isEmpty
                    ? _buildEmptyState()
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: ListView.separated(
                          key: ValueKey('search_$_searchQuery'),
                          padding: const EdgeInsets.all(16),
                          itemCount: allMatchingDisciplines.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = allMatchingDisciplines[index];
                            final disciplina = item['disciplina'] as Disciplina;
                            final periodoNome = item['periodo'] as String;
                            return _buildIndividualDisciplineCard(
                                disciplina, periodoNome);
                          },
                        ),
                      ))
                : (periodos.isEmpty
                    ? _buildEmptyState()
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: ListView.separated(
                          key: ValueKey(
                              '${_searchQuery}_${_showOnlyCurrentSemester}_${_sortBy}_$_groupByStatus'),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: periodos.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final periodo = periodos[index];
                            final expanded =
                                _expandedPeriods.contains(periodo.nome);
                            return _buildPeriodoCard(periodo, expanded);
                          },
                        ),
                      )),
          ),
        ],
      ),
    );
  }

  Widget _dividerLine() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white.withOpacity(0.35),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Nenhuma disciplina encontrada',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tente ajustar os filtros ou a pesquisa.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodoCard(Periodo periodo, bool expanded) {
    final aprovadas = periodo.disciplinas
        .where((d) => d.situacao.toUpperCase().contains('APROVADO'))
        .length;
    final reprovadas = periodo.disciplinas
        .where((d) => d.situacao.toUpperCase().contains('REPROVADO'))
        .length;
    final total = periodo.disciplinas.length;
    final cursando = total - aprovadas - reprovadas;
    final periodMedia = _computePeriodoAverage(periodo);
    final aprovacaoPercent = total > 0 ? (aprovadas / total) * 100.0 : 0.0;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey(periodo.nome),
          initiallyExpanded: expanded,
          onExpansionChanged: (isOpen) {
            setState(() {
              if (isOpen) {
                _expandedPeriods.add(periodo.nome);
              } else {
                _expandedPeriods.remove(periodo.nome);
              }
            });
          },
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      periodo.nome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Média ${periodMedia.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9), fontSize: 10),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.task_alt, size: 14, color: Colors.green.shade700),
                  const SizedBox(width: 4),
                  Text('$aprovadas'),
                  const SizedBox(width: 8),
                  Icon(Icons.hourglass_bottom,
                      size: 14, color: Colors.orange.shade700),
                  const SizedBox(width: 4),
                  Text('$cursando'),
                  const SizedBox(width: 8),
                  Icon(Icons.cancel, size: 14, color: Colors.red.shade700),
                  const SizedBox(width: 4),
                  Text('$reprovadas'),
                  const SizedBox(width: 12),
                  Text(
                    '${aprovacaoPercent.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getAprovacaoColor(aprovacaoPercent),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _groupByStatus
                  ? _buildGroupedDisciplines(periodo.disciplinas)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Text('Aprovação',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade700)),
                            const Spacer(),
                            Text(
                              '${aprovacaoPercent.toStringAsFixed(0)}%',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getAprovacaoColor(aprovacaoPercent)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (aprovacaoPercent / 100.0)
                                .clamp(0.0, 1.0)
                                .toDouble(),
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getAprovacaoColor(aprovacaoPercent),
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...periodo.disciplinas.map(
                            (disciplina) => _buildDisciplineCard(disciplina)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedDisciplines(List<Disciplina> disciplinas) {
    final groups = <String, List<Disciplina>>{
      'Cursando': [],
      'Aprovado': [],
      'Reprovado': [],
    };
    for (final d in disciplinas) {
      final s = d.situacao.toUpperCase();
      if (s.contains('APROVADO')) {
        groups['Aprovado']!.add(d);
      } else if (s.contains('REPROVADO')) {
        groups['Reprovado']!.add(d);
      } else {
        groups['Cursando']!.add(d);
      }
    }

    final items = <Widget>[];
    for (final entry in groups.entries) {
      if (entry.value.isEmpty) continue;
      items.add(Row(
        children: [
          _groupPill(entry.key),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ));
      items.add(const SizedBox(height: 8));
      items.addAll(entry.value.map(_buildDisciplineCard));
      items.add(const SizedBox(height: 12));
    }
    return Column(children: items);
  }

  Widget _groupPill(String label) {
    Color c;
    IconData i;
    switch (label) {
      case 'Aprovado':
        c = Colors.green.shade700;
        i = Icons.check_circle;
        break;
      case 'Reprovado':
        c = Colors.red.shade700;
        i = Icons.cancel;
        break;
      default:
        c = Colors.orange.shade700;
        i = Icons.hourglass_bottom;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(i, size: 14, color: c),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: c,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAprovacaoColor(double percent) {
    if (percent >= 80.0) return Colors.green.shade600;
    if (percent >= 60.0) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  Widget _buildDisciplineCard(Disciplina disciplina) {
    final situacaoColor = _getSituacaoColor(disciplina.situacao);
    final situacaoIcon = _getSituacaoIcon(disciplina.situacao);

    return InkWell(
      onTap: () => _showDisciplinaDetails(disciplina),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Acento lateral
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4,
              child: Container(color: situacaoColor),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome em cima, status em baixo (compact)
                  RichText(
                    text: _highlightQuery(
                      disciplina.nome,
                      baseStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: situacaoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: situacaoColor.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(situacaoIcon, size: 14, color: situacaoColor),
                        const SizedBox(width: 6),
                        Text(
                          disciplina.situacao,
                          style: TextStyle(
                            color: situacaoColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (disciplina.notas.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    // Notas com destaque de "Média"
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: disciplina.notas.entries.map((entry) {
                        final isNumericGrade = _isNumericGrade(entry.value);
                        final gradeValue = isNumericGrade
                            ? double.tryParse(entry.value.replaceAll(',', '.'))
                            : null;
                        final isMedia = _isMediaKey(entry.key);
                        final color = _chipColorFor(entry.key, entry.value);

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: color.withOpacity(0.25)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isMedia)
                                    Icon(Icons.star, size: 14, color: color),
                                  if (isMedia) const SizedBox(width: 4),
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDisciplinaDetails(Disciplina d) async {
    final situacaoColor = _getSituacaoColor(d.situacao);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                d.nome,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getSituacaoIcon(d.situacao),
                      size: 16, color: situacaoColor),
                  const SizedBox(width: 6),
                  Text(
                    d.situacao,
                    style: TextStyle(
                      color: situacaoColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (d.notas.isNotEmpty)
                Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: d.notas.entries.map((e) {
                        final isMedia = _isMediaKey(e.key);
                        final color = _chipColorFor(e.key, e.value);
                        return Container(
                          width: (MediaQuery.of(context).size.width -
                                  16 -
                                  16 -
                                  10) /
                              2, // 2 colunas
                          constraints: const BoxConstraints(minWidth: 120),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: color.withOpacity(0.25)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.key,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                e.value,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: color,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  TextSpan _highlightQuery(String text, {TextStyle? baseStyle}) {
    final q = _searchQuery.trim();
    if (q.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }
    final lower = text.toLowerCase();
    final query = q.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    while (true) {
      final index = lower.indexOf(query, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }
      if (index > start) {
        spans.add(
            TextSpan(text: text.substring(start, index), style: baseStyle));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + q.length),
        style: baseStyle?.copyWith(
          backgroundColor: Colors.yellow.shade200,
        ),
      ));
      start = index + q.length;
    }
    return TextSpan(children: spans);
  }

  Color _getSituacaoColor(String situacao) {
    if (situacao.toUpperCase().contains('APROVADO')) {
      return Colors.green.shade700;
    } else if (situacao.toUpperCase().contains('REPROVADO')) {
      return Colors.red.shade700;
    } else {
      return Colors.orange.shade700;
    }
  }

  IconData _getSituacaoIcon(String situacao) {
    if (situacao.toUpperCase().contains('APROVADO')) {
      return Icons.check_circle;
    } else if (situacao.toUpperCase().contains('REPROVADO')) {
      return Icons.cancel;
    } else {
      return Icons.hourglass_empty;
    }
  }

  bool _isNumericGrade(String grade) {
    return double.tryParse(grade.replaceAll(',', '.')) != null;
  }

  bool _isMediaKey(String key) {
    final k = key.toLowerCase();
    return k.contains('média') || k.contains('media') || k.contains('mf');
  }

  Color _getGradeColor(String grade) {
    final numericGrade = double.tryParse(grade.replaceAll(',', '.'));
    if (numericGrade != null) {
      if (numericGrade >= 7.0) {
        return Colors.green.shade700;
      } else if (numericGrade >= 5.0) {
        return Colors.orange.shade700;
      } else {
        return Colors.red.shade700;
      }
    }
    return Colors.blue.shade700; // Para notas não numéricas
  }

  Widget _buildIndividualDisciplineCard(
      Disciplina disciplina, String periodoNome) {
    final situacaoColor = _getSituacaoColor(disciplina.situacao);
    final situacaoIcon = _getSituacaoIcon(disciplina.situacao);

    return InkWell(
      onTap: () => _showDisciplinaDetails(disciplina),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Acento lateral
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4,
              child: Container(color: situacaoColor),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Período no topo
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _primary.withOpacity(0.25)),
                    ),
                    child: Text(
                      periodoNome,
                      style: TextStyle(
                        color: _primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Nome da disciplina
                  RichText(
                    text: _highlightQuery(
                      disciplina.nome,
                      baseStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Status
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: situacaoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: situacaoColor.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(situacaoIcon, size: 14, color: situacaoColor),
                        const SizedBox(width: 6),
                        Text(
                          disciplina.situacao,
                          style: TextStyle(
                            color: situacaoColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (disciplina.notas.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    // Notas
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: disciplina.notas.entries.map((entry) {
                        final isMedia = _isMediaKey(entry.key);
                        final color = _chipColorFor(entry.key, entry.value);

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: color.withOpacity(0.25)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isMedia)
                                    Icon(Icons.star, size: 14, color: color),
                                  if (isMedia) const SizedBox(width: 4),
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
