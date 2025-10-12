import 'package:my_ufape/core/exceptions/app_exception.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStoragePreferencesService {
  SharedPreferences prefs;

  static const String _debugOverlayKey = 'debug_overlay_enabled';

  static const String _initialSyncKey = 'initial_sync_completed';

  LocalStoragePreferencesService(this.prefs);
  bool get isDarkMode => prefs.getBool('isDarkMode') ?? false;

  bool get isDebugOverlayEnabled => prefs.getBool(_debugOverlayKey) ?? false;

  bool get isInitialSyncCompleted => prefs.getBool(_initialSyncKey) ?? false;

  AsyncResult<Unit> toggleDarkMode() async {
    try {
      await prefs.setBool('isDarkMode', !isDarkMode);
      return Success(unit);
    } catch (e, s) {
      return Failure(AppException(e.toString(), s));
    }
  }

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
}
