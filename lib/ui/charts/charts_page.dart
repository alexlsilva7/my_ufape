import 'package:flutter/material.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/core/debug/logarte.dart';
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
import 'package:my_ufape/data/repositories/school_history/school_history_repository.dart';
import 'package:my_ufape/domain/entities/subject_note.dart';

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
    _loadDataAndCompute();
  }

  bool isLoading = true;

  Future<void> _loadDataAndCompute() async {
    setState(() {
      isLoading = true;
    });
    // Copiar os dados recebidos
    final merged = _periodosData.map((e) {
      return {
        'nome': e['nome'] as String,
        'disciplinas': List<SubjectNote>.from(
            (e['disciplinas'] as List).cast<SubjectNote>()),
      };
    }).toList();

    // Tentar buscar disciplinas dispensadas e mesclar por período
    try {
      final schoolHistoryRepo = injector.get<SchoolHistoryRepository>();
      final waivedResult = await schoolHistoryRepo
          .getSchoolHistoriesSubjectByStatus('DISPENSADO');
      waivedResult.fold((waivedSubjects) {
        for (final waived in waivedSubjects) {
          final period = waived.period;
          final nome = (waived.code != null && waived.name != null)
              ? '${waived.code} - ${waived.name}'
              : (waived.name ?? 'Dispensada');
          final note = SubjectNote(
            nome: nome,
            semestre: period,
            situacao: waived.status ?? 'DISPENSADO',
            teacher: '',
          )..notas = {};

          final idx = merged.indexWhere((p) => p['nome'] == period);
          if (idx >= 0) {
            (merged[idx]['disciplinas'] as List<SubjectNote>).add(note);
          } else {
            merged.add({
              'nome': period,
              'disciplinas': [note]
            });
          }
        }
      }, (error) {
        logarte.log(
            'Erro ao buscar disciplinas dispensadas para análise de gráficos: $error',
            source: '_loadDataAndCompute');
      });
    } catch (e) {
      logarte.log(
          'Erro ao buscar disciplinas dispensadas para análise de gráficos: ${e.toString()}',
          source: '_loadDataAndCompute');
    }

    // Passar para o viewModel
    _viewModel.computeAll(merged);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise de Desempenho'),
      ),
      body: AnimatedCrossFade(
        duration: const Duration(milliseconds: 400),
        secondCurve: Curves.decelerate,
        crossFadeState:
            isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        firstChild: Container(),
        secondChild: SingleChildScrollView(
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

              // Distribuição de Notas
              if (_viewModel.gradeDistribution.isNotEmpty)
                GradeDistributionCard(
                    distribution: _viewModel.gradeDistribution),

              // Top 10 Melhores Disciplinas
              if (_viewModel.subjectPerformance.isNotEmpty)
                SubjectPerformanceCard(
                    performance: _viewModel.subjectPerformance),

              // Melhor Período
              if (_viewModel.periodMedias.isNotEmpty)
                BestPeriodCard(
                    periodMedias: _viewModel.periodMedias,
                    periodosData: _periodosData),

              // Comparativo: Correlação entre carga (nº disciplinas) e média por período
              if (_viewModel.periodMedias.isNotEmpty)
                CorrelationCard(
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
      ),
    );
  }
}
