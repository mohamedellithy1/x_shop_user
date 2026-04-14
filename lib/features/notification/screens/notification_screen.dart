import 'package:stackfood_multivendor/common/enums/order_status.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/notification/controllers/notification_controller.dart';
import 'package:stackfood_multivendor/features/notification/widgets/add_fund_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/notification/widgets/notification_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/notification/widgets/notification_dialog_widget.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:stackfood_multivendor/common/widgets/web_page_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatefulWidget {
  final bool fromNotification;
  const NotificationScreen({super.key, this.fromNotification = false});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController scrollController = ScrollController();

  void _loadData() async {
    Get.find<MarketNotificationController>().clearNotification();
    if (Get.find<MarketSplashController>(tag: 'xmarket').configModel == null) {
      await Get.find<MarketSplashController>(tag: 'xmarket').getConfigData();
    }
    if (Get.find<MarketAuthController>().isLoggedIn()) {
      Get.find<MarketNotificationController>().getNotificationList(true);
    }
    if (Get.find<MarketAuthController>().isLoggedIn() &&
        (Get.find<MarketProfileController>().userInfoModel?.walletBalance ==
            null)) {
      await Get.find<MarketProfileController>().getUserInfo();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        if (widget.fromNotification) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else {
          return;
        }
      },
      child: Scaffold(
        backgroundColor:
            Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
                ? Colors.black
                : Color(0xFFfafef5),
        appBar: CustomAppBarWidget(
            title: 'notification'.tr,
            // bgColor: Colors.transparent,
            onBackPressed: () {
              if (widget.fromNotification) {
                Get.offAllNamed(RouteHelper.getInitialRoute());
              } else {
                Get.back();
              }
            }),
        endDrawer: const MenuDrawerWidget(),
        endDrawerEnableOpenDragGesture: false,
        body: Get.find<MarketAuthController>().isLoggedIn()
            ? GetBuilder<MarketNotificationController>(
                builder: (notificationController) {
                if (notificationController.notificationList != null) {
                  notificationController.saveSeenNotificationCount(
                      notificationController.notificationList!.length);
                }
                List<DateTime> dateTimeList = [];
                return notificationController.notificationList != null
                    ? notificationController.notificationList!.isNotEmpty
                        ? RefreshIndicator(
                            color: Colors.orange,
                            onRefresh: () async {
                              await notificationController
                                  .getNotificationList(true);
                            },
                            child: SingleChildScrollView(
                              controller: scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  WebScreenTitleWidget(
                                      title: 'notification'.tr),
                                  Center(
                                      child: SizedBox(
                                          width: Dimensions.webMaxWidth,
                                          child: ListView.builder(
                                            itemCount: notificationController
                                                .notificationList!.length,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              DateTime originalDateTime =
                                                  DateConverter
                                                      .dateTimeStringToDate(
                                                          notificationController
                                                              .notificationList![
                                                                  index]
                                                              .createdAt!);
                                              DateTime convertedDate = DateTime(
                                                  originalDateTime.year,
                                                  originalDateTime.month,
                                                  originalDateTime.day);
                                              bool addTitle = false;
                                              if (!dateTimeList
                                                  .contains(convertedDate)) {
                                                addTitle = true;
                                                dateTimeList.add(convertedDate);
                                              }
                                              bool isSeen = notificationController
                                                  .getSeenNotificationIdList()!
                                                  .contains(
                                                      notificationController
                                                          .notificationList![
                                                              index]
                                                          .id);

                                              return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    addTitle
                                                        ? Center(
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                  .symmetric(
                                                                  vertical:
                                                                      Dimensions
                                                                          .paddingSizeSmall),
                                                              child: Text(
                                                                DateConverter.dateTimeStringToDateOnly(
                                                                    notificationController
                                                                        .notificationList![
                                                                            index]
                                                                        .createdAt!),
                                                                style: robotoRegular.copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .disabledColor),
                                                              ),
                                                            ),
                                                          )
                                                        : const SizedBox(),
                                                    Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4,
                                                          horizontal: Dimensions
                                                              .paddingSizeDefault),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Colors.black),
                                                        color: Colors.white,
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    Dimensions
                                                                        .radiusLarge)),
                                                      ),
                                                      child: InkWell(
                                                        onTap: () {
                                                          notificationController
                                                              .addSeenNotificationId(
                                                                  notificationController
                                                                      .notificationList![
                                                                          index]
                                                                      .id!);

                                                          if (notificationController.notificationList![index].data!.type == 'push_notification' ||
                                                              notificationController
                                                                      .notificationList![
                                                                          index]
                                                                      .data!
                                                                      .type ==
                                                                  'referral_code' ||
                                                              notificationController
                                                                      .notificationList![
                                                                          index]
                                                                      .data!
                                                                      .type ==
                                                                  'referral_earn') {
                                                            ResponsiveHelper
                                                                    .isDesktop(
                                                                        context)
                                                                ? showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return NotificationDialogWidget(
                                                                          notificationModel:
                                                                              notificationController.notificationList![index]);
                                                                    })
                                                                : showModalBottomSheet(
                                                                    isScrollControlled:
                                                                        true,
                                                                    useRootNavigator:
                                                                        true,
                                                                    context: Get
                                                                        .context!,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    shape:
                                                                        const RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(Dimensions
                                                                              .radiusExtraLarge),
                                                                          topRight:
                                                                              Radius.circular(Dimensions.radiusExtraLarge)),
                                                                    ),
                                                                    builder:
                                                                        (context) {
                                                                      return ConstrainedBox(
                                                                        constraints:
                                                                            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                                                                        child: NotificationBottomSheet(
                                                                            notificationModel:
                                                                                notificationController.notificationList![index]),
                                                                      );
                                                                    },
                                                                  );
                                                          } else if (notificationController
                                                                  .notificationList![
                                                                      index]
                                                                  .data!
                                                                  .type ==
                                                              'order_status') {
                                                            if (notificationController
                                                                        .notificationList![
                                                                            index]
                                                                        .data!
                                                                        .orderStatus ==
                                                                    OrderStatus
                                                                        .picked_up
                                                                        .name ||
                                                                notificationController
                                                                        .notificationList![
                                                                            index]
                                                                        .data!
                                                                        .orderStatus ==
                                                                    OrderStatus
                                                                        .handover
                                                                        .name) {
                                                              Get.toNamed(RouteHelper.getOrderTrackingRoute(
                                                                  notificationController
                                                                      .notificationList![
                                                                          index]
                                                                      .data!
                                                                      .orderId!,
                                                                  null));
                                                            } else {
                                                              Get.toNamed(RouteHelper.getOrderDetailsRoute(
                                                                  notificationController
                                                                      .notificationList![
                                                                          index]
                                                                      .data!
                                                                      .orderId!,
                                                                  fromGuestTrack:
                                                                      true));
                                                            }
                                                          } else if (notificationController
                                                                  .notificationList![
                                                                      index]
                                                                  .data!
                                                                  .type ==
                                                              'add_fund') {
                                                            ResponsiveHelper
                                                                    .isMobile(
                                                                        context)
                                                                ? Get
                                                                    .bottomSheet(
                                                                    AddFundBottomSheet(
                                                                        notificationModel:
                                                                            notificationController.notificationList![index]),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                    isScrollControlled:
                                                                        true,
                                                                  )
                                                                : Get.dialog(
                                                                    Dialog(
                                                                        child: AddFundBottomSheet(
                                                                            notificationModel:
                                                                                notificationController.notificationList![index])),
                                                                  );
                                                          }
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              vertical: Dimensions
                                                                  .paddingSizeLarge,
                                                              horizontal: Dimensions
                                                                  .paddingSizeDefault),
                                                          child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Expanded(
                                                                    child: Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Row(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            Expanded(
                                                                              child: Text(
                                                                                notificationController.notificationList![index].data!.title ?? '',
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: robotoBold.copyWith(
                                                                                  fontSize: Dimensions.fontSizeDefault,
                                                                                  color: isSeen ? Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5) : Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.9),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(width: Dimensions.paddingSizeSmall),
                                                                            Row(children: [
                                                                              Text(
                                                                                DateConverter.dateTimeStringToFormattedTime(notificationController.notificationList![index].createdAt!),
                                                                                style: robotoRegular.copyWith(color: isSeen ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8), fontSize: Dimensions.fontSizeExtraSmall),
                                                                              ),
                                                                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                                              Icon(
                                                                                Icons.access_time,
                                                                                size: 14,
                                                                                color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                                                                              ),
                                                                            ]),
                                                                          ]),
                                                                      const SizedBox(
                                                                          height:
                                                                              Dimensions.paddingSizeExtraSmall),
                                                                      Text(
                                                                        notificationController.notificationList![index].data!.description ??
                                                                            '',
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: robotoRegular.copyWith(
                                                                            color: isSeen
                                                                                ? Theme.of(context).disabledColor
                                                                                : Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8)),
                                                                      ),
                                                                    ])),
                                                              ]),
                                                        ),
                                                      ),
                                                    ),
                                                  ]);
                                            },
                                          ))),
                                ],
                              ),
                            ),
                          )
                        : NoDataScreen(
                            title: 'no_notification'.tr,
                            isCenter: true,
                            isEmptyNotification: true)
                    : const Center(child: CircularProgressIndicator());
              })
            : NotLoggedInScreen(callBack: (value) {
                _loadData();
                setState(() {});
              }),
      ),
    );
  }
}
