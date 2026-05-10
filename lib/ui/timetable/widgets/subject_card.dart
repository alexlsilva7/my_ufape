import 'package:flutter/material.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/repositories/subject/subject_repository.dart';
import 'package:my_ufape/data/repositories/subject_note/subject_note_repository.dart';
import 'package:my_ufape/domain/entities/subject.dart';
import 'package:my_ufape/domain/entities/time_table.dart';
import 'package:my_ufape/ui/subjects/subjects_view_model.dart';
import 'package:my_ufape/data/repositories/teaching_plan/teaching_plan_repository.dart';
import 'package:my_ufape/domain/entities/teaching_plan.dart';
import 'package:routefly/routefly.dart';

class SubjectCard extends StatefulWidget {
  final ScheduledSubject subject;
  final List<TimeSlot> daySlots;

  const SubjectCard({required this.subject, required this.daySlots, super.key});

  static void showDetailsForScheduleSubject(BuildContext context,
      {required ScheduledSubject subject}) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            SimpleChip(label: subject.code),
                            const SizedBox(width: 6),
                            SimpleChip(label: subject.className),
                            const SizedBox(width: 6),
                            SimpleChip(label: subject.room),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status: ${subject.status}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                          if (subject.timeSlots.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text(
                              'Horários',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            GroupedTimeSlots(slots: subject.timeSlots),
                          ],
                          _TeachingPlanContent(subjectCode: subject.code),
                          const SizedBox(height: 20),
                          OutlinedButton(
                            onPressed: () async {
                              final subjectFind =
                                  await _subjectExists(subject.name);
                              if (subjectFind != null) {
                                Routefly.push(
                                    routePaths.subjects.subjectDetails,
                                    arguments:
                                        EnrichedSubject(subject: subjectFind));
                              } else {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Matéria "${subject.name}" não encontrada.'),
                                  ),
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40),
                              side: BorderSide(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            child: const Text('Ver disciplina'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> {
  String _getGroupedTimeText(List<TimeSlot> slots) {
    if (slots.isEmpty) return '';

    final slotsByDay = <DayOfWeek, List<TimeSlot>>{};
    for (final slot in slots) {
      slotsByDay.putIfAbsent(slot.day, () => []).add(slot);
    }

    final grouped = <String>[];
    for (final daySlots in slotsByDay.values) {
      if (daySlots.isEmpty) continue;
      daySlots.sort((a, b) => a.startTime.compareTo(b.startTime));
      final firstStart = daySlots.first.startTime;
      final lastEnd = daySlots.last.endTime;
      grouped.add('$firstStart–$lastEnd');
    }

    return grouped.join(', ');
  }

  final subjectsRepository = injector.get<SubjectRepository>();
  final subjectNoteRepository = injector.get<SubjectNoteRepository>();

  @override
  Widget build(BuildContext context) {
    final timesText = _getGroupedTimeText(widget.daySlots);
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => SubjectCard.showDetailsForScheduleSubject(context,
            subject: widget.subject),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.subject.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          widget.subject.code,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                        ),
                        Text(
                          ' • ',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        Text(
                          widget.subject.className,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                        ),
                        Text(
                          ' • ',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.subject.room,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (timesText.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: colorScheme.primary.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timesText,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<Subject?> _subjectExists(String name) async {
  Subject? subject;
  (await injector.get<SubjectRepository>().getSubjectsByName(name))
      .onSuccess((result) {
    if (result.isNotEmpty) {
      subject = result.first;
    }
  });

  return subject;
}

class SimpleChip extends StatelessWidget {
  final String label;
  const SimpleChip({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 11,
            ),
      ),
    );
  }
}

class GroupedTimeSlots extends StatelessWidget {
  final List<TimeSlot> slots;
  const GroupedTimeSlots({required this.slots, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final slotsByDay = <DayOfWeek, List<TimeSlot>>{};
    for (final slot in slots) {
      slotsByDay.putIfAbsent(slot.day, () => []).add(slot);
    }

    final children = <Widget>[];
    for (final entry in slotsByDay.entries) {
      final day = entry.key;
      final daySlots = entry.value;
      if (daySlots.isEmpty) continue;

      daySlots.sort((a, b) => a.startTime.compareTo(b.startTime));
      final firstStart = daySlots.first.startTime;
      final lastEnd = daySlots.last.endTime;

      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  day.toShortString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.schedule,
                size: 14,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                '$firstStart – $lastEnd',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _TeachingPlanContent extends StatelessWidget {
  final String subjectCode;

  const _TeachingPlanContent({required this.subjectCode});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TeachingPlan?>(
      future: injector.get<TeachingPlanRepository>().getBySubject(subjectCode),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final plan = snapshot.data!;
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);

        // Verifica se há aula hoje
        final topic = plan.topics.cast<ClassTopic?>().firstWhere(
              (t) => t?.date != null && t!.date!.isAtSameMomentAs(todayDate),
              orElse: () => null,
            );

        if (topic == null) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Aula de Hoje',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                topic.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      },
    );
  }
}
