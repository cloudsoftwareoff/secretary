import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Tunis'));

    final String localTimeZone = DateTime.now().timeZoneName;
    print("🌍 Device Timezone: $localTimeZone");

    // Create a notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'appointment_channel',
      'Appointment Notifications',
      importance: Importance.max,
      description: 'Channel for appointment notifications',
    );

    final androidPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
      print("✅ Notification channel created: ${channel.id}");
    } else {
      print(
          "❌ Failed to create notification channel: Android plugin not found");
    }

    // Initialize the plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    print("✅ FlutterLocalNotificationsPlugin initialized");
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Convert the scheduled time to the local time zone
    final tz.TZDateTime eventTime = tz.TZDateTime.from(scheduledTime, tz.local);
    final tz.TZDateTime startTime = eventTime.subtract(const Duration(minutes: 30));
    final now = tz.TZDateTime.now(tz.local);

    print("Event Time: $eventTime");
    print("Start Time (30 min before): $startTime");
    print("Current Time: $now");

    // Check if the start time is in the past
    if (startTime.isBefore(now)) {
      print("❌ Start time is in the past: $startTime");
      return;
    }

    // Schedule countdown notifications every 10 minutes for 30 minutes
    for (int minutesLeft = 30; minutesLeft >= 0; minutesLeft -= 10) {
      final tz.TZDateTime scheduledDate = eventTime.subtract(Duration(minutes: minutesLeft));
      
      if (scheduledDate.isBefore(now)) continue; // Skip past times

      final String countdownBody = "$body - $minutesLeft min remaining";

      // Configure notification details
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'appointment_channel',
        'Appointment Notifications',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@android:drawable/ic_lock_idle_alarm', // Using system clock icon
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      try {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id + (30 - minutesLeft) ~/ 10, // Unique ID for each notification (e.g., id+0, id+1, id+2, id+3)
          title,
          countdownBody,
          scheduledDate,
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        print("✅ Notification scheduled for $scheduledDate: $countdownBody");
      } on PlatformException catch (e) {
        print("❌ Failed to schedule notification: ${e.message}");
      }
    }
  }
}