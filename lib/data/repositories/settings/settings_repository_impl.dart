import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_ufape/core/exceptions/app_exception.dart';
import 'package:my_ufape/data/services/settings/local_storage_preferences_service.dart';
import 'package:my_ufape/domain/entities/login.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './settings_repository.dart';

class SettingsRepositoryImpl extends ChangeNotifier
    implements SettingsRepository {
  final LocalStoragePreferencesService _localStoragePreferencesService;
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  SettingsRepositoryImpl(
    this._localStoragePreferencesService,
    this._prefs,
    this._secureStorage,
  ) {
    isDarkMode = _localStoragePreferencesService.isDarkMode;
    isDebugOverlayEnabled =
        _localStoragePreferencesService.isDebugOverlayEnabled;
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
      await _prefs.clear();
      await _secureStorage.deleteAll();
      return Success(unit);
    } catch (e, s) {
      return Failure(AppException('Falha ao restaurar o aplicativo: $e', s));
    }
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
}
