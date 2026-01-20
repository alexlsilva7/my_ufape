import 'package:flutter/material.dart';
import 'package:my_ufape/ui/charts/charts_explanations.dart';
import 'package:my_ufape/ui/charts/widgets/info_dialog.dart';

class InsightsCard extends StatelessWidget {
  final Map<String, dynamic> analytics;
  final Map<String, dynamic>? trend;
  final Map<String, dynamic>? consistency;

  const InsightsCard(
      {super.key, required this.analytics, this.trend, this.consistency});

  @override
  Widget build(BuildContext context) {
    final insights = <Map<String, dynamic>>[];

    // Insight sobre aprovação
    final approvalRate = analytics['approvalRate'] as double? ?? 0.0;
    if (approvalRate >= 90) {
      insights.add({
        'icon': Icons.star,
        'color': Colors.green.shade600,
        'title': 'Excelente desempenho!',
        'description':
            'Você tem uma taxa de aprovação de ${approvalRate.toStringAsFixed(1)}%. Continue assim!',
      });
    } else if (approvalRate < 70) {
      insights.add({
        'icon': Icons.lightbulb_outline,
        'color': Colors.orange.shade600,
        'title': 'Foco necessário',
        'description':
            'Sua taxa de aprovação é ${approvalRate.toStringAsFixed(1)}%. Considere dedicar mais tempo aos estudos.',
      });
    }

    // Insight sobre média
    final overallAverage = analytics['overallAverage'] as double? ?? 0.0;
    if (overallAverage >= 8.5) {
      insights.add({
        'icon': Icons.emoji_events,
        'color': Colors.amber.shade700,
        'title': 'Média excepcional!',
        'description':
            'Sua média geral de ${overallAverage.toStringAsFixed(2)} está acima da média. Parabéns!',
      });
    } else if (overallAverage < 7.0) {
      insights.add({
        'icon': Icons.trending_up,
        'color': Colors.blue.shade600,
        'title': 'Oportunidade de melhoria',
        'description':
            'Com dedicação, você pode aumentar sua média de ${overallAverage.toStringAsFixed(2)}.',
      });
    }

    // Insight sobre consistência
    if (consistency != null && consistency!['isConsistent'] == true) {
      insights.add({
        'icon': Icons.verified,
        'color': Colors.green.shade600,
        'title': 'Desempenho consistente',
        'description':
            'Suas notas são estáveis. Mantenha essa regularidade nos estudos!',
      });
    }

    // Insight sobre tendência
    if (trend != null && trend!['isImproving'] == true) {
      insights.add({
        'icon': Icons.auto_graph,
        'color': Colors.green.shade600,
        'title': 'Trajetória positiva',
        'description': 'Seu desempenho está melhorando. Continue com o ritmo!',
      });
    }

    if (insights.isEmpty) {
      insights.add({
        'icon': Icons.info_outline,
        'title': 'Continue estudando',
        'description':
            'Mantenha a consistência nos estudos para alcançar seus objetivos.',
      });
    }

    return GestureDetector(
      onTap: () => showInfoDialog(
        context,
        insightsMarkdown,
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
                  Icon(Icons.psychology),
                  const SizedBox(width: 8),
                  Text(
                    'Insights e Recomendações',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...insights.map((insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            (insight['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (insight['color'] as Color)
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            insight['icon'] as IconData,
                            color: insight['color'] as Color,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  insight['title'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: insight['color'] as Color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  insight['description'] as String,
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
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
