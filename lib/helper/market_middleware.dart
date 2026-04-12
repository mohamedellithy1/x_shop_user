import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/maintance_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
// import 'package:stackfood_multivendor/xride/features/splash/controllers/config_controller.dart';

class MarketMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
//    ConfigController configController = Get.find<ConfigController>();
    MarketSplashController marketSplashController =
        Get.find<MarketSplashController>(tag: 'xmarket');

    // 1. Check if config is loaded
    if (marketSplashController.configModel == null) {
      // If we are coming from another part of the app and config isn't ready,
      // we might want to stay on a loading state or just let it load in background.
      // But usually, it should be pre-fetched in Splash.
    }

    // 2. Check Maintenance Mode
    bool isInMaintenance = MaintenanceHelper.isMaintenanceEnable();
    if (isInMaintenance) {
      return RouteSettings(name: RouteHelper.getUpdateRoute(false));
    }

    // 3. User Session / Location Logic
    // Let navigation proceed normally - location setup is handled by LocationController
    return null;
  }
}
