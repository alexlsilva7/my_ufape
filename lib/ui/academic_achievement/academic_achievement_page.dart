import 'package:flutter/material.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/domain/entities/academic_achievement.dart';
import 'package:my_ufape/ui/academic_achievement/academic_achievement_view_model.dart';
import 'package:animated_tree_view/animated_tree_view.dart';

class AcademicAchievementPage extends StatefulWidget {
  const AcademicAchievementPage({super.key});

  @override
  State<AcademicAchievementPage> createState() =>
      _AcademicAchievementPageState();
}

class _AcademicAchievementPageState extends State<AcademicAchievementPage> {
  final AcademicAchievementViewModel _viewModel = injector.get();

  @override
  void initState() {
    super.initState();
    _viewModel.loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: isDark ? theme.colorScheme.surface : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Rendimento',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: _viewModel.isSyncing
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : Icon(Icons.sync_rounded, size: 24),
                onPressed:
                    _viewModel.isSyncing ? null : _viewModel.syncFromSiga,
                tooltip: 'Sincronizar com o SIGA',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                ),
              ),
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
          if (_viewModel.achievement == null) {
            return _buildEmptyState(context, isDark);
          }

          final achievement = _viewModel.achievement!;

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildWorkloadCard(achievement.workloadSummary, isDark),
                    const SizedBox(height: 16),
                    _buildComponentSummaryCard(
                        achievement.componentSummary, isDark),
                    const SizedBox(height: 16),
                    _buildPendingSubjectsCard(achievement.pendingSubjects,
                        achievement.totalPendingHours, isDark),
                    const SizedBox(height: 8),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Carregando aproveitamento acadêmico...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Erro ao carregar dados',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _viewModel.errorMessage ?? 'Erro desconhecido',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _viewModel.loadData(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 72,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum dado encontrado',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sincronize com o SIGA para carregar\nseu aproveitamento acadêmico',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _viewModel.syncFromSiga,
              icon: const Icon(Icons.sync_rounded),
              label: const Text('Sincronizar com SIGA'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkloadCard(List<WorkloadSummaryItem> rootItems, bool isDark) {
    final theme = Theme.of(context);

    // Converter WorkloadSummaryItem para TreeNode
    int nodeCounter = 0;
    TreeNode<WorkloadSummaryItem> convertToTreeNode(
        WorkloadSummaryItem item, int index) {
      // Usar um contador único para garantir chaves únicas sem pontos
      final uniqueKey = 'node_${nodeCounter++}';

      final node = TreeNode<WorkloadSummaryItem>(
        key: uniqueKey,
        data: item,
      );

      for (var i = 0; i < item.children.length; i++) {
        node.add(convertToTreeNode(item.children[i], i));
      }

      return node;
    }

    // Criar a árvore raiz
    final treeRoot = TreeNode<WorkloadSummaryItem>.root();
    for (var i = 0; i < rootItems.length; i++) {
      treeRoot.add(convertToTreeNode(rootItems[i], i));
    }

    int countLeafNodes(List<WorkloadSummaryItem> nodes) {
      int count = 0;
      for (var node in nodes) {
        if (node.children.isEmpty ||
            (node.completedHours != null && node.completedHours! > 0) ||
            (node.toCompleteHours != null && node.toCompleteHours! > 0)) {
          if (node.name != "Total" && node.name != "ATENÇÃO:") {
            count++;
          }
        }
        count += countLeafNodes(node.children);
      }
      return count;
    }

    final totalCategories = countLeafNodes(rootItems);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumo da Carga Horária',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (totalCategories > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '$totalCategories categorias',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // TreeView
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: TreeView.simple<WorkloadSummaryItem>(
              tree: treeRoot,
              showRootNode: false,
              shrinkWrap: true,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              expansionBehavior: ExpansionBehavior.none,
              indentation: Indentation(
                style: IndentStyle.roundJoint,
                width: 24,
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
              expansionIndicatorBuilder: (context, node) {
                if (node.childrenAsList.isEmpty) {
                  return NoExpansionIndicator(tree: node);
                }
                return ChevronIndicator.rightDown(
                  tree: node,
                  color: theme.colorScheme.primary,
                  padding: const EdgeInsets.only(right: 8, top: 20),
                  icon: Icons.keyboard_arrow_right_rounded,
                );
              },
              builder: (context, node) {
                final item = node.data!;
                return _buildWorkloadTreeItem(item, isDark, theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkloadTreeItem(
    WorkloadSummaryItem item,
    bool isDark,
    ThemeData theme,
  ) {
    final completedPercentage = item.completedPercentage ?? 0.0;

    if (item.name == null ||
        item.name!.trim().isEmpty ||
        item.name == "ATENÇÃO:") {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.3)
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    item.name!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (item.completedPercentage != null) ...[
                  Text(
                    '${completedPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(width: 20),
                ]
              ],
            ),
            if (item.completedPercentage != null &&
                item.completedPercentage! > 0) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: completedPercentage / 100.0,
                  minHeight: 7,
                  backgroundColor:
                      isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
            if (item.completedHours != null ||
                item.waivedHours != null ||
                item.toCompleteHours != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  if (item.completedHours != null && item.completedHours! >= 0)
                    _buildHoursBadge(
                      'Cursado: ${item.completedHours}h',
                      Icons.check_circle_rounded,
                      theme,
                      isDark,
                    ),
                  if (item.waivedHours != null && item.waivedHours! > 0)
                    _buildHoursBadge(
                      'Disp.: ${item.waivedHours}h',
                      Icons.verified_rounded,
                      theme,
                      isDark,
                    ),
                  if (item.toCompleteHours != null &&
                      item.toCompleteHours! >= 0)
                    _buildHoursBadge(
                      'Faltam: ${item.toCompleteHours}h',
                      Icons.pending_rounded,
                      theme,
                      isDark,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHoursBadge(
    String text,
    IconData icon,
    ThemeData theme,
    bool isDark,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildComponentSummaryCard(
      List<ComponentSummaryItem> items, bool isDark) {
    final theme = Theme.of(context);
    final filteredItems = items
        .where((item) =>
            item.description != null &&
            item.description!.isNotEmpty &&
            ((item.hours ?? 0) > 0 || (item.quantity ?? 0) > 0))
        .toList();

    if (filteredItems.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.assessment_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Resumo de Realização',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2.5),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                ),
              ),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.3),
                  ),
                  children: [
                    _buildTableHeader('Descrição', theme),
                    _buildTableHeader('Horas', theme, center: true),
                    _buildTableHeader('Qtd.', theme, center: true),
                  ],
                ),
                ...filteredItems.map((item) {
                  return TableRow(
                    children: [
                      _buildTableCell(
                        item.description!,
                        theme,
                        isFirst: true,
                      ),
                      _buildTableCell(
                        item.hours != null ? '${item.hours}h' : '-',
                        theme,
                        align: TextAlign.center,
                      ),
                      _buildTableCell(
                        item.quantity != null ? '${item.quantity}' : '-',
                        theme,
                        align: TextAlign.center,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text, ThemeData theme,
      {bool center = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildTableCell(
    String text,
    ThemeData theme, {
    bool isFirst = false,
    TextAlign align = TextAlign.start,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isFirst ? FontWeight.w500 : FontWeight.w400,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildPendingSubjectsCard(
      List<PendingSubject> subjects, int? totalHours, bool isDark) {
    final theme = Theme.of(context);
    final isEmpty = subjects.isEmpty;

    // Calcular a soma das horas das disciplinas pendentes
    final calculatedTotalHours = subjects.fold<int>(
      0,
      (sum, subject) => sum + (subject.workload ?? 0),
    );

    // Usar o valor calculado se totalHours for null
    final displayTotalHours =
        totalHours == 0 ? calculatedTotalHours : totalHours;

    // Converter para TreeNode
    int nodeCounter = 0;
    final treeRoot = TreeNode<PendingSubject>.root();

    for (var subject in subjects) {
      treeRoot.add(TreeNode<PendingSubject>(
        key: 'subject_${nodeCounter++}',
        data: subject,
      ));
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  isEmpty
                      ? Icons.check_circle_rounded
                      : Icons.pending_actions_rounded,
                  size: 20,
                  color: isEmpty ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Componentes Obrigatórios Pendentes',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (!isEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${subjects.length} disciplinas • ${displayTotalHours}h',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.celebration_rounded,
                      color: Colors.green,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Todas as disciplinas obrigatórias foram concluídas!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: TreeView.simple<PendingSubject>(
                tree: treeRoot,
                showRootNode: false,
                shrinkWrap: true,
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                expansionBehavior: ExpansionBehavior.none,
                indentation: const Indentation(
                  style: IndentStyle.none,
                  width: 0,
                ),
                expansionIndicatorBuilder: (context, node) =>
                    NoExpansionIndicator(tree: node),
                builder: (context, node) {
                  final subject = node.data!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.surfaceContainerHighest
                                .withOpacity(0.3)
                            : theme.colorScheme.surfaceContainerHighest
                                .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              subject.name ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (subject.code != null) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Text(
                                subject.code!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                          if (subject.workload != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${subject.workload}h',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(String text, IconData icon, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface.withOpacity(0.6)
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.primary.withOpacity(0.8),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
