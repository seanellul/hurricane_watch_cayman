import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

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
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
    // Initialize timezone database once for accurate scheduling
    try {
      tzdata.initializeTimeZones();
    } catch (_) {
      // Safe to ignore if already initialized
    }
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
      channelDescription: 'Hurricane advisories and alerts',
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
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
      {String? body, String? title}) async {
    await init();
    tz.Location location;
    try {
      // Cayman follows America/Cayman (UTC-5, no DST)
      location = tz.getLocation('America/Cayman');
    } catch (_) {
      location = tz.local;
    }

    final now = tz.TZDateTime.now(location);
    var scheduled = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const android = AndroidNotificationDetails(
      'daily_digest',
      'Daily Digest',
      channelDescription: 'Once‑a‑day reminder to check today\'s outlook',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);

    await _plugin.zonedSchedule(
      // Stable ID for replacement
      1001,
      title ?? 'Daily check‑in',
      body ?? 'Open Cayman Hurricane Watch to see today\'s outlook.',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyDigest() async {
    await _plugin.cancel(1001);
  }
}
