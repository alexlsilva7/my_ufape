import 'package:flutter/material.dart';
import 'package:my_ufape/domain/entities/subject.dart';
import 'package:my_ufape/domain/entities/prerequisite.dart';

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
                    _buildHeader(context),
                    const SizedBox(height: 20),

                    // Badge do tipo
                    _buildTypeBadge(subject.type),
                    const SizedBox(height: 20),

                    // Informações básicas
                    _buildInfoCard(context),
                    const SizedBox(height: 16),

                    // Carga horária
                    _buildWorkloadCard(context),
                    const SizedBox(height: 16),

                    // Pré-requisitos
                    if (subject.prerequisites.isNotEmpty) ...[
                      _buildPrerequisitesCard(
                        context,
                        'Pré-requisitos',
                        subject.prerequisites,
                        Icons.lock_outline,
                        Colors.orange,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Co-requisitos
                    if (subject.corequisites.isNotEmpty) ...[
                      _buildPrerequisitesCard(
                        context,
                        'Co-requisitos',
                        subject.corequisites,
                        Icons.link,
                        Colors.blue,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Equivalências
                    if (subject.equivalences.isNotEmpty) ...[
                      _buildPrerequisitesCard(
                        context,
                        'Equivalências',
                        subject.equivalences,
                        Icons.swap_horiz,
                        Colors.purple,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Ementa
                    if (subject.ementa.isNotEmpty) ...[
                      _buildEmentaCard(context),
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

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subject.code,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subject.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildTypeBadge(CourseType type) {
    Color color;
    IconData icon;

    switch (type) {
      case CourseType.obrigatorio:
        color = Colors.red;
        icon = Icons.star;
        break;
      case CourseType.optativo:
        color = Colors.blue;
        icon = Icons.check_circle_outline;
        break;
      case CourseType.eletivo:
        color = Colors.green;
        icon = Icons.extension;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            type.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
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
                Icon(Icons.info_outline,
                    size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Informações Gerais',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildInfoRow(
              Icons.calendar_today,
              'Período Sugerido',
              subject.period,
              context,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.stars,
              'Créditos',
              subject.credits.toString(),
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkloadCard(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, size: 20, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Carga Horária',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildWorkloadRow(
                'Teórica', subject.workload.teorica ?? 0, context),
            const SizedBox(height: 8),
            _buildWorkloadRow(
                'Prática', subject.workload.pratica ?? 0, context),
            const SizedBox(height: 8),
            _buildWorkloadRow(
                'Extensão', subject.workload.extensao ?? 0, context),
            const Divider(height: 20),
            _buildWorkloadRow('Total', subject.workload.total ?? 0, context,
                isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkloadRow(String label, int hours, BuildContext context,
      {bool isTotal = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isTotal
        ? Theme.of(context).primaryColor
        : Theme.of(context).colorScheme.onSurface;

    final backgroundColor = isTotal
        ? Theme.of(context).primaryColor.withOpacity(0.1)
        : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${hours}h',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Text(
                '$label: ',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrerequisitesCard(
    BuildContext context,
    String title,
    List<Prerequisite> items,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor: color.withOpacity(0.2),
                    child: Icon(Icons.book, size: 16, color: color),
                  ),
                  label: Text(
                    '${item.code} - ${item.name}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: color.withOpacity(0.1),
                  side: BorderSide(color: color.withOpacity(0.3)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmentaCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description_outlined,
                    size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Ementa',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                subject.ementa,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
