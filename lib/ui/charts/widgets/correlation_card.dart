import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_ufape/domain/entities/subject_note.dart';
import 'package:my_ufape/ui/charts/charts_explanations.dart';
import 'package:my_ufape/ui/charts/widgets/info_dialog.dart';
import 'dart:math' as math;

class CorrelationCard extends StatelessWidget {
  final List<Map<String, dynamic>> periodMedias;
  final List<Map<String, dynamic>> periodosData;

  const CorrelationCard(
      {super.key, required this.periodMedias, required this.periodosData});

  @override
  Widget build(BuildContext context) {
    // Gera pontos (x = número de disciplinas do período, y = média do período)
    final xs = <double>[];
    final ys = <double>[];
    final spots = <ScatterSpot>[];
    final periodoNames = <String>[];

    for (final pm in periodMedias) {
      final periodoName = pm['periodo'] as String;
      final media = (pm['media'] as double);

      final periodoObj = periodosData.firstWhere(
        (p) => p['nome'] == periodoName,
        orElse: () => {'nome': periodoName, 'disciplinas': <SubjectNote>[]},
      );

      final disciplinas =
          (periodoObj['disciplinas'] as List<dynamic>).cast<SubjectNote>();
      final count = disciplinas.length;
      xs.add(count.toDouble());
      ys.add(media);
      periodoNames.add(periodoName);
      spots.add(ScatterSpot(count.toDouble(), media));
    }

    if (xs.isEmpty) {
      return const SizedBox.shrink();
    }

    // Cálculo da correlação de Pearson
    final meanX = xs.reduce((a, b) => a + b) / xs.length;
    final meanY = ys.reduce((a, b) => a + b) / ys.length;
    double cov = 0;
    double varX = 0;
    double varY = 0;
    for (var i = 0; i < xs.length; i++) {
      final dx = xs[i] - meanX;
      final dy = ys[i] - meanY;
      cov += dx * dy;
      varX += dx * dx;
      varY += dy * dy;
    }
    cov = cov / xs.length;
    varX = varX / xs.length;
    varY = varY / xs.length;
    final stdX = math.sqrt(varX);
    final stdY = math.sqrt(varY);
    final corr = (stdX == 0 || stdY == 0) ? 0.0 : cov / (stdX * stdY);

    // Interpretação e cor baseada na correlação
    String interpretation;
    Color interpretationColor;
    final absCorr = corr.abs();
    if (absCorr >= 0.8) {
      interpretation = 'Correlação forte';
      interpretationColor = Theme.of(context).colorScheme.primary;
    } else if (absCorr >= 0.5) {
      interpretation = 'Correlação moderada';
      interpretationColor = Theme.of(context).colorScheme.secondary;
    } else if (absCorr >= 0.3) {
      interpretation = 'Correlação fraca';
      interpretationColor = Theme.of(context).colorScheme.tertiary;
    } else {
      interpretation = 'Sem correlação aparente';
      interpretationColor = Theme.of(context).colorScheme.outline;
    }

    final minX = (xs.reduce((a, b) => a < b ? a : b) - 1)
        .clamp(0, double.infinity)
        .toDouble();
    final maxX = (xs.reduce((a, b) => a > b ? a : b) + 1).toDouble();
    final minY = 0.0;
    final maxY = 10.0;

    return GestureDetector(
      onTap: () => showInfoDialog(
        context,
        correlacaoCargaMediaMarkdown,
      ),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.scatter_plot,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Correlação: carga vs média',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'r = ${corr.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 240,
                child: ScatterChart(
                  ScatterChartData(
                    scatterSpots: spots,
                    minX: minX,
                    maxX: maxX,
                    minY: minY,
                    maxY: maxY,
                    scatterTouchData: ScatterTouchData(
                      enabled: true,
                      touchTooltipData: ScatterTouchTooltipData(
                        getTooltipColor: (touchedSpot) =>
                            Theme.of(context).colorScheme.primary,
                        tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        getTooltipItems: (touchedSpot) {
                          final index = spots.indexOf(touchedSpot);
                          if (index < 0 || index >= periodoNames.length) {
                            return null;
                          }

                          final periodo = periodoNames[index];
                          final disciplinas = touchedSpot.x.toInt();
                          final media = touchedSpot.y.toStringAsFixed(2);

                          return ScatterTooltipItem(
                            '$periodo\n',
                            textStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: 'Disciplinas: $disciplinas\n',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 11,
                                ),
                              ),
                              TextSpan(
                                text: 'Média: $media',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      touchCallback: (FlTouchEvent event,
                          ScatterTouchResponse? touchResponse) {},
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      drawHorizontalLine: true,
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
                      bottomTitles: AxisTitles(
                        axisNameWidget: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Quantidade de disciplinas',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        axisNameSize: 20,
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                value.toInt().toString(),
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
                          },
                          interval: 1,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        axisNameWidget: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            'Média',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        axisNameSize: 16,
                        sideTitles: SideTitles(
                          showTitles: true,
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
                          interval: 2,
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
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
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: interpretationColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      absCorr >= 0.5 ? Icons.trending_up : Icons.trending_flat,
                      size: 16,
                      color: interpretationColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      interpretation,
                      style: TextStyle(
                        fontSize: 12,
                        color: interpretationColor,
                        fontWeight: FontWeight.w600,
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
