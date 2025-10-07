import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:routefly/routefly.dart';
import '../../domain/entities/grades_model.dart';
import 'dart:math' as math;

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  static const Color _primary = Color(0xFF004D40);
  static const Color _secondary = Color(0xFF00695C);
  static const Color _accent = Color(0xFF26A69A);

  final List<Periodo> periodos = Routefly.query.arguments['periodos'] ?? [];

  @override
  Widget build(BuildContext context) {
    final analytics = _computeAnalytics();
    final periodMedias = _computePeriodAverages();
    final subjectPerformance = _computeSubjectPerformance();
    final gradeDistribution = _computeGradeDistribution();
    final performanceTrend = _computePerformanceTrend(periodMedias);
    final consistency = _computeConsistency();
    final progression = _computeProgression(periodMedias);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Análise de Desempenho'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cards de Resumo Principal
            _buildMainStatsCards(analytics),
            const SizedBox(height: 24),

            // Tendência de Performance
            if (performanceTrend != null) ...[
              _buildPerformanceTrendCard(performanceTrend),
              const SizedBox(height: 24),
            ],

            // Análise de Consistência e Progressão
            Row(
              children: [
                if (consistency != null)
                  Expanded(
                    child: _buildConsistencyCard(consistency),
                  ),
                if (consistency != null && progression != null)
                  const SizedBox(width: 12),
                if (progression != null)
                  Expanded(
                    child: _buildProgressionCard(progression),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Gráfico de Pizza - Distribuição de Situações
            _buildPieChartCard(analytics),
            const SizedBox(height: 24),

            // Gráfico de Linha - Evolução das Médias
            if (periodMedias.length > 1) _buildLineChartCard(periodMedias),
            const SizedBox(height: 24),

            // Comparativo: Correlação entre carga (nº disciplinas) e média por período
            if (periodMedias.isNotEmpty) _buildCorrelationCard(periodMedias),
            const SizedBox(height: 24),

            // Distribuição de Notas
            if (gradeDistribution.isNotEmpty)
              _buildGradeDistributionCard(gradeDistribution),
            const SizedBox(height: 24),

            // Top 5 Melhores Disciplinas
            if (subjectPerformance.isNotEmpty)
              _buildSubjectPerformanceCard(subjectPerformance),
            const SizedBox(height: 24),

            // Melhor Período
            if (periodMedias.isNotEmpty) _buildBestPeriodCard(periodMedias),
            const SizedBox(height: 24),

            // Insights e Recomendações
            _buildInsightsCard(analytics, performanceTrend, consistency),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStatsCards(Map<String, dynamic> analytics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Média Geral',
                analytics['overallAverage'].toStringAsFixed(2),
                Icons.analytics_outlined,
                _primary,
                subtitle: _getGradeLabel(analytics['overallAverage']),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Taxa de Aprovação',
                '${analytics['approvalRate'].toStringAsFixed(1)}%',
                Icons.trending_up,
                analytics['approvalRate'] >= 80
                    ? Colors.green.shade600
                    : analytics['approvalRate'] >= 60
                        ? Colors.orange.shade600
                        : Colors.red.shade600,
                subtitle: _getApprovalLabel(analytics['approvalRate']),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Períodos',
                analytics['totalPeriodos'].toString(),
                Icons.calendar_month,
                Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Disciplinas',
                analytics['totalDisciplinas'].toString(),
                Icons.school_outlined,
                Colors.purple.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Aprovadas',
                analytics['totalAprovadas'].toString(),
                Icons.check_circle_outline,
                Colors.green.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceTrendCard(Map<String, dynamic> trend) {
    final isImproving = trend['isImproving'] as bool;
    final change = trend['change'] as double;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isImproving ? Colors.green.shade50 : Colors.orange.shade50,
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
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsistencyCard(Map<String, dynamic> consistency) {
    final stdDev = consistency['stdDev'] as double;
    final isConsistent = consistency['isConsistent'] as bool;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              isConsistent ? Icons.trending_flat : Icons.show_chart,
              color:
                  isConsistent ? Colors.green.shade600 : Colors.blue.shade600,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              isConsistent ? 'Consistente' : 'Variável',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    isConsistent ? Colors.green.shade700 : Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Desvio: ${stdDev.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isConsistent ? 'Desempenho estável' : 'Desempenho oscilante',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressionCard(Map<String, dynamic> progression) {
    final change = progression['change'] as double;
    final percentage = progression['percentage'] as double;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              change > 0
                  ? Icons.north
                  : change < 0
                      ? Icons.south
                      : Icons.remove,
              color: change > 0
                  ? Colors.green.shade600
                  : change < 0
                      ? Colors.red.shade600
                      : Colors.grey.shade600,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'Progressão',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: change > 0
                    ? Colors.green.shade700
                    : change < 0
                        ? Colors.red.shade700
                        : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${change > 0 ? '+' : ''}${change.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${percentage > 0 ? '+' : ''}${percentage.toStringAsFixed(1)}%',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestPeriodCard(List<Map<String, dynamic>> periodMedias) {
    // Período com maior média
    final best = periodMedias.reduce(
        (a, b) => (a['media'] as double) > (b['media'] as double) ? a : b);

    // Período com mais disciplinas aprovadas
    final periodWithMostApproved = periodos.fold<Periodo?>(null, (prev, p) {
      if (prev == null) return p;
      final approvedP = p.disciplinas
          .where((d) => d.situacao.toUpperCase().contains('APROVADO'))
          .length;
      final approvedPrev = prev.disciplinas
          .where((d) => d.situacao.toUpperCase().contains('APROVADO'))
          .length;
      return approvedP > approvedPrev ? p : prev;
    })!;

    final approvedCount = periodWithMostApproved.disciplinas
        .where((d) => d.situacao.toUpperCase().contains('APROVADO'))
        .length;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber.shade700, size: 26),
                const SizedBox(width: 10),
                Text(
                  'Melhor Período Acadêmico',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Melhor média (coluna esquerda)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          best['periodo'] as String,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Média',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            (best['media'] as double).toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Período com mais aprovadas (coluna direita)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          periodWithMostApproved.nome,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Aprovadas',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '$approvedCount',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Comparação rápida: período com maior média vs período com mais disciplinas aprovadas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartCard(Map<String, dynamic> analytics) {
    final totalAprovadas = analytics['totalAprovadas'] as int;
    final totalCursando = analytics['totalCursando'] as int;
    final totalReprovadas = analytics['totalReprovadas'] as int;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Distribuição de Situações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sections: [
                    if (totalAprovadas > 0)
                      PieChartSectionData(
                        color: Colors.green.shade600,
                        value: totalAprovadas.toDouble(),
                        title:
                            '${((totalAprovadas / (totalAprovadas + totalCursando + totalReprovadas)) * 100).toStringAsFixed(0)}%',
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        radius: 85,
                      ),
                    if (totalCursando > 0)
                      PieChartSectionData(
                        color: Colors.orange.shade600,
                        value: totalCursando.toDouble(),
                        title:
                            '${((totalCursando / (totalAprovadas + totalCursando + totalReprovadas)) * 100).toStringAsFixed(0)}%',
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        radius: 85,
                      ),
                    if (totalReprovadas > 0)
                      PieChartSectionData(
                        color: Colors.red.shade600,
                        value: totalReprovadas.toDouble(),
                        title:
                            '${((totalReprovadas / (totalAprovadas + totalCursando + totalReprovadas)) * 100).toStringAsFixed(0)}%',
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
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem(
                  Colors.green.shade600,
                  'Aprovadas',
                  totalAprovadas,
                ),
                _buildLegendItem(
                  Colors.orange.shade600,
                  'Cursando',
                  totalCursando,
                ),
                _buildLegendItem(
                  Colors.red.shade600,
                  'Reprovadas',
                  totalReprovadas,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChartCard(List<Map<String, dynamic>> periodMedias) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Evolução das Médias por Período',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primary,
              ),
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
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
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
                                  color: Colors.grey.shade700,
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
                              color: Colors.grey.shade700,
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
                    border: Border.all(color: Colors.grey.shade400),
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
                        colors: [_primary, _accent],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: _primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            _primary.withOpacity(0.15),
                            _accent.withOpacity(0.05),
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
    );
  }

  Widget _buildCorrelationCard(List<Map<String, dynamic>> periodMedias) {
    // Gera pontos (x = número de disciplinas do período, y = média do período)
    final xs = <double>[];
    final ys = <double>[];
    final spots = <ScatterSpot>[];

    for (final pm in periodMedias) {
      final periodoName = pm['periodo'] as String;
      final media = (pm['media'] as double);

      final periodoObj = periodos.firstWhere(
        (p) => p.nome == periodoName,
        orElse: () => Periodo(nome: periodoName, disciplinas: []),
      );

      final count = periodoObj.disciplinas.length;
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

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.scatter_plot, color: _secondary),
                const SizedBox(width: 8),
                Text(
                  'Correlação: carga vs média',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _primary),
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
                                  color: Colors.grey.shade700,
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
                                color: Colors.grey.shade700,
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
                      border: Border.all(color: Colors.grey.shade300)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              interpretation,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeDistributionCard(Map<String, int> distribution) {
    final maxCount =
        distribution.values.reduce((a, b) => a > b ? a : b).toDouble();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Distribuição de Notas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 280,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxCount,
                  titlesData: FlTitlesData(
                    show: true,
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
                          final ranges = distribution.keys.toList();
                          final index = value.toInt();
                          if (index >= 0 && index < ranges.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                ranges[index],
                                style: TextStyle(
                                  color: Colors.grey.shade700,
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
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey.shade700,
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
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  barGroups: distribution.entries
                      .toList()
                      .asMap()
                      .entries
                      .map(
                        (entry) => BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.value.toDouble(),
                              color: _getColorForGradeRange(entry.value.key),
                              width: 32,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Quantidade de disciplinas por faixa de nota',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectPerformanceCard(List<Map<String, dynamic>> performance) {
    final best = performance.take(10).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top 10 Melhores Desempenhos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primary,
              ),
            ),
            const SizedBox(height: 20),
            if (best.isNotEmpty) ...[
              ...best.asMap().entries.map((entry) {
                final index = entry.key;
                final subject = entry.value;
                return _buildSubjectItem(
                  subject['nome'] as String,
                  subject['media'] as double,
                  index == 0
                      ? Colors.amber.shade700
                      : index == 1
                          ? Colors.grey.shade400
                          : index == 2
                              ? Colors.brown.shade400
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
    );
  }

  Widget _buildSubjectItem(String name, double grade, Color color,
      {int? rank, String? periodo, String? professor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
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
                      color: Colors.white,
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
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (periodo != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      periodo,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
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

  Widget _buildInsightsCard(Map<String, dynamic> analytics,
      Map<String, dynamic>? trend, Map<String, dynamic>? consistency) {
    final insights = <Map<String, dynamic>>[];

    // Insight sobre aprovação
    final approvalRate = analytics['approvalRate'] as double;
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
    final overallAverage = analytics['overallAverage'] as double;
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
    if (consistency != null && consistency['isConsistent'] == true) {
      insights.add({
        'icon': Icons.verified,
        'color': Colors.green.shade600,
        'title': 'Desempenho consistente',
        'description':
            'Suas notas são estáveis. Mantenha essa regularidade nos estudos!',
      });
    }

    // Insight sobre tendência
    if (trend != null && trend['isImproving'] == true) {
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
        'color': _primary,
        'title': 'Continue estudando',
        'description':
            'Mantenha a consistência nos estudos para alcançar seus objetivos.',
      });
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: _primary),
                const SizedBox(width: 8),
                Text(
                  'Insights e Recomendações',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primary,
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
                      color: (insight['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (insight['color'] as Color).withOpacity(0.3),
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
                                  color: Colors.grey.shade700,
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
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, int count) {
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
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Analytics computation methods
  Map<String, dynamic> _computeAnalytics() {
    final allDisciplinas = periodos.expand((p) => p.disciplinas).toList();
    final totalDisciplinas = allDisciplinas.length;
    final totalAprovadas = allDisciplinas
        .where((d) => d.situacao.toUpperCase().contains('APROVADO'))
        .length;
    final totalReprovadas = allDisciplinas
        .where((d) => d.situacao.toUpperCase().contains('REPROVADO'))
        .length;
    final totalCursando = totalDisciplinas - totalAprovadas - totalReprovadas;
    final approvalRate =
        totalDisciplinas > 0 ? (totalAprovadas / totalDisciplinas) * 100 : 0.0;

    return {
      'totalDisciplinas': totalDisciplinas,
      'totalAprovadas': totalAprovadas,
      'totalReprovadas': totalReprovadas,
      'totalCursando': totalCursando,
      'totalPeriodos': periodos.length,
      'approvalRate': approvalRate,
      'overallAverage': _computeOverallAverage(),
    };
  }

  List<Map<String, dynamic>> _computePeriodAverages() {
    final periodMedias = <Map<String, dynamic>>[];

    for (final periodo in periodos) {
      final medias = <double>[];

      for (final disciplina in periodo.disciplinas) {
        for (final entry in disciplina.notas.entries) {
          if (_isMediaKey(entry.key)) {
            final value = double.tryParse(entry.value.replaceAll(',', '.'));
            if (value != null) medias.add(value);
          }
        }
      }

      if (medias.isNotEmpty) {
        final mediaPeriodo = medias.reduce((a, b) => a + b) / medias.length;
        periodMedias.add({
          'periodo': periodo.nome,
          'media': mediaPeriodo,
        });
      }
    }

    periodMedias.sort(
        (a, b) => (a['periodo'] as String).compareTo(b['periodo'] as String));

    return periodMedias;
  }

  List<Map<String, dynamic>> _computeSubjectPerformance() {
    final subjectData = <String, Map<String, dynamic>>{};

    for (final periodo in periodos) {
      for (final disciplina in periodo.disciplinas) {
        for (final entry in disciplina.notas.entries) {
          if (_isMediaKey(entry.key)) {
            final value = double.tryParse(entry.value.replaceAll(',', '.'));
            if (value != null) {
              if (!subjectData.containsKey(disciplina.nome)) {
                subjectData[disciplina.nome] = {
                  'grades': <double>[],
                  'periodo': periodo.nome,
                  'professor':
                      _getProfessorForSubject(disciplina.nome, periodo),
                };
              }
              subjectData[disciplina.nome]!['grades'].add(value);
            }
          }
        }
      }
    }

    final performance = subjectData.entries.map((entry) {
      final grades = entry.value['grades'] as List<double>;
      final avg = grades.reduce((a, b) => a + b) / grades.length;
      return {
        'nome': entry.key,
        'media': avg,
        'periodo': entry.value['periodo'],
        'professor': entry.value['professor'],
      };
    }).toList();

    performance
        .sort((a, b) => (b['media'] as double).compareTo(a['media'] as double));

    return performance;
  }

  Map<String, int> _computeGradeDistribution() {
    final distribution = <String, int>{
      '0-2': 0,
      '2-4': 0,
      '4-6': 0,
      '6-8': 0,
      '8-10': 0,
    };

    for (final periodo in periodos) {
      for (final disciplina in periodo.disciplinas) {
        for (final entry in disciplina.notas.entries) {
          if (_isMediaKey(entry.key)) {
            final value = double.tryParse(entry.value.replaceAll(',', '.'));
            if (value != null) {
              if (value < 2) {
                distribution['0-2'] = distribution['0-2']! + 1;
              } else if (value < 4) {
                distribution['2-4'] = distribution['2-4']! + 1;
              } else if (value < 6) {
                distribution['4-6'] = distribution['4-6']! + 1;
              } else if (value < 8) {
                distribution['6-8'] = distribution['6-8']! + 1;
              } else {
                distribution['8-10'] = distribution['8-10']! + 1;
              }
            }
          }
        }
      }
    }

    return distribution;
  }

  Map<String, dynamic>? _computePerformanceTrend(
      List<Map<String, dynamic>> periodMedias) {
    if (periodMedias.length < 2) return null;

    final lastPeriod = periodMedias.last['media'] as double;
    final previousPeriod =
        periodMedias[periodMedias.length - 2]['media'] as double;
    final change = lastPeriod - previousPeriod;

    return {
      'isImproving': change > 0,
      'change': change,
    };
  }

  Map<String, dynamic>? _computeConsistency() {
    final allMedias = <double>[];

    for (final periodo in periodos) {
      for (final disciplina in periodo.disciplinas) {
        for (final entry in disciplina.notas.entries) {
          if (_isMediaKey(entry.key)) {
            final value = double.tryParse(entry.value.replaceAll(',', '.'));
            if (value != null) allMedias.add(value);
          }
        }
      }
    }

    if (allMedias.length < 2) return null;

    final mean = allMedias.reduce((a, b) => a + b) / allMedias.length;
    final variance =
        allMedias.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) /
            allMedias.length;
    final stdDev = math.sqrt(variance);

    return {
      'stdDev': stdDev,
      'isConsistent': stdDev < 1.5,
    };
  }

  Map<String, dynamic>? _computeProgression(
      List<Map<String, dynamic>> periodMedias) {
    if (periodMedias.length < 2) return null;

    final first = periodMedias.first['media'] as double;
    final last = periodMedias.last['media'] as double;
    final change = last - first;
    final percentage = first > 0 ? (change / first) * 100 : 0.0;

    return {
      'change': change,
      'percentage': percentage,
    };
  }

  double _computeOverallAverage() {
    final allMedias = <double>[];

    for (final periodo in periodos) {
      for (final disciplina in periodo.disciplinas) {
        for (final entry in disciplina.notas.entries) {
          if (_isMediaKey(entry.key)) {
            final value = double.tryParse(entry.value.replaceAll(',', '.'));
            if (value != null) allMedias.add(value);
          }
        }
      }
    }

    if (allMedias.isEmpty) return 0.0;
    return allMedias.reduce((a, b) => a + b) / allMedias.length;
  }

  bool _isMediaKey(String key) {
    final k = key.toLowerCase();
    return k.contains('média') || k.contains('media') || k.contains('mf');
  }

  String _getGradeLabel(double grade) {
    if (grade >= 9.0) return 'Excelente';
    if (grade >= 8.0) return 'Ótimo';
    if (grade >= 7.0) return 'Bom';
    if (grade >= 6.0) return 'Regular';
    return 'Precisa melhorar';
  }

  String _getApprovalLabel(double rate) {
    if (rate >= 90) return 'Excepcional';
    if (rate >= 80) return 'Muito bom';
    if (rate >= 70) return 'Bom';
    if (rate >= 60) return 'Regular';
    return 'Precisa atenção';
  }

  Color _getColorForGradeRange(String range) {
    switch (range) {
      case '0-2':
        return Colors.red.shade700;
      case '2-4':
        return Colors.orange.shade700;
      case '4-6':
        return Colors.amber.shade700;
      case '6-8':
        return Colors.lightGreen.shade600;
      case '8-10':
        return Colors.green.shade700;
      default:
        return Colors.grey;
    }
  }

  String _getProfessorForSubject(String subjectName, Periodo periodo) {
    // Lista de professores fictícios baseada no nome da disciplina
    final professors = [
      'Prof. Silva',
      'Prof. Santos',
      'Prof. Oliveira',
      'Prof. Pereira',
      'Prof. Costa',
      'Prof. Rodrigues',
      'Prof. Ferreira',
      'Prof. Almeida',
      'Prof. Carvalho',
      'Prof. Gomes',
    ];

    // Gera um índice baseado no nome da disciplina para consistência
    final hash = subjectName.hashCode.abs();
    return professors[hash % professors.length];
  }
}
