import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

class AuthHelper {

  static bool isGuestLoggedIn() {
    return Get.find<MarketAuthController>().isGuestLoggedIn();
  }

  static String getGuestId() {
    return Get.find<MarketAuthController>().getGuestId();
  }

  static bool isLoggedIn() {
    return Get.find<MarketAuthController>().isLoggedIn();
  }
}