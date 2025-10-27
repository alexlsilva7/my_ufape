import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/core/debug/logarte.dart';
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
  print('Iniciando sincronização em background...');
  // Inicializa as dependências para o isolate de background
  await setupDependencies();

  final sigaService =
      injector.get<SigaBackgroundService>(key: 'siga_background');
  final settingsRepo = injector.get<SettingsRepository>();

  // Garante que a sincronização automática ainda está habilitada
  if (!settingsRepo.isAutoSyncEnabled) {
    await Workmanager().cancelAll();
    logarte.log(
        'Sincronização em background cancelada pois a opção foi desabilitada.',
        source: 'BackgroundSync');
    return;
  }

  // Verifica se já existe uma sincronização em andamento antes de iniciar
  if (sigaService.isSyncing) {
    logarte.log(
        'Sincronização em background ignorada: outra sincronização já está em andamento (${sigaService.currentSyncOperation}).',
        source: 'BackgroundSync');
    return;
  }

  logarte.log('Iniciando tarefa de sincronização em background...',
      source: 'BackgroundSync');

  try {
    await sigaService.runFullBackgroundSync();
    // Atualiza o timestamp da última sincronização realizada pelo Workmanager
    try {
      //await settingsRepo.updateLastSyncTimestamp();
      logarte.log('Último timestamp de sincronização atualizado.',
          source: 'BackgroundSync');
    } catch (e) {
      logarte.log('Falha ao atualizar o timestamp de sincronização: $e',
          source: 'BackgroundSync');
    }
    logarte.log('Tarefa de sincronização em background finalizada com sucesso.',
        source: 'BackgroundSync');
  } catch (e) {
    logarte.log('Erro na sincronização em background: $e',
        source: 'BackgroundSync');
  }
}
