import 'package:flutter/material.dart';
import 'package:my_ufape/domain/entities/subject.dart';
import 'package:my_ufape/ui/subjects/subjects_view_model.dart';
import 'package:my_ufape/ui/widgets/subject_detail_widgets.dart';

class EnrichedSubjectDetailsModal extends StatelessWidget {
  final EnrichedSubject enrichedSubject;

  const EnrichedSubjectDetailsModal({
    super.key,
    required this.enrichedSubject,
  });

  static void show(BuildContext context, EnrichedSubject enrichedSubject) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          EnrichedSubjectDetailsModal(enrichedSubject: enrichedSubject),
    );
  }

  Subject get subject => enrichedSubject.subject;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Header(subject: subject),
                    const SizedBox(height: 20),
                    TypeBadge(type: subject.type),
                    const SizedBox(height: 20),
                    if (enrichedSubject.completionNote != null) ...[
                      _GradesCard(enrichedSubject: enrichedSubject),
                      const SizedBox(height: 16),
                    ],
                    InfoCard(subject: subject),
                    const SizedBox(height: 16),
                    WorkloadCard(subject: subject),
                    const SizedBox(height: 16),
                    if (subject.prerequisites.isNotEmpty) ...[
                      PrerequisitesCard(
                          title: 'Pré-requisitos',
                          items: subject.prerequisites,
                          icon: Icons.lock_outline,
                          color: Colors.orange),
                      const SizedBox(height: 16),
                    ],
                    if (subject.corequisites.isNotEmpty) ...[
                      PrerequisitesCard(
                          title: 'Co-requisitos',
                          items: subject.corequisites,
                          icon: Icons.link,
                          color: Colors.blue),
                      const SizedBox(height: 16),
                    ],
                    if (subject.equivalences.isNotEmpty) ...[
                      PrerequisitesCard(
                          title: 'Equivalências',
                          items: subject.equivalences,
                          icon: Icons.swap_horiz,
                          color: Colors.purple),
                      const SizedBox(height: 16),
                    ],
                    if (subject.ementa.isNotEmpty) ...[
                      EmentaCard(subject: subject),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// This widget remains private as it's only used here.
class _GradesCard extends StatelessWidget {
  const _GradesCard({required this.enrichedSubject});

  final EnrichedSubject enrichedSubject;

  @override
  Widget build(BuildContext context) {
    final note = enrichedSubject.completionNote!;
    final color = enrichedSubject.isApproved
        ? Colors.green.shade700
        : (enrichedSubject.isFailed
            ? Colors.red.shade700
            : Colors.orange.shade700);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.grade_outlined, size: 20, color: color),
                const SizedBox(width: 8),
                Text('Desempenho Acadêmico',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),
            if (enrichedSubject.isFulfilledByEquivalence) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.purple.withValues(alpha: 0.3))),
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz,
                        color: Colors.purple.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Aprovado por equivalência com: ${note.nome}',
                        style: TextStyle(
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            InfoRow(
                icon: Icons.check_circle_outline,
                label: 'Situação',
                value: note.situacao),
            const SizedBox(height: 12),
            if (note.teacher.isNotEmpty) ...[
              InfoRow(
                  icon: Icons.person_outline,
                  label: 'Professor',
                  value: note.teacher),
              const SizedBox(height: 12),
            ],
            if (note.notas.isNotEmpty) ...[
              const Text('Notas:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: note.notas.entries
                    .map((entry) => Chip(
                          label: Text('${entry.key}: ${entry.value}',
                              style: const TextStyle(fontSize: 12)),
                        ))
                    .toList(),
              )
            ]
          ],
        ),
      ),
    );
  }
}
