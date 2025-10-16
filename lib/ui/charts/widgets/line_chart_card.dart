import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_ufape/ui/charts/charts_explanations.dart';
import 'package:my_ufape/ui/charts/widgets/info_dialog.dart';

class LineChartCard extends StatelessWidget {
  final List<Map<String, dynamic>> periodMedias;

  const LineChartCard({super.key, required this.periodMedias});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showInfoDialog(
        context,
        evolucaoMediasMarkdown,
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
                    'Evolução das Médias por Período',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 280,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 2,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < periodMedias.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  periodMedias[index]['periodo'] as String,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 2,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(1),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                    ),
                    minX: 0,
                    maxX: (periodMedias.length - 1).toDouble(),
                    minY: 0,
                    maxY: 10,
                    lineBarsData: [
                      LineChartBarData(
                        spots: periodMedias
                            .asMap()
                            .entries
                            .map(
                              (entry) => FlSpot(
                                entry.key.toDouble(),
                                entry.value['media'] as double,
                              ),
                            )
                            .toList(),
                        isCurved: true,
                        curveSmoothness: 0.3,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 5,
                              color: Theme.of(context).primaryColor,
                              strokeWidth: 2,
                              strokeColor: Theme.of(context).cardColor,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.15),
                              Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
