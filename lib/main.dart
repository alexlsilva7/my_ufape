import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/services/home_widget/home_widget_service.dart';
import 'package:terminate_restart/terminate_restart.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  TerminateRestart.instance.initialize();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await setupDependencies();

  // Inicializar Home Widget
  await HomeWidgetService.initialize();

  // Registrar listener para cliques no widget quando app está aberto
  HomeWidgetService.registerClickListener((uri) {
    HomeWidgetService.handleWidgetUri(uri);
  });

  runApp(const MyUfapeApp());

  // Verificar se app foi aberto via Widget após o primeiro frame
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final initialUri = await HomeWidgetService.getInitialUri();
    if (initialUri != null) {
      HomeWidgetService.pendingDeepLink = initialUri;
    }
  });
}
