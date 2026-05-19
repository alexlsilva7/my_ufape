import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/ui/timetable_builder/timetable_builder_view_model.dart';
import 'package:my_ufape/domain/entities/time_table.dart';

class TimetableBuilderPage extends StatefulWidget {
  const TimetableBuilderPage({super.key});

  @override
  State<TimetableBuilderPage> createState() => _TimetableBuilderPageState();
}

class _TimetableBuilderPageState extends State<TimetableBuilderPage> {
  final TimetableBuilderViewModel _viewModel = injector.get();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.first.bytes != null) {
      await _viewModel.processSchedulePdf(result.files.first.bytes!);
    }
  }

  Future<void> _saveGrade() async {
    if (_viewModel.selectedClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione disciplinas antes de salvar.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.save_outlined, size: 36),
        title: const Text('Salvar Grade'),
        content: Text(
          'Isso substituirá sua grade de horário atual por '
          '${_viewModel.selectedClasses.length} disciplina(s) selecionada(s).\n\n'
          'Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await _viewModel.saveToDatabase();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Grade salva com sucesso!'
                : _viewModel.errorMessage ?? 'Erro ao salvar.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Montador de Grade'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: _viewModel.isLoading ? null : _pickPdf,
              tooltip: 'Importar PDF de Horários',
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.list_alt, size: 20),
                text:
                    'Ofertas${_viewModel.allClasses.isNotEmpty ? ' (${_viewModel.allClasses.length})' : ''}',
              ),
              Tab(
                icon: const Icon(Icons.calendar_month, size: 20),
                text:
                    'Minha Grade${_viewModel.selectedClasses.isNotEmpty ? ' (${_viewModel.selectedClasses.length})' : ''}',
              ),
            ],
          ),
        ),
        body: _viewModel.isLoading
            ? const _LoadingState()
            : _viewModel.allClasses.isEmpty
                ? const _EmptyState()
                : TabBarView(
                    children: [
                      _AvailableClassesTab(
                        viewModel: _viewModel,
                        isDark: isDark,
                        colorScheme: colorScheme,
                      ),
                      _SelectedClassesTab(
                        viewModel: _viewModel,
                        isDark: isDark,
                        colorScheme: colorScheme,
                        onSave: _saveGrade,
                      ),
                    ],
                  ),
        floatingActionButton: _viewModel.allClasses.isEmpty
            ? FloatingActionButton.extended(
                onPressed: _pickPdf,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Importar PDF'),
              )
            : null,
      ),
    );
  }
}

// ─── ESTADOS ────────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Analisando PDF com IA...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Isso pode levar alguns segundos',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_fix_high,
              size: 80,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'Monte sua Grade Ideal',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Importe o PDF de oferta de horários da UFAPE e a IA vai extrair todas as disciplinas para você montar sua grade sem conflitos.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ABA 1: OFERTAS ─────────────────────────────────────────────────────────

class _AvailableClassesTab extends StatelessWidget {
  final TimetableBuilderViewModel viewModel;
  final bool isDark;
  final ColorScheme colorScheme;

