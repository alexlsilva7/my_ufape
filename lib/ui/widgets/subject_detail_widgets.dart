import 'package:flutter/material.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/repositories/subject/subject_repository.dart';
import 'package:my_ufape/data/repositories/subject_note/subject_note_repository.dart';
import 'package:my_ufape/domain/entities/prerequisite.dart';
import 'package:my_ufape/domain/entities/subject.dart';
import 'package:my_ufape/ui/subjects/subjects_view_model.dart';
import 'package:result_dart/result_dart.dart';
import 'package:routefly/routefly.dart';

class Header extends StatelessWidget {
  const Header({super.key, required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context) {
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
}

class TypeBadge extends StatelessWidget {
  const TypeBadge({super.key, required this.type});

  final CourseType type;
  @override
  Widget build(BuildContext context) {
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.subject});

  final Subject subject;
  @override
  Widget build(BuildContext context) {
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
            InfoRow(
              icon: Icons.calendar_today,
              label: 'Período Sugerido',
              value: subject.period,
            ),
            const SizedBox(height: 12),
            InfoRow(
              icon: Icons.stars,
              label: 'Créditos',
              value: subject.credits.toString(),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkloadCard extends StatelessWidget {
  const WorkloadCard({super.key, required this.subject});
  final Subject subject;
  @override
  Widget build(BuildContext context) {
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
            WorkloadRow(label: 'Teórica', hours: subject.workload.teorica ?? 0),
            const SizedBox(height: 8),
            WorkloadRow(label: 'Prática', hours: subject.workload.pratica ?? 0),
            const SizedBox(height: 8),
            WorkloadRow(
                label: 'Extensão', hours: subject.workload.extensao ?? 0),
            const Divider(height: 20),
            WorkloadRow(
                label: 'Total',
                hours: subject.workload.total ?? 0,
                isTotal: true),
          ],
        ),
      ),
    );
  }
}

class WorkloadRow extends StatelessWidget {
  const WorkloadRow(
      {super.key,
      required this.label,
      required this.hours,
      this.isTotal = false});
  final String label;
  final int hours;
  final bool isTotal;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isTotal
        ? Theme.of(context).primaryColor
        : Theme.of(context).colorScheme.onSurface;

    final backgroundColor = isTotal
        ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
        : (isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade100);

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
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
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
                        .withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PrerequisitesCard extends StatefulWidget {
  const PrerequisitesCard({
    super.key,
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
    this.onTapDetail = false,
  });
  final String title;
  final List<Prerequisite> items;
  final IconData icon;
  final Color color;
  final bool onTapDetail;

  @override
  State<PrerequisitesCard> createState() => _PrerequisitesCardState();
}

class _PrerequisitesCardState extends State<PrerequisitesCard> {
  final subjectsRepository = injector.get<SubjectRepository>();
  final subjectNoteRepository = injector.get<SubjectNoteRepository>();

  Future<Subject?> _subjectExists(String name) async {
    Subject? subject;
    await subjectsRepository.getSubjectsByName(name).onSuccess((result) {
      if (result.isNotEmpty) {
        subject = result.first;
      }
    });

    return subject;
  }

  @override
  Widget build(BuildContext context) {
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
                Icon(widget.icon, size: 20, color: widget.color),
                const SizedBox(width: 8),
                Text(
                  widget.title,
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
              children: widget.items.map((item) {
                return GestureDetector(
                  onTap: widget.onTapDetail
                      ? () async {
                          if (item.name == null) return;
                          final subject = await _subjectExists(item.name!);
                          if (subject != null) {
                            Routefly.push(routePaths.subjects.subjectDetails,
                                arguments: EnrichedSubject(subject: subject));
                          } else {
                            if (mounted) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Matéria "${item.code}" não encontrada no catálogo.'),
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  child: Chip(
                    avatar: CircleAvatar(
                      backgroundColor: widget.color.withValues(alpha: 0.2),
                      child: Icon(Icons.book, size: 16, color: widget.color),
                    ),
                    label: Text(
                      '${item.code} - ${item.name}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: widget.color.withValues(alpha: 0.1),
                    side:
                        BorderSide(color: widget.color.withValues(alpha: 0.3)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class EmentaCard extends StatelessWidget {
  const EmentaCard({super.key, required this.subject});

  final Subject subject;
  @override
  Widget build(BuildContext context) {
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
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                subject.ementa,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.8),
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
