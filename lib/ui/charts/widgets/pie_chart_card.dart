import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_ufape/ui/charts/charts_explanations.dart';
import 'package:my_ufape/ui/charts/widgets/info_dialog.dart';

class PieChartCard extends StatelessWidget {
  final Map<String, dynamic> analytics;

  const PieChartCard({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    final totalAprovadas = analytics['totalAprovadas'] as int? ?? 0;
    final totalCursando = analytics['totalCursando'] as int? ?? 0;
    final totalReprovadas = analytics['totalReprovadas'] as int? ?? 0;
    final totalDispensadas = analytics['totalDispensadas'] as int? ?? 0;
    final total =
        totalAprovadas + totalCursando + totalReprovadas + totalDispensadas;

    return GestureDetector(
      onTap: () => showInfoDialog(
        context,
        distribuicaoSituacoesMarkdown,
      ),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Distribuição de Situações',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sections: [
                      if (totalAprovadas > 0 && total > 0)
                        PieChartSectionData(
                          color: Colors.green.shade600,
                          value: totalAprovadas.toDouble(),
                          title:
                              '${((totalAprovadas / total) * 100).toStringAsFixed(0)}%',
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          radius: 85,
                        ),
                      if (totalCursando > 0 && total > 0)
                        PieChartSectionData(
                          color: Colors.orange.shade600,
                          value: totalCursando.toDouble(),
                          title:
                              '${((totalCursando / total) * 100).toStringAsFixed(0)}%',
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          radius: 85,
                        ),
                      if (totalReprovadas > 0 && total > 0)
                        PieChartSectionData(
                          color: Colors.red.shade600,
                          value: totalReprovadas.toDouble(),
                          title:
                              '${((totalReprovadas / total) * 100).toStringAsFixed(0)}%',
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          radius: 85,
                        ),
                      if (totalDispensadas > 0 && total > 0)
                        PieChartSectionData(
                          color: Colors.blue.shade600,
                          value: totalDispensadas.toDouble(),
                          title:
                              '${((totalDispensadas / total) * 100).toStringAsFixed(0)}%',
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          radius: 85,
                        ),
                    ],
                    sectionsSpace: 3,
                    centerSpaceRadius: 50,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildLegendItem(
                    context,
                    Colors.green.shade600,
                    'Aprovadas',
                    totalAprovadas,
                  ),
                  _buildLegendItem(
                    context,
                    Colors.orange.shade600,
                    'Cursando',
                    totalCursando,
                  ),
                  _buildLegendItem(
                    context,
                    Colors.red.shade600,
                    'Reprovadas',
                    totalReprovadas,
                  ),
                  if (totalDispensadas > 0)
                    _buildLegendItem(
                      context,
                      Colors.blue.shade600,
                      'Dispensadas',
                      totalDispensadas,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(
      BuildContext context, Color color, String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
