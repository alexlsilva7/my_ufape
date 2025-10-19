import 'package:flutter/material.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/ui/academic_achievement/academic_achievement_view_model.dart';

import 'widgets/component_summary_card.dart';
import 'widgets/empty_state.dart';
import 'widgets/error_state.dart';
import 'widgets/loading_state.dart';
import 'widgets/pending_subjects_card.dart';
import 'widgets/workload_card.dart';

class AcademicAchievementPage extends StatefulWidget {
  const AcademicAchievementPage({super.key});

  @override
  State<AcademicAchievementPage> createState() =>
      _AcademicAchievementPageState();
}

class _AcademicAchievementPageState extends State<AcademicAchievementPage> {
  final AcademicAchievementViewModel _viewModel = injector.get();

  @override
  void initState() {
    super.initState();
    _viewModel.loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: isDark ? theme.colorScheme.surface : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Rendimento',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: _viewModel.isSyncing
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : const Icon(Icons.sync_rounded, size: 24),
                onPressed:
                    _viewModel.isSyncing ? null : _viewModel.syncFromSiga,
                tooltip: 'Sincronizar com o SIGA',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary.withAlpha((255 * 0.1).round()),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const LoadingState();
          }
          if (_viewModel.errorMessage != null) {
            return ErrorState(
              errorMessage: _viewModel.errorMessage,
              onRetry: _viewModel.loadData,
            );
          }
          if (_viewModel.achievement == null) {
            return EmptyState(onSync: _viewModel.syncFromSiga);
          }

          final achievement = _viewModel.achievement!;

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    WorkloadCard(
                      workloadSummary: achievement.workloadSummary,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    ComponentSummaryCard(
                      items: achievement.componentSummary,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    PendingSubjectsCard(
                      subjects: achievement.pendingSubjects,
                      totalHours: achievement.totalPendingHours,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}