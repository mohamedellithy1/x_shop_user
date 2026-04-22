import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/helper/permission_helper.dart';
import 'package:stackfood_multivendor/util/xmarket_images.dart';
import 'package:stackfood_multivendor/util/xmarket_images.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/news/controllers/news_controller.dart';

class XMarkSplashScreen extends StatefulWidget {
  final NotificationBodyModel? body;

  const XMarkSplashScreen({super.key, this.body});

  @override
  XMarkSplashScreenState createState() => XMarkSplashScreenState();
}

class XMarkSplashScreenState extends State<XMarkSplashScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  bool _isNavigated = false;

  void _route() async {
    await PermissionHelper.requestInitialPermissions();
    debugPrint('🚀 [Splash] Starting config fetch...');

    // محاولة جلب البيانات
    Get.find<MarketSplashController>(tag: 'xmarket')
        .getConfigData(source: DataSourceEnum.client)
        .then((value) {
      debugPrint('✅ [Splash] Config fetch completed.');
      _navigateToHome();
    }).catchError((error) {
      debugPrint('❌ [Splash] Config fetch error: $error');
      _navigateToHome();
    });

    // سياج أمان: لو البيانات اتأخرت أكتر من 5 ثواني حول للهوم فوراً
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_isNavigated) {
        debugPrint('⏰ [Splash] Timeout reached, navigating to home...');
        _navigateToHome();
      }
    });
  }

  void _navigateToHome() {
    if (_isNavigated) return;
    _isNavigated = true;

    if (Get.find<MarketAuthController>().isLoggedIn()) {
      Get.offAllNamed(RouteHelper.getInitialRoute());
      if (widget.body != null) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (widget.body!.notificationType == NotificationType.order) {
            Get.toNamed(RouteHelper.getOrderDetailsRoute(widget.body!.orderId,
                fromNotification: true));
          } else if (widget.body!.notificationType ==
              NotificationType.message) {
            Get.toNamed(RouteHelper.getChatRoute(
                notificationBody: widget.body,
                conversationID: widget.body!.conversationId,
                fromNotification: true));
          } else if (widget.body!.notificationType == NotificationType.block ||
              widget.body!.notificationType == NotificationType.unblock) {
            Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.notification));
          } else if (widget.body!.notificationType ==
                  NotificationType.add_fund ||
              widget.body!.notificationType == NotificationType.referral_earn ||
              widget.body!.notificationType == NotificationType.CashBack) {
            Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true));
          } else if (widget.body!.notificationType ==
              NotificationType.news_comment_reply) {
            Get.find<NewsController>().setPendingNotification(widget.body);
            Get.toNamed(RouteHelper.getMainRoute('news'));
          } else {
            Get.toNamed(
                RouteHelper.getNotificationRoute(fromNotification: true));
          }
        });
      }
    } else {
      Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              XmarketImages.splashLogo,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
          // const Positioned(
          //   bottom: 50,
          //   left: 0,
          //   right: 0,
          //   child: Center(
          //     child: CircularProgressIndicator(color: Colors.orange),
          //   ),
          // ),
        ],
      ),
    );
  }
}
