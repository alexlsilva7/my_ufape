import 'package:flutter/material.dart';
import 'package:my_ufape/ui/charts/charts_explanations.dart';
import 'package:my_ufape/ui/charts/widgets/info_dialog.dart';

class MainStatsCards extends StatelessWidget {
  final Map<String, dynamic> analytics;

  const MainStatsCards({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Média Geral',
                value: analytics['overallAverage'].toStringAsFixed(2),
                icon: Icons.analytics_outlined,
                color: Theme.of(context).primaryColor,
                subtitle: _getGradeLabel(analytics['overallAverage']),
                onInfoTap: () => showInfoDialog(
                  context,
                  mediaGeralMarkdown,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Taxa de Aprovação',
                value: '${analytics['approvalRate'].toStringAsFixed(1)}%',
                icon: Icons.trending_up,
                color: analytics['approvalRate'] >= 70
                    ? Colors.green.shade600
                    : analytics['approvalRate'] >= 60
                        ? Colors.orange.shade600
                        : Colors.red.shade600,
                subtitle: _getApprovalLabel(analytics['approvalRate']),
                onInfoTap: () => showInfoDialog(
                  context,
                  taxaDeAprovacaoMarkdown,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Períodos',
                value: analytics['totalPeriodos'].toString(),
                icon: Icons.calendar_month,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Disciplinas',
                value: analytics['totalDisciplinas'].toString(),
                icon: Icons.school_outlined,
                color: Colors.purple.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Aprovadas',
                value: analytics['totalAprovadas'].toString(),
                icon: Icons.check_circle_outline,
                color: Colors.green.shade600,
              ),
            ),
          ],
        ),
      ],
    );
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
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onInfoTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onInfoTap,
      child: Card(
        margin: const EdgeInsets.all(8),
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 28, color: color),
                ],
              ),
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
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
