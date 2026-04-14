import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/xmarket_images.dart';

class XMarkSplashScreen extends StatefulWidget {
  const XMarkSplashScreen({super.key});

  @override
  XMarkSplashScreenState createState() => XMarkSplashScreenState();
}

class XMarkSplashScreenState extends State<XMarkSplashScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  void _route() {
    debugPrint('🚀 [Splash] Starting config fetch...');

    // محاولة جلب البيانات مع تحديد مهلة زمنية (Timeout) للأمان
    Get.find<MarketSplashController>(tag: 'xmarket')
        .getConfigData(source: DataSourceEnum.client)
        .then((value) {
      debugPrint('✅ [Splash] Config fetch completed.');
      _navigateToHome();
    }).catchError((error) {
      debugPrint('❌ [Splash] Config fetch error: $error');
      _navigateToHome(); // برضه هنحول للهوم عشان ميفضلش معلق
    });

    // سياج أمان: لو البيانات اتأخرت أكتر من 5 ثواني حول للهوم فوراً
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        debugPrint('⏰ [Splash] Timeout reached, navigating to home...');
        _navigateToHome();
      }
    });
  }

  void _navigateToHome() {
    if (Get.currentRoute != RouteHelper.getInitialRoute()) {
      if (Get.find<MarketAuthController>().isLoggedIn()) {
        Get.offAllNamed(RouteHelper.getInitialRoute());
      } else {
        Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
      }
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
