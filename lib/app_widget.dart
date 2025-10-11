import 'package:flutter/material.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/core/ui/app_config_ui.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:routefly/routefly.dart';
import 'app_widget.route.dart';

part 'app_widget.g.dart';

@Main('lib/ui')
class MyUfapeApp extends StatefulWidget {
  const MyUfapeApp({super.key});

  @override
  State<MyUfapeApp> createState() => _MyUfapeAppState();
}

class _MyUfapeAppState extends State<MyUfapeApp> {
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
            title: 'My UFAPE',
            theme: settingsRepository.isDarkMode
                ? AppConfigUI.darkTheme
                : AppConfigUI.lightTheme,
            debugShowCheckedModeBanner: false,
          );
        });
  }
}
