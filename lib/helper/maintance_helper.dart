import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';

class MaintenanceHelper {
  static bool isMaintenanceEnable() {
    return false;
    /*
    bool isMaintenanceMode = Get.find<MarketSplashController>(tag: 'xmarket')
        .configModel!
        .maintenanceMode!;
    String platform = GetPlatform.isWeb ? 'user_web_app' : 'user_mobile_app';

    bool isInMaintenance = isMaintenanceMode &&
        Get.find<MarketSplashController>(tag: 'xmarket')
                .configModel!
                .maintenanceModeData !=
            null &&
        Get.find<MarketSplashController>(tag: 'xmarket')
            .configModel!
            .maintenanceModeData!
            .maintenanceSystemSetup!
            .contains(platform);

    return isInMaintenance;
    */
  }
}
