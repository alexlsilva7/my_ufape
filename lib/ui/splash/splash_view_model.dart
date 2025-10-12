import 'package:flutter/material.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:routefly/routefly.dart';

class SplashViewModel extends ChangeNotifier {
  SettingsRepository settingsRepository;

  SplashViewModel(this.settingsRepository);

  init() async {
    await Future.delayed(const Duration(milliseconds: 1200));

    final hasCredentials = await settingsRepository.hasUserCredentials();

    if (hasCredentials) {
      // MUDANÇA AQUI: Verificar se a sincronização inicial já foi feita
      final isSyncComplete = await settingsRepository.isInitialSyncCompleted();

      if (isSyncComplete) {
        // Se sim, vai para a Home
        Routefly.navigate(routePaths.home);
      } else {
        // Se não, vai para a tela de sincronização
        Routefly.navigate(routePaths.initialSync);
      }
    } else {
      // Sem credenciais, precisa fazer o login inicial.
      Routefly.navigate(routePaths.login);
    }
  }
}
