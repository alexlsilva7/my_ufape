import 'package:flutter/material.dart';
import 'package:my_ufape/ui/charts/charts_explanations.dart';
import 'package:my_ufape/ui/charts/widgets/info_dialog.dart';

class SubjectPerformanceCard extends StatelessWidget {
  final List<Map<String, dynamic>> performance;

  const SubjectPerformanceCard({super.key, required this.performance});

  @override
  Widget build(BuildContext context) {
    final best = performance.take(10).toList();

    return GestureDetector(
      onTap: () => showInfoDialog(
        context,
        topDesempenhosMarkdown,
      ),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  //ranking icon
                  Icon(Icons.emoji_events,
                      color: Colors.amber.shade700, size: 26),
                  const SizedBox(width: 10),
                  Text(
                    'Top 10 Melhores Desempenhos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (best.isNotEmpty) ...[
                ...best.asMap().entries.map((entry) {
                  final index = entry.key;
                  final subject = entry.value;
                  return _buildSubjectItem(
                    context,
                    subject['nome'] as String,
                    subject['media'] as double,
                    index == 0
                        ? Colors.amber.shade700
                        : index == 1
                            ? Colors.amber.shade700
                            : index == 2
                                ? Colors.amber.shade700
                                : Colors.green.shade600,
                    rank: index + 1,
                    periodo: subject['periodo'] as String?,
                    professor: subject['professor'] as String?,
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectItem(
      BuildContext context, String name, double grade, Color color,
      {int? rank, String? periodo, String? professor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            if (rank != null) ...[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Mostrar o professor, se disponível
                  if (professor != null && professor.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      professor,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withAlpha(170),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (periodo != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      periodo,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withAlpha(170),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                grade.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
