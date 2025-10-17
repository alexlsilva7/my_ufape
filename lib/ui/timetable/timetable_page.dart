import 'package:flutter/material.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/domain/entities/time_table.dart';
import 'package:my_ufape/ui/timetable/timetable_view_model.dart';
import 'package:my_ufape/ui/timetable/widgets/day_column.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  TimetableViewModel viewModel = injector.get<TimetableViewModel>();

  final ScrollController _scrollController = ScrollController();
  final Map<DayOfWeek, GlobalKey> _dayKeys = {};

  @override
  void initState() {
    super.initState();
    for (var day in DayOfWeek.values) {
      _dayKeys[day] = GlobalKey();
    }
    viewModel.addListener(_onVmChanged);
    viewModel.loadSubjects();
  }

  @override
  void dispose() {
    viewModel.removeListener(_onVmChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onVmChanged() {
    if (mounted) {
      setState(() {
        // Se o carregamento terminou e não há erros, chama a função de rolagem
        if (!viewModel.isLoading && viewModel.errorMessage == null) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToCurrentDay());
        }
      });
    }
  }

  void _scrollToCurrentDay() {
    final today = DateTime.now();
    final currentDayOfWeek = DayOfWeek.fromDateTimeWeekday(today.weekday);

    final key = _dayKeys[currentDayOfWeek];
    final context = key?.currentContext;

    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.05, // Alinha um pouco antes do topo da tela
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = viewModel.groupByDay();
    final totalSubjects = viewModel.subjects.length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Grade de Horário'),
            if (totalSubjects > 0 && !viewModel.isLoading)
              Text(
                '$totalSubjects ${totalSubjects == 1 ? 'disciplina' : 'disciplinas'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          if (!viewModel.isLoading && !viewModel.isSyncing)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: viewModel.syncFromSiga,
              tooltip: 'Sincronizar',
            ),
        ],
      ),
      body: viewModel.isLoading || viewModel.isSyncing
          ? TimetableLoading(isSyncing: viewModel.isSyncing)
          : viewModel.errorMessage != null
              ? TimetableError(
                  message: viewModel.errorMessage,
                  onRetry: viewModel.syncFromSiga,
                )
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: TimetableBody(
                    grouped: grouped,
                    viewModel: viewModel,
                    scrollController: _scrollController,
                    dayKeys: _dayKeys,
                  ),
                ),
    );
  }
}

class TimetableLoading extends StatelessWidget {
  final bool isSyncing;
  const TimetableLoading({required this.isSyncing, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            isSyncing ? 'Sincronizando grade de horário...' : 'Carregando...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class TimetableError extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const TimetableError(
      {required this.message, required this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 72,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
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
              message ?? 'Erro desconhecido',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class TimetableBody extends StatelessWidget {
  final Map<DayOfWeek, List<ScheduledSubject>> grouped;
  final TimetableViewModel viewModel;
  final ScrollController scrollController;
  final Map<DayOfWeek, GlobalKey> dayKeys;

  const TimetableBody(
      {required this.grouped,
      required this.viewModel,
      required this.scrollController,
      required this.dayKeys,
      super.key});

  @override
  Widget build(BuildContext context) {
    final hasAny = grouped.values.any((list) => list.isNotEmpty);
    if (!hasAny) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 72,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
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
                        .withValues(alpha: 0.5),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: viewModel.syncFromSiga,
              icon: const Icon(Icons.sync),
              label: const Text('Sincronizar Grade'),
            ),
          ],
        ),
      );
    }

    final visibleDays = TimetableViewModel.dayOrder
        .where((d) => (grouped[d]?.isNotEmpty ?? false))
        .toList();

    final today = DateTime.now();
    final currentDay = DayOfWeek.fromDateTimeWeekday(today.weekday);

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: visibleDays.map((day) {
          final isToday = day == currentDay;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: DayColumn(
              key: dayKeys[day],
              day: day,
              subjects: grouped[day] ?? [],
              isToday: isToday,
            ),
          );
        }).toList(),
      ),
    );
  }
}
