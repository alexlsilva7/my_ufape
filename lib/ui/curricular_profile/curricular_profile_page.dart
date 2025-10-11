import 'package:flutter/material.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/repositories/block_of_profile/block_of_profile_repository.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';
import 'package:my_ufape/domain/entities/block_of_profile.dart';
import 'package:my_ufape/domain/entities/subject.dart';
import 'package:my_ufape/ui/curricular_profile/widgets/subject_details_modal.dart';

class CurricularProfilePage extends StatefulWidget {
  const CurricularProfilePage({super.key});

  @override
  State<CurricularProfilePage> createState() => _CurricularProfilePageState();
}

class _CurricularProfilePageState extends State<CurricularProfilePage> {
  final BlockOfProfileRepository _blockRepository = injector.get();
  final SigaBackgroundService _sigaService = injector.get();
  final TextEditingController _searchController = TextEditingController();

  List<BlockOfProfile> _blocks = [];
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _filterByType = 'todos'; // todos | obrigatorio | optativo | eletivo

  @override
  void initState() {
    super.initState();
    _loadBlocks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBlocks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _blockRepository.getAllBlocks();

    result.fold(
      (blocks) async {
        for (final block in blocks) {
          await block.subjects.load();
        }

        if (blocks.isEmpty) {
          // Se não houver blocos, sincronizar automaticamente
          await _syncFromSiga();
        } else {
          if (mounted) {
            setState(() {
              _blocks = blocks;
              _isLoading = false;
            });
          }
        }
      },
      (error) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Erro ao carregar perfil curricular: $error';
            _isLoading = false;
          });
        }
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
      await _sigaService.initialize();
      final blocks = await _sigaService.navigateAndExtractProfile();
      _sigaService.goToHome();

      if (mounted) {
        setState(() {
          _blocks = blocks;
          _isSyncing = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao sincronizar perfil: ${e.toString()}';
          _isSyncing = false;
          _isLoading = false;
        });
      }
    }
  }

  List<Subject> get _allSubjects {
    return _blocks.expand((block) => block.subjects).toList();
  }

  List<Subject> get _filteredSubjects {
    var subjects = _allSubjects;

    // Filtro por tipo
    if (_filterByType != 'todos') {
      subjects = subjects.where((s) {
        switch (_filterByType) {
          case 'obrigatorio':
            return s.type == CourseType.obrigatorio;
          case 'optativo':
            return s.type == CourseType.optativo;
          case 'eletivo':
            return s.type == CourseType.eletivo;
          default:
            return true;
        }
      }).toList();
    }

    // Filtro por pesquisa
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      subjects = subjects.where((s) {
        return s.name.toLowerCase().contains(query) ||
            s.code.toLowerCase().contains(query);
      }).toList();
    }

    return subjects;
  }

  Map<String, List<Subject>> get _preparedBlocks {
    if (_searchQuery.isEmpty && _filterByType == 'todos') {
      // Modo normal: mostrar por blocos
      final map = <String, List<Subject>>{};
      for (final block in _blocks) {
        if (block.subjects.isNotEmpty) {
          map[block.name] = block.subjects.toList();
        }
      }
      return map;
    } else {
      // Modo filtrado: reorganizar por bloco
      final filtered = _filteredSubjects;
      final map = <String, List<Subject>>{};

      for (final subject in filtered) {
        final block = _blocks.firstWhere(
          (b) => b.subjects.contains(subject),
          orElse: () => _blocks.first,
        );
        if (!map.containsKey(block.name)) {
          map[block.name] = [];
        }
        map[block.name]!.add(subject);
      }

      return map;
    }
  }

  int get _totalSubjects => _allSubjects.length;

  int get _obrigatorias =>
      _allSubjects.where((s) => s.type == CourseType.obrigatorio).length;

  int get _optativas =>
      _allSubjects.where((s) => s.type == CourseType.optativo).length;

  int get _eletivas =>
      _allSubjects.where((s) => s.type == CourseType.eletivo).length;

  int _calculateTotalWorkload() {
    return _allSubjects.fold(0, (sum, s) => sum + (s.workload.total ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil Curricular')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _isSyncing
                    ? 'Sincronizando perfil do SIGA...'
                    : 'Carregando perfil...',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil Curricular')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 64, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text(_errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.error,
                    )),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
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

    if (_blocks.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil Curricular')),
        body: _buildEmptyState(),
      );
    }

    final isSearching = _searchQuery.isNotEmpty || _filterByType != 'todos';
    final preparedBlocks = _preparedBlocks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil Curricular'),
        toolbarHeight: 80,
        actions: [
          // Botão de sincronização
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar por Tipo',
            onSelected: (value) => setState(() => _filterByType = value),
            itemBuilder: (context) => [
              _buildFilterMenuItem('todos', 'Todas', Icons.school),
              _buildFilterMenuItem('obrigatorio', 'Obrigatórias', Icons.star),
              _buildFilterMenuItem(
                  'optativo', 'Optativas', Icons.check_circle_outline),
              _buildFilterMenuItem('eletivo', 'Eletivas', Icons.extension),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBlocks,
            tooltip: 'Recarregar',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                // Estatísticas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                        'Total', _totalSubjects.toString(), Icons.school),
                    _dividerLine(),
                    _buildStatItem(
                        'Obrigatórias', _obrigatorias.toString(), Icons.star),
                    _dividerLine(),
                    _buildStatItem('CH Total', '${_calculateTotalWorkload()}h',
                        Icons.access_time),
                    _dividerLine(),
                    _buildStatItem(
                        'Blocos', _blocks.length.toString(), Icons.category),
                  ],
                ),
                const SizedBox(height: 12),
                // Legenda
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    _legendDot(Colors.red, 'Obrigatórias: $_obrigatorias'),
                    _legendDot(Colors.blue, 'Optativas: $_optativas'),
                    _legendDot(Colors.green, 'Eletivas: $_eletivas'),
                  ],
                ),
                const SizedBox(height: 12),
                // Barra de pesquisa
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
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
          // Indicador de filtro ativo
          if (_filterByType != 'todos')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: _getFilterColor(_filterByType).withOpacity(0.1),
              child: Row(
                children: [
                  Icon(_getFilterIcon(_filterByType),
                      size: 16, color: _getFilterColor(_filterByType)),
                  const SizedBox(width: 8),
                  Text(
                    'Filtro ativo: ${_getFilterLabel(_filterByType)}',
                    style: TextStyle(
                      color: _getFilterColor(_filterByType),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _filterByType = 'todos'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getFilterColor(_filterByType).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Limpar',
                              style: TextStyle(
                                  color: _getFilterColor(_filterByType),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 4),
                          Icon(Icons.clear,
                              size: 14, color: _getFilterColor(_filterByType)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Lista de disciplinas
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: preparedBlocks.isEmpty
                  ? _buildEmptySearchState()
                  : isSearching
                      ? _buildSearchResults(preparedBlocks)
                      : _buildBlockList(preparedBlocks),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildFilterMenuItem(
      String value, String label, IconData icon) {
    final isSelected = _filterByType == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            isSelected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _dividerLine() {
    return Container(
      width: 1,
      height: 24,
      color: Theme.of(context).dividerColor,
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
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined,
                size: 64,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Nenhum perfil curricular cadastrado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                )),
            const SizedBox(height: 8),
            Text('Sincronize com o SIGA para carregar seu perfil curricular',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                )),
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
        ),
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text('Nenhuma disciplina encontrada',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Tente ajustar os filtros ou a pesquisa',
              style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSearchResults(Map<String, List<Subject>> blocks) {
    final allSubjects = blocks.entries.expand((entry) {
      return entry.value
          .map((subject) => {'subject': subject, 'block': entry.key});
    }).toList();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: allSubjects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = allSubjects[index];
        final subject = item['subject'] as Subject;
        final blockName = item['block'] as String;
        return _buildSubjectCard(subject, blockName);
      },
    );
  }

  Widget _buildBlockList(Map<String, List<Subject>> blocks) {
    final blockNames = blocks.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: blockNames.length,
      itemBuilder: (context, index) {
        final blockName = blockNames[index];
        final subjects = blocks[blockName]!;
        return _buildBlockCard(blockName, subjects);
      },
    );
  }

  Widget _buildBlockCard(String blockName, List<Subject> subjects) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(blockName,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Text('${subjects.length} disciplina(s)',
              style: const TextStyle(fontSize: 12)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: subjects
                    .map((subject) => _buildSubjectListTile(subject))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectListTile(Subject subject) {
    final typeColor = _getTypeColor(subject.type);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Container(
        width: 4,
        decoration: BoxDecoration(
          color: typeColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      minLeadingWidth: 0,
      title: Text(
        '${subject.code} - ${subject.name}',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        'Período: ${subject.period} | CH: ${subject.workload.total}h | Créditos: ${subject.credits}',
        style: const TextStyle(fontSize: 12),
      ),
      onTap: () => SubjectDetailsModal.show(context, subject),
    );
  }

  Widget _buildSubjectCard(Subject subject, String blockName) {
    final typeColor = _getTypeColor(subject.type);
    final typeIcon = _getTypeIcon(subject.type);

    return InkWell(
      onTap: () => SubjectDetailsModal.show(context, subject),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.withAlpha(60)
                : Colors.grey.withAlpha(30),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Código e nome
                  Text(
                    subject.code,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subject.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Tipo
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: typeColor.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(typeIcon, size: 14, color: typeColor),
                        const SizedBox(width: 6),
                        Text(
                          subject.type.toString(),
                          style: TextStyle(
                            color: typeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Informações
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('${subject.period}º',
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('${subject.workload.total}h',
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 12),
                      Icon(Icons.stars, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('${subject.credits} créditos',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    blockName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(CourseType type) {
    switch (type) {
      case CourseType.obrigatorio:
        return Colors.red;
      case CourseType.optativo:
        return Colors.blue;
      case CourseType.eletivo:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(CourseType type) {
    switch (type) {
      case CourseType.obrigatorio:
        return Icons.star;
      case CourseType.optativo:
        return Icons.check_circle_outline;
      case CourseType.eletivo:
        return Icons.extension;
      default:
        return Icons.help_outline;
    }
  }

  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'obrigatorio':
        return Colors.red.shade700;
      case 'optativo':
        return Colors.blue.shade700;
      case 'eletivo':
        return Colors.green.shade700;
      default:
        return Theme.of(context).primaryColor;
    }
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'obrigatorio':
        return Icons.star;
      case 'optativo':
        return Icons.check_circle_outline;
      case 'eletivo':
        return Icons.extension;
      default:
        return Icons.school;
    }
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'obrigatorio':
        return 'Disciplinas Obrigatórias';
      case 'optativo':
        return 'Disciplinas Optativas';
      case 'eletivo':
        return 'Disciplinas Eletivas';
      default:
        return 'Todas as Disciplinas';
    }
  }
}
