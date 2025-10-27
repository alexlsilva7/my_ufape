import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/core/database/database.dart';
import 'package:my_ufape/core/exceptions/app_exception.dart';
import 'package:my_ufape/data/services/settings/local_storage_preferences_service.dart';
import 'package:my_ufape/domain/entities/login.dart';
import 'package:my_ufape/ui/initial_sync/initial_sync_view_model.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';
import 'package:local_auth/local_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:local_auth_android/local_auth_android.dart';
// ignore: depend_on_referenced_packages
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:workmanager/workmanager.dart';

import './settings_repository.dart';

class SettingsRepositoryImpl extends ChangeNotifier
    implements SettingsRepository {
  final LocalStoragePreferencesService _localStoragePreferencesService;
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;
  final Database _database;
  final LocalAuthentication _localAuth = LocalAuthentication();

  late ThemeMode _themeMode;

  SettingsRepositoryImpl(
    this._localStoragePreferencesService,
    this._prefs,
    this._secureStorage,
    this._database,
  ) {
    _themeMode = _localStoragePreferencesService.themeMode;
    isDebugOverlayEnabled =
        _localStoragePreferencesService.isDebugOverlayEnabled;
    isAutoSyncEnabled = _localStoragePreferencesService.isAutoSyncEnabled;
    isBiometricAuthEnabled =
        _localStoragePreferencesService.isBiometricAuthEnabled;
    initBiometricAuth();
  }

  @override
  ThemeMode get themeMode => _themeMode;

  @override
  bool isDebugOverlayEnabled = false;

  @override
  bool isBiometricAuthEnabled = false;

  @override
  bool isBiometricAvailable = false;

  @override
  Future<void> saveSyncStatus(Map<SyncStep, StepStatus> status) =>
      _localStoragePreferencesService.saveSyncStatus(status);

  @override
  Map<SyncStep, StepStatus> getSyncStatus() =>
      _localStoragePreferencesService.getSyncStatus();

  @override
  Future<void> clearSyncStatus() =>
      _localStoragePreferencesService.clearSyncStatus();

  Future<void> initBiometricAuth() async {
    bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
    bool isDeviceSupported = await _localAuth.isDeviceSupported();
    isBiometricAvailable = canAuthenticateWithBiometrics || isDeviceSupported;
  }

  @override
  AsyncResult<Unit> toggleBiometricAuth() async {
    await _localStoragePreferencesService.toggleBiometricAuth();
    isBiometricAuthEnabled = !isBiometricAuthEnabled;
    notifyListeners();
    return Success(unit);
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    try {
      final bool canAuthenticate = await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
      if (!canAuthenticate) {
        return false;
      }

      return await _localAuth.authenticate(
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            cancelButton: 'Cancelar',
            goToSettingsButton: 'Ir para configurações',
            goToSettingsDescription:
                'Por favor, configure sua biometria para usar esta funcionalidade.',
            biometricNotRecognized:
                'Biometria não reconhecida. Tente novamente.',
            biometricSuccess: 'Biometria reconhecida com sucesso.',
            deviceCredentialsSetupDescription:
                'Por favor, configure suas credenciais do dispositivo para usar esta funcionalidade.',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancelar',
            goToSettingsButton: 'Ir para configurações',
            goToSettingsDescription:
                'Por favor, configure sua biometria para usar esta funcionalidade.',
          ),
        ],
        localizedReason: 'Por favor, autentique-se para acessar o aplicativo',
        options: const AuthenticationOptions(
          biometricOnly: false, // Permite outros métodos de autenticação
        ),
      );
    } catch (e) {
      // Trata exceções, como o usuário não ter biometria configurada
      return false;
    }
  }

  @override
  AsyncResult<Unit> changeThemeMode(ThemeMode mode) async {
    await _localStoragePreferencesService.setThemeMode(mode);
    _themeMode = mode;
    notifyListeners();
    return Success(unit);
  }

  @override
  AsyncResult<Unit> toggleDebugOverlay() async {
    await _localStoragePreferencesService.toggleDebugOverlay();
    isDebugOverlayEnabled = !isDebugOverlayEnabled;
    notifyListeners();
    return Success(unit);
  }

  @override
  AsyncResult<Unit> restoreApp() async {
    try {
      // 1. Limpa o banco de dados Isar
      final isar = await _database.connection;
      await isar.writeTxn(() async => await isar.clear());

      // 2. Limpa SharedPreferences (incluindo a flag de sync)
      await _prefs.clear();

      // Limpa o estado de sincronização salvo
      await _localStoragePreferencesService.clearSyncStatus();

      // 3. Limpa Secure Storage (credenciais)
      await _secureStorage.deleteAll();
      var sigaBackgroundService =
          injector.get<SigaBackgroundService>(key: 'siga_background');
      await sigaBackgroundService.resetService();

      // Notifica listeners para atualizar a UI se necessário (ex: modo escuro voltando ao padrão)
      _themeMode = ThemeMode.system;
      isDebugOverlayEnabled = false;
      notifyListeners();

      return Success(unit);
    } catch (e, s) {
      return Failure(AppException('Falha ao restaurar o aplicativo: $e', s));
    }
  }

  @override
  bool isAutoSyncEnabled = true;

  @override
  int get lastSyncTimestamp =>
      _localStoragePreferencesService.lastSyncTimestamp;

  @override
  AsyncResult<Unit> toggleAutoSync() async {
    try {
      final newState = !isAutoSyncEnabled;
      await _localStoragePreferencesService.toggleAutoSync();
      isAutoSyncEnabled = newState;

      if (newState) {
        await scheduleSyncTask();
      } else {
        await cancelSyncTask();
      }

      notifyListeners();
      return Success(unit);
    } catch (e, s) {
      return Failure(AppException(e.toString(), s));
    }
  }

  @override
  Future<void> scheduleSyncTask() async {
    await cancelSyncTask(); // Sempre cancele a tarefa anterior

    if (syncMode == SyncMode.fixedTime) {
      final now = DateTime.now();
      final targetTime = syncFixedTime;

      var scheduledDate = DateTime(
          now.year, now.month, now.day, targetTime.hour, targetTime.minute);

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final initialDelay = scheduledDate.difference(now);

      await Workmanager().registerOneOffTask(
        "my-ufape-data-sync-fixed",
        "data_sync",
        initialDelay: initialDelay,
        constraints: Constraints(networkType: NetworkType.connected),
      );
      // Salva o timestamp para feedback visual
      await _localStoragePreferencesService
          .setNextSyncTimestamp(scheduledDate.millisecondsSinceEpoch);
    } else {
      // Modo Intervalo
      await Workmanager().registerPeriodicTask(
        "my-ufape-data-sync-periodic",
        "data_sync",
        frequency: syncInterval,
        constraints: Constraints(networkType: NetworkType.connected),
      );
      // Salva o timestamp para feedback visual
      final nextSync = DateTime.now().add(syncInterval);
      await _localStoragePreferencesService
          .setNextSyncTimestamp(nextSync.millisecondsSinceEpoch);
    }
    notifyListeners();
  }

  @override
  Future<void> cancelSyncTask() async {
    await Workmanager().cancelByUniqueName("my-ufape-data-sync-periodic");
    await Workmanager().cancelByUniqueName("my-ufape-data-sync-fixed");
    await _localStoragePreferencesService.setNextSyncTimestamp(0);
    notifyListeners();
  }

  @override
  AsyncResult<Unit> deleteUserCredentials() async {
    try {
      await _secureStorage.delete(key: 'username');
      await _secureStorage.delete(key: 'password');
      notifyListeners();
      return Success(unit);
    } catch (e, s) {
      return Failure(AppException('Falha ao excluir credenciais: $e', s));
    }
  }

  @override
  AsyncResult<Login> getUserCredentials() async {
    try {
      final username = await _secureStorage.read(key: 'username');
      final password = await _secureStorage.read(key: 'password');

      if (username == null || password == null) {
        return Failure(
          AppException(
              'Credenciais do usuário não encontradas', StackTrace.current),
        );
      }

      return Success(Login(username: username, password: password));
    } catch (e, s) {
      return Failure(AppException('Falha ao recuperar credenciais: $e', s));
    }
  }

  @override
  AsyncResult<Unit> saveUserCredentials(Login login) async {
    try {
      await _secureStorage.write(key: 'username', value: login.username);
      await _secureStorage.write(key: 'password', value: login.password);
      notifyListeners();
      return Success(unit);
    }
    catch (e, s) {
      return Failure(AppException('Falha ao salvar credenciais: $e', s));
    }
  }

  @override
  Future<bool> hasUserCredentials() async {
    try {
      final username = await _secureStorage.read(key: 'username');
      final password = await _secureStorage.read(key: 'password');
      return username != null && password != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isInitialSyncCompleted() async {
    var status = _localStoragePreferencesService.getSyncStatus();
    if (status.isEmpty) {
      return false;
    }
    bool allCompleted = true;
    status.forEach((step, stepStatus) {
      if (stepStatus != StepStatus.success) {
        allCompleted = false;
      }
    });
    return allCompleted;
  }

  @override
  Duration get syncInterval => _localStoragePreferencesService.syncInterval;

  @override
  Future<void> setSyncInterval(Duration interval) async {
    await _localStoragePreferencesService.setSyncInterval(interval);
    notifyListeners();
    await scheduleSyncTask();
  }

  @override
  SyncMode get syncMode => _localStoragePreferencesService.syncMode;

  @override
  Future<void> setSyncMode(SyncMode mode) async {
    await _localStoragePreferencesService.setSyncMode(mode);
    notifyListeners();
    await scheduleSyncTask();
  }

  @override
  TimeOfDay get syncFixedTime => _localStoragePreferencesService.syncFixedTime;

  @override
  Future<void> setSyncFixedTime(TimeOfDay time) async {
    await _localStoragePreferencesService.setSyncFixedTime(time);
    notifyListeners();
    await scheduleSyncTask();
  }

  @override
  int get nextSyncTimestamp =>
      _localStoragePreferencesService.nextSyncTimestamp;
}
