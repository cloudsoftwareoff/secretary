import 'package:permission_handler/permission_handler.dart';

Future<void> requestExactAlarmPermission() async {
  if (await Permission.scheduleExactAlarm.request().isGranted) {
    print("Exact alarm permission granted");
  } else {
    print("Exact alarm permission denied");
  }
}