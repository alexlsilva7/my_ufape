import 'package:flutter/material.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:my_ufape/domain/entities/login.dart';
import 'package:routefly/routefly.dart';

class SplashViewModel extends ChangeNotifier {
  SettingsRepository settingsRepository;

  SplashViewModel(this.settingsRepository);

  init() async {
    await Future.delayed(const Duration(seconds: 1));
    Login? login;

    await settingsRepository.getUserCredentials().then((result) {
      result.fold(
        (success) {
          login = success;
        },
        (failure) {
          login = null;
        },
      );
    });
    print('Login: ${login?.username}, ${login?.password}');
    if (login != null) {
      Routefly.navigate(routePaths.home, arguments: {
        'username': login!.username,
        'password': login!.password,
      });
    } else {
      Routefly.navigate(routePaths.login);
    }
    notifyListeners();
  }
}
