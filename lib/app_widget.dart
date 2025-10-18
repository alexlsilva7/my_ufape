import 'package:flutter/material.dart';
import 'package:logarte/logarte.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/core/debug/logarte.dart';
import 'package:my_ufape/core/ui/app_config_ui.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';
import 'package:my_ufape/ui/widgets/debug_overlay_widget.dart';
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
  final sigaService = injector.get<SigaBackgroundService>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsRepository,
      builder: (context, child) {
        return MaterialApp.router(
          routerConfig: Routefly.routerConfig(
            routes: routes,
            initialPath: routePaths.splash,
            observers: [
              LogarteNavigatorObserver(logarte),
            ],
          ),
          builder: (context, child) => DebugOverlayWidget(child: child!),
          title: 'My UFAPE',
          theme: AppConfigUI.lightTheme,
          darkTheme: AppConfigUI.darkTheme,
          themeMode: settingsRepository.themeMode,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}