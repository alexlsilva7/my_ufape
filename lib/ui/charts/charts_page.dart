import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/grades_model.dart';

class ChartsPage extends StatefulWidget {
  final List<Periodo> periodos;

  const ChartsPage({super.key, required this.periodos});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  static const Color _primary = Color(0xFF004D40);
  static const Color _secondary = Color(0xFF00695C);

  @override
  Widget build(BuildContext context) {
    final totalDisciplinas =
        widget.periodos.expand((p) => p.disciplinas).length;
    final totalAprovadas = widget.periodos
        .expand((p) => p.disciplinas)
        .where((d) => d.situacao.toUpperCase().contains('APROVADO'))
        .length;
    final totalReprovadas = widget.periodos
        .expand((p) => p.disciplinas)
        .where((d) => d.situacao.toUpperCase().contains('REPROVADO'))
        .length;
    final totalCursando = totalDisciplinas - totalAprovadas - totalReprovadas;

    final periodMedias = _computePeriodAverages();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Gráficos de Desempenho'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gráfico de Pizza - Distribuição de Situações
            Card(
              elevation: 3,
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
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            if (totalAprovadas > 0)
                              PieChartSectionData(
                                color: Colors.green.shade600,
                                value: totalAprovadas.toDouble(),
                                title: '$totalAprovadas\nAprovadas',
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                radius: 80,
                              ),
                            if (totalCursando > 0)
                              PieChartSectionData(
                                color: Colors.orange.shade600,
                                value: totalCursando.toDouble(),
                                title: '$totalCursando\nCursando',
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                radius: 80,
                              ),
                            if (totalReprovadas > 0)
                              PieChartSectionData(
                                color: Colors.red.shade600,
                                value: totalReprovadas.toDouble(),
                                title: '$totalReprovadas\nReprovadas',
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                radius: 80,
                              ),
                          ],
                          sectionsSpace: 4,
                          centerSpaceRadius: 60,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Legenda
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildLegendItem(
                          Colors.green.shade600,
                          'Aprovadas ($totalAprovadas)',
                        ),
                        _buildLegendItem(
                          Colors.orange.shade600,
                          'Cursando ($totalCursando)',
                        ),
                        _buildLegendItem(
                          Colors.red.shade600,
                          'Reprovadas ($totalReprovadas)',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Gráfico de Linha - Evolução das Médias por Período
            if (periodMedias.isNotEmpty)
              Card(
                elevation: 3,
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
                        height: 300,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              horizontalInterval: 1,
                              verticalInterval: 1,
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
                                  reservedSize: 30,
                                  interval: 1,
                                  getTitlesWidget:
                                      (double value, TitleMeta meta) {
                                    final index = value.toInt();
                                    if (index >= 0 &&
                                        index < periodMedias.length) {
                                      // Exibe apenas o último dígito do período
                                      final periodoName = periodMedias[index]
                                          ['periodo'] as String;
                                      final lastChar = periodoName.isNotEmpty
                                          ? periodoName
                                              .substring(periodoName.length - 1)
                                          : '';
                                      return Text(
                                        lastChar,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
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
                                  interval: 1,
                                  getTitlesWidget:
                                      (double value, TitleMeta meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                  reservedSize: 32,
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
                                gradient: LinearGradient(
                                  colors: [
                                    _primary.withOpacity(0.8),
                                    _secondary.withOpacity(0.8),
                                  ],
                                ),
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 6,
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
                                      _primary.withOpacity(0.2),
                                      _secondary.withOpacity(0.1),
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
                      const SizedBox(height: 10),
                      Text(
                        'Períodos ordenados cronologicamente',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Resumo Estatístico
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Resumo Estatístico',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Taxa de Aprovação',
                            '${((totalAprovadas / totalDisciplinas) * 100).toStringAsFixed(1)}%',
                            Icons.trending_up,
                            Colors.green.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Média Geral',
                            _computeOverallAverage().toStringAsFixed(2),
                            Icons.analytics,
                            _primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Períodos',
                            widget.periodos.length.toString(),
                            Icons.calendar_today,
                            Colors.blue.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Total Disciplinas',
                            totalDisciplinas.toString(),
                            Icons.school,
                            Colors.purple.shade600,
                          ),
                        ),
                      ],
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

  Widget _buildLegendItem(Color color, String label) {
    return Row(
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
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
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
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _computePeriodAverages() {
    final List<Map<String, dynamic>> periodMedias = [];

    for (final periodo in widget.periodos) {
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

    // Ordenar períodos cronologicamente
    periodMedias.sort(
        (a, b) => (a['periodo'] as String).compareTo(b['periodo'] as String));

    return periodMedias;
  }

  double _computeOverallAverage() {
    final allMedias = <double>[];

    for (final periodo in widget.periodos) {
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
}
