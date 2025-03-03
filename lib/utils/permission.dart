import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {

  if (await Permission.notification.request().isGranted) {
    print("Notification permission granted");
  } else {
    print("Notification permission denied");
  }


  if (await Permission.scheduleExactAlarm.request().isGranted) {
    print("Exact alarm permission granted");
  } else {
    print("Exact alarm permission denied");
  }
}
