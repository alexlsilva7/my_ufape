import 'package:flutter/material.dart';
import 'package:my_ufape/domain/entities/subject.dart';
import 'package:my_ufape/ui/widgets/subject_detail_widgets.dart';

class SubjectDetailsModal extends StatelessWidget {
  final Subject subject;

  const SubjectDetailsModal({
    super.key,
    required this.subject,
  });

  static void show(BuildContext context, Subject subject) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SubjectDetailsModal(subject: subject),
    );
  }

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
              // Handle bar
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
                    // Cabeçalho com código e nome
                    Header(subject: subject),
                    const SizedBox(height: 20),

                    // Badge do tipo
                    TypeBadge(type: subject.type),
                    const SizedBox(height: 20),

                    // Informações básicas
                    InfoCard(subject: subject),
                    const SizedBox(height: 16),

                    // Carga horária
                    WorkloadCard(subject: subject),
                    const SizedBox(height: 16),

                    // Pré-requisitos
                    if (subject.prerequisites.isNotEmpty) ...[
                      PrerequisitesCard(
                        title: 'Pré-requisitos',
                        items: subject.prerequisites,
                        icon: Icons.lock_outline,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Co-requisitos
                    if (subject.corequisites.isNotEmpty) ...[
                      PrerequisitesCard(
                        title: 'Co-requisitos',
                        items: subject.corequisites,
                        icon: Icons.link,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Equivalências
                    if (subject.equivalences.isNotEmpty) ...[
                      PrerequisitesCard(
                        title: 'Equivalências',
                        items: subject.equivalences,
                        icon: Icons.swap_horiz,
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Ementa
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
