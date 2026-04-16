import 'dart:async';
// import 'package:stackfood_multivendor/features/checkout/widgets/offline_success_dialog.dart';
import 'package:stackfood_multivendor/common/widgets/custom_loader_widget.dart';
import 'package:stackfood_multivendor/features/dashboard/screens/dashboard_screen.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/subscription_schedule_model.dart';
import 'package:stackfood_multivendor/features/order/widgets/bottom_view_widget.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_info_section.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_pricing_section.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_details_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
// import 'package:stackfood_multivendor/common/widgets/custom_dialog_widget.dart';
// import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_page_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/styles.dart';

import 'package:stackfood_multivendor/core/realtime/delivery_realtime_service.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel? orderModel;
  final int? orderId;
  final bool fromOfflinePayment;
  final String? contactNumber;
  final bool fromGuestTrack;
  final bool fromNotification;
  final bool fromDineIn;
  const OrderDetailsScreen(
      {super.key,
      required this.orderModel,
      required this.orderId,
      this.contactNumber,
      this.fromOfflinePayment = false,
      this.fromGuestTrack = false,
      this.fromNotification = false,
      this.fromDineIn = false});

  @override
  OrderDetailsScreenState createState() => OrderDetailsScreenState();
}

class OrderDetailsScreenState extends State<OrderDetailsScreen>
    with WidgetsBindingObserver {
  final ScrollController scrollController = ScrollController();

  Future<void> _loadData() async {
    await Get.find<OrderController>()
        .trackOrder(widget.orderId.toString(), widget.orderModel, false,
            contactNumber: widget.contactNumber)
        .then((value) {
      // if (widget.fromOfflinePayment) {
      //   Future.delayed(
      //       const Duration(seconds: 2),
      //       () => showAnimatedDialog(
      //           Get.context!, OfflineSuccessDialog(orderId: widget.orderId)));
      // } else if (widget.fromDineIn) {
      //   Future.delayed(
      //       const Duration(seconds: 2),
      //       () => showAnimatedDialog(Get.context!,
      //           OfflineSuccessDialog(orderId: widget.orderId, isDineIn: true)));
      // }
    });
    Get.find<OrderController>().getOrderCancelReasons();
    Get.find<OrderController>().getOrderDetails(widget.orderId.toString());
    if (Get.find<OrderController>().trackModel != null) {
      Get.find<OrderController>().callTrackOrderApi(
          orderModel: Get.find<OrderController>().trackModel!,
          orderId: widget.orderId.toString(),
          contactNumber: widget.contactNumber);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadData();
    _initializeWebSocketConnection();
  }

  StreamSubscription? _realtimeSubscription;

  Future<void> _initializeWebSocketConnection() async {
    try {
      debugPrint('🔌 [OrderDetails] Ensuring WebSocket connection...');

      // Wait a bit if needed
      await Future.delayed(const Duration(milliseconds: 500));

      final profileController = Get.find<MarketProfileController>();

      final customerId = profileController.userInfoModel?.id?.toString() ??
          (AuthHelper.isGuestLoggedIn() ? AuthHelper.getGuestId() : '');

      if (customerId.isNotEmpty) {
        if (Get.isRegistered<UserRealtimeService>()) {
          final realtimeService = Get.find<UserRealtimeService>();
          await realtimeService.initializeListeners(customerId);

          // 🔄 Listen for socket status to handle reconnections if needed
          _realtimeSubscription?.cancel();
          _realtimeSubscription =
              realtimeService.isListening.listen((listening) {
            if (listening) {
              debugPrint(
                  '📡 [OrderDetails] Socket is listening, UI will update on events');
            }
          });
        }
      }
    } catch (e, stackTrace) {
      debugPrint(
          '❌ [OrderDetails] Failed to initialize WebSocket: $e\n$stackTrace');
    }
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Get.find<OrderController>().callTrackOrderApi(
          orderModel: Get.find<OrderController>().trackModel!,
          orderId: widget.orderId.toString(),
          contactNumber: widget.contactNumber);
      _initializeWebSocketConnection();
    } else if (state == AppLifecycleState.paused) {
      Get.find<OrderController>().cancelTimer();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _realtimeSubscription?.cancel();

    Get.find<OrderController>().cancelTimer();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        if (((widget.orderModel == null || widget.fromOfflinePayment) &&
                !widget.fromGuestTrack) ||
            widget.fromNotification) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else if (widget.fromGuestTrack) {
          return;
        } else {
          return;
        }
      },
      child: GetBuilder<OrderController>(builder: (orderController) {
        double? deliveryCharge = 0;
        double itemsPrice = 0;
        double? discount = 0;
        double? couponDiscount = 0;
        double? tax = 0;
        double addOns = 0;
        double? dmTips = 0;
        double extraPackagingCharge = 0;
        double referrerBonusAmount = 0;
        bool showChatPermission = true;
        // double? additionalCharge = 0;
        // bool? taxIncluded = false;
        OrderModel? order = orderController.trackModel;
        bool subscription = false;
        bool isDineIn = false;
        List<String> schedules = [];
        if (orderController.orderDetails != null && order != null) {
          isDineIn = order.orderType == 'dine_in';
          subscription = order.subscription != null;

          if (subscription) {
            if (order.subscription!.type == 'weekly') {
              List<String> weekDays = [
                'sunday',
                'monday',
                'tuesday',
                'wednesday',
                'thursday',
                'friday',
                'saturday'
              ];
              for (SubscriptionScheduleModel schedule
                  in orderController.schedules!) {
                schedules.add(
                    '${weekDays[schedule.day!].tr} (${DateConverter.convertTimeToTime(schedule.time!)})');
              }
            } else if (order.subscription!.type == 'monthly') {
              for (SubscriptionScheduleModel schedule
                  in orderController.schedules!) {
                schedules.add(
                    '${'day_capital'.tr} ${schedule.day} (${DateConverter.convertTimeToTime(schedule.time!)})');
              }
            } else {
              schedules.add(DateConverter.convertTimeToTime(
                  orderController.schedules![0].time!));
            }
          }
          if (order.orderType == 'delivery') {
            deliveryCharge = order.deliveryCharge;
            dmTips = order.dmTips;
          }
          couponDiscount = order.couponDiscountAmount;
          discount = order.restaurantDiscountAmount;
          tax = order.totalTaxAmount;
          extraPackagingCharge = order.extraPackagingAmount!;
          referrerBonusAmount = order.referrerBonusAmount!;
          itemsPrice = (order.orderAmount ?? 0) -
              (order.deliveryCharge ?? 0) -
              (order.additionalCharge ?? 0);
          for (OrderDetailsModel orderDetails
              in orderController.orderDetails!) {
            for (AddOn addOn in orderDetails.addOns!) {
              addOns = addOns + (addOn.price! * addOn.quantity!);
            }
          }
          if (order.restaurant != null) {
            if (order.restaurant!.restaurantModel == 'commission') {
              showChatPermission = true;
            } else if (order.restaurant!.restaurantSubscription != null &&
                order.restaurant!.restaurantSubscription!.chat == 1) {
              showChatPermission = true;
            } else {
              showChatPermission = false;
            }
          }
        }
        double total = order?.orderAmount ?? 0;
        double subTotal = total;

        return GetBuilder<MarketThemeController>(
          init: Get.find<MarketThemeController>(tag: 'xmarket'),
          builder: (marketThemeController) {
            return Theme(
              data: marketThemeController.darkTheme ? darkTheme : lightTheme,
              child: Scaffold(
                backgroundColor: marketThemeController.darkTheme
                    ? Colors.black
                    : Color(0xFFfafef5),
                appBar: (!isDesktop
                    ? PreferredSize(
                        preferredSize: const Size.fromHeight(kToolbarHeight),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFe3ebd5),
                                Color(0xFFfafff4),
                                Color(0xFFe3ebd5),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),

                            // gradient: LinearGradient(
                            //   colors: [Color(0xFFd6e0c4), Color(0xFFe7feba)],
                            //   begin: Alignment.topLeft,
                            //   end: Alignment.bottomRight,
                            // ),
                          ),
                          child: AppBar(
                            title: Column(children: [
                              Text(
                                  '${subscription ? 'subscription'.tr : 'order'.tr} # ${order?.id ?? ''}',
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color: Color(0xFF55745a))),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall),
                            ]),
                            centerTitle: true,
                            leading: IconButton(
                              icon: const Icon(Icons.arrow_back_ios,
                                  color: Colors.black),
                              onPressed: () {
                                if ((widget.orderModel == null ||
                                        widget.fromOfflinePayment) &&
                                    !widget.fromGuestTrack) {
                                  Get.offAllNamed(
                                      RouteHelper.getInitialRoute());
                                } else if (widget.fromGuestTrack) {
                                  Get.back();
                                } else {
                                  Get.back();
                                }
                              },
                            ),
                            actions: const [SizedBox()],
                            backgroundColor: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
                            elevation: 0,
                          ),
                        ),
                      )
                    : CustomAppBarWidget(
                        title: subscription
                            ? 'subscription_details'.tr
                            : 'order_details'.tr,
                        onBackPressed: () {
                          if (((widget.orderModel == null ||
                                      widget.fromOfflinePayment) &&
                                  !widget.fromGuestTrack) ||
                              widget.fromNotification) {
                            Get.offAllNamed(RouteHelper.getInitialRoute());
                          } else if (widget.fromGuestTrack) {
                            Get.back();
                          } else {
                            Get.back();
                          }
                        })) as PreferredSizeWidget?,
                endDrawer: const MenuDrawerWidget(),
                endDrawerEnableOpenDragGesture: false,
                body: SafeArea(
                  child: (order != null && orderController.orderDetails != null)
                      ? Column(children: [
                          WebScreenTitleWidget(
                              title: subscription
                                  ? 'subscription_details'.tr
                                  : 'order_details'.tr),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: SizedBox(
                                width: Dimensions.webMaxWidth,
                                child: isDesktop
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            top: Dimensions.paddingSizeLarge),
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  flex: 6,
                                                  child: Column(
                                                    children: [
                                                      subscription
                                                          ? Text(
                                                              '${'subscription'.tr} # ${order.id.toString()}',
                                                              style: robotoBold
                                                                  .copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeLarge))
                                                          : const SizedBox(),
                                                      SizedBox(
                                                          height: subscription
                                                              ? Dimensions
                                                                  .paddingSizeExtraSmall
                                                              : 0),
                                                      subscription
                                                          ? Text(
                                                              '${'your_order_is'.tr} ${order.orderStatus}',
                                                              style: robotoRegular.copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor))
                                                          : const SizedBox(),
                                                      SizedBox(
                                                          height: subscription
                                                              ? Dimensions
                                                                  .paddingSizeLarge
                                                              : 0),
                                                      OrderInfoSection(
                                                          order: order,
                                                          orderController:
                                                              orderController,
                                                          schedules: schedules,
                                                          showChatPermission:
                                                              showChatPermission,
                                                          contactNumber: widget
                                                              .contactNumber,
                                                          totalAmount: total),
                                                    ],
                                                  )),
                                              const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeLarge),
                                              Expanded(
                                                  flex: 4,
                                                  child: OrderPricingSection(
                                                    itemsPrice: itemsPrice,
                                                    addOns: addOns,
                                                    order: order,
                                                    subTotal: subTotal,
                                                    discount: discount ?? 0,
                                                    couponDiscount:
                                                        couponDiscount ?? 0,
                                                    tax: tax ?? 0,
                                                    dmTips: dmTips ?? 0,
                                                    deliveryCharge:
                                                        deliveryCharge ?? 0,
                                                    total: total,
                                                    orderController:
                                                        orderController,
                                                    orderId: widget.orderId,
                                                    contactNumber:
                                                        widget.contactNumber,
                                                    extraPackagingAmount:
                                                        extraPackagingCharge,
                                                    referrerBonusAmount:
                                                        referrerBonusAmount,
                                                  ))
                                            ]),
                                      )
                                    : Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical:
                                                Dimensions.paddingSizeDefault),
                                        child: Column(children: [
                                          OrderInfoSection(
                                              order: order,
                                              orderController: orderController,
                                              schedules: schedules,
                                              showChatPermission:
                                                  showChatPermission,
                                              contactNumber:
                                                  widget.contactNumber,
                                              totalAmount: total),
                                          Container(
                                            color:
                                                marketThemeController.darkTheme
                                                    ? Colors.black
                                                    : Colors.white,
                                            child: Column(children: [
                                              OrderPricingSection(
                                                itemsPrice: itemsPrice,
                                                addOns: addOns,
                                                order: order,
                                                subTotal: subTotal,
                                                discount: discount ?? 0,
                                                couponDiscount:
                                                    couponDiscount ?? 0,
                                                tax: tax ?? 0,
                                                dmTips: dmTips ?? 0,
                                                deliveryCharge:
                                                    deliveryCharge ?? 0,
                                                total: total,
                                                orderController:
                                                    orderController,
                                                orderId: widget.orderId,
                                                contactNumber:
                                                    widget.contactNumber,
                                                extraPackagingAmount:
                                                    extraPackagingCharge,
                                                referrerBonusAmount:
                                                    referrerBonusAmount,
                                              ),
                                              !isDesktop
                                                  ? BottomViewWidget(
                                                      orderController:
                                                          orderController,
                                                      order: order,
                                                      orderId: widget.orderId,
                                                      total: total,
                                                      contactNumber:
                                                          widget.contactNumber)
                                                  : const SizedBox(),
                                            ]),
                                          ),
                                        ]),
                                      ),
                              ),
                            ),
                          ),
                        ])
                      : const Center(child: CustomLoaderWidget()),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
