import 'package:auto_injector/auto_injector.dart';
import 'package:my_ufape/ui/home/home_view_model.dart';
import 'package:my_ufape/ui/splash/splash_view_model.dart';

final injector = AutoInjector();

Future<void> setupDependencies() async {
  injector.addLazySingleton(SplashViewModel.new);
  injector.addLazySingleton(HomeViewModel.new);

  injector.commit();
}
