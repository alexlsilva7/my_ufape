import 'package:flutter/foundation.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:my_ufape/data/repositories/user/user_repository.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';

enum SyncStep {
  timetable,
  grades,
  profile,
  user,
  academicHistory,
  academicAchievement
}

enum StepStatus { idle, running, success, failure }

class InitialSyncViewModel extends ChangeNotifier {
  final SigaBackgroundService _sigaService;
  final UserRepository _userRepository;
  final SettingsRepository _settingsRepository;

  InitialSyncViewModel(
      this._sigaService, this._userRepository, this._settingsRepository);

  final Map<SyncStep, StepStatus> _status = {
    for (var step in SyncStep.values) step: StepStatus.idle
  };
  Map<SyncStep, StepStatus> get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  bool get isSyncComplete =>
      _status.values.every((s) => s == StepStatus.success);

  final ValueNotifier<bool> navigateToHome = ValueNotifier(false);

  final int _maxAttempts = 1;

  Future<bool> _executeStep(SyncStep step) async {
    _status[step] = StepStatus.running;
    notifyListeners();

    late Future<void> Function() syncFunction;
    late String errorContext;

    switch (step) {
      case SyncStep.timetable:
        syncFunction = _sigaService.navigateAndExtractTimetable;
        errorContext = 'grade de horário';
        break;
      case SyncStep.grades:
        syncFunction = _sigaService.navigateAndExtractGrades;
        errorContext = 'notas';
        break;
      case SyncStep.profile:
        syncFunction = _sigaService.navigateAndExtractProfile;
        errorContext = 'perfil';
        break;
      case SyncStep.user:
        syncFunction = _sigaService.navigateAndExtractUser;
        errorContext = 'dados do usuário';
        break;
      case SyncStep.academicHistory:
        syncFunction = _sigaService.navigateAndExtractSchoolHistory;
        errorContext = 'histórico escolar';
        break;
      case SyncStep.academicAchievement:
        syncFunction = _sigaService.navigateAndExtractAcademicAchievement;
        errorContext = 'aproveitamento acadêmico';
        break;
    }

    for (int attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        await _sigaService.goToHome();
        await Future.delayed(const Duration(milliseconds: 500));
        await syncFunction();
        _status[step] = StepStatus.success;
        await _settingsRepository.saveSyncStatus(_status);
        notifyListeners();
        return true;
      } catch (e) {
        if (attempt == _maxAttempts) {
          _status[step] = StepStatus.failure;
          _errorMessage = "Falha ao sincronizar $errorContext.";
          await _settingsRepository.saveSyncStatus(_status);
          notifyListeners();
          return false;
        }
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    return false;
  }

  Future<void> startSync() async {
    if (isSyncing) return;

    _isSyncing = true;
    _errorMessage = null;
    navigateToHome.value = false;

    // Carrega o estado salvo
    _status.addAll(_settingsRepository.getSyncStatus());
    notifyListeners();

    for (final step in SyncStep.values) {
      if (_status[step] != StepStatus.success) {
        await _executeStep(step);
      }
    }

    _isSyncing = false;
    notifyListeners();
    _checkCompletionAndNavigate();
  }

  Future<void> retryStep(SyncStep step) async {
    if (isSyncing || _status[step] != StepStatus.failure) return;

    _isSyncing = true;
    _errorMessage = null;
    notifyListeners();

    await _executeStep(step);

    _isSyncing = false;
    notifyListeners();
    _checkCompletionAndNavigate();
  }

  void _checkCompletionAndNavigate() async {
    if (isSyncComplete) {
      (await _userRepository.getUser()).onSuccess((user) async {
        user.lastSyncAttempt = DateTime.now();
        await _userRepository.upsertUser(user);
        _settingsRepository.updateNextSyncTimestamp();
      });
      await Future.delayed(const Duration(milliseconds: 1500));
      navigateToHome.value = true;
    }
  }
}
