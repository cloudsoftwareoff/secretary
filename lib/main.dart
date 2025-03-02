import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:secretary/config/apptheme.dart';
import 'package:secretary/dev/watermark.dart';
import 'package:secretary/utils/notification_service.dart';
import 'package:secretary/utils/permission.dart';
import 'package:secretary/wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  final notificationService = NotificationService();
  await notificationService.init();

  await requestExactAlarmPermission();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme(),
      home: WatermarkWrapper(
        child: Wrapper(),
      ),
    );
  }
}
