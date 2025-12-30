import 'package:flutter/material.dart';
import 'package:my_ufape/domain/entities/login.dart';
import 'package:my_ufape/ui/initial_sync/initial_sync_view_model.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class SettingsRepository extends ChangeNotifier {
  AsyncResult<Unit> restoreApp();
  ThemeMode get themeMode;
  AsyncResult<Unit> changeThemeMode(ThemeMode mode);
  bool isDebugOverlayEnabled = false;

  int get lastSyncTimestamp;
  bool isAutoSyncEnabled = true;
  AsyncResult<Unit> toggleAutoSync();
  AsyncResult<Unit> updateLastSyncTimestamp();

  bool isBiometricAuthEnabled = false;
  bool isBiometricAvailable = false;
  AsyncResult<Unit> toggleBiometricAuth();
  Future<bool> authenticateWithBiometrics();

  AsyncResult<Unit> saveUserCredentials(Login login);

  AsyncResult<Login> getUserCredentials();

  Future<bool> hasUserCredentials();

  AsyncResult<Unit> deleteUserCredentials();

  AsyncResult<Unit> toggleDebugOverlay();

  Future<bool> isInitialSyncCompleted();

  Future<void> saveSyncStatus(Map<SyncStep, StepStatus> status);
  Map<SyncStep, StepStatus> getSyncStatus();
  Future<void> clearSyncStatus();

  String get sigaUrl;
  AsyncResult<Unit> setSigaUrl(String url);
}
