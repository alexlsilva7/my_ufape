import 'package:flutter/material.dart';
import 'package:my_ufape/domain/entities/time_table.dart';
import 'package:my_ufape/ui/timetable/widgets/subject_card.dart';

class DayColumn extends StatefulWidget {
  final DayOfWeek day;
  final List<ScheduledSubject> subjects;
  final bool isToday;

  const DayColumn({
    super.key,
    required this.day,
    required this.subjects,
    this.isToday = false,
  });

  @override
  State<DayColumn> createState() => _DayColumnState();
}

class _DayColumnState extends State<DayColumn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blinkController;
  // control finite number of blinks (forward+reverse = 1 cycle)
  int _cycles = 0;
  final int _maxCycles = 4;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _blinkController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // reached highlight -> reverse to original
        _blinkController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        // completed a full cycle (forward+reverse)
        _cycles++;
        if (_cycles < _maxCycles) {
          _blinkController.forward();
        }
      }
    });

    if (widget.isToday) {
      _cycles = 0;
      _blinkController.forward();
    } else {
      _blinkController.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(covariant DayColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isToday &&
        !_blinkController.isAnimating &&
        _cycles >= _maxCycles) {
      // restart finite blinking if day became today again
      _cycles = 0;
      _blinkController.forward();
    } else if (widget.isToday &&
        !_blinkController.isAnimating &&
        _cycles == 0) {
      _blinkController.forward();
    } else if (!widget.isToday && _blinkController.isAnimating) {
      // stop and restore original border
      _blinkController.stop();
      _blinkController.value = 0.0;
      _cycles = 0;
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.day.toShortString();
    final colorScheme = Theme.of(context).colorScheme;

    // Visual tweaks when it's the current day
    final cardElevation = widget.isToday ? 4.0 : 0.0;
    final baseBorderColor = widget.isToday
        ? colorScheme.primary
        : colorScheme.outline.withValues(alpha: 0.1);
    final highlightColor = colorScheme.primary.withValues(alpha: 0.24);
    final backgroundColor =
        widget.isToday ? colorScheme.primary.withValues(alpha: 0.06) : null;

    // Use AnimatedBuilder to animate border color only when isToday
    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, child) {
        final borderColor = widget.isToday
            ? Color.lerp(
                baseBorderColor, highlightColor, _blinkController.value)!
            : baseBorderColor;

        return Card(
          margin: EdgeInsets.zero,
          elevation: cardElevation,
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: borderColor,
              width: widget.isToday ? 1.6 : 1,
            ),
          ),
          child: child,
        );
      },
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
                    _fullDayName(widget.day),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: widget.isToday
                              ? colorScheme.onSurface
                              : null, // subtle emphasis
                        ),
                  ),
                ),
                if (widget.isToday) ...[
                  const SizedBox(width: 8),
                  // Keep HOJE badge stable (no opacity animation), border will blink
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'HOJE',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                    ),
                  )
                ],
                if (!widget.isToday)
                  Text(
                    '${widget.subjects.length}',
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
                height: 1,
                color: widget.isToday
                    ? colorScheme.primary.withValues(alpha: 0.12)
                    : colorScheme.outline.withValues(alpha: 0.1)),
            const SizedBox(height: 12),
            widget.subjects.isEmpty
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
                      itemCount: widget.subjects.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final subject = widget.subjects[index];
                        final slots = subject.timeSlots
                            .where((s) => s.day == widget.day)
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
