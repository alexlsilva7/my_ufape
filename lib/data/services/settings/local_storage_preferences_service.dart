import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_ufape/core/exceptions/app_exception.dart';
import 'package:my_ufape/ui/initial_sync/initial_sync_view_model.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStoragePreferencesService {
  SharedPreferences prefs;

  static const String _debugOverlayKey = 'debug_overlay_enabled';
  static const String _autoSyncKey = 'auto_sync_enabled';
  static const String _lastSyncTimestampKey = 'last_sync_timestamp';
  static const String _biometricAuthKey = 'biometric_auth_enabled';
  static const String _themeModeKey = 'theme_mode';
  static const String _syncStatusKey = 'initial_sync_status';
  static const String _sigaUrlKey = 'siga_institution_url';

  static const String urlUfape = 'https://siga.ufape.edu.br/ufape/index.jsp';
  static const String urlUpe = 'https://siga.upe.br/upe/index.jsp';

  LocalStoragePreferencesService(this.prefs);

  ThemeMode get themeMode {
    final themeIndex = prefs.getInt(_themeModeKey) ?? 0;
    return ThemeMode.values[themeIndex];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await prefs.setInt(_themeModeKey, mode.index);
  }

  // Métodos para o status da sincronização
  Future<void> saveSyncStatus(Map<SyncStep, StepStatus> status) async {
    final stringMap =
        status.map((key, value) => MapEntry(key.name, value.name));
    await prefs.setString(_syncStatusKey, jsonEncode(stringMap));
  }

  Map<SyncStep, StepStatus> getSyncStatus() {
    final jsonString = prefs.getString(_syncStatusKey);
    if (jsonString == null) {
      return {for (var step in SyncStep.values) step: StepStatus.idle};
    }
    final stringMap = jsonDecode(jsonString) as Map<String, dynamic>;

    //verifica se o mapa tem todas as chaves necessárias
    for (var step in SyncStep.values) {
      if (!stringMap.containsKey(step.name)) {
        stringMap[step.name] = StepStatus.idle.name;
      }
    }

    return stringMap.map((key, value) {
      final step = SyncStep.values
          .firstWhere((e) => e.name == key, orElse: () => SyncStep.user);
      final status = StepStatus.values
          .firstWhere((e) => e.name == value, orElse: () => StepStatus.idle);
      return MapEntry(step, status);
    });
  }

  Future<void> clearSyncStatus() async {
    await prefs.remove(_syncStatusKey);
  }

  bool get isDebugOverlayEnabled => prefs.getBool(_debugOverlayKey) ?? false;

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

  String get sigaUrl => prefs.getString(_sigaUrlKey) ?? urlUfape;

  Future<void> setSigaUrl(String url) async {
    await prefs.setString(_sigaUrlKey, url);
  }
}
