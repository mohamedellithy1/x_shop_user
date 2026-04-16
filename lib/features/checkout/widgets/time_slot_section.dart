import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/time_slot_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class TimeSlotSection extends StatelessWidget {
  final bool fromCart;
  final CheckoutController checkoutController;
  final bool tomorrowClosed;
  final bool todayClosed;
  final JustTheController tooltipController2;
  const TimeSlotSection({
    super.key,
    required this.fromCart,
    required this.checkoutController,
    required this.tomorrowClosed,
    required this.todayClosed,
    required this.tooltipController2,
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = Get.find<MarketAuthController>().isGuestLoggedIn();
    bool isDineIn = checkoutController.orderType == 'dine_in' ||
        checkoutController.orderType == 'take_away';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      (!isGuestLoggedIn &&
              fromCart &&
              !checkoutController.subscriptionOrder &&
              checkoutController.restaurant!.scheduleOrder! &&
              !isDineIn)
          ? Container(
              decoration: BoxDecoration(
                color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
                    ? const Color(0xFF141313)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                boxShadow: [
                  BoxShadow(
                      color: Get.find<MarketThemeController>(tag: 'xmarket')
                              .darkTheme
                          ? Colors.black.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 1))
                ],
              ),
              margin: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 0 : Dimensions.fontSizeDefault),
              padding: EdgeInsets.symmetric(
                  horizontal: isDesktop
                      ? Dimensions.paddingSizeLarge
                      : Dimensions.paddingSizeSmall,
                  vertical: Dimensions.paddingSizeSmall),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('preference_time'.tr, style: robotoMedium),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      JustTheTooltip(
                        backgroundColor: Colors.black87,
                        controller: tooltipController2,
                        preferredDirection: AxisDirection.right,
                        tailLength: 14,
                        tailBaseWidth: 20,
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('schedule_time_tool_tip'.tr,
                              style:
                                  robotoRegular.copyWith(color: Colors.white)),
                        ),
                        child: InkWell(
                          onTap: () => tooltipController2.showTooltip(),
                          child: const Icon(Icons.info_outline),
                        ),
                        // child: const Icon(Icons.info_outline),
                      ),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    InkWell(
                      onTap: () {
                        if (ResponsiveHelper.isDesktop(context)) {
                          if (checkoutController.canShowTimeSlot) {
                            checkoutController.showHideTimeSlot();
                          } else {
                            checkoutController.showHideTimeSlot();
                          }
                        } else {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (con) => TimeSlotBottomSheet(
                              tomorrowClosed: tomorrowClosed,
                              todayClosed: todayClosed,
                              restaurant: checkoutController.restaurant!,
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).disabledColor,
                              width: 0.3),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        height: 50,
                        child: Row(children: [
                          const SizedBox(width: Dimensions.paddingSizeLarge),
                          Builder(builder: (context) {
                            return Expanded(
                                child: Text(
                              (checkoutController.selectedDateSlot == 0 &&
                                          todayClosed) ||
                                      (checkoutController.selectedDateSlot ==
                                              1 &&
                                          tomorrowClosed) ||
                                      (checkoutController.selectedDateSlot ==
                                              2 &&
                                          checkoutController
                                              .customDateRestaurantClose)
                                  ? 'restaurant_is_closed'.tr
                                  : checkoutController.preferableTime.isNotEmpty
                                      ? checkoutController.preferableTime
                                      : (Get.find<MarketSplashController>(
                                                      tag: 'xmarket')
                                                  .configModel!
                                                  .instantOrder! &&
                                              checkoutController
                                                  .restaurant!.instantOrder!)
                                          ? 'now'.tr
                                          : 'select_preference_time'.tr,
                              style: robotoRegular.copyWith(
                                  color: (checkoutController.selectedDateSlot ==
                                                  0 &&
                                              todayClosed) ||
                                          (checkoutController
                                                      .selectedDateSlot ==
                                                  1 &&
                                              tomorrowClosed) ||
                                          (checkoutController
                                                      .selectedDateSlot ==
                                                  2 &&
                                              checkoutController
                                                  .customDateRestaurantClose)
                                      ? Theme.of(context).colorScheme.error
                                      : Get.find<MarketThemeController>(
                                                  tag: 'xmarket')
                                              .darkTheme
                                          ? Colors.white
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color),
                            ));
                          }),
                          Icon(Icons.access_time_filled_outlined,
                              color: Theme.of(context).primaryColor),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                        ]),
                      ),
                    ),
                    isDesktop && checkoutController.canShowTimeSlot
                        ? Padding(
                            padding: const EdgeInsets.only(
                                top: Dimensions.paddingSizeLarge),
                            child: TimeSlotBottomSheet(
                                tomorrowClosed: tomorrowClosed,
                                todayClosed: todayClosed,
                                restaurant: checkoutController.restaurant!),
                          )
                        : const SizedBox(),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ]),
            )
          : const SizedBox(),
      SizedBox(
          height: (fromCart &&
                  !checkoutController.subscriptionOrder &&
                  checkoutController.restaurant!.scheduleOrder! &&
                  !isDineIn)
              ? Dimensions.paddingSizeSmall
              : 0),
    ]);
  }

  Widget tobView(
      {required BuildContext context,
      required String title,
      required bool isSelected,
      required Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(title,
              style: isSelected
                  ? robotoBold.copyWith(color: Theme.of(context).primaryColor)
                  : robotoMedium),
          Divider(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
              thickness: isSelected ? 2 : 1),
        ],
      ),
    );
  }
}
