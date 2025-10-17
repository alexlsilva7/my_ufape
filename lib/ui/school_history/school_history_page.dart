import 'package:flutter/material.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/domain/entities/school_history.dart';
import 'package:my_ufape/ui/school_history/school_history_view_model.dart';

class SchoolHistoryPage extends StatefulWidget {
  const SchoolHistoryPage({super.key});

  @override
  State<SchoolHistoryPage> createState() => _SchoolHistoryPageState();
}

class _SchoolHistoryPageState extends State<SchoolHistoryPage> {
  final SchoolHistoryViewModel _viewModel = injector.get();

  @override
  void initState() {
    super.initState();
    _viewModel.loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico Escolar'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) => IconButton(
              icon: _viewModel.isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.sync),
              onPressed: _viewModel.isSyncing ? null : _viewModel.syncFromSiga,
              tooltip: 'Sincronizar com o SIGA',
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return _buildLoadingState(context);
          }

          if (_viewModel.errorMessage != null) {
            return _buildErrorState(context, isDark);
          }

          if (_viewModel.history.isEmpty) {
            return _buildEmptyState(context, isDark);
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final periodHistory = _viewModel.history[index];
                      return _buildPeriodCard(context, periodHistory);
                    },
                    childCount: _viewModel.history.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Carregando histórico escolar...',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 72,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 20),
            Text(
              'Erro ao carregar histórico',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _viewModel.errorMessage ?? 'Erro desconhecido',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _viewModel.loadHistory();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum histórico encontrado',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.8),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sincronize com o SIGA para carregar seu histórico escolar',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _viewModel.syncFromSiga,
              icon: const Icon(Icons.sync),
              label: const Text('Sincronizar com SIGA'),
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

  Color _getGradeColor(double grade) {
    if (grade >= 7.0) return const Color(0xFF4CAF50); // Verde sucesso
    if (grade >= 5.0) return Colors.orange.shade600;
    return const Color(0xFFEF5350); // Vermelho erro
  }

  Widget _buildPeriodCard(BuildContext context, SchoolHistory history) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final totalSubjects = history.subjects.length;
    final approvedSubjects = history.subjects
        .where((s) => s.status?.toUpperCase().contains('APROVADO') ?? false)
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.primary.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary
                .withValues(alpha: isDark ? 0.1 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.calendar_today,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          title: Text(
            history.period,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: history.periodAverage != null ||
                  history.periodCoefficient != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      if (history.periodAverage != null) ...[
                        Icon(Icons.grade,
                            size: 14,
                            color: _getGradeColor(history.periodAverage!)),
                        const SizedBox(width: 4),
                        Text(
                          'Média ${history.periodAverage!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: _getGradeColor(history.periodAverage!),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (history.periodCoefficient != null) ...[
                        Icon(Icons.trending_up,
                            size: 14,
                            color: _getGradeColor(history.periodCoefficient!)),
                        const SizedBox(width: 4),
                        Text(
                          'CR ${history.periodCoefficient!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: _getGradeColor(history.periodCoefficient!),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : null,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$approvedSubjects/$totalSubjects',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
          children: [
            ...history.subjects.map((subject) {
              final statusColor = _getStatusColor(subject.status);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.surface.withValues(alpha: 0.3)
                      : theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.2),
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  title: Text(
                    subject.name ?? 'Componente Desconhecido',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 4,
                          children: [
                            if (subject.code != null && subject.code != "N/A")
                              _buildInfoBadge(
                                subject.code!,
                                Icons.tag,
                                theme,
                              ),
                            if (subject.finalGrade != null)
                              _buildInfoBadge(
                                'Nota: ${subject.finalGrade}',
                                Icons.grade,
                                theme,
                              ),
                            if (subject.absences != null)
                              _buildInfoBadge(
                                'Faltas: ${subject.absences}',
                                Icons.event_busy,
                                theme,
                              ),
                            if (subject.workload != null)
                              _buildInfoBadge(
                                '${subject.workload}h',
                                Icons.access_time,
                                theme,
                              ),
                            if (subject.credits != null)
                              _buildInfoBadge(
                                '${subject.credits} CR',
                                Icons.stars,
                                theme,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            subject.status ?? '',
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String text, IconData icon, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface.withValues(alpha: 0.5)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    final statusUpper = status?.toUpperCase() ?? '';
    if (statusUpper.contains('APROVADO')) {
      return const Color(0xFF4CAF50);
    }
    if (statusUpper.contains('REPROVADO')) {
      return const Color(0xFFEF5350);
    }
    if (statusUpper.contains('CURSANDO')) return Colors.orange.shade600;
    if (statusUpper.contains('DISPENSADO')) {
      return const Color(0xFF2196F3);
    }
    return Colors.grey.shade500;
  }
}
