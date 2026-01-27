import 'package:flutter/material.dart';
import 'package:my_ufape/core/debug/logarte.dart';
import 'package:my_ufape/data/repositories/scheduled_subject/scheduled_subject_repository.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';
import 'package:my_ufape/domain/entities/time_table.dart';
import 'package:my_ufape/data/services/home_widget/home_widget_service.dart';

class TimetableViewModel extends ChangeNotifier {
  final ScheduledSubjectRepository _repository;
  final SigaBackgroundService _sigaService;
  final HomeWidgetService _homeWidgetService;

  List<ScheduledSubject> subjects = [];
  bool isLoading = true;
  bool isSyncing = false;
  String? errorMessage;

  TimetableViewModel(
      this._repository, this._sigaService, this._homeWidgetService);

  static const dayOrder = [
    DayOfWeek.segunda,
    DayOfWeek.terca,
    DayOfWeek.quarta,
    DayOfWeek.quinta,
    DayOfWeek.sexta,
    DayOfWeek.sabado,
  ];

  Future<void> loadSubjects() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getAllScheduledSubjects();

      result.fold(
        (subjects) {
          if (subjects.isEmpty) {
            // tenta sincronizar automaticamente se não houver disciplinas
            syncFromSiga();
          } else {
            this.subjects = subjects;
            isLoading = false;
            notifyListeners();
            // Atualizar o widget sempre que carregar dados locais com sucesso
            _updateHomeWidget();
          }
        },
        (error) {
          errorMessage = 'Erro ao carregar disciplinas: ${error.toString()}';
          isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      errorMessage = 'Erro inesperado: ${e.toString()}';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncFromSiga() async {
    if (isSyncing) return;

    isSyncing = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _sigaService.goToHome();
      await Future.delayed(const Duration(seconds: 2));
      final subjects = await _sigaService.navigateAndExtractTimetable();
      await _sigaService.goToHome();

      this.subjects = subjects;
      isLoading = false;
      isSyncing = false;
      notifyListeners();

      // Atualizar o widget após sincronização bem-sucedida
      _updateHomeWidget();
    } catch (e) {
      logarte.log('Erro ao sincronizar com SIGA: $e',
          source: 'TimetableViewModel');
      await _sigaService.goToHome();
      errorMessage = 'Erro ao sincronizar: ${e.toString()}';
      isLoading = false;
      isSyncing = false;
      notifyListeners();
    }
  }

  // Método auxiliar para atualizar o widget
  Future<void> _updateHomeWidget() async {
    try {
      logarte.log('Atualizando widget', source: 'TimetableViewModel');
      await _homeWidgetService.updateWidget();
    } catch (e) {
      logarte.log('Erro ao atualizar widget: $e', source: 'TimetableViewModel');
    }
  }

  Map<DayOfWeek, List<ScheduledSubject>> groupByDay() {
    final map = <DayOfWeek, List<ScheduledSubject>>{};
    for (final day in dayOrder) {
      map[day] = [];
    }

    for (final subject in subjects) {
      for (final slot in subject.timeSlots) {
        if (map.containsKey(slot.day)) {
          if (!map[slot.day]!.contains(subject)) {
            map[slot.day]!.add(subject);
          }
        }
      }
    }

    for (final day in map.keys) {
      map[day]!.sort((a, b) {
        final aSlotsForDay = a.timeSlots.where((s) => s.day == day).toList();
        final bSlotsForDay = b.timeSlots.where((s) => s.day == day).toList();

        if (aSlotsForDay.isEmpty && bSlotsForDay.isEmpty) return 0;
        if (aSlotsForDay.isEmpty) return 1;
        if (bSlotsForDay.isEmpty) return -1;

        aSlotsForDay.sort((x, y) => x.startTime.compareTo(y.startTime));
        bSlotsForDay.sort((x, y) => x.startTime.compareTo(y.startTime));

        return aSlotsForDay.first.startTime
            .compareTo(bSlotsForDay.first.startTime);
      });
    }

    return map;
  }
}
