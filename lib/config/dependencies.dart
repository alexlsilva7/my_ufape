import 'package:auto_injector/auto_injector.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository_impl.dart';
import 'package:my_ufape/data/services/settings/local_storage_preferences_service.dart';
import 'package:my_ufape/ui/home/home_view_model.dart';
import 'package:my_ufape/ui/splash/splash_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final injector = AutoInjector();

Future<void> setupDependencies() async {
  injector.addSingleton(LocalStoragePreferencesService.new);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  injector.addInstance<SharedPreferences>(prefs);
  injector.addSingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  injector.addSingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      injector.get<LocalStoragePreferencesService>(),
      injector.get<SharedPreferences>(),
      injector.get<FlutterSecureStorage>(),
    ),
  );

  injector.addLazySingleton(SplashViewModel.new);
  injector.addLazySingleton(HomeViewModel.new);

  injector.commit();
}
