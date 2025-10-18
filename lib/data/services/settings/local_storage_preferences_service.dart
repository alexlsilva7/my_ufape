import 'package:flutter/material.dart';
import 'package:my_ufape/core/exceptions/app_exception.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStoragePreferencesService {
  SharedPreferences prefs;

  static const String _debugOverlayKey = 'debug_overlay_enabled';
  static const String _initialSyncKey = 'initial_sync_completed';
  static const String _autoSyncKey = 'auto_sync_enabled';
  static const String _lastSyncTimestampKey = 'last_sync_timestamp';
  static const String _biometricAuthKey = 'biometric_auth_enabled';
  static const String _themeModeKey = 'theme_mode';

  LocalStoragePreferencesService(this.prefs);

  ThemeMode get themeMode {
    final themeIndex = prefs.getInt(_themeModeKey) ?? 0;
    return ThemeMode.values[themeIndex];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await prefs.setInt(_themeModeKey, mode.index);
  }

  bool get isDebugOverlayEnabled => prefs.getBool(_debugOverlayKey) ?? false;

  bool get isInitialSyncCompleted => prefs.getBool(_initialSyncKey) ?? false;

  bool get isAutoSyncEnabled =>
      prefs.getBool(_autoSyncKey) ?? true; // Padrão para ativado
  int get lastSyncTimestamp => prefs.getInt(_lastSyncTimestampKey) ?? 0;

  bool get isBiometricAuthEnabled => prefs.getBool(_biometricAuthKey) ?? false;

  AsyncResult<Unit> toggleDebugOverlay() async {
    try {
      await prefs.setBool(_debugOverlayKey, !isDebugOverlayEnabled);
      return Success(unit);
    } catch (e, s) {
      return Failure(AppException(e.toString(), s));
    }
  }

  AsyncResult<Unit> setInitialSyncCompleted(bool value) async {
    try {
      await prefs.setBool(_initialSyncKey, value);
      return Success(unit);
    } catch (e, s) {
      return Failure(AppException(e.toString(), s));
    }
  }

  AsyncResult<Unit> toggleAutoSync() async {
    try {
      await prefs.setBool(_autoSyncKey, !isAutoSyncEnabled);
      return Success(unit);
    } catch (e, s) {
      return Failure(AppException(e.toString(), s));
    }
  }

  AsyncResult<Unit> updateLastSyncTimestamp() async {
    try {
      await prefs.setInt(
          _lastSyncTimestampKey, DateTime.now().millisecondsSinceEpoch);
      return Success(unit);
    } catch (e, s) {
      return Failure(AppException(e.toString(), s));
    }
  }

  AsyncResult<Unit> toggleBiometricAuth() async {
    try {
      await prefs.setBool(_biometricAuthKey, !isBiometricAuthEnabled);
      return Success(unit);
    } catch (e, s) {
      return Failure(AppException(e.toString(), s));
    }
  }
}