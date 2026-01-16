import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _available = false;

  Future<void> init() async {
    if (kIsWeb) {
      // Web: no-op
      _available = false;
      return;
    }
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      const initSettings = InitializationSettings(android: android, iOS: ios);
      await _plugin.initialize(initSettings);
      // Android 13+ requires runtime notification permission
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidImpl?.requestNotificationsPermission();
      // Request permissions on Apple platforms
      final iosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      final macPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      await macPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      _available = true;
    } catch (_) {
      // In tests or unsupported environments, initialization can fail.
      // Gracefully degrade to no-op notifications.
      _available = false;
    }
  }

  Future<void> showThreat(String title, String body) async {
    if (kIsWeb || !_available) return; // Web or unavailable: skip
    const androidDetails = AndroidNotificationDetails(
      'threats',
      'Threat Alerts',
      channelDescription: 'Notifications for detected threats',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
      );
    } catch (_) {
      // Ignore failures when notifications aren't available.
    }
  }
}
