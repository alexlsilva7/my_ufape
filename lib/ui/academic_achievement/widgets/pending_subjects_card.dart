import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:my_ufape/domain/entities/academic_achievement.dart';

class PendingSubjectsCard extends StatelessWidget {
  final List<PendingSubject> subjects;
  final int? totalHours;
  final bool isDark;

  const PendingSubjectsCard(
      {super.key,
      required this.subjects,
      required this.totalHours,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
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
          if (isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
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
                                .withValues(alpha: 0.3)
                            : theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
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
                                      .withValues(alpha: 0.7),
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
                                color: Colors.orange.withValues(alpha: 0.15),
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
}
