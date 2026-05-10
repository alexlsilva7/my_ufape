import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_ufape/domain/entities/teaching_plan.dart';

class TeachingPlanCard extends StatefulWidget {
  final TeachingPlan plan;

  const TeachingPlanCard({super.key, required this.plan});

  @override
  State<TeachingPlanCard> createState() => _TeachingPlanCardState();
}

class _TeachingPlanCardState extends State<TeachingPlanCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Ordenar tópicos por data, nulos por último
    final sortedTopics = List<ClassTopic>.from(widget.plan.topics)
      ..sort((a, b) {
        if (a.date == null && b.date == null) return 0;
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        return a.date!.compareTo(b.date!);
      });

    // Data de hoje (ignorando hora)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Filtrar tópicos futuros (incluindo hoje) ou sem data
    final upcomingTopics = sortedTopics.where((t) {
      if (t.date == null)
        return true; // Mostra sem data também? Assumindo que sim.
      return t.date!.isAfter(today) || t.date!.isAtSameMomentAs(today);
    }).toList();

    // Limitar visualização inicial se não expandido
    // Se minimizado: mostra apenas os próximos 3 (filtrado)
    // Se expandido: mostra TUDO (histórico completo)
    final displayTopics =
        _isExpanded ? sortedTopics : upcomingTopics.take(3).toList();

    // Tem mais se:
    // 1. A lista filtrada tem mais que 3 (então tem mais futuros escondidos)
    // 2. OU se a lista completa é maior que a lista filtrada (então tem passados escondidos)
    // Simplificando: se a lista de exibição é menor que a lista total
    final hasMore = sortedTopics.length > displayTopics.length;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.calendar_month_outlined,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('Plano de Ensino',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (hasMore)
                  TextButton(
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                    child: Text(_isExpanded ? 'Ver menos' : 'Ver tudo'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayTopics.length,
            separatorBuilder: (_, __) =>
                const Divider(indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final topic = displayTopics[index];
              return ListTile(
                leading: _buildDateBadge(context, topic.date),
                title: Text(
                  topic.content,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
                subtitle: topic.type != null
                    ? Text(
                        topic.type!.toUpperCase(),
                        style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.secondary),
                      )
                    : null,
                dense: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateBadge(BuildContext context, DateTime? date) {
    if (date == null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.access_time, size: 16, color: Colors.grey),
      );
    }

    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('dd').format(date),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          Text(
            DateFormat('MMM').format(date).toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
