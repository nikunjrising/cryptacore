import 'package:permission_handler/permission_handler.dart';

class AppPermissionService {
  /// ------------------------------------------------------
  /// CHECK + REQUEST NOTIFICATION PERMISSION
  /// ------------------------------------------------------
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.status;

    // Already granted
    if (status.isGranted) {
      print("🔔 Notification Permission Already Granted");
      return true;
    }

    // Request permission
    final result = await Permission.notification.request();

    if (result.isGranted) {
      print("✅ Notification Permission Granted");
      return true;
    } else if (result.isDenied) {
      print("❌ Notification Permission Denied");
      return false;
    } else if (result.isPermanentlyDenied) {
      print("⛔ Permanently Denied — Opening App Settings");
      await openAppSettings();
      return false;
    }

    return false;
  }
}
