import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // Configuração básica para iOS (caso expanda no futuro)
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(initializationSettings);

    // Cria o canal de notificação para Android
    await _createNotificationChannel();

    _isInitialized = true;
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'grades_channel', // id
      'Novas Notas', // title
      description: 'Notificações quando novas notas são lançadas no SIGA',
      importance: Importance.high,
      playSound: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> requestPermissions() async {
    await Permission.notification.request();
  }

  Future<void> showGradeNotification({
    required String subjectName,
    required String gradeKey,
    required String gradeValue,
  }) async {
    if (!_isInitialized) await init();

    // ID único baseado no hash para não sobrescrever notificações de matérias diferentes
    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'grades_channel',
      'Novas Notas',
      channelDescription: 'Notificações de notas novas',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      notificationId,
      'Nova nota em $subjectName',
      '$gradeKey: $gradeValue',
      platformChannelSpecifics,
    );
  }
}
