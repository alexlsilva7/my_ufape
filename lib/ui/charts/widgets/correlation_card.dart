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
      // Usar construtor mínimo para compatibilidade da versão do fl_chart
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

    // Interpretação simples
    String interpretation;
    final absCorr = corr.abs();
    if (absCorr >= 0.8) {
      interpretation = 'Correlação forte';
    } else if (absCorr >= 0.5) {
      interpretation = 'Correlação moderada';
    } else if (absCorr >= 0.3) {
      interpretation = 'Correlação fraca';
    } else {
      interpretation = 'Sem correlação aparente';
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
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Correlação: carga vs média',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'r = ${corr.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: ScatterChart(
                  ScatterChartData(
                    scatterSpots: spots,
                    minX: minX,
                    maxX: maxX,
                    minY: minY,
                    maxY: maxY,
                    gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        drawHorizontalLine: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
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
                                    fontWeight: FontWeight.w600),
                              ),
                            );
                          },
                          interval: 1,
                        ),
                      ),
                      leftTitles: AxisTitles(
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
                                  fontWeight: FontWeight.w600),
                            );
                          },
                          interval: 2,
                        ),
                      ),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade600
                              : Colors.grey.shade300,
                        )),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                interpretation,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
