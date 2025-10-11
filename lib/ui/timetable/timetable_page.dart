import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/repositories/scheduled_subject/scheduled_subject_repository.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';
import 'package:my_ufape/domain/entities/time_table.dart';
import 'package:routefly/routefly.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  final ScheduledSubjectRepository _repository = injector.get();
  final SigaBackgroundService _sigaService = injector.get();

  List<ScheduledSubject> _subjects = [];
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _repository.getAllScheduledSubjects();

      result.fold(
        (subjects) {
          if (subjects.isEmpty) {
            // Se não houver disciplinas salvas, tenta sincronizar automaticamente
            _syncFromSiga();
          } else {
            setState(() {
              _subjects = subjects;
              _isLoading = false;
            });
          }
        },
        (error) {
          setState(() {
            _errorMessage = 'Erro ao carregar disciplinas: ${error.toString()}';
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _syncFromSiga() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
      _errorMessage = null;
    });

    try {
      final subjects = await _sigaService.navigateAndExtractTimetable();
      _sigaService.goToHome();

      setState(() {
        _subjects = subjects;
        _isLoading = false;
        _isSyncing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao sincronizar: ${e.toString()}';
        _isLoading = false;
        _isSyncing = false;
      });
    }
  }

  static const _dayOrder = [
    DayOfWeek.segunda,
    DayOfWeek.terca,
    DayOfWeek.quarta,
    DayOfWeek.quinta,
    DayOfWeek.sexta,
    DayOfWeek.sabado,
  ];

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDay(_subjects);
    final totalSubjects = _subjects.length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Grade de Horário'),
            if (totalSubjects > 0 && !_isLoading)
              Text(
                '$totalSubjects ${totalSubjects == 1 ? 'disciplina' : 'disciplinas'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          if (!_isLoading && !_isSyncing)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _syncFromSiga,
              tooltip: 'Sincronizar',
            ),
        ],
      ),
      body: _isLoading || _isSyncing
          ? _buildLoadingState(context)
          : _errorMessage != null
              ? _buildErrorState(context)
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _buildBody(context, grouped),
                ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            _isSyncing ? 'Sincronizando grade de horário...' : 'Carregando...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 72,
              color: Theme.of(context).colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            Text(
              'Erro ao carregar grade',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Erro desconhecido',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadSubjects,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, Map<DayOfWeek, List<ScheduledSubject>> grouped) {
    // If no subjects, show friendly empty state
    final hasAny = grouped.values.any((list) => list.isNotEmpty);
    if (!hasAny) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              'Nenhuma disciplina encontrada',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Clique no botão de sincronizar para buscar sua grade.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _syncFromSiga,
              icon: const Icon(Icons.sync),
              label: const Text('Sincronizar Grade'),
            ),
          ],
        ),
      );
    }

    // Build a responsive list of days - show only days that have classes
    final visibleDays =
        _dayOrder.where((d) => (grouped[d]?.isNotEmpty ?? false)).toList();

    // Always use list layout
    return ListView.separated(
      itemCount: visibleDays.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final day = visibleDays[index];
        return _DayColumn(day: day, subjects: grouped[day] ?? []);
      },
    );
  }

  Map<DayOfWeek, List<ScheduledSubject>> _groupByDay(
      List<ScheduledSubject> subjects) {
    final map = <DayOfWeek, List<ScheduledSubject>>{};
    for (final day in _dayOrder) {
      map[day] = [];
    }

    for (final subject in subjects) {
      for (final slot in subject.timeSlots) {
        if (map.containsKey(slot.day)) {
          // avoid duplicates in case a subject has multiple slots same day
          if (!map[slot.day]!.contains(subject)) {
            map[slot.day]!.add(subject);
          }
        }
      }
    }

    // Sort subjects by earliest start time for each day
    for (final day in map.keys) {
      map[day]!.sort((a, b) {
        // Get earliest start time for subject a
        final aSlotsForDay = a.timeSlots.where((s) => s.day == day).toList();
        final bSlotsForDay = b.timeSlots.where((s) => s.day == day).toList();

        if (aSlotsForDay.isEmpty && bSlotsForDay.isEmpty) return 0;
        if (aSlotsForDay.isEmpty) return 1;
        if (bSlotsForDay.isEmpty) return -1;

        // Sort to find earliest
        aSlotsForDay.sort((x, y) => x.startTime.compareTo(y.startTime));
        bSlotsForDay.sort((x, y) => x.startTime.compareTo(y.startTime));

        return aSlotsForDay.first.startTime
            .compareTo(bSlotsForDay.first.startTime);
      });
    }

    return map;
  }
}

