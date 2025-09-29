import 'package:my_ufape/core/exceptions/app_exception.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStoragePreferencesService {
  SharedPreferences prefs;

  LocalStoragePreferencesService(this.prefs);
  bool get isDarkMode => prefs.getBool('isDarkMode') ?? false;

  AsyncResult<Unit> toggleDarkMode() async {
    try {
      await prefs.setBool('isDarkMode', !isDarkMode);
      return Success(unit);
    } catch (e, s) {
      return Failure(AppException(e.toString(), s));
    }
  }
}
