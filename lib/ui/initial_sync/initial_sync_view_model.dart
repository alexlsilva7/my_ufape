import 'package:flutter/foundation.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';

enum SyncStep {
  user,
  grades,
  profile,
  timetable,
  academicHistory,
  academicAchievement
}

enum StepStatus { idle, running, success, failure }

class InitialSyncViewModel extends ChangeNotifier {
  final SigaBackgroundService _sigaService;
  final SettingsRepository _settingsRepository;

  InitialSyncViewModel(this._sigaService, this._settingsRepository);

  final Map<SyncStep, StepStatus> _status = {
    SyncStep.user: StepStatus.idle,
    SyncStep.grades: StepStatus.idle,
    SyncStep.profile: StepStatus.idle,
    SyncStep.timetable: StepStatus.idle,
    SyncStep.academicHistory: StepStatus.idle,
    SyncStep.academicAchievement: StepStatus.idle,
  };
  Map<SyncStep, StepStatus> get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  bool get isSyncComplete =>
      _status.values.every((s) => s == StepStatus.success);

  /// Notificador para sinalizar à UI que a navegação para a home deve ocorrer.
  final ValueNotifier<bool> navigateToHome = ValueNotifier(false);

  final int _maxAttempts = 3;

  // Função helper para executar uma etapa com retentativas
  Future<bool> _runSyncStep(
    SyncStep step,
    Future<void> Function() syncFunction,
    String errorContext,
  ) async {
    _status[step] = StepStatus.running;
    notifyListeners();

    for (int attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        await syncFunction();
        _status[step] = StepStatus.success;
        notifyListeners();
        return true; // Sucesso
      } catch (e) {
        if (attempt == _maxAttempts) {
          _status[step] = StepStatus.failure;
          _errorMessage =
              "Falha ao sincronizar $errorContext após $attempt tentativas. Verifique sua conexão e tente novamente.";
          notifyListeners();
          return false; // Falha definitiva
        }
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    return false;
  }

  Future<void> startSync() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _errorMessage = null;
    navigateToHome.value = false;

    // Reseta o status dos passos antes de iniciar
    _status.updateAll((key, value) => StepStatus.idle);
    notifyListeners();

    await _sigaService.goToHome();
    await Future.delayed(const Duration(milliseconds: 500));

    if (!await _runSyncStep(SyncStep.timetable,
        _sigaService.navigateAndExtractTimetable, 'grade de horário')) {
      _isSyncing = false;
      return;
    }
    await _sigaService.goToHome();
    await Future.delayed(const Duration(milliseconds: 500));
    // 2. Sincronizar Notas com retentativas
    if (!await _runSyncStep(
        SyncStep.grades, _sigaService.navigateAndExtractGrades, 'notas')) {
      _isSyncing = false;
      return; // Para a sincronização se uma etapa falhar
    }

    await _sigaService.goToHome();
    await Future.delayed(const Duration(milliseconds: 500));

    // 3. Sincronizar Perfil Curricular com retentativas
    if (!await _runSyncStep(
        SyncStep.profile, _sigaService.navigateAndExtractProfile, 'perfil')) {
      _isSyncing = false;
      return;
    }

    // 4. Sincronizar Dados do Usuário
    if (!await _runSyncStep(SyncStep.user, _sigaService.navigateAndExtractUser,
        'dados do usuário')) {
      _isSyncing = false;
      return;
    }

    // 5. Sincronizar Histórico Escolar
    if (!await _runSyncStep(SyncStep.academicHistory,
        _sigaService.navigateAndExtractSchoolHistory, 'histórico escolar')) {
      _isSyncing = false;
      return;
    }

    // 6. Sincronizar Aproveitamento Acadêmico
    if (!await _runSyncStep(
        SyncStep.academicAchievement,
        _sigaService.navigateAndExtractAcademicAchievement,
        'aproveitamento acadêmico')) {
      _isSyncing = false;
      return;
    }

    // Finalização
    await _sigaService.goToHome();
    await _settingsRepository.setInitialSyncCompleted(true);
    await _settingsRepository.updateLastSyncTimestamp();
    _isSyncing = false;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    // Sinaliza que a navegação deve ocorrer.
    navigateToHome.value = true;
  }
}
