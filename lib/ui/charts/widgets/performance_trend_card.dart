import 'package:flutter/material.dart';
import 'package:my_ufape/ui/charts/charts_explanations.dart';
import 'package:my_ufape/ui/charts/widgets/info_dialog.dart';

class PerformanceTrendCard extends StatelessWidget {
  final Map<String, dynamic> trend;

  const PerformanceTrendCard({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {
    final isImproving = trend['isImproving'] as bool;
    final change = trend['change'] as double;

    return GestureDetector(
      onTap: () => showInfoDialog(
        context,
        tendenciaDesempenhoMarkdown,
      ),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isImproving
                      ? Colors.green.shade600.withValues(alpha: 0.15)
                      : Colors.orange.shade600.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isImproving ? Icons.trending_up : Icons.trending_down,
                  color: isImproving
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isImproving
                          ? 'Desempenho em Melhoria'
                          : 'Atenção ao Desempenho',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isImproving
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isImproving
                          ? 'Sua média aumentou ${change.abs().toStringAsFixed(2)} pontos'
                          : 'Sua média diminuiu ${change.abs().toStringAsFixed(2)} pontos',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
