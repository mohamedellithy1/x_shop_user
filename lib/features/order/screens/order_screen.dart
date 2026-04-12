import 'package:stackfood_multivendor/features/dashboard/screens/dashboard_screen.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/widgets/guest_track_order_input_view_widget.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_view_widget.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    _tabController?.addListener(() {
      if (!_tabController!.indexIsChanging &&
          _tabController!.index != _currentIndex) {
        _currentIndex = _tabController!.index;
        if (AuthHelper.isLoggedIn()) {
          if (_currentIndex == 0) {
            Get.find<OrderController>()
                .getRunningOrders(1, limit: 10, notify: true, reload: false);
          } else {
            Get.find<OrderController>()
                .getHistoryOrders(1, notify: true, reload: false);
          }
        }
      }
    });

    initCall();
  }

  void initCall() {
    if (AuthHelper.isLoggedIn()) {
      Get.find<OrderController>().getRunningOrders(1, limit: 10, notify: false);
      Get.find<OrderController>()
          .getRunningSubscriptionOrders(1, notify: false);
      Get.find<OrderController>().getHistoryOrders(1, notify: false);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return GetBuilder<MarketThemeController>(
        init: Get.find<MarketThemeController>(tag: 'xmarket'),
        builder: (marketThemeController) {
          return Theme(
            data: marketThemeController.darkTheme ? darkTheme : lightTheme,
            child: Scaffold(
              backgroundColor:
                  marketThemeController.darkTheme ? Colors.black : Colors.white,
              appBar: CustomAppBarWidget(
                  title: 'orders'.tr,
                  isBackButtonExist: ResponsiveHelper.isDesktop(context)),
              endDrawer: const MenuDrawerWidget(),
              endDrawerEnableOpenDragGesture: false,
              body: isLoggedIn
                  ? GetBuilder<OrderController>(builder: (orderController) {
                      return Column(children: [
                        Container(
                          color: ResponsiveHelper.isDesktop(context)
                              ? Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1)
                              : Colors.transparent,
                          child: Column(
                            children: [
                              ResponsiveHelper.isDesktop(context)
                                  ? Center(
                                      child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: Dimensions.paddingSizeSmall),
                                      child: Text('orders'.tr,
                                          style: robotoMedium),
                                    ))
                                  : const SizedBox(),
                              Center(
                                child: SizedBox(
                                  width: Dimensions.webMaxWidth,
                                  child: Align(
                                    alignment:
                                        ResponsiveHelper.isDesktop(context)
                                            ? Alignment.centerLeft
                                            : Alignment.center,
                                    child: Container(
                                      width: ResponsiveHelper.isDesktop(context)
                                          ? 350
                                          : Dimensions.webMaxWidth,
                                      color: ResponsiveHelper.isDesktop(context)
                                          ? Colors.transparent
                                          : marketThemeController.darkTheme
                                              ? const Color(0xFF242424)
                                              : Colors.white,
                                      child: TabBar(
                                        controller: _tabController,
                                        indicatorColor: Colors.orange,
                                        indicatorWeight: 3,
                                        labelColor:
                                            marketThemeController.darkTheme
                                                ? Colors.orange
                                                : Colors.orange,
                                        unselectedLabelColor:
                                            marketThemeController.darkTheme
                                                ? Colors.white
                                                : Colors.black,
                                        unselectedLabelStyle:
                                            robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall),
                                        labelStyle: robotoBold.copyWith(
                                            fontSize: Dimensions.fontSizeSmall),
                                        tabs: [
                                          Tab(text: 'running'.tr),
                                          // Tab(text: 'subscription'.tr),
                                          Tab(text: 'history'.tr),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                            child: TabBarView(
                          controller: _tabController,
                          children: const [
                            OrderViewWidget(isRunning: true),
                            // OrderViewWidget(isRunning: false, isSubscription: true),
                            OrderViewWidget(isRunning: false),
                          ],
                        )),
                      ]);
                    })
                  : const GuestTrackOrderInputViewWidget(),
            ),
          );
        });
  }
}
