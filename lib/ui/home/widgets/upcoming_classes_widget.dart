import 'package:flutter/material.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/services/upcoming_classes/upcoming_classes_service.dart';
import 'package:my_ufape/domain/entities/upcoming_class_data.dart';
import 'package:my_ufape/ui/home/widgets/upcoming_class_card.dart';
import 'package:my_ufape/ui/timetable/widgets/subject_card.dart';

/// Widget completo que exibe a seção de próximas aulas.
///
/// Inclui título, botão de atualização e lista de cards.
/// Gerencia estados de loading, empty e populated.
class UpcomingClassesWidget extends StatefulWidget {
  /// Número máximo de aulas a exibir
  final int limit;

  /// Callback quando uma aula é clicada (opcional)
  /// Se não fornecido, abre o diálogo de detalhes padrão
  final void Function(UpcomingClassData)? onClassTap;

  /// Se deve mostrar o título da seção
  final bool showTitle;

  /// Se deve mostrar o botão de atualização
  final bool showRefreshButton;

  const UpcomingClassesWidget({
    super.key,
    this.limit = 3,
    this.onClassTap,
    this.showTitle = true,
    this.showRefreshButton = true,
  });

  @override
  State<UpcomingClassesWidget> createState() => _UpcomingClassesWidgetState();
}

class _UpcomingClassesWidgetState extends State<UpcomingClassesWidget> {
  final UpcomingClassesService _service =
      injector.get<UpcomingClassesService>();

  List<UpcomingClassData> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);

    final result = await _service.getUpcomingClasses(limit: widget.limit);

    if (mounted) {
      result.fold(
        (classes) {
          setState(() {
            _classes = classes;
            _isLoading = false;
          });
        },
        (_) {
          setState(() {
            _classes = [];
            _isLoading = false;
          });
        },
      );
    }
  }

  void _handleClassTap(UpcomingClassData classData) {
    if (widget.onClassTap != null) {
      widget.onClassTap!(classData);
    } else {
      // Comportamento padrão: abre diálogo de detalhes
      SubjectCard.showDetailsForScheduleSubject(
        context,
        subject: classData.subject,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _SectionTitle()),
              if (widget.showRefreshButton)
                _RefreshButton(
                  onPressed: _loadClasses,
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const _LoadingState();
    }

    if (_classes.isEmpty) {
      return const _EmptyState();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _classes
          .map((classData) => UpcomingClassCard(
                classData: classData,
                onTap: () => _handleClassTap(classData),
              ))
          .toList(),
    );
  }
}

/// Título da seção
class _SectionTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 22,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 6),
        const Text(
          'Próximas Aulas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Botão de atualização
class _RefreshButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _RefreshButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.refresh,
        size: 20,
        color: Theme.of(context).primaryColor,
      ),
      onPressed: onPressed,
      tooltip: 'Atualizar próximas aulas',
    );
  }
}

/// Estado de carregamento
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18.0),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Carregando próximas aulas...'),
          ],
        ),
      ),
    );
  }
}

/// Estado vazio
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Nenhuma próxima aula encontrada.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
