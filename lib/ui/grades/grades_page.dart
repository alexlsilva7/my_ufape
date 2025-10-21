import 'package:flutter/material.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/repositories/subject_note/subject_note_repository.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';
import 'package:my_ufape/domain/entities/subject_note.dart';
import 'package:routefly/routefly.dart';

class GradesPage extends StatefulWidget {
  const GradesPage({super.key});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  final SubjectNoteRepository subjectNoteRepository = injector.get();
  final SigaBackgroundService _sigaService =
      injector.get<SigaBackgroundService>(key: 'siga_background');

  List<SubjectNote> allDisciplinas = [];
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'recente'; // recente | antigo | disciplina
  final bool _groupByStatus = false;
  final Set<String> _expandedPeriods = {};
  String _filterBySituacao = 'todos'; // todos | aprovado | cursando | reprovado

  @override
  void initState() {
    super.initState();
    _loadDisciplinas();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadDisciplinas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await subjectNoteRepository.getAllSubjectNotes();

    result.fold(
      (disciplinas) async {
        if (disciplinas.isEmpty) {
          // Se não houver notas, sincronizar automaticamente
          await _syncFromSiga();
        } else {
          setState(() {
            allDisciplinas = disciplinas;
            _isLoading = false;
          });
        }
      },
      (error) {
        setState(() {
          _errorMessage = 'Erro ao carregar dados: $error';
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _syncFromSiga() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final grades = await _sigaService.navigateAndExtractGrades();

      if (mounted) {
        setState(() {
          allDisciplinas = grades;
          _isSyncing = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao sincronizar notas: ${e.toString()}';
          _isSyncing = false;
          _isLoading = false;
        });
      }
    }
  }

  // Verifica se um período é o atual (tem disciplinas cursando)
  bool _isCurrentPeriod(String semestre, List<SubjectNote> disciplinas) {
    return disciplinas.any((d) {
      final situacao = d.situacao.toUpperCase();
      return !situacao.contains('APROVADO') && !situacao.contains('REPROVADO');
    });
  }

  // Agrupa disciplinas por semestre
  Map<String, List<SubjectNote>> get _groupedBySemester {
    final Map<String, List<SubjectNote>> grouped = {};
    for (final disciplina in allDisciplinas) {
      final semestre = disciplina.semestre;
      if (!grouped.containsKey(semestre)) {
        grouped[semestre] = [];
      }
      grouped[semestre]!.add(disciplina);
    }
    return grouped;
  }

  Map<String, List<SubjectNote>> get _preparedPeriodos {
    var base = Map<String, List<SubjectNote>>.from(_groupedBySemester);

    // Aplicar filtro por situação
    if (_filterBySituacao != 'todos') {
      base = base.map((semestre, disciplinas) {
        final disciplinasFiltradas = disciplinas.where((d) {
          final situacao = d.situacao.toUpperCase();
          switch (_filterBySituacao) {
            case 'aprovado':
              return situacao.contains('APROVADO');
            case 'cursando':
              return !situacao.contains('APROVADO') &&
                  !situacao.contains('REPROVADO');
            case 'reprovado':
              return situacao.contains('REPROVADO');
            default:
              return true;
          }
        }).toList();
        return MapEntry(semestre, disciplinasFiltradas);
      });
      // Remover semestres vazios
      base.removeWhere((key, value) => value.isEmpty);
    }

    // Aplicar busca
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      base = base.map((semestre, disciplinas) {
        final disciplinasFiltradas =
            disciplinas.where((d) => d.nome.toLowerCase().contains(q)).toList();
        return MapEntry(semestre, disciplinasFiltradas);
      });
      // Remover semestres vazios
      base.removeWhere((key, value) => value.isEmpty);
    }

    // Ordenar disciplinas dentro de cada semestre se necessário
    if (_sortBy == 'disciplina') {
      base = base.map((semestre, disciplinas) {
        final sorted = [...disciplinas]
          ..sort((a, b) => a.nome.compareTo(b.nome));
        return MapEntry(semestre, sorted);
      });
    }

    return base;
  }

  List<String> get _sortedSemesters {
    final semesters = _preparedPeriodos.keys.toList();
    if (_sortBy == 'recente') {
      semesters.sort((a, b) => b.compareTo(a));
    } else if (_sortBy == 'antigo') {
      semesters.sort((a, b) => a.compareTo(b));
    }

    return semesters;
  }

  double _computeSemesterAverage(List<SubjectNote> disciplinas) {
    final medias = <double>[];
    for (final d in disciplinas) {
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

  double _computeOverallAverage() {
    final allMedias = <double>[];
    for (final disciplinas in _preparedPeriodos.values) {
      for (final d in disciplinas) {
        final situacao = d.situacao.toUpperCase();
        if (!situacao.contains('APROVADO') && !situacao.contains('REPROVADO')) {
          continue;
        }
        for (final e in d.notas.entries) {
          if (_isMediaKey(e.key)) {
            final v = double.tryParse(e.value.replaceAll(',', '.'));
            if (v != null) allMedias.add(v);
          }
        }
      }
    }
    if (allMedias.isEmpty) return 0.0;
    return allMedias.reduce((a, b) => a + b) / allMedias.length;
  }

  Color _chipColorFor(String key, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lowerKey = key.toLowerCase();

    // Não tratar "faltas" ou "freq" como nota negativa
    if (lowerKey.contains('falt') || lowerKey.contains('freq')) {
      final numeric = double.tryParse(value.replaceAll(',', '.'));
      if (numeric == null) {
        return isDark ? const Color(0xFF00B4D8) : Colors.blue.shade700;
      }
      if (numeric == 0) {
        return isDark ? Colors.grey.shade500 : Colors.grey.shade700;
      }
      if (numeric < 3) return Colors.orange.shade600;
      return Colors.green.shade600;
    }

    // Se for média, dar destaque roxo/azul do tema
    if (_isMediaKey(key)) {
      return isDark ? const Color(0xFF8A2BE2) : const Color(0xFF8A2BE2);
    }

    // Senão cair para cor por valor
    return _getGradeColor(value);
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading enquanto carrega
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Minhas Notas'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _isSyncing
                    ? 'Sincronizando notas do SIGA...'
                    : 'Carregando notas...',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // Mostrar erro se houver
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Minhas Notas'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 64, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _loadDisciplinas,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar Novamente'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _syncFromSiga,
                      icon: const Icon(Icons.sync),
                      label: const Text('Sincronizar do SIGA'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    final periodos = _preparedPeriodos;
    final sortedSemesters = _sortedSemesters;

    final totalDisciplinas = allDisciplinas.length;
    final totalAprovadas = allDisciplinas
        .where((d) => d.situacao.toUpperCase().contains('APROVADO'))
        .length;
    final totalReprovadas = allDisciplinas
        .where((d) => d.situacao.toUpperCase().contains('REPROVADO'))
        .length;
    final totalCursando = totalDisciplinas - totalAprovadas - totalReprovadas;
    final overallMedia = _computeOverallAverage();

    // Quando há busca, mostra disciplinas individualmente
    final isSearching = _searchQuery.isNotEmpty;
    final allMatchingDisciplines = isSearching
        ? periodos.entries
            .expand((entry) => entry.value.map((d) => {
                  'disciplina': d,
                  'periodo': entry.key,
                }))
            .toList()
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Notas'),
        toolbarHeight: 80,
        actions: [
          IconButton(
            onPressed: _isSyncing ? null : _syncFromSiga,
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            tooltip: 'Sincronizar com SIGA',
          ),
          // Botão de Gráficos
          IconButton(
            onPressed: () {
              // Converter para o formato esperado pela página de gráficos
              final periodosForChart = periodos.entries.map((entry) {
                return {
                  'nome': entry.key,
                  'disciplinas': entry.value,
                };
              }).toList();

              Routefly.push(routePaths.charts, arguments: {
                'periodos': periodosForChart,
              });
            },
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Ver Gráficos de Desempenho',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(148),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: Column(
              children: [
                // Estatísticas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                        'Total', totalDisciplinas.toString(), Icons.school),
                    _dividerLine(context),
                    _buildStatItem('Aprovadas', totalAprovadas.toString(),
                        Icons.check_circle),
                    _dividerLine(context),
                    _buildStatItem(
                        'Períodos',
                        sortedSemesters.length.toString(),
                        Icons.calendar_today),
                    _dividerLine(context),
                    _buildStatItem('Média', overallMedia.toStringAsFixed(2),
                        Icons.analytics),
                  ],
                ),
                const SizedBox(height: 10),
                // Legenda rápida
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    _legendDot(
                        Colors.green.shade600, 'Aprovadas: $totalAprovadas'),
                    if (totalCursando > 0)
                      _legendDot(
                          Colors.orange.shade600, 'Cursando: $totalCursando'),
                    _legendDot(
                        Colors.red.shade600, 'Reprovadas: $totalReprovadas'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Barra de pesquisa (compacta)
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Pesquisar disciplinas...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          filled: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    // Botão de Filtro por Situação
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.filter_list),
                      tooltip: 'Filtrar por Situação',
                      onSelected: (value) {
                        setState(() {
                          _filterBySituacao = value;
                        });
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'todos',
                          child: Row(
                            children: [
                              Icon(
                                _filterBySituacao == 'todos'
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: _filterBySituacao == 'todos'
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text('Todas'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'aprovado',
                          child: Row(
                            children: [
                              Icon(
                                _filterBySituacao == 'aprovado'
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: _filterBySituacao == 'aprovado'
                                    ? Colors.green.shade700
                                    : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text('Aprovadas',
                                  style:
                                      TextStyle(color: Colors.green.shade700)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'cursando',
                          child: Row(
                            children: [
                              Icon(
                                _filterBySituacao == 'cursando'
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: _filterBySituacao == 'cursando'
                                    ? Colors.orange.shade700
                                    : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text('Cursando',
                                  style:
                                      TextStyle(color: Colors.orange.shade700)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'reprovado',
                          child: Row(
                            children: [
                              Icon(
                                _filterBySituacao == 'reprovado'
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: _filterBySituacao == 'reprovado'
                                    ? Colors.red.shade700
                                    : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text('Reprovadas',
                                  style: TextStyle(color: Colors.red.shade700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _sortBy = _sortBy == 'recente' ? 'antigo' : 'recente';
                        });
                      },
                      icon: Icon(
                        _sortBy == 'recente'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                      ),
                      tooltip: _sortBy == 'recente'
                          ? 'Ordenado: Mais recente primeiro'
                          : 'Ordenado: Mais antigo primeiro',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        child: Column(
          children: [
            // Indicador de filtro ativo
            if (_filterBySituacao != 'todos')
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color:
                    _getFilterColor(_filterBySituacao).withValues(alpha: 0.1),
                child: Row(
                  children: [
                    Icon(
                      _getFilterIcon(_filterBySituacao),
                      size: 16,
                      color: _getFilterColor(_filterBySituacao),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filtro ativo: ${_getFilterLabel(_filterBySituacao)}',
                      style: TextStyle(
                        color: _getFilterColor(_filterBySituacao),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _filterBySituacao = 'todos'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getFilterColor(_filterBySituacao)
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Limpar',
                              style: TextStyle(
                                color: _getFilterColor(_filterBySituacao),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.clear,
                              size: 14,
                              color: _getFilterColor(_filterBySituacao),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                              final disciplina =
                                  item['disciplina'] as SubjectNote;
                              final periodoNome = item['periodo'] as String;
                              return _buildIndividualDisciplineCard(
                                  disciplina, periodoNome);
                            },
                          ),
                        ))
                  : (sortedSemesters.isEmpty
                      ? _buildEmptyState()
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: ListView.separated(
                            key: ValueKey(
                                '${_searchQuery}_${_sortBy}_${_groupByStatus}_$_filterBySituacao'),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: sortedSemesters.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final semestre = sortedSemesters[index];
                              final disciplinas = periodos[semestre]!;
                              final expanded =
                                  _expandedPeriods.contains(semestre);
                              return _buildPeriodoCard(
                                  semestre, disciplinas, expanded);
                            },
                          ),
                        )),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'aprovado':
        return Colors.green.shade700;
      case 'cursando':
        return Colors.orange.shade700;
      case 'reprovado':
        return Colors.red.shade700;
      default:
        return Theme.of(context).primaryColor;
    }
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'aprovado':
        return Icons.check_circle;
      case 'cursando':
        return Icons.hourglass_empty;
      case 'reprovado':
        return Icons.cancel;
      default:
        return Icons.filter_list;
    }
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'aprovado':
        return 'Disciplinas Aprovadas';
      case 'cursando':
        return 'Disciplinas Cursando';
      case 'reprovado':
        return 'Disciplinas Reprovadas';
      default:
        return 'Todas as Disciplinas';
    }
  }

  Widget _dividerLine(BuildContext ctx) {
    return Container(
      width: 1,
      height: 24,
      color: Theme.of(ctx).dividerColor,
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
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasFilter = _filterBySituacao != 'todos' || _searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilter ? Icons.search_off : Icons.school_outlined,
              size: 64,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              hasFilter
                  ? 'Nenhuma disciplina encontrada'
                  : 'Nenhuma nota cadastrada',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilter
                  ? 'Tente ajustar os filtros ou a pesquisa.'
                  : 'Sincronize com o SIGA para carregar suas notas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
            if (!hasFilter) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _syncFromSiga,
                icon: const Icon(Icons.sync),
                label: const Text('Sincronizar do SIGA'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodoCard(
      String semestre, List<SubjectNote> disciplinas, bool expanded) {
    final aprovadas = disciplinas
        .where((d) => d.situacao.toUpperCase().contains('APROVADO'))
        .length;
    final reprovadas = disciplinas
        .where((d) => d.situacao.toUpperCase().contains('REPROVADO'))
        .length;
    final total = disciplinas.length;
    final cursando = total - aprovadas - reprovadas;
    final periodMedia = _computeSemesterAverage(disciplinas);
    final aprovacaoPercent = total > 0 ? (aprovadas / total) * 100.0 : 0.0;
    final isCurrentPeriod = _isCurrentPeriod(semestre, disciplinas);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey(semestre),
          initiallyExpanded: expanded,
          onExpansionChanged: (isOpen) {
            setState(() {
              if (isOpen) {
                _expandedPeriods.add(semestre);
              } else {
                _expandedPeriods.remove(semestre);
              }
            });
          },
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Theme.of(context).colorScheme.primary.withValues(
                            alpha: 0,
                          )
                      : Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      semestre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Média ${periodMedia.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Mostrar badge "PERÍODO ATUAL" ou contagens
              if (isCurrentPeriod)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.orange.shade800
                        : Colors.orange.shade600,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.shade600.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'PERÍODO ATUAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Icon(Icons.task_alt,
                        size: 14, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Text('$aprovadas'),
                    const SizedBox(width: 8),
                    if (cursando > 0)
                      Icon(Icons.hourglass_bottom,
                          size: 14, color: Colors.orange.shade700),
                    if (cursando > 0) const SizedBox(width: 4),
                    if (cursando > 0) Text('$cursando'),
                    const SizedBox(width: 8),
                    Icon(Icons.cancel, size: 14, color: Colors.red.shade700),
                    const SizedBox(width: 4),
                    Text('$reprovadas'),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 35,
                      child: Center(
                        child: Text(
                          '${aprovacaoPercent.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getAprovacaoColor(aprovacaoPercent),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _groupByStatus
                  ? _buildGroupedDisciplines(disciplinas)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Text('Aprovação', style: TextStyle(fontSize: 12)),
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
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getAprovacaoColor(aprovacaoPercent),
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...disciplinas.map(
                            (disciplina) => _buildDisciplineCard(disciplina)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedDisciplines(List<SubjectNote> disciplinas) {
    final groups = <String, List<SubjectNote>>{
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
          Expanded(
            child: Divider(
              color: Theme.of(context).dividerColor,
            ),
          ),
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
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.35)),
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

  Widget _buildDisciplineCard(SubjectNote disciplina) {
    final situacaoColor = _getSituacaoColor(disciplina.situacao);
    final situacaoIcon = _getSituacaoIcon(disciplina.situacao);

    return InkWell(
      onTap: () => _showDisciplinaDetails(disciplina),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.withAlpha(60)
                : Colors.grey.withAlpha(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.2
                      : 0.04),
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
              child: Container(
                decoration: BoxDecoration(
                  color: situacaoColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
              ),
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
                      baseStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (disciplina.teacher.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            disciplina.teacher,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: situacaoColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: situacaoColor.withValues(alpha: 0.25)),
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
                        final isMedia = _isMediaKey(entry.key);
                        final color = _chipColorFor(entry.key, entry.value);

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: color.withValues(alpha: 0.25)),
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
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withValues(alpha: 0.8),
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

  Future<void> _showDisciplinaDetails(SubjectNote d) async {
    final situacaoColor = _getSituacaoColor(d.situacao);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 1,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 16),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
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
              if (d.teacher.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        d.teacher,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: d.notas.entries.map((e) {
                      final color = _chipColorFor(e.key, e.value);
                      return Container(
                        constraints: const BoxConstraints(minWidth: 120),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: color.withValues(alpha: 0.25)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              e.key,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withValues(alpha: 0.8),
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
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFFAA77FF).withValues(alpha: 0.3)
              : Colors.yellow.shade200,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
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
      SubjectNote disciplina, String periodoNome) {
    final situacaoColor = _getSituacaoColor(disciplina.situacao);
    final situacaoIcon = _getSituacaoIcon(disciplina.situacao);

    return InkWell(
      onTap: () => _showDisciplinaDetails(disciplina),
      borderRadius: BorderRadius.circular(0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          color: Theme.of(context).cardTheme.color,
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.withAlpha(60)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.2
                      : 0.04),
              blurRadius: 2,
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
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      periodoNome,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
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
                      baseStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (disciplina.teacher.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            disciplina.teacher,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),

                  // Status
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: situacaoColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: situacaoColor.withValues(alpha: 0.25)),
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
                            color: color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: color.withValues(alpha: 0.25)),
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
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withValues(alpha: 0.8),
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
