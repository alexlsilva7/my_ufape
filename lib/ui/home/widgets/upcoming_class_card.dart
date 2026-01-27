import 'package:flutter/material.dart';
import 'package:my_ufape/domain/entities/upcoming_class_data.dart';

/// Widget que exibe um card individual de próxima aula.
///
/// Mostra o badge de status (AGORA/Hoje/Amanhã/dia da semana),
/// nome da disciplina, horário, turma e sala.
class UpcomingClassCard extends StatelessWidget {
  final UpcomingClassData classData;
  final VoidCallback? onTap;

  const UpcomingClassCard({
    super.key,
    required this.classData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color =
        classData.isOngoing ? Colors.orange.shade700 : Colors.blue.shade600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _StatusIndicator(color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusBadge(
                    isOngoing: classData.isOngoing,
                    dayLabel: classData.dayLabel,
                    color: color,
                  ),
                  const SizedBox(height: 6),
                  _SubjectName(name: classData.subject.name),
                  const SizedBox(height: 6),
                  _ClassDetails(classData: classData, isDark: isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Indicador colorido lateral
class _StatusIndicator extends StatelessWidget {
  final Color color;

  const _StatusIndicator({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 78,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Badge de status (AGORA, Hoje, Amanhã, etc.)
class _StatusBadge extends StatelessWidget {
  final bool isOngoing;
  final String dayLabel;
  final Color color;

  const _StatusBadge({
    required this.isOngoing,
    required this.dayLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (isOngoing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 8, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'EM ANDAMENTO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        dayLabel.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Nome da disciplina
class _SubjectName extends StatelessWidget {
  final String name;

  const _SubjectName({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Detalhes da aula (horário, turma, sala)
class _ClassDetails extends StatelessWidget {
  final UpcomingClassData classData;
  final bool isDark;

  const _ClassDetails({
    required this.classData,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final greyColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Row(
      children: [
        const Icon(Icons.access_time, size: 14),
        const SizedBox(width: 6),
        Text(
          '${classData.slot.startTime} - ${classData.slot.endTime}',
          style: TextStyle(fontSize: 13, color: greyColor),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.person, size: 14),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            classData.subject.className.isNotEmpty
                ? classData.subject.className
                : classData.subject.status,
            style: TextStyle(fontSize: 12, color: greyColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.room, size: 14),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            classData.subject.room,
            style: TextStyle(fontSize: 13, color: greyColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
