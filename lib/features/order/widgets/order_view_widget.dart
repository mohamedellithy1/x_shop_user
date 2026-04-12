import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_loader_widget.dart';
import 'package:stackfood_multivendor/common/enums/order_status.dart';
import 'package:stackfood_multivendor/common/enums/order_type.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_details_model.dart';
import 'package:stackfood_multivendor/features/order/screens/order_details_screen.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_shimmer_widget.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/review/domain/models/rate_review_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class OrderViewWidget extends StatelessWidget {
  final bool isRunning;
  final bool isSubscription;
  const OrderViewWidget(
      {super.key, required this.isRunning, this.isSubscription = false});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    bool isDeskTop = ResponsiveHelper.isDesktop(context);
    final MarketThemeController themeController =
        Get.find<MarketThemeController>(tag: 'xmarket');

    return Scaffold(
      backgroundColor: themeController.darkTheme ? Colors.black : Colors.white,
      body: GetBuilder<OrderController>(builder: (orderController) {
        List<OrderModel>? orderList;
        bool paginate = false;
        int pageSize = 1;
        int offset = 1;
        if (orderController.runningOrderList != null &&
            orderController.historyOrderList != null) {
          orderList = isSubscription
              ? orderController.runningSubscriptionOrderList
              : isRunning
                  ? orderController.runningOrderList
                  : orderController.historyOrderList;
          paginate = isSubscription
              ? orderController.runningSubscriptionPaginate
              : isRunning
                  ? orderController.runningPaginate
                  : orderController.historyPaginate;
          pageSize = isSubscription
              ? (orderController.runningSubscriptionPageSize! / 10).ceil()
              : isRunning
                  ? (orderController.runningPageSize! / 10).ceil()
                  : (orderController.historyPageSize! / 10).ceil();
          offset = isSubscription
              ? orderController.runningSubscriptionOffset
              : isRunning
                  ? orderController.runningOffset
                  : orderController.historyOffset;
        }
        scrollController.addListener(() {
          if (scrollController.position.pixels ==
                  scrollController.position.maxScrollExtent &&
              orderList != null &&
              !paginate) {
            if (offset < pageSize) {
              Get.find<OrderController>()
                  .setOffset(offset + 1, isRunning, isSubscription);
              debugPrint('end of the page');
              Get.find<OrderController>()
                  .showBottomLoader(isRunning, isSubscription);
              if (isRunning) {
                Get.find<OrderController>()
                    .getRunningOrders(offset + 1, limit: 10);
              } else if (isSubscription) {
                Get.find<OrderController>()
                    .getRunningSubscriptionOrders(offset + 1);
              } else {
                Get.find<OrderController>().getHistoryOrders(offset + 1);
              }
            }
          }
        });

        return orderList != null
            ? orderList.isNotEmpty
                ? RefreshIndicator(
                    color: Colors.orange,
                    onRefresh: () async {
                      if (isRunning) {
                        await orderController.getRunningOrders(1);
                      } else if (isSubscription) {
                        await orderController.getRunningSubscriptionOrders(1);
                      } else {
                        await orderController.getHistoryOrders(1);
                      }
                    },
                    child: SingleChildScrollView(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Center(
                          child: SizedBox(
                            width: Dimensions.webMaxWidth,
                            child: Column(children: [
                              GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisSpacing: isDeskTop
                                            ? Dimensions.paddingSizeLarge
                                            : Dimensions.paddingSizeLarge,
                                        mainAxisSpacing: isDeskTop
                                            ? Dimensions.paddingSizeSmall
                                            : 0,
                                        crossAxisCount: isDeskTop ? 2 : 1,
                                        mainAxisExtent: isDeskTop ? 195 : 190),
                                padding: isDeskTop
                                    ? const EdgeInsets.symmetric(
                                        vertical: Dimensions.paddingSizeLarge)
                                    : const EdgeInsets.all(
                                        Dimensions.paddingSizeSmall),
                                itemCount: orderList.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  String dineInOrderStatus = '';
                                  String? orderStatus =
                                      orderList![index].orderStatus;
                                  bool isDineIn = orderList[index].orderType ==
                                      OrderType.dine_in.name;
                                  bool isDelivery =
                                      orderList[index].orderType ==
                                          OrderType.delivery.name;
                                  bool delivered =
                                      orderList[index].orderStatus ==
                                          OrderStatus.delivered.name;
                                  bool cancelled =
                                      orderList[index].orderStatus ==
                                          OrderStatus.canceled.name;
                                  bool failed = orderList[index].orderStatus ==
                                      OrderStatus.failed.name;
                                  bool refundRequestCanceled = orderList[index]
                                          .orderStatus ==
                                      OrderStatus.refund_request_canceled.name;

                                  if (isDineIn) {
                                    dineInOrderStatus = orderStatus ==
                                            OrderStatus.processing.name
                                        ? 'cooking'.tr
                                        : orderStatus ==
                                                OrderStatus.handover.name
                                            ? 'ready_to_serve'.tr
                                            : orderStatus ==
                                                    OrderStatus.pending.name
                                                ? 'pending'.tr
                                                : orderStatus ==
                                                        OrderStatus
                                                            .canceled.name
                                                    ? 'canceled'.tr
                                                    : orderStatus ==
                                                            OrderStatus
                                                                .confirmed.name
                                                        ? 'confirmed'.tr
                                                        : 'served'.tr;
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: Dimensions.paddingSizeSmall),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: themeController.darkTheme
                                            ? const Color(0xFF242424)
                                            : Colors.white,
                                        // boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .disabledColor
                                                .withValues(alpha: 0.3)),
                                      ),
                                      child: CustomInkWellWidget(
                                        onTap: () {
                                          Get.toNamed(
                                            RouteHelper.getOrderDetailsRoute(
                                                orderList![index].id),
                                            arguments: OrderDetailsScreen(
                                                orderId: orderList[index].id,
                                                orderModel: orderList[index]),
                                          );
                                        },
                                        radius: Dimensions.radiusDefault,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                    Dimensions
                                                        .paddingSizeSmall),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(1),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: themeController
                                                                      .darkTheme
                                                                  ? Colors.black
                                                                  : Colors
                                                                      .white,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      Dimensions
                                                                          .radiusSmall),
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      Dimensions
                                                                          .radiusSmall),
                                                              child:
                                                                  CustomImageWidget(
                                                                image: orderList[
                                                                            index]
                                                                        .restaurant
                                                                        ?.logoFullUrl ??
                                                                    '',
                                                                height: 40,
                                                                width: 40,
                                                                fit: BoxFit
                                                                    .cover,
                                                                isRestaurant:
                                                                    true,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: Dimensions
                                                                  .paddingSizeSmall),
                                                          Expanded(
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                      '${'order'.tr} # ${orderList[index].id}',
                                                                      style: robotoBold.copyWith(
                                                                          color: themeController.darkTheme
                                                                              ? Colors.white
                                                                              : Colors.black)),
                                                                  const SizedBox(
                                                                      height: Dimensions
                                                                          .paddingSizeExtraSmall),
                                                                  Text(
                                                                    DateConverter.dateTimeStringToDateTimeToLines(
                                                                        orderList[index]
                                                                            .createdAt!),
                                                                    style: robotoRegular.copyWith(
                                                                        color: themeController.darkTheme
                                                                            ? Colors
                                                                                .grey
                                                                            : Colors
                                                                                .black,
                                                                        fontSize:
                                                                            Dimensions.fontSizeSmall),
                                                                  ),
                                                                ]),
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    Dimensions
                                                                        .paddingSizeSmall,
                                                                vertical: Dimensions
                                                                    .paddingSizeExtraSmall),
                                                            margin: EdgeInsets.only(
                                                                bottom: isDeskTop
                                                                    ? Dimensions
                                                                        .paddingSizeOverLarge
                                                                    : Dimensions
                                                                        .paddingSizeDefault),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      Dimensions
                                                                          .radiusSmall),
                                                              color: themeController
                                                                      .darkTheme
                                                                  ? Colors.black
                                                                  : Colors
                                                                      .white,
                                                            ),
                                                            child: Text(
                                                              isDineIn
                                                                  ? dineInOrderStatus
                                                                  : orderStatus ==
                                                                          OrderStatus
                                                                              .handover
                                                                              .name
                                                                      ? 'جاري التسليم'
                                                                      : orderStatus
                                                                          !.tr,
                                                              style: robotoMedium.copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeExtraSmall,
                                                                  color: themeController
                                                                          .darkTheme
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black),
                                                            ),
                                                          ),
                                                        ]),
                                                    SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeDefault),
                                                    Row(children: [
                                                      Expanded(
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Container(
                                                              padding: const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      Dimensions
                                                                          .paddingSizeSmall,
                                                                  vertical:
                                                                      Dimensions
                                                                          .paddingSizeExtraSmall),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        Dimensions
                                                                            .radiusExtraLarge),
                                                                color: themeController
                                                                        .darkTheme
                                                                    ? Colors
                                                                        .black
                                                                    : Colors
                                                                        .white,
                                                              ),
                                                              child: Text(
                                                                orderList[index]
                                                                        .restaurant
                                                                        ?.name ??
                                                                    '',
                                                                style: robotoRegular.copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeSmall,
                                                                    color: themeController.darkTheme
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width: Dimensions
                                                              .paddingSizeLarge),
                                                    ]),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeExtraSmall),
                                              Container(
                                                padding: EdgeInsets.all(
                                                    Dimensions
                                                        .paddingSizeSmall),
                                                decoration: BoxDecoration(
                                                  color: themeController
                                                          .darkTheme
                                                      ? const Color(0xFF1C1C1C)
                                                      : Colors.white,
                                                  borderRadius: BorderRadius.only(
                                                      bottomLeft: Radius
                                                          .circular(Dimensions
                                                              .radiusDefault),
                                                      bottomRight: Radius
                                                          .circular(Dimensions
                                                              .radiusDefault)),
                                                ),
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        PriceConverter
                                                            .convertPrice(
                                                                orderList[index]
                                                                    .orderAmount),
                                                        style: robotoBold.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeLarge,
                                                            color: themeController
                                                                    .darkTheme
                                                                ? Colors.white
                                                                : Colors.black),
                                                      ),
                                                      (isRunning ||
                                                              isSubscription)
                                                          ? isDelivery
                                                              ? InkWell(
                                                                  onTap: () => Get.toNamed(
                                                                      RouteHelper.getOrderTrackingRoute(
                                                                          orderList![index]
                                                                              .id,
                                                                          null)),
                                                                  child:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            Dimensions
                                                                                .paddingSizeSmall,
                                                                        vertical:
                                                                            7),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              Dimensions.radiusMedium),
                                                                      color: themeController.darkTheme
                                                                          ? Colors
                                                                              .black
                                                                          : Colors
                                                                              .white,
                                                                      border: Border.all(
                                                                          width:
                                                                              1,
                                                                          color: themeController.darkTheme
                                                                              ? Colors.white
                                                                              : Colors.black),
                                                                    ),
                                                                    child: Text(
                                                                        'track_order'
                                                                            .tr,
                                                                        style: robotoMedium
                                                                            .copyWith(
                                                                          fontSize:
                                                                              Dimensions.fontSizeSmall,
                                                                          color: themeController.darkTheme
                                                                              ? Colors.white
                                                                              : Colors.black,
                                                                        )),
                                                                  ),
                                                                )
                                                              : const SizedBox()
                                                          : Row(children: [
                                                              (!isSubscription &&
                                                                      delivered &&
                                                                      orderList[index]
                                                                              .itemCampaignId ==
                                                                          null)
                                                                  ? InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        await Get.find<OrderController>().getOrderDetails(orderList![index]
                                                                            .id
                                                                            .toString());

                                                                        List<OrderDetailsModel>
                                                                            orderDetailsList =
                                                                            [];
                                                                        List<int?>
                                                                            orderDetailsIdList =
                                                                            [];
                                                                        for (var orderDetail
                                                                            in orderController.orderDetails!) {
                                                                          if (!orderDetailsIdList.contains(orderDetail
                                                                              .foodDetails!
                                                                              .id)) {
                                                                            orderDetailsList.add(orderDetail);
                                                                            orderDetailsIdList.add(orderDetail.foodDetails!.id);
                                                                          }
                                                                        }
                                                                        orderController
                                                                            .cancelTimer();
                                                                        RateReviewModel
                                                                            rateReviewModel =
                                                                            RateReviewModel(
                                                                                orderDetailsList: orderDetailsList,
                                                                                deliveryMan: orderList[index].deliveryMan);
                                                                        await Get.toNamed(
                                                                            RouteHelper.getReviewRoute(rateReviewModel));
                                                                        orderController.callTrackOrderApi(
                                                                            orderModel:
                                                                                orderList[index],
                                                                            orderId: orderList[index].id.toString(),
                                                                            contactNumber: orderList[index].deliveryAddress?.contactPersonNumber);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                Dimensions.paddingSizeSmall,
                                                                            vertical: 7),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border: Border.all(
                                                                              color: themeController.darkTheme ? Colors.white : Colors.black,
                                                                              width: 1),
                                                                          borderRadius:
                                                                              BorderRadius.circular(Dimensions.radiusMedium),
                                                                          color: themeController.darkTheme
                                                                              ? Colors.black
                                                                              : Colors.white,
                                                                        ),
                                                                        child: Text(
                                                                            'give_review'
                                                                                .tr,
                                                                            style:
                                                                                robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: themeController.darkTheme ? Colors.white : Colors.black)),
                                                                      ),
                                                                    )
                                                                  : SizedBox(),
                                                              SizedBox(
                                                                  width: (!isSubscription &&
                                                                          delivered &&
                                                                          orderList[index].itemCampaignId ==
                                                                              null)
                                                                      ? Dimensions
                                                                          .paddingSizeSmall
                                                                      : 0),
                                                              !isSubscription &&
                                                                      Get.find<MarketSplashController>(
                                                                              tag:
                                                                                  'xmarket')
                                                                          .configModel!
                                                                          .repeatOrderOption! &&
                                                                      (delivered ||
                                                                          cancelled ||
                                                                          failed ||
                                                                          refundRequestCanceled)
                                                                  ? orderList[index]
                                                                              .itemCampaignId ==
                                                                          null
                                                                      ? InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            await Get.find<OrderController>().getOrderDetails(orderList![index].id.toString());
                                                                            orderController.reOrder(orderController.orderDetails!,
                                                                                orderList[index].restaurant!.zoneId);
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 7),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                                                                              color: themeController.darkTheme ? Colors.black : Colors.white,
                                                                              border: Border.all(width: 1, color: themeController.darkTheme ? Colors.white : Colors.black),
                                                                            ),
                                                                            child: Text('buy_again'.tr,
                                                                                style: robotoMedium.copyWith(
                                                                                  fontSize: Dimensions.fontSizeSmall,
                                                                                  color: themeController.darkTheme ? Colors.white : Colors.black,
                                                                                )),
                                                                          ),
                                                                        )
                                                                      : SizedBox()
                                                                  : SizedBox(),
                                                            ]),
                                                    ]),
                                              ),
                                            ]),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              paginate
                                  ? const Center(
                                      child: CustomLoaderWidget(size: 40),
                                    )
                                  : const SizedBox(),
                            ]),
                          ),
                        )),
                  )
                : SingleChildScrollView(
                    child: Center(
                    child: NoDataScreen(
                        title: isRunning
                            ? 'no_order_ranning'.tr
                            : 'no_order_history'.tr,
                        isEmptyOrder: true),
                  ))
            : OrderShimmerWidget(orderController: orderController);
      }),
    );
  }
}