class _DayColumn extends StatelessWidget {
  final DayOfWeek day;
  final List<ScheduledSubject> subjects;

  const _DayColumn({required this.day, required this.subjects});

  @override
  Widget build(BuildContext context) {
    final title = day.toShortString();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.1),
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
            Divider(height: 1, color: colorScheme.outline.withOpacity(0.1)),
            const SizedBox(height: 12),
            subjects.isEmpty
                ? SizedBox(
                    height: 60,
                    child: Center(
                      child: Text(
                        'Sem aulas',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  colorScheme.onSurfaceVariant.withOpacity(0.5),
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

class SubjectCard extends StatelessWidget {
  final ScheduledSubject subject;
  final List<TimeSlot> daySlots;

  const SubjectCard({required this.subject, required this.daySlots, super.key});

  String _getGroupedTimeText(List<TimeSlot> slots) {
    if (slots.isEmpty) return '';

    // Agrupar por dia
    final slotsByDay = <DayOfWeek, List<TimeSlot>>{};
    for (final slot in slots) {
      if (!slotsByDay.containsKey(slot.day)) {
        slotsByDay[slot.day] = [];
      }
      slotsByDay[slot.day]!.add(slot);
    }

    // Para cada dia, pegar o primeiro startTime e o último endTime
    final grouped = <String>[];
    for (final daySlots in slotsByDay.values) {
      if (daySlots.isEmpty) continue;

      // Ordenar por hora de início
      daySlots.sort((a, b) => a.startTime.compareTo(b.startTime));

      final firstStart = daySlots.first.startTime;
      final lastEnd = daySlots.last.endTime;
      grouped.add('$firstStart–$lastEnd');
    }

    return grouped.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final timesText = _getGroupedTimeText(daySlots);
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showDetails(context),
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
                      subject.name,
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
                          subject.code,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                        ),
                        Text(
                          ' • ',
                          style: TextStyle(
                            color:
                                colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                        ),
                        Text(
                          subject.className,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                        ),
                        Text(
                          ' • ',
                          style: TextStyle(
                            color:
                                colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            subject.room,
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
                            color: colorScheme.primary.withOpacity(0.7),
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
                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
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
                      color: colorScheme.onSurfaceVariant.withOpacity(0.3),
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
                          color: colorScheme.outline.withOpacity(0.1),
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
                            _buildSimpleChip(context, subject.code),
                            const SizedBox(width: 6),
                            _buildSimpleChip(context, subject.className),
                            const SizedBox(width: 6),
                            _buildSimpleChip(context, subject.room),
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
                            ..._buildGroupedTimeSlots(
                                context, subject.timeSlots, colorScheme),
                          ],
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

  List<Widget> _buildGroupedTimeSlots(
      BuildContext context, List<TimeSlot> slots, ColorScheme colorScheme) {
    // Agrupar por dia
    final slotsByDay = <DayOfWeek, List<TimeSlot>>{};
    for (final slot in slots) {
      if (!slotsByDay.containsKey(slot.day)) {
        slotsByDay[slot.day] = [];
      }
      slotsByDay[slot.day]!.add(slot);
    }

    // Criar widgets para cada dia
    final widgets = <Widget>[];
    for (final entry in slotsByDay.entries) {
      final day = entry.key;
      final daySlots = entry.value;

      if (daySlots.isEmpty) continue;

      // Ordenar por hora de início
      daySlots.sort((a, b) => a.startTime.compareTo(b.startTime));

      final firstStart = daySlots.first.startTime;
      final lastEnd = daySlots.last.endTime;

      widgets.add(
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
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
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

    return widgets;
  }

  Widget _buildSimpleChip(BuildContext context, String label) {
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
