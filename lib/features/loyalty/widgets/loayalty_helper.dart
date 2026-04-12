import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/xmarket_images.dart';

class LoyaltyXmarketPointHelpWidget extends StatelessWidget {
  const LoyaltyXmarketPointHelpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      surfaceTintColor: Get.isDarkMode
          ? Theme.of(context).hintColor
          : Theme.of(context).cardColor,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: 10,
        ),
        child: SizedBox(
          width: Get.width,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                  onTap: () => Get.back(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding:
                        const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    child: Image.asset(
                      XmarketImages.crossIcon,
                      height: Dimensions.paddingSizeSmall,
                      width: Dimensions.paddingSizeSmall,
                      color: Colors.black,
                    ),
                  )),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text('how_to_use'.tr,
                style: robotoRegular.copyWith(
                  color:
                      Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
                          ? Colors.white
                          : Colors.black,
                )),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Lottie.asset("assets/image/gifts.json", height: 100, width: 200),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin:
                      const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  height: 7,
                  width: 7,
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor,
                    borderRadius: const BorderRadius.all(Radius.circular(100)),
                  ),
                ),
                Text('convert_your_loyalty_point_to_wallet_money'.tr,
                    style: robotoRegular.copyWith(
                      color: Get.find<MarketThemeController>(tag: 'xmarket')
                              .darkTheme
                          ? Colors.white
                          : Colors.black,
                    ))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin:
                      const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  height: 7,
                  width: 7,
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor,
                    borderRadius: const BorderRadius.all(Radius.circular(100)),
                  ),
                ),
                Expanded(
                    child: Text(
                  '${'minimum'.tr} ${Get.find<MarketSplashController>().configModel?.loyaltyPointExchangeRate}'
                  '${'points_required_to_convert_into_currency'.tr}',
                  style: robotoRegular.copyWith(
                    color: Get.find<MarketThemeController>(tag: 'xmarket')
                            .darkTheme
                        ? Colors.white
                        : Colors.black,
                  ),
                )),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
