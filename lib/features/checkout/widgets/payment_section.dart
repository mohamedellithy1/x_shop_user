import 'package:stackfood_multivendor/common/widgets/custom_tool_tip.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/payment_method_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/extensions.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/xmarket_images.dart';

class PaymentSection extends StatelessWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final bool isOfflinePaymentActive;
  final double total;
  final CheckoutController checkoutController;
  const PaymentSection(
      {super.key,
      required this.isCashOnDeliveryActive,
      required this.isDigitalPaymentActive,
      required this.isWalletActive,
      required this.total,
      required this.checkoutController,
      required this.isOfflinePaymentActive});

  @override
  Widget build(BuildContext context) {
    double walletBalance =
        Get.find<MarketProfileController>().userInfoModel?.walletBalance ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? const Color(0xFF1b1b1b) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
              color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 1))
        ],
      ),
      margin: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.isDesktop(context)
              ? 0
              : Dimensions.fontSizeDefault),
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeLarge,
          vertical: Dimensions.paddingSizeDefault),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(spacing: Dimensions.paddingSizeSmall, children: [
            Text('payment_method'.tr, style: robotoMedium.copyWith(color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? Colors.white : Colors.black)),
          ]),
          InkWell(
            onTap: () {
              if (ResponsiveHelper.isDesktop(context)) {
                Get.dialog(Dialog(
                    backgroundColor: Colors.transparent,
                    child: PaymentMethodBottomSheet(
                      isCashOnDeliveryActive: isCashOnDeliveryActive,
                      isDigitalPaymentActive: isDigitalPaymentActive,
                      isWalletActive: isWalletActive,
                      totalPrice: total,
                      isOfflinePaymentActive: isOfflinePaymentActive,
                    )));
              } else {
                Get.bottomSheet(
                  PaymentMethodBottomSheet(
                    isCashOnDeliveryActive: isCashOnDeliveryActive,
                    isDigitalPaymentActive: isDigitalPaymentActive,
                    isWalletActive: isWalletActive,
                    totalPrice: total,
                    isOfflinePaymentActive: isOfflinePaymentActive,
                  ),
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  useRootNavigator: true,
                );
              }
            },
            child:
                Image.asset(XmarketImages.paymentSelect, height: 24, width: 24),
          ),
        ]),
        const Divider(),
        Container(
          child: checkoutController.paymentMethodIndex == 0 &&
                  !checkoutController.isPartialPay
              ? Row(children: [
                  Image.asset(XmarketImages.cash, width: 20, height: 20),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                      child: Row(
                    children: [
                      Text(
                        'cash_on_delivery'.tr,
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? Colors.white70 : Colors.black),
                      ),
                    ],
                  )),
                  Text(
                    PriceConverter.convertPrice(total),
                    textDirection: TextDirection.ltr,
                    style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).primaryColor),
                  )
                ])
              : checkoutController.isPartialPay
                  ? Column(children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('paid_by_wallet'.tr,
                                style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? Colors.white70 : Colors.black)),
                            Text(
                              PriceConverter.convertPrice(walletBalance),
                              textDirection: TextDirection.ltr,
                              style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? Colors.white : Colors.black),
                            ),
                          ]),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Row(children: [
                        Text(
                          '${checkoutController.paymentMethodIndex == 0 ? 'cash_on_delivery'.tr : checkoutController.paymentMethodIndex == 1 && !checkoutController.isPartialPay ? 'wallet_payment'.tr : checkoutController.paymentMethodIndex == 2 ? '${'digital_payment'.tr} (${checkoutController.digitalPaymentName?.replaceAll('_', ' ').toTitleCase() ?? ''})' : checkoutController.paymentMethodIndex == 3 ? '${'offline_payment'.tr} (${checkoutController.offlineMethodList![checkoutController.selectedOfflineBankIndex].methodName})' : 'select_payment_method'.tr} ${checkoutController.paymentMethodIndex != 2 ? '(${'due'.tr})' : ''}',
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color:
                                  checkoutController.paymentMethodIndex == 1 &&
                                          checkoutController.isPartialPay
                                      ? (Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? Colors.white70 : Colors.black)
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        checkoutController.paymentMethodIndex == 1 &&
                                checkoutController.isPartialPay
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    left: Dimensions.paddingSizeExtraSmall),
                                child: Icon(Icons.error,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.error),
                              )
                            : const SizedBox(),
                        const Spacer(),
                        Text(
                          PriceConverter.convertPrice(total - walletBalance),
                          textDirection: TextDirection.ltr,
                          style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).primaryColor),
                        ),
                      ]),
                    ])
                  : Row(children: [
                      checkoutController.paymentMethodIndex != -1
                          ? Image.asset(
                              checkoutController.paymentMethodIndex == 0
                                  ? XmarketImages.cash
                                  : checkoutController.paymentMethodIndex == 1
                                      ? XmarketImages.wallet
                                      : XmarketImages.digitalPayment,
                              width: 20,
                              height: 20,
                            )
                          : Icon(Icons.wallet_outlined,
                              size: 18, color: Theme.of(context).disabledColor),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Row(children: [
                          Text(
                            checkoutController.paymentMethodIndex == 0
                                ? 'cash_on_delivery'.tr
                                : checkoutController.paymentMethodIndex == 1 &&
                                        !checkoutController.isPartialPay
                                    ? 'wallet_payment'.tr
                                    : checkoutController.paymentMethodIndex == 2
                                        ? '${'digital_payment'.tr} (${checkoutController.digitalPaymentName?.replaceAll('_', ' ').toTitleCase() ?? ''})'
                                        : checkoutController
                                                    .paymentMethodIndex ==
                                                3
                                            ? '${'offline_payment'.tr} ${(checkoutController.offlineMethodList != null && checkoutController.offlineMethodList!.isNotEmpty) ? '(${checkoutController.offlineMethodList![checkoutController.selectedOfflineBankIndex].methodName})' : ''}'
                                            : 'select_payment_method'.tr,
                            style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).disabledColor),
                          ),
                          checkoutController.paymentMethodIndex == -1
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: Dimensions.paddingSizeExtraSmall),
                                  child: CustomToolTip(
                                      message:
                                          'no_payment_method_has_been_selected_kindly_select_a_payment_method'
                                              .tr,
                                      child: Icon(Icons.error,
                                          size: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error)),
                                )
                              : const SizedBox(),
                        ]),
                      ),
                      !ResponsiveHelper.isDesktop(context)
                          ? PriceConverter.convertAnimationPrice(
                              checkoutController.isPartialPay
                                  ? checkoutController.viewTotalPrice
                                  : total,
                              textStyle: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(context).primaryColor),
                            )
                          : const SizedBox(),
                    ]),
        ),
      ]),
    );
  }
}
