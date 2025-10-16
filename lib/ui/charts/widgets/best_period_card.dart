import 'package:flutter/material.dart';
import 'package:my_ufape/domain/entities/subject_note.dart';
import 'package:my_ufape/ui/charts/charts_explanations.dart';
import 'package:my_ufape/ui/charts/widgets/info_dialog.dart';

class BestPeriodCard extends StatelessWidget {
  final List<Map<String, dynamic>> periodMedias;
  final List<Map<String, dynamic>> periodosData;

  const BestPeriodCard(
      {super.key, required this.periodMedias, required this.periodosData});

  @override
  Widget build(BuildContext context) {
    // Período com maior média
    final best = periodMedias.reduce(
        (a, b) => (a['media'] as double) > (b['media'] as double) ? a : b);

    // Período com mais disciplinas aprovadas
    Map<String, dynamic>? periodWithMostApproved;
    int maxApproved = 0;

    for (final p in periodosData) {
      final disciplinas =
          (p['disciplinas'] as List<dynamic>).cast<SubjectNote>();
      final approved = disciplinas
          .where((d) => d.situacao.toUpperCase().contains('APROVADO'))
          .length;
      if (approved > maxApproved) {
        maxApproved = approved;
        periodWithMostApproved = p;
      }
    }

    final approvedCount = maxApproved;

    return GestureDetector(
      onTap: () => showInfoDialog(
        context,
        melhorPeriodoMarkdown,
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
                  Icon(Icons.star, color: Colors.amber.shade700, size: 26),
                  const SizedBox(width: 10),
                  Text(
                    'Melhor Período Acadêmico',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
                        color: Colors.amber.shade600.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.amber.shade600.withValues(alpha: 0.3),
                        ),
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
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
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
                        color: Colors.blue.shade600.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.blue.shade600.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            periodWithMostApproved?['nome'] as String? ?? '',
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
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
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
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
