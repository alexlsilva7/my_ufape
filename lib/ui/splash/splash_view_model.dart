import 'package:flutter/material.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:my_ufape/data/services/home_widget/home_widget_service.dart';
import 'package:routefly/routefly.dart';

class SplashViewModel extends ChangeNotifier {
  SettingsRepository settingsRepository;

  SplashViewModel(this.settingsRepository);
  bool isLoading = true;

  init() async {
    final hasCredentials = await settingsRepository.hasUserCredentials();

    if (hasCredentials) {
      final useBiometrics = settingsRepository.isBiometricAuthEnabled;
      bool proceed =
          !useBiometrics; // Prossiga se a biometria estiver desativada

      if (useBiometrics) {
        final didAuthenticate =
            await settingsRepository.authenticateWithBiometrics();
        if (didAuthenticate) {
          proceed = true;
          isLoading = false;
          notifyListeners();
        } else {
          // Se a biometria falhar ou for cancelada, não prossiga
          proceed = false;
          isLoading = false;
          notifyListeners();
        }
      }

      if (proceed) {
        // Verificar se há um deep link pendente do Widget
        if (HomeWidgetService.pendingDeepLink != null) {
          final handled = await HomeWidgetService.handleWidgetUri(
              HomeWidgetService.pendingDeepLink);
          if (handled) {
            HomeWidgetService.pendingDeepLink = null; // Limpar após uso
            return; // Não continuar para rota padrão
          }
        }

        final isSyncComplete =
            await settingsRepository.isInitialSyncCompleted();
        if (isSyncComplete) {
          Routefly.navigate(routePaths.home);
        } else {
          Routefly.navigate(routePaths.initialSync);
        }
      }
    } else {
      // Sem credenciais, precisa fazer o login inicial.
      Routefly.navigate(routePaths.login);
    }
  }

  Future<void> authenticateWithBiometrics() async {
    isLoading = true;
    notifyListeners();
    bool didAuthenticate =
        await settingsRepository.authenticateWithBiometrics();
    if (didAuthenticate) {
      // Autenticação bem-sucedida
      Routefly.navigate(routePaths.home);
    } else {
      // Autenticação falhou ou foi cancelada
      isLoading = false;
      notifyListeners();
    }
  }
}
