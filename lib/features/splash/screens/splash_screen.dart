import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
// import 'package:stackfood_multivendor/util/images.dart';

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
    Get.find<MarketSplashController>(tag: 'xmarket').getConfigData(source: DataSourceEnum.client).then((value) {
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
      Get.offAllNamed(RouteHelper.getInitialRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/image/xshop.png',
              width: 200,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.orange),
          ],
        ),
      ),
    );
  }
}
