import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/deep_link_body.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';

void route(
    {required NotificationBodyModel? notificationBody,
    required DeepLinkBody? linkBody}) {
  // double? minimumVersion = _getMinimumVersion();
  // bool needsUpdate = AppConstants.appVersion < minimumVersion;

  // bool isInMaintenance = MaintenanceHelper.isMaintenanceEnable();
  // if (needsUpdate || isInMaintenance) {
  //   Get.offNamed(RouteHelper.getUpdateRoute(needsUpdate));
  // } else if (!GetPlatform.isWeb) {
  _handleNavigation(notificationBody, linkBody);
  // } else if (GetPlatform.isWeb &&
  //     Get.currentRoute.contains(RouteHelper.update) &&
  //     !isInMaintenance) {
  //   Get.offNamed(RouteHelper.getInitialRoute());
  // }
}

void _handleNavigation(
    NotificationBodyModel? notificationBody, DeepLinkBody? linkBody) async {
  if (notificationBody != null && linkBody == null) {
    _forNotificationRouteProcess(notificationBody);
  } else if (Get.find<MarketAuthController>().isLoggedIn()) {
    _forLoggedInUserRouteProcess(notificationBody);
  } else if (Get.find<MarketSplashController>(tag: 'xmarket').showIntro()!) {
    _newlyRegisteredRouteProcess();
  } else if (Get.find<MarketAuthController>().isGuestLoggedIn()) {
    _forGuestUserRouteProcess();
  } else {
    await Get.find<MarketAuthController>().guestLogin();
    _forGuestUserRouteProcess();
  }
}

void _forNotificationRouteProcess(NotificationBodyModel? notificationBody) {
  if (notificationBody!.notificationType == NotificationType.order) {
    Get.offAllNamed(RouteHelper.getOrderDetailsRoute(notificationBody.orderId,
        fromNotification: true));
  } else if (notificationBody.notificationType == NotificationType.message) {
    Get.offAllNamed(RouteHelper.getChatRoute(
        notificationBody: notificationBody,
        conversationID: notificationBody.conversationId,
        fromNotification: true));
  } else if (notificationBody.notificationType == NotificationType.block ||
      notificationBody.notificationType == NotificationType.unblock) {
    Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.notification));
  } else if (notificationBody.notificationType == NotificationType.add_fund ||
      notificationBody.notificationType == NotificationType.referral_earn ||
      notificationBody.notificationType == NotificationType.CashBack) {
    Get.offAllNamed(RouteHelper.getWalletRoute(fromNotification: true));
  } else {
    Get.offAllNamed(RouteHelper.getNotificationRoute(fromNotification: true));
  }
}

Future<void> _forLoggedInUserRouteProcess(
    NotificationBodyModel? notificationBody) async {
  Get.find<MarketAuthController>().updateToken();
  await Get.find<FavouriteController>().getFavouriteList();
  if (notificationBody != null) {
    _forNotificationRouteProcess(notificationBody);
  } else if (AddressHelper.getAddressFromSharedPref() != null) {
    Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
  } else {
    // Get.offNamed(RouteHelper.getAccessLocationRoute('splash'));
    Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
  }
}

void _newlyRegisteredRouteProcess() {
  if (AppConstants.languages.length > 1) {
    Get.offNamed(RouteHelper.getLanguageRoute('splash'));
  } else {
    Get.offNamed(RouteHelper.getOnBoardingRoute());
  }
}

void _forGuestUserRouteProcess() {
  if (AddressHelper.getAddressFromSharedPref() != null) {
    Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
  } else {
    // Get.find<MarketSplashController>(tag: 'xmarket')
    //     .navigateToLocationScreen('splash', offNamed: true);
    Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
  }
}
