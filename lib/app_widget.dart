import 'package:flutter/material.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/core/ui/app_config_ui.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:routefly/routefly.dart';
import 'app_widget.route.dart';

part 'app_widget.g.dart';

@Main('lib/ui')
class SigaUfapeApp extends StatefulWidget {
  const SigaUfapeApp({super.key});

  @override
  State<SigaUfapeApp> createState() => _SigaUfapeAppState();
}

class _SigaUfapeAppState extends State<SigaUfapeApp> {
  final settingsRepository = injector.get<SettingsRepository>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: settingsRepository,
        builder: (context, child) {
          return MaterialApp.router(
            routerConfig: Routefly.routerConfig(
              routes: routes,
              initialPath: routePaths.splash,
            ),
            title: 'Login SIGA UFAPE',
            theme: settingsRepository.isDarkMode
                ? AppConfigUI.darkTheme
                : AppConfigUI.lightTheme,
            debugShowCheckedModeBanner: false,
          );
        });
  }
}
