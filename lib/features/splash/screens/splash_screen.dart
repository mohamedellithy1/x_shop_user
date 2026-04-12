// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:ride_sharing_user_app/common/widgets/no_internet_screen_widget.dart';
// import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
// import 'package:ride_sharing_user_app/features/notification/domain/models/notification_body_model.dart';
// import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
// import 'package:ride_sharing_user_app/features/splash/domain/models/deep_link_body.dart';
// import 'package:ride_sharing_user_app/helper/address_helper.dart';
// import 'package:ride_sharing_user_app/util/dimensions.dart';
// import 'package:ride_sharing_user_app/util/images.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ride_sharing_user_app/helper/splash_route_helper.dart';

/*
class XMarkSplashScreen extends StatefulWidget {
  final NotificationBodyModel? notificationBody;
  final DeepLinkBody? linkBody;
  const XMarkSplashScreen(
      {super.key, required this.notificationBody, required this.linkBody});

  @override
  XMarkSplashScreenState createState() => XMarkSplashScreenState();
}

class XMarkSplashScreenState extends State<XMarkSplashScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

  late AnimationController _animController;
  late Animation<Offset> _textSlideAnimation;

  bool _showText = false;
  String _displayText = "";

  @override
  void initState() {
    super.initState();

    // إعداد أنيميشن النص
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));

    // بعد شوية ابدأ النص
    Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        _animController.forward();
        setState(() => _showText = true);
        _startTextAnimation();
      }
    });

    // connectivity listener
    bool firstTime = true;
    _onConnectivityChanged = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile);

      if (!firstTime) {
        ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
        if (isConnected) {
          _route();
        } else {
          Get.to(const NoInternetScreen());
        }
      }

      firstTime = false;
    });

    Get.find<MarketSplashController>(tag: 'xmarket').initSharedData();
    if (AddressHelper.getAddressFromSharedPref() != null &&
        (AddressHelper.getAddressFromSharedPref()!.zoneIds == null ||
            AddressHelper.getAddressFromSharedPref()!.zoneData == null)) {
      AddressHelper.clearAddressFromSharedPref();
    }
    if (Get.find<MarketAuthController>().isGuestLoggedIn() ||
        Get.find<MarketAuthController>().isLoggedIn()) {
      // Get.find<MarketCartController>().getCartDataOnline();
    }
    // _route() هتتنفذ بعد ما الكلام يخلص
  }

  void _startTextAnimation() {
    String fullText = "رمضان كريم";
    for (int i = 0; i <= fullText.length; i++) {
      Timer(Duration(milliseconds: 80 * i), () {
        if (mounted) {
          setState(() {
            _displayText = fullText.substring(0, i);
          });

          // لما الكلام يكتمل، استنى شوية وبعدين انتقل
          if (i == fullText.length) {
            Timer(const Duration(milliseconds: 700), () {
              if (mounted) {
                _route();
              }
            });
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _onConnectivityChanged?.cancel();
    super.dispose();
  }

  void _route() {
    Get.find<MarketSplashController>(tag: 'xmarket').getConfigData(
        handleMaintenanceMode: true, notificationBody: widget.notificationBody);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: GetBuilder<MarketSplashController>(tag: 'xmarket', 
          id: 'xmarket',
          init: Get.find<MarketSplashController>(tag: 'xmarket'),
          builder: (splashController) {
            return Stack(
              children: [
                Image.asset(
                  Images.ramadanBg,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fill,
                ),
                Center(
                  child: splashController.hasConnection
                      ? Stack(
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_showText)
                              Positioned(
                                bottom: 35,
                                left: 20,
                                right: 20,
                                child: SlideTransition(
                                  position: _textSlideAnimation,
                                  child: Text(
                                    _displayText,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[700],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            // الصورة ثابتة
                            Image.asset(
                              "assets/image/xshop.png",
                              width: 500,
                              height: 500,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                            // النص - typewriter + slide من تحت
                          ],
                        )
                      : NoInternetScreen(
                          child: XMarkSplashScreen(
                              notificationBody: widget.notificationBody,
                              linkBody: widget.linkBody)),
                ),
              ],
            );
          }),
    );
  }
}
*/
