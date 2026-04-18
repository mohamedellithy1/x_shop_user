import 'dart:async';
import 'dart:io';
import 'package:stackfood_multivendor/theme/dark_theme.dart';
import 'package:stackfood_multivendor/theme/light_theme.dart';

import 'package:flutter/services.dart';
import 'package:stackfood_multivendor/features/cart/screens/cart_screen.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/congratulation_dialogue.dart';
import 'package:stackfood_multivendor/features/dashboard/widgets/registration_success_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/home/screens/home_screen.dart';
import 'package:stackfood_multivendor/features/menu/screens/menu_screen.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/screens/order_screen.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stackfood_multivendor/features/dashboard/widgets/address_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/dashboard/widgets/bottom_nav_item.dart';
import 'package:stackfood_multivendor/features/dashboard/widgets/running_order_view_widget.dart';
import 'package:stackfood_multivendor/features/favourite/screens/favourite_screen.dart';
import 'package:stackfood_multivendor/features/loyalty/controllers/loyalty_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/cart_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_dialog_widget.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/features/home/controllers/banner_controller.dart';
import 'package:stackfood_multivendor/news/screens/news.screens.dart';

final ThemeData darkTheme = dark;
final ThemeData lightTheme = light;

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final bool fromSplash;
  const DashboardScreen(
      {super.key, required this.pageIndex, this.fromSplash = false});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  bool _canExit = GetPlatform.isWeb ? true : false;
  late bool _isLogin;
  bool active = false;

  @override
  void initState() {
    super.initState();

    _isLogin = Get.find<MarketAuthController>().isLoggedIn();

    _showRegistrationSuccessBottomSheet();

    // if (_isLogin) {
    //   if (Get.find<MarketSplashController>(tag: 'xmarket').configModel!.loyaltyPointStatus! &&
    //       Get.find<LoyaltyController>().getEarningPint().isNotEmpty &&
    //       !ResponsiveHelper.isDesktop(Get.context)) {
    //     Future.delayed(
    //         const Duration(seconds: 1),
    //         () => showAnimatedDialog(
    //             Get.context!, const CongratulationDialogue()));
    //   }
    //   _suggestAddressBottomSheet();
    //   Get.find<OrderController>().getRunningOrders(1, notify: false);
    // }

    _pageIndex = widget.pageIndex;

    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      const XMarketHomeScreen(),
      const NewsScreen(),
      const CartScreen(fromNav: true),
      const OrderScreen(),
      const MenuScreen()
    ];

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });
  }

  void _showRegistrationSuccessBottomSheet() {
    bool canShowBottomSheet =
        Get.find<DashboardController>().getRegistrationSuccessfulSharedPref();
    if (canShowBottomSheet) {
      Future.delayed(const Duration(seconds: 1), () {
        ResponsiveHelper.isDesktop(Get.context)
            ? Get.dialog(const Dialog(child: RegistrationSuccessBottomSheet()))
                .then((value) {
                Get.find<DashboardController>()
                    .saveRegistrationSuccessfulSharedPref(false);
                Get.find<DashboardController>()
                    .saveIsRestaurantRegistrationSharedPref(false);
                setState(() {});
              })
            : showModalBottomSheet(
                context: Get.context!,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (con) => const RegistrationSuccessBottomSheet(),
              ).then((value) {
                Get.find<DashboardController>()
                    .saveRegistrationSuccessfulSharedPref(false);
                Get.find<DashboardController>()
                    .saveIsRestaurantRegistrationSharedPref(false);
                setState(() {});
              });
      });
    }
  }

  Future<void> _suggestAddressBottomSheet() async {
    active = await Get.find<DashboardController>().checkLocationActive();
    if (widget.fromSplash &&
        Get.find<DashboardController>().showLocationSuggestion &&
        active) {
      Future.delayed(const Duration(seconds: 1), () {
        showModalBottomSheet(
          context: Get.context!,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (con) => const AddressBottomSheet(),
        ).then((value) {
          Get.find<DashboardController>().hideSuggestedLocation();
          setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarketThemeController>(
        init: Get.find<MarketThemeController>(tag: 'xmarket'),
        builder: (marketThemeController) {
          return Theme(
            data: marketThemeController.darkTheme ? darkTheme : lightTheme,
            child: PopScope(
              canPop: Navigator.canPop(context),
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
                debugPrint('$_canExit');
                if (_pageIndex != 0) {
                  _setPage(0);
                } else {
                  if (_canExit) {
                    if (GetPlatform.isAndroid) {
                      SystemNavigator.pop();
                    } else if (GetPlatform.isIOS) {
                      exit(0);
                    }
                  }
                  if (!ResponsiveHelper.isDesktop(context)) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('back_press_again_to_exit'.tr,
                          style: const TextStyle(color: Colors.white)),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF9ebc67),
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    ));
                  }
                  _canExit = true;

                  Timer(const Duration(seconds: 2), () {
                    _canExit = false;
                  });
                }
              },
              child: Scaffold(
                key: _scaffoldKey,
                backgroundColor: marketThemeController.darkTheme
                    ? Colors.black
                    : Colors.white,
                floatingActionButton: const SizedBox(),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                bottomNavigationBar: ResponsiveHelper.isDesktop(context)
                    ? const SizedBox()
                    : GetBuilder<OrderController>(builder: (orderController) {
                        return (orderController.showBottomSheet &&
                                (orderController.runningOrderList != null &&
                                    orderController
                                        .runningOrderList!.isNotEmpty &&
                                    _isLogin))
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeDefault),
                                child: Container(
                                  height: 65,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: const Color(0xFF9ebc67),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: const Offset(0, 4),
                                        blurRadius: 3,
                                        color: Colors.black.withOpacity(0.3),
                                      )
                                    ],
                                  ),
                                  child: Row(children: [
                                    BottomNavItem(
                                        iconData: Icons.home,
                                        title: 'home'.tr,
                                        isSelected: _pageIndex == 0,
                                        onTap: () => _setPage(0)),
                                    BottomNavItem(
                                        iconData: Icons.newspaper,
                                        title: 'الاخبار',
                                        isSelected: _pageIndex == 1,
                                        onTap: () => _setPage(1)),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => _setPage(2),
                                        child: CartWidget(
                                          color: Colors.white,
                                          size: 25,
                                          iconColor: _pageIndex == 2
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.7),
                                          textColor: _pageIndex == 2
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ),
                                    BottomNavItem(
                                        iconData: Icons.shopping_bag,
                                        title: 'orders'.tr,
                                        isSelected: _pageIndex == 3,
                                        onTap: () => _setPage(3)),
                                    BottomNavItem(
                                        iconData: Icons.menu,
                                        title: 'القائمة',
                                        isSelected: _pageIndex == 4,
                                        onTap: () => _setPage(4)),
                                  ]),
                                ),
                              );
                      }),
                body: GetBuilder<OrderController>(builder: (orderController) {
                  List<OrderModel> runningOrder =
                      orderController.runningOrderList != null
                          ? orderController.runningOrderList!
                          : [];

                  List<OrderModel> reversOrder =
                      List.from(runningOrder.reversed);
                  return ExpandableBottomSheet(
                    background: PageView.builder(
                      controller: _pageController,
                      itemCount: _screens.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return _screens[index];
                      },
                    ),
                    persistentContentHeight: 100,
                    onIsContractedCallback: () {
                      if (!orderController.showOneOrder) {
                        orderController.showOrders();
                      }
                    },
                    onIsExtendedCallback: () {
                      if (orderController.showOneOrder) {
                        orderController.showOrders();
                      }
                    },
                    enableToggle: true,
                    expandableContent: (ResponsiveHelper.isDesktop(context) ||
                            !_isLogin ||
                            orderController.runningOrderList == null ||
                            orderController.runningOrderList!.isEmpty ||
                            !orderController.showBottomSheet)
                        ? const SizedBox()
                        : Dismissible(
                            key: UniqueKey(),
                            onDismissed: (direction) {
                              if (orderController.showBottomSheet) {
                                orderController.showRunningOrders();
                              }
                            },
                            child: RunningOrderViewWidget(
                                reversOrder: reversOrder,
                                onMoreClick: () {
                                  if (orderController.showBottomSheet) {
                                    orderController.showRunningOrders();
                                  }
                                  _setPage(3);
                                }),
                          ),
                  );
                }),
              ),
            ),
          );
        });
  }

  void _setPage(int pageIndex) {
    // لو المستخدم بيبعد عن Home (index 0) أو بيرجعلها
    // // final bannerController = Get.find<BannerController>();
    // if (_pageIndex == 0 && pageIndex != 0) {
    //   // مسافر من Home - وقف الفيديو وابدأ من الأول
    //   // bannerController.forcePauseVideo(true);
    //   bannerController.resetBanner();
    // } else if (pageIndex == 0 && _pageIndex != 0) {
    //   // راجع لـ Home - فك الإيقاف
    //   bannerController.forcePauseVideo(false);
    // }

    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }
}