  const _AvailableClassesTab({
    required this.viewModel,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final classes = viewModel.availableClasses;

    return Column(
      children: [
        // Filtro de períodos
        if (viewModel.availablePeriods.length > 1)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Todos'),
                  selected: viewModel.selectedPeriodFilter == null,
                  onSelected: (_) => viewModel.setFilter(null),
                ),
                const SizedBox(width: 8),
                ...viewModel.availablePeriods.map((period) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('$periodº Período'),
                      selected: viewModel.selectedPeriodFilter == period,
                      onSelected: (_) => viewModel.setFilter(
                        viewModel.selectedPeriodFilter == period
                            ? null
                            : period,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        // Erro
        if (viewModel.errorMessage != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        // Lista
        Expanded(
          child: classes.isEmpty
              ? Center(
                  child: Text(
                    'Nenhuma disciplina encontrada para esse filtro.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: classes.length,
                  itemBuilder: (ctx, index) {
                    final c = classes[index];
                    final isAdded = viewModel.isSelected(c);
                    final conflict = viewModel.checkConflict(c);
                    final isPassed = viewModel.isPassed(c);

                    return _ClassCard(
                      aClass: c,
                      isAdded: isAdded,
                      isPassed: isPassed,
                      conflictMessage: isAdded ? null : conflict,
                      isDark: isDark,
                      colorScheme: colorScheme,
                      onAdd: () {
                        try {
                          viewModel.addClass(c);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${c.subjectName} adicionada!'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      onRemove: () => viewModel.removeClass(c),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─── ABA 2: MINHA GRADE ─────────────────────────────────────────────────────

class _SelectedClassesTab extends StatelessWidget {
  final TimetableBuilderViewModel viewModel;
  final bool isDark;
  final ColorScheme colorScheme;
  final VoidCallback onSave;

  const _SelectedClassesTab({
    required this.viewModel,
    required this.isDark,
    required this.colorScheme,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    if (viewModel.selectedClasses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_note_outlined,
                size: 72,
                color: colorScheme.primary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhuma disciplina selecionada',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vá para a aba "Ofertas" e adicione disciplinas à sua grade.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final grouped = viewModel.groupByDay();
    final visibleDays = TimetableBuilderViewModel.dayOrder
        .where((d) => (grouped[d]?.isNotEmpty ?? false))
        .toList();

    final today = DateTime.now();
    final currentDay = DayOfWeek.fromDateTimeWeekday(today.weekday);

    return Column(
      children: [
        // Lista de selecionadas
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: visibleDays.map((day) {
                final isToday = day == currentDay;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _BuilderDayColumn(
                    day: day,
                    classes: grouped[day] ?? [],
                    isToday: isToday,
                    colorScheme: colorScheme,
                    onRemove: (c) => viewModel.removeClass(c),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Botão Salvar
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: viewModel.isSaving ? null : onSave,
            icon: viewModel.isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(viewModel.isSaving
                ? 'Salvando...'
                : 'Salvar Grade (${viewModel.selectedClasses.length})'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── WIDGETS DE APOIO ───────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _ClassCard extends StatelessWidget {
  final AvailableClass aClass;
  final bool isAdded;
  final bool isPassed;
  final String? conflictMessage;
  final bool isDark;
  final ColorScheme colorScheme;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _ClassCard({
    required this.aClass,
    required this.isAdded,
    this.isPassed = false,
    required this.conflictMessage,
    required this.isDark,
    required this.colorScheme,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasConflict = conflictMessage != null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isAdded
            ? BorderSide(color: Colors.green.withValues(alpha: 0.5), width: 1.5)
            : hasConflict
                ? BorderSide(
                    color: Colors.orange.withValues(alpha: 0.4), width: 1)
                : BorderSide.none,
      ),
      child: Opacity(
        opacity: isPassed && !isAdded ? 0.6 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Text(
                              aClass.subjectName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                decoration: isPassed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (isPassed)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Já Aprovado',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (aClass.professor.isNotEmpty)
                          _InfoRow(
                              icon: Icons.person_outline,
                              text: aClass.professor),
                        _InfoRow(
                          icon: Icons.groups_outlined,
                          text:
                              'Turma: ${aClass.className} | ${aClass.period}º Período',
                        ),
                        if (aClass.room.isNotEmpty)
                          _InfoRow(
                              icon: Icons.room_outlined, text: aClass.room),
                        if (aClass.localSubjectData != null)
                          _InfoRow(
                            icon: Icons.star_outline,
                            text:
                                '${aClass.localSubjectData!.credits} créditos | ${aClass.localSubjectData!.type}',
                          ),
                      ],
                    ),
                  ),
                  isAdded
                      ? IconButton(
                          icon: const Icon(Icons.check_circle,
                              color: Colors.green),
                          onPressed: onRemove,
                          tooltip: 'Remover',
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.add_circle,
                            color: hasConflict ? Colors.orange : Colors.green,
                          ),
                          onPressed: hasConflict ? null : onAdd,
                          tooltip: hasConflict ? conflictMessage : 'Adicionar',
                        ),
                ],
              ),
              // Horários
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: aClass.schedules.map((s) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          colorScheme.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${_dayLabel(s.day)} ${s.start}-${s.end}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (hasConflict) ...[
                const SizedBox(height: 6),
                Text(
                  '⚠ $conflictMessage',
                  style: const TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _dayLabel(String day) {
    switch (day.toLowerCase()) {
      case 'segunda':
        return 'SEG';
      case 'terca':
        return 'TER';
      case 'quarta':
        return 'QUA';
      case 'quinta':
        return 'QUI';
      case 'sexta':
        return 'SEX';
      case 'sabado':
        return 'SÁB';
      default:
        return day.toUpperCase();
    }
  }
}

class _BuilderDayColumn extends StatelessWidget {
  final DayOfWeek day;
  final List<AvailableClass> classes;
  final bool isToday;
  final ColorScheme colorScheme;
  final Function(AvailableClass) onRemove;

  const _BuilderDayColumn({
    required this.day,
    required this.classes,
    this.isToday = false,
    required this.colorScheme,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final title = day.toShortString();
    
    final cardElevation = isToday ? 4.0 : 0.0;
    final baseBorderColor = isToday
        ? colorScheme.primary
        : colorScheme.outline.withValues(alpha: 0.1);
    final backgroundColor =
        isToday ? colorScheme.primary.withValues(alpha: 0.06) : null;

    return Card(
      margin: EdgeInsets.zero,
      elevation: cardElevation,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: baseBorderColor,
          width: isToday ? 1.6 : 1,
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
                          color: isToday
                              ? colorScheme.onSurface
                              : null,
                        ),
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(width: 8),
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
                if (!isToday)
                  Text(
                    '${classes.length}',
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
                color: isToday
                    ? colorScheme.primary.withValues(alpha: 0.12)
                    : colorScheme.outline.withValues(alpha: 0.1)),
            const SizedBox(height: 12),
            classes.isEmpty
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
                    constraints: const BoxConstraints(maxHeight: 1200),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: classes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final c = classes[index];
                        return _BuilderSubjectCard(
                          aClass: c,
                          day: day,
                          colorScheme: colorScheme,
                          onRemove: () => onRemove(c),
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

class _BuilderSubjectCard extends StatelessWidget {
  final AvailableClass aClass;
  final DayOfWeek day;
  final ColorScheme colorScheme;
  final VoidCallback onRemove;

  const _BuilderSubjectCard({
    required this.aClass,
    required this.day,
    required this.colorScheme,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final daySchedules = aClass.schedules.where((s) => s.day.toLowerCase() == _dayString(day)).toList();
    daySchedules.sort((a, b) => a.start.compareTo(b.start));
    
    final timesText = daySchedules.map((s) => '${s.start}–${s.end}').join(', ');
    final subjectCode = aClass.localSubjectData?.code ?? aClass.subjectCode;

    return Material(
      color: Colors.transparent,
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
                    aClass.subjectName,
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
                      if (subjectCode.isNotEmpty) ...[
                        Text(
                          subjectCode,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                        ),
                        Text(
                          ' • ',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                      Text(
                        aClass.className,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                      ),
                      Text(
                        ' • ',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          aClass.room,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: onRemove,
              tooltip: 'Remover',
            ),
          ],
        ),
      ),
    );
  }

  String _dayString(DayOfWeek d) {
    switch (d) {
      case DayOfWeek.segunda: return 'segunda';
      case DayOfWeek.terca: return 'terca';
      case DayOfWeek.quarta: return 'quarta';
      case DayOfWeek.quinta: return 'quinta';
      case DayOfWeek.sexta: return 'sexta';
      case DayOfWeek.sabado: return 'sabado';
      default: return '';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon,
              size: 14,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
