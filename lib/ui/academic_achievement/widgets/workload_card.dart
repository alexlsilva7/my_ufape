import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:my_ufape/domain/entities/academic_achievement.dart';

class WorkloadCard extends StatelessWidget {
  final List<WorkloadSummaryItem> workloadSummary;
  final bool isDark;

  const WorkloadCard(
      {super.key, required this.workloadSummary, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Converter WorkloadSummaryItem para TreeNode
    int nodeCounter = 0;
    IndexedTreeNode<WorkloadSummaryItem> convertToTreeNode(
        WorkloadSummaryItem item, int index) {
      final uniqueKey = 'node_${nodeCounter++}';

      final node = IndexedTreeNode<WorkloadSummaryItem>(
        key: uniqueKey,
        data: item,
      );

      // Primeiro, processar e filtrar os filhos normalmente
      List<IndexedTreeNode<WorkloadSummaryItem>> validChildren = [];

      for (var i = 0; i < item.children.length; i++) {
        var newNode = convertToTreeNode(item.children[i], i);
        // Aplicar a filtragem original
        if (newNode.data != null &&
                (newNode.data!.toCompleteHours != null &&
                    newNode.data!.toCompleteHours! == 0 &&
                    newNode.data!.completedHours != null &&
                    newNode.data!.completedHours! == 0) ||
            (newNode.data!.completedHours == 0 &&
                newNode.data!.toCompleteHours == null) ||
            (newNode.data!.completedHours == 0 &&
                newNode.data!.toCompleteHours == 0)) {
          continue;
        }
        validChildren.add(newNode);
      }

      // Depois da filtragem, verificar se deve pular nível intermediário
      // Se após filtrar sobrou apenas 1 filho e esse filho tem outros filhos,
      // pular o nível intermediário
      if (validChildren.length == 1 &&
          validChildren[0].childrenAsList.isNotEmpty) {
        // Adicionar os netos diretamente
        for (var grandchild in validChildren[0].childrenAsList) {
          node.add(grandchild);
        }
      } else {
        // Caso normal: adicionar os filhos válidos
        for (var child in validChildren) {
          node.add(child);
        }
      }

      return node;
    }

    // Criar a árvore raiz
    final treeRoot = IndexedTreeNode<WorkloadSummaryItem>.root();
    for (var i = 0; i < workloadSummary.length; i++) {
      treeRoot.add(convertToTreeNode(workloadSummary[i], i));
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

    final totalCategories = countLeafNodes(workloadSummary);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
            child: TreeView.indexed<WorkloadSummaryItem>(
              tree: treeRoot,
              showRootNode: false,
              shrinkWrap: true,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              expansionBehavior: ExpansionBehavior.none,
              indentation: Indentation(
                style: IndentStyle.roundJoint,
                width: 24,
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
                return _WorkloadTreeItem(item: item, isDark: isDark);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkloadTreeItem extends StatelessWidget {
  final WorkloadSummaryItem item;
  final bool isDark;

  const _WorkloadTreeItem({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
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
                    _HoursBadge(
                      text: 'Cursado: ${item.completedHours}h',
                      icon: Icons.check_circle_rounded,
                    ),
                  if (item.waivedHours != null && item.waivedHours! > 0)
                    _HoursBadge(
                      text: 'Disp.: ${item.waivedHours}h',
                      icon: Icons.verified_rounded,
                    ),
                  if (item.toCompleteHours != null &&
                      item.toCompleteHours! >= 0)
                    _HoursBadge(
                      text: 'Faltam: ${item.toCompleteHours}h',
                      icon: Icons.pending_rounded,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HoursBadge extends StatelessWidget {
  final String text;
  final IconData icon;

  const _HoursBadge({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
