import 'package:flutter/material.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/ui/subjects/subjects_view_model.dart';

import 'package:my_ufape/ui/subjects/subject_details/subject_details_page.dart';
import 'package:routefly/routefly.dart';

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  final SubjectsViewModel _viewModel = injector.get();
  String _searchQuery = '';
  String _filterStatus = 'Todas';
  final Map<String, bool> _expanded = {};

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel.loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disciplinas do Curso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: () => _viewModel.loadData(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          if (_viewModel.isLoading) {
            return _buildLoadingState();
          }

          if (_viewModel.errorMessage != null) {
            return _buildErrorState(context);
          }

          if (_viewModel.groupedSubjects.isEmpty) {
            return _buildEmptyState(context, isDark);
          }

          return Column(
            children: [
              _buildSearchAndFilter(context, isDark),
              Expanded(child: _buildSubjectsList(context)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Carregando disciplinas...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _viewModel.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _viewModel.loadData(),
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma disciplina encontrada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'As disciplinas do seu curso aparecerão aqui',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          TextFormField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
                _collapseAllPeriods();
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar disciplina...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                          _collapseAllPeriods();
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Todas', Icons.school),
                const SizedBox(width: 8),
                _buildFilterChip('Aprovadas', Icons.check_circle),
                const SizedBox(width: 8),
                _buildFilterChip('Cursando', Icons.hourglass_bottom),
                const SizedBox(width: 8),
                _buildFilterChip('Pendentes', Icons.radio_button_unchecked),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _filterStatus == label;
    final color = _getFilterColor(label);

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : color),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _filterStatus = selected ? label : 'Todas';
          _collapseAllPeriods();
        });
      },
      backgroundColor: color.withValues(alpha: 0.1),
      selectedColor: color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : color,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: isSelected ? color : color.withValues(alpha: 0.3),
      ),
    );
  }

  Color _getFilterColor(String status) {
    switch (status) {
      case 'Aprovadas':
        return Colors.green;
      case 'Cursando':
        return Colors.orange;
      case 'Pendentes':
        return Colors.grey;
      default:
        return Theme.of(context).primaryColor;
    }
  }

  Widget _buildSubjectsList(BuildContext context) {
    final filteredSubjects = _getFilteredSubjects();

    if (filteredSubjects.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'Nenhuma disciplina encontrada',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    final periodNames = filteredSubjects.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: periodNames.length,
      itemBuilder: (context, index) {
        final periodName = periodNames[index];
        final subjects = filteredSubjects[periodName]!;
        return _buildPeriodCard(periodName, subjects);
      },
    );
  }

  Map<String, List<EnrichedSubject>> _getFilteredSubjects() {
    final allGroups = _viewModel.groupedSubjects;
    final filtered = <String, List<EnrichedSubject>>{};

    for (final entry in allGroups.entries) {
      final matchingSubjects = entry.value.where((subject) {
        final matchesSearch = _searchQuery.isEmpty ||
            subject.subject.name.toLowerCase().contains(_searchQuery) ||
            subject.subject.code.toLowerCase().contains(_searchQuery);

        final matchesFilter = _filterStatus == 'Todas' ||
            (_filterStatus == 'Aprovadas' && subject.isApproved) ||
            (_filterStatus == 'Cursando' && subject.isTaking) ||
            (_filterStatus == 'Pendentes' &&
                !subject.isApproved &&
                !subject.isFailed &&
                !subject.isTaking);

        return matchesSearch && matchesFilter;
      }).toList();

      if (matchingSubjects.isNotEmpty) {
        filtered[entry.key] = matchingSubjects;
      }
    }

    return filtered;
  }

  void _collapseAllPeriods() {
    final groups = _viewModel.groupedSubjects;
    for (final k in groups.keys) {
      _expanded[k] = false;
    }
  }

  Widget _buildPeriodCard(String periodName, List<EnrichedSubject> subjects) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final approved = subjects.where((s) => s.isApproved).length;
    final allCompleted = approved == subjects.length;
    final showCompleted =
        allCompleted && _searchQuery.isEmpty && _filterStatus == 'Todas';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: showCompleted
              ? Colors.green.shade600
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: showCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: showCompleted
                ? Colors.green.shade600.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: ValueKey(periodName),
          initiallyExpanded: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: showCompleted
                      ? Colors.green.shade600.withValues(alpha: 0.1)
                      : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  showCompleted ? Icons.check_circle : Icons.folder_outlined,
                  color: showCompleted
                      ? Colors.green.shade600
                      : Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      periodName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (_searchQuery.isNotEmpty ||
                              _filterStatus == 'Aprovadas' ||
                              _filterStatus == 'Cursando' ||
                              _filterStatus == 'Pendentes')
                          ? '${subjects.length} disciplinas'
                          : showCompleted
                              ? 'Período concluído!'
                              : '$approved/${subjects.length} concluída(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: showCompleted
                            ? Colors.green.shade600
                            : Colors.grey.shade600,
                        fontWeight:
                            showCompleted ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: showCompleted
                      ? Colors.green.shade600.withValues(alpha: 0.1)
                      : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${subjects.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: showCompleted
                        ? Colors.green.shade600
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildSubjectListTile(EnrichedSubject enrichedSubject) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    IconData statusIcon;
    Color statusColor;

    if (enrichedSubject.isApproved) {
      statusIcon = Icons.check_circle;
      statusColor = Colors.green.shade600;
    } else if (enrichedSubject.isFailed) {
      statusIcon = Icons.cancel;
      statusColor = Colors.red.shade600;
    } else if (enrichedSubject.isTaking) {
      statusIcon = Icons.hourglass_bottom;
      statusColor = Colors.orange.shade600;
    } else {
      statusIcon = Icons.radio_button_unchecked;
      statusColor = Colors.grey.shade500;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade900.withValues(alpha: 0.3)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        title: Text(
          enrichedSubject.subject.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildInfoBadge(
                enrichedSubject.subject.code,
                Icons.tag,
                isDark,
              ),
              _buildInfoBadge(
                '${enrichedSubject.subject.workload.total}h',
                Icons.access_time,
                isDark,
              ),
              _buildInfoBadge(
                '${enrichedSubject.subject.credits} CR',
                Icons.stars,
                isDark,
              ),
            ],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          Routefly.push(routePaths.subjects.subjectDetails,
              arguments: enrichedSubject);
        },
      ),
    );
  }

  Widget _buildInfoBadge(String text, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
