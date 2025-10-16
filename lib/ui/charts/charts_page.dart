import 'package:flutter/material.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/ui/charts/widgets/best_period_card.dart';
import 'package:my_ufape/ui/charts/widgets/correlation_card.dart';
import 'package:my_ufape/ui/charts/widgets/grade_distribution_card.dart';
import 'package:my_ufape/ui/charts/widgets/insights_card.dart';
import 'package:my_ufape/ui/charts/widgets/line_chart_card.dart';
import 'package:my_ufape/ui/charts/widgets/main_stats_cards.dart';
import 'package:my_ufape/ui/charts/widgets/performance_trend_card.dart';
import 'package:my_ufape/ui/charts/widgets/pie_chart_card.dart';
import 'package:my_ufape/ui/charts/widgets/subject_performance_card.dart';
import 'package:routefly/routefly.dart';

import 'package:my_ufape/ui/charts/charts_view_model.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  late final ChartsViewModel _viewModel;
  final List<Map<String, dynamic>> _periodosData =
      (Routefly.query.arguments['periodos'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<ChartsViewModel>();
    _viewModel.computeAll(_periodosData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise de Desempenho'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cards de Resumo Principal
            MainStatsCards(analytics: _viewModel.analytics),

            // Tendência de Performance
            if (_viewModel.performanceTrend != null)
              PerformanceTrendCard(trend: _viewModel.performanceTrend!),

            // Gráfico de Pizza - Distribuição de Situações
            PieChartCard(analytics: _viewModel.analytics),

            // Gráfico de Linha - Evolução das Médias
            if (_viewModel.periodMedias.length > 1)
              LineChartCard(periodMedias: _viewModel.periodMedias),

            // Comparativo: Correlação entre carga (nº disciplinas) e média por período
            if (_viewModel.periodMedias.isNotEmpty)
              CorrelationCard(
                  periodMedias: _viewModel.periodMedias,
                  periodosData: _periodosData),

            // Distribuição de Notas
            if (_viewModel.gradeDistribution.isNotEmpty)
              GradeDistributionCard(distribution: _viewModel.gradeDistribution),

            // Top 10 Melhores Disciplinas
            if (_viewModel.subjectPerformance.isNotEmpty)
              SubjectPerformanceCard(
                  performance: _viewModel.subjectPerformance),

            // Melhor Período
            if (_viewModel.periodMedias.isNotEmpty)
              BestPeriodCard(
                  periodMedias: _viewModel.periodMedias,
                  periodosData: _periodosData),

            // Insights e Recomendações
            InsightsCard(
              analytics: _viewModel.analytics,
              trend: _viewModel.performanceTrend,
              consistency: _viewModel.consistency,
            ),
          ],
        ),
      ),
    );
  }
}
