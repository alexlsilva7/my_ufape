import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/core/debug/logarte.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';

/// Inicializa e configura o Flutter Background Service.
/// Chame esta função no `main()` antes de `runApp()`.
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  // Configuração do canal de notificação (obrigatório no Android)
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_ufape_sync_channel',
    'Sincronização My UFAPE',
    description: 'Notificações de sincronização em background do My UFAPE.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false, // Controlamos manualmente quando iniciar
      isForegroundMode: true,
      notificationChannelId: 'my_ufape_sync_channel',
      initialNotificationTitle: 'My UFAPE',
      initialNotificationContent: 'Preparando sincronização...',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.dataSync],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

/// Callback para iOS background (necessário mesmo se não for usado)
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

/// Função principal que roda no Isolate do serviço de background.
/// ATENÇÃO: Este código roda em um Isolate separado!
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // 1. OBRIGATÓRIO: Inicializar Flutter Bindings
  DartPluginRegistrant.ensureInitialized();

  // 2. OBRIGATÓRIO: Reinjetar dependências (pois é um novo Isolate)
  await setupDependencies();

  // Obtém os serviços necessários
  final sigaService =
      injector.get<SigaBackgroundService>(key: 'siga_background');
  final settingsRepo = injector.get<SettingsRepository>();

  // Listener para comando de parar o serviço
  service.on('stopService').listen((event) async {
    logarte.log('Recebido comando stopService', source: 'BackgroundService');
    await sigaService.disposeService();
    service.stopSelf();
  });

  // Listener para comando de iniciar sincronização
  service.on('startSync').listen((event) async {
    logarte.log('Recebido comando startSync', source: 'BackgroundService');

    // Verifica se a sincronização está habilitada
    if (!settingsRepo.isAutoSyncEnabled) {
      logarte.log('Sincronização desabilitada pelo usuário',
          source: 'BackgroundService');
      _updateNotification(service, 'Sincronização desabilitada');
      await Future.delayed(const Duration(seconds: 2));
      service.stopSelf();
      return;
    }

    // Verifica se o usuário está logado
    if (!sigaService.isLoggedIn) {
      logarte.log('Usuário não está logado. Sincronização cancelada.',
          source: 'BackgroundService');
      _updateNotification(service, 'Faça login para sincronizar');
      await Future.delayed(const Duration(seconds: 2));
      service.stopSelf();
      return;
    }

    // Verifica se já está sincronizando
    if (sigaService.isSyncing) {
      logarte.log(
          'Sincronização já em andamento: ${sigaService.currentSyncOperation}',
          source: 'BackgroundService');
      _updateNotification(service, 'Sincronização já em andamento...');
      await Future.delayed(const Duration(seconds: 2));
      service.stopSelf();
      return;
    }

    // Atualiza notificação
    _updateNotification(service, 'Sincronizando dados acadêmicos...');

    try {
      // Inicializa o serviço SIGA se necessário
      await sigaService.initialize();

      // Executa a sincronização completa
      await sigaService.runFullBackgroundSync();

      // Sucesso
      _updateNotification(service, 'Sincronização concluída com sucesso!');
      logarte.log('Sincronização em background concluída com sucesso',
          source: 'BackgroundService');
    } catch (e) {
      _updateNotification(service, 'Erro na sincronização');
      logarte.log('Erro na sincronização em background: $e',
          source: 'BackgroundService');
    } finally {
      // Aguarda um pouco para o usuário ver a notificação final
      await Future.delayed(const Duration(seconds: 3));

      // Encerra o serviço para não gastar bateria
      await sigaService.disposeService();
      service.stopSelf();
    }
  });

  // Se o serviço foi iniciado, envia o comando de sync automaticamente
  // (útil quando o serviço é iniciado diretamente)
  service.invoke('startSync');
}

/// Atualiza a notificação do foreground service
void _updateNotification(ServiceInstance service, String content) {
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: 'My UFAPE',
      content: content,
    );
  }
}
