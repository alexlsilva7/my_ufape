import 'package:flutter/material.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/core/ui/gen/assets.gen.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:my_ufape/ui/initial_sync/initial_sync_view_model.dart';
import 'package:routefly/routefly.dart';

class InitialSyncPage extends StatefulWidget {
  const InitialSyncPage({super.key});

  @override
  State<InitialSyncPage> createState() => _InitialSyncPageState();
}

class _InitialSyncPageState extends State<InitialSyncPage> {
  final InitialSyncViewModel _viewModel = injector.get();

  @override
  void initState() {
    super.initState();
    _viewModel.navigateToHome.addListener(_handleNavigation);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.startSync();
    });
  }

  @override
  void dispose() {
    _viewModel.navigateToHome.removeListener(_handleNavigation);
    super.dispose();
  }

  void _handleNavigation() {
    // Se o valor for true e a tela ainda estiver "montada", navega.
    if (_viewModel.navigateToHome.value && mounted) {
      Routefly.navigate(routePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, child) {
              final isFinished = _viewModel.isSyncComplete &&
                  !_viewModel.isSyncing &&
                  _viewModel.errorMessage == null;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        theme.colorScheme.primary, BlendMode.srcIn),
                    child: Assets.images.myUfapeLogo.image(height: 100),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    child: Text(
                      isFinished
                          ? 'Sincronização Concluída!'
                          : 'Sincronização Inicial',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    onLongPress: () async {
                      await injector
                          .get<SettingsRepository>()
                          .toggleDebugOverlay();
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isFinished
                        ? 'Redirecionando para a tela inicial...'
                        : 'Estamos preparando tudo para você. Isso pode levar alguns instantes.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  _buildStepTile('Grade de Horário', SyncStep.timetable,
                      _viewModel.status[SyncStep.timetable]!),
                  _buildStepTile('Notas', SyncStep.grades,
                      _viewModel.status[SyncStep.grades]!),
                  _buildStepTile('Disciplinas', SyncStep.profile,
                      _viewModel.status[SyncStep.profile]!),
                  _buildStepTile('Usuário', SyncStep.user,
                      _viewModel.status[SyncStep.user]!),
                  _buildStepTile(
                      'Histórico Acadêmico',
                      SyncStep.academicHistory,
                      _viewModel.status[SyncStep.academicHistory]!),
                  _buildStepTile(
                      'Aproveitamento Acadêmico',
                      SyncStep.academicAchievement,
                      _viewModel.status[SyncStep.academicAchievement]!),
                  const SizedBox(height: 24),
                  if (_viewModel.errorMessage != null && !_viewModel.isSyncing)
                    Text(
                      _viewModel.errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStepTile(String title, SyncStep step, StepStatus status) {
    Widget trailing;
    bool canRetry = status == StepStatus.failure && !_viewModel.isSyncing;

    switch (status) {
      case StepStatus.idle:
        trailing = const Icon(Icons.more_horiz, color: Colors.grey);
        break;
      case StepStatus.running:
        trailing = Padding(
          padding: const EdgeInsets.all(12.0),
          child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2)),
        );
        break;
      case StepStatus.success:
        trailing = Padding(
          padding: const EdgeInsets.all(12.0),
          child: const Icon(Icons.check_circle, color: Colors.green),
        );
        break;
      case StepStatus.failure:
        trailing = IconButton(
          padding: EdgeInsets.zero,
          splashRadius: 20,
          icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.error),
          onPressed: () => _viewModel.retryStep(step),
          tooltip: 'Tentar novamente',
        );
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      child: ListTile(
        leading: Icon(
          _getIconForStep(step),
          color: Theme.of(context).primaryColor,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: trailing,
        onTap: canRetry ? () => _viewModel.retryStep(step) : null,
      ),
    );
  }

  IconData _getIconForStep(SyncStep step) {
    switch (step) {
      case SyncStep.grades:
        return Icons.grade_outlined;
      case SyncStep.profile:
        return Icons.menu_book_rounded;
      case SyncStep.timetable:
        return Icons.schedule_outlined;
      case SyncStep.user:
        return Icons.person_outline;
      case SyncStep.academicHistory:
        return Icons.history_edu_outlined;
      case SyncStep.academicAchievement:
        return Icons.school_outlined;
    }
  }
}
