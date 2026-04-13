import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

class PermissionHelper {
  static Future<void> requestInitialPermissions() async {
    if (GetPlatform.isMobile) {
      // طلب أذونات الموقع والإشعارات
      await [
        Permission.location,
        Permission.notification,
      ].request();
    }
  }
}
