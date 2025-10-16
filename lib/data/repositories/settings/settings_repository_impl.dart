import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/core/database/database.dart';
import 'package:my_ufape/core/exceptions/app_exception.dart';
import 'package:my_ufape/data/services/settings/local_storage_preferences_service.dart';
import 'package:my_ufape/domain/entities/login.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';

import './settings_repository.dart';

class SettingsRepositoryImpl extends ChangeNotifier
    implements SettingsRepository {
  final LocalStoragePreferencesService _localStoragePreferencesService;
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;
  final Database _database;

  SettingsRepositoryImpl(
    this._localStoragePreferencesService,
    this._prefs,
    this._secureStorage,
    this._database,
  ) {
    isDarkMode = _localStoragePreferencesService.isDarkMode;
    isDebugOverlayEnabled =
        _localStoragePreferencesService.isDebugOverlayEnabled;
    // Adicione esta linha
    isAutoSyncEnabled = _localStoragePreferencesService.isAutoSyncEnabled;
  }

  @override
  bool isDarkMode = false;

  @override
  bool isDebugOverlayEnabled = false;

  @override
  AsyncResult<Unit> toggleDarkMode() async {
    await _localStoragePreferencesService.toggleDarkMode();
    isDarkMode = !isDarkMode;
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

      // 3. Limpa Secure Storage (credenciais)
      await _secureStorage.deleteAll();
      var sigaBackgroundService = injector.get<SigaBackgroundService>();
      await sigaBackgroundService.resetService();

      // Notifica listeners para atualizar a UI se necessário (ex: modo escuro voltando ao padrão)
      isDarkMode = false;
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
  int get lastSyncTimestamp => _localStoragePreferencesService.lastSyncTimestamp;

  @override
  AsyncResult<Unit> toggleAutoSync() async {
    await _localStoragePreferencesService.toggleAutoSync();
    isAutoSyncEnabled = !isAutoSyncEnabled;
    notifyListeners();
    return Success(unit);
  }

  @override
  AsyncResult<Unit> updateLastSyncTimestamp() async {
    return _localStoragePreferencesService.updateLastSyncTimestamp();
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
    } catch (e, s) {
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
    return _localStoragePreferencesService.isInitialSyncCompleted;
  }

  @override
  AsyncResult<Unit> setInitialSyncCompleted(bool value) async {
    final result =
        await _localStoragePreferencesService.setInitialSyncCompleted(value);
    return result;
  }
}
