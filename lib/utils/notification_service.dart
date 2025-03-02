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
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
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
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      scheduledTime.subtract(const Duration(minutes: 30)),
      tz.local,
    );

    print("Original Scheduled Time: $scheduledTime");
    print("Computed Scheduled Date (30 min before): $scheduledDate");

    // Get the current time in the local time zone
    final now = tz.TZDateTime.now(tz.local);
    print("Current Time (Local): $now");

    // Check if the scheduled date is in the future
    if (scheduledDate.isBefore(now)) {
      print("❌ Scheduled date is in the past: $scheduledDate");
      return;
    }

    // Configure notification details
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'appointment_channel', // Same as channelId
      'Appointment Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print("✅ Notification scheduled successfully at: $scheduledDate");
    } on PlatformException catch (e) {
      print("❌ Failed to schedule notification: ${e.message}");
    }
  }

  // Future<void> testScheduledNotification() async {
  //   final notificationService = NotificationService();
  //   await notificationService.init();

  //   // Get the current time plus 5 seconds
  //   final scheduledTime = DateTime.now().add(Duration(seconds: 5));

  //   // Configure scheduled notification without the 30-minute subtraction
  //   final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
  //     scheduledTime,
  //     tz.local,
  //   );

  //   print("Scheduling notification for: $scheduledDate");

  //   // Configure notification details
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     'appointment_channel',
  //     'Appointment Notifications',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);

  //   try {
  //     await _flutterLocalNotificationsPlugin.zonedSchedule(
  //       1,
  //       'Test Notification',
  //       'This is a scheduled test notification!',
  //       scheduledDate,
  //       platformChannelSpecifics,
  //       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //       uiLocalNotificationDateInterpretation:
  //           UILocalNotificationDateInterpretation.absoluteTime,
  //     );
  //     print("✅ Test notification scheduled for: $scheduledDate");
  //   } on PlatformException catch (e) {
  //     print("❌ Failed to schedule notification: ${e.message}");
  //   }

  //   final bool? pending = await _flutterLocalNotificationsPlugin
  //       .pendingNotificationRequests()
  //       .then((value) => value.isNotEmpty);
  //   print("Pending Notifications: $pending");
  // }
}
