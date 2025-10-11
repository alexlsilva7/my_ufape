import 'package:flutter/material.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:routefly/routefly.dart';

class SplashViewModel extends ChangeNotifier {
  SettingsRepository settingsRepository;

  SplashViewModel(this.settingsRepository);

  init() async {
    // Pequeno delay para a splash ser visível
    await Future.delayed(const Duration(milliseconds: 1200));

    final hasCredentials = await settingsRepository.hasUserCredentials();

    if (hasCredentials) {
      // Vai direto para a Home, permitindo acesso offline aos dados locais.
      // O SigaBackgroundService fará a sincronização em segundo plano por conta própria.
      Routefly.navigate(routePaths.home);
    } else {
      // Sem credenciais, precisa fazer o login inicial.
      Routefly.navigate(routePaths.login);
    }
    notifyListeners();
  }
}
