import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool quietHours = true; // can be toggled in settings
  bool caymanOnly = true;

  Future<void> init() async {
    if (_initialized) return;
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const IOSInitializationSettings iosSettings = IOSInitializationSettings();

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> showAdvisory({
    required String tier, // Outlook | Watch | Warning
    required String title,
    required String body,
  }) async {
    await init();
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'advisories',
      'Advisories',
      'Hurricane advisories and alerts',
      importance: Importance.max,
      priority: Priority.high,
    );
    const IOSNotificationDetails iosDetails = IOSNotificationDetails();
    const NotificationDetails details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '$tier: $title',
      body,
      details,
    );
  }

  Future<void> scheduleDailyDigest(TimeOfDay time,
      {required String body}) async {
    await init();
    // For v8 we keep it simple on-demand; advanced scheduling requires TZ setup
    await showAdvisory(tier: 'Daily Digest', title: 'Today', body: body);
  }
}
