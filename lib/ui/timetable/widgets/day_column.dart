import 'package:flutter/material.dart';
import 'package:my_ufape/domain/entities/time_table.dart';
import 'package:my_ufape/ui/timetable/widgets/subject_card.dart';

class DayColumn extends StatelessWidget {
  final DayOfWeek day;
  final List<ScheduledSubject> subjects;

  const DayColumn({super.key, required this.day, required this.subjects});

  @override
  Widget build(BuildContext context) {
    final title = day.toShortString();
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _fullDayName(day),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                  ),
                ),
                Text(
                  '${subjects.length}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(
                height: 1, color: colorScheme.outline.withValues(alpha: 0.1)),
            const SizedBox(height: 12),
            subjects.isEmpty
                ? SizedBox(
                    height: 60,
                    child: Center(
                      child: Text(
                        'Sem aulas',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                      ),
                    ),
                  )
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: subjects.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final subject = subjects[index];
                        final slots = subject.timeSlots
                            .where((s) => s.day == day)
                            .toList();
                        return SubjectCard(
                          subject: subject,
                          daySlots: slots,
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  String _fullDayName(DayOfWeek d) {
    switch (d) {
      case DayOfWeek.segunda:
        return 'Segunda-feira';
      case DayOfWeek.terca:
        return 'Terça-feira';
      case DayOfWeek.quarta:
        return 'Quarta-feira';
      case DayOfWeek.quinta:
        return 'Quinta-feira';
      case DayOfWeek.sexta:
        return 'Sexta-feira';
      case DayOfWeek.sabado:
        return 'Sábado';
      default:
        return '';
    }
  }
}
