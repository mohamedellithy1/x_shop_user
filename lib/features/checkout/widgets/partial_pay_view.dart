import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/xmarket_images.dart';

class PartialPayView extends StatelessWidget {
  final double totalPrice;
  const PartialPayView({super.key, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      bool isLoggedIn =
          Get.find<MarketProfileController>().userInfoModel != null;

      return AnimatedContainer(
        duration: const Duration(seconds: 2),
        decoration: BoxDecoration(
          color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
              ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
              : Theme.of(context).primaryColor.withValues(alpha: 0.05),
          border: Border.all(color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? Colors.white.withValues(alpha: 0.1) : Theme.of(context).primaryColor.withValues(alpha: 0.1), width: 1.0),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          image: const DecorationImage(
            alignment: Alignment.bottomRight,
            image: AssetImage(XmarketImages.partialWalletTransparent),
          ),
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.isDesktop(context)
              ? Dimensions.paddingSizeLarge
              : Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Image.asset(XmarketImages.partialWallet, height: 30, width: 30),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                PriceConverter.convertPrice(isLoggedIn
                    ? Get.find<MarketProfileController>()
                        .userInfoModel!
                        .walletBalance!
                    : 0),
                style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeOverLarge,
                    color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                'wallet_balance'.tr,
                style: robotoMedium.copyWith(fontSize: 20, color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? Colors.white : Colors.black),
              ),
            ]),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            checkoutController.isPartialPay ||
                    checkoutController.paymentMethodIndex == 1
                ? Row(children: [
                    Container(
                      decoration: const BoxDecoration(
                          color: Colors.green, shape: BoxShape.circle),
                      padding: const EdgeInsets.all(2),
                      child: const Icon(Icons.check,
                          size: 12, color: Colors.white),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(
                      'applied'.tr,
                      style: robotoMedium.copyWith(
                          color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? Colors.white : Colors.black,
                          fontSize: Dimensions.fontSizeLarge),
                    )
                  ])
                : SizedBox.shrink(),
            InkWell(
              onTap: () {
                double walletBalance = isLoggedIn
                    ? Get.find<MarketProfileController>()
                        .userInfoModel!
                        .walletBalance!
                    : 0;

                if (walletBalance < totalPrice) {
                  // Case 1: Wallet NOT enough -> Use Partial Payment
                  checkoutController.changePartialPayment();
                } else {
                  // Case 2: Wallet IS enough -> Switch to full Wallet Payment (Method index 1)
                  if (checkoutController.paymentMethodIndex != 1) {
                    checkoutController.setPaymentMethod(1);
                  } else {
                    checkoutController.setPaymentMethod(-1);
                  }
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: checkoutController.isPartialPay ||
                          checkoutController.paymentMethodIndex == 1
                      ? (Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? Colors.grey[800] : Theme.of(context).cardColor)
                      : Theme.of(context).primaryColor,
                  border: Border.all(
                      color: checkoutController.isPartialPay ||
                              checkoutController.paymentMethodIndex == 1
                          ? (Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? Colors.white12 : Colors.grey[200]!)
                          : Theme.of(context).primaryColor,
                      width: 0.5),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeSmall,
                    horizontal: Dimensions.paddingSizeLarge),
                child: Text(
                  checkoutController.isPartialPay ||
                          checkoutController.paymentMethodIndex == 1
                      ? 'remove'.tr
                      : 'use'.tr,
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: checkoutController.isPartialPay ||
                              checkoutController.paymentMethodIndex == 1
                          ? Colors.red
                          : Colors.white),
                ),
              ),
            ),
          ]),
          checkoutController.paymentMethodIndex == 1
              ? Text(
                  '${'remaining_wallet_balance'.tr}: ${PriceConverter.convertPrice(isLoggedIn ? Get.find<MarketProfileController>().userInfoModel!.walletBalance! - totalPrice : 0)}',
                  style:
                      robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                )
              : const SizedBox(),
        ]),
      );
    });
  }
}
