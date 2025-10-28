import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:terminate_restart/terminate_restart.dart';
import 'package:workmanager/workmanager.dart';
import 'package:my_ufape/data/services/siga/background_sync.dart';

import 'package:my_ufape/data/repositories/settings/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  TerminateRestart.instance.initialize();
  Workmanager().initialize(callbackDispatcher);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await setupDependencies();

  final settingsRepository = injector.get<SettingsRepository>();
  if (settingsRepository.isAutoSyncEnabled &&
      !settingsRepository.isSyncTaskRegistered) {
    await settingsRepository.scheduleSyncTask();
  }

  runApp(const MyUfapeApp());
}
