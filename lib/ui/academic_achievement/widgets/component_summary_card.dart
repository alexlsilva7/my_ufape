import 'package:flutter/material.dart';
import 'package:my_ufape/domain/entities/academic_achievement.dart';

class ComponentSummaryCard extends StatelessWidget {
  final List<ComponentSummaryItem> items;
  final bool isDark;

  const ComponentSummaryCard(
      {super.key, required this.items, required this.isDark});

  @override
  Widget build(BuildContext context) {
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
}
