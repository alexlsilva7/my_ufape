import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/core/debug/logarte.dart';
import 'package:my_ufape/core/notifications/notification_service.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case "data_sync":
          await syncDataWithServer();
          break;
        default:
          return Future.value(false);
      }
      return Future.value(true);
    } catch (err) {
      logarte.log('Erro global no callbackDispatcher: $err',
          source: 'Workmanager');
      return Future.value(false);
    }
  });
}

Future<void> syncDataWithServer() async {
  await setupDependencies();
  final settingsRepo = injector.get<SettingsRepository>();
  final notificationService = NotificationService();
  await notificationService.init();

  if (!settingsRepo.isAutoSyncEnabled) {
    await Workmanager().cancelAll();
    logarte.log(
        'Sincronização em background cancelada pois a opção foi desabilitada.',
        source: 'BackgroundSync');
    return;
  }

  final sigaService =
      injector.get<SigaBackgroundService>(key: 'siga_background');

  if (sigaService.isSyncing) {
    logarte.log(
        'Sincronização em background ignorada: outra sincronização já está em andamento (${sigaService.currentSyncOperation}).',
        source: 'BackgroundSync');
    return;
  }

  if (settingsRepo.isDebugOverlayEnabled) {
    await notificationService.showDebugNotification(
      'My UFAPE Sync',
      'Iniciando sincronização em background...',
    );
  }

  logarte.log('Iniciando sincronização em background...',
      source: 'BackgroundSync');

  try {
    await sigaService.runFullBackgroundSync();

    if (settingsRepo.isDebugOverlayEnabled) {
      await notificationService.showDebugNotification(
        'My UFAPE Sync',
        'Sincronização concluída com sucesso!',
      );
    }
    logarte.log('Tarefa de sincronização em background finalizada com sucesso.',
        source: 'BackgroundSync');
  } catch (e) {
    if (settingsRepo.isDebugOverlayEnabled) {
      await notificationService.showDebugNotification(
        'My UFAPE Sync',
        'Falha na sincronização: ${e.toString()}',
      );
    }
    logarte.log('Erro na sincronização em background: $e',
        source: 'BackgroundSync');
  }

  await settingsRepo.scheduleSyncTask();
}
