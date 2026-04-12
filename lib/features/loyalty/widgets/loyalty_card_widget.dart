import 'package:stackfood_multivendor/features/loyalty/widgets/loayalty_helper.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/loyalty/widgets/loyalty_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

import 'package:dotted_border/dotted_border.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/util/xmarket_images.dart';

class LoyaltyCardWidget extends StatelessWidget {
  final JustTheController tooltipController;
  const LoyaltyCardWidget({super.key, required this.tooltipController});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarketProfileController>(builder: (userController) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Title with "How it works" tooltip
        Padding(
          padding:
              const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title
              Text(
                'loyalty_points'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),

              // How it works link
              InkWell(
                onTap: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (_) => const LoyaltyXmarketPointHelpWidget(),
                  );
                },
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: Dimensions.paddingSizeExtraSmall,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'how_it_works'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Get.find<MarketThemeController>(tag: 'xmarket')
                                  .darkTheme
                              ? Colors.white70
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Icon(
                        Icons.help_outline,
                        size: 18,
                        color: Get.find<MarketThemeController>(tag: 'xmarket')
                                .darkTheme
                            ? Colors.white70
                            : Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        DottedBorder(
          dashPattern: const [1, 1],
          borderType: BorderType.RRect,
          color: Theme.of(context).primaryColor,
          radius: const Radius.circular(Dimensions.radiusLarge),
          child: InkWell(
            onTap: () {
              Get.dialog(
                Dialog(
                    backgroundColor: Colors.transparent,
                    child: LoyaltyBottomSheetWidget(
                      amount: userController.userInfoModel?.loyaltyPoint == null
                          ? '0'
                          : userController.userInfoModel!.loyaltyPoint
                              .toString(),
                    )),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
                vertical: Dimensions.paddingSizeOverLarge,
              ),
              decoration: BoxDecoration(
                color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
                    ? const Color(0xFF1b1b1b)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Points Display
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        XmarketImages.loyaltyPoint,
                        height: 25,
                        width:
                            0, // Hidden as in XRide code if needed, but show if wanted
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Text(
                        '${'your_points'.tr}:',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Get.find<MarketThemeController>(tag: 'xmarket')
                                  .darkTheme
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        userController.userInfoModel?.loyaltyPoint == null
                            ? '0'
                            : userController.userInfoModel!.loyaltyPoint
                                .toString(),
                        style: robotoBold.copyWith(
                          fontSize: 28,
                          color: Get.find<MarketThemeController>(tag: 'xmarket')
                                  .darkTheme
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),

                  // Arrow Icon
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Get.find<MarketThemeController>(tag: 'xmarket')
                            .darkTheme
                        ? Colors.white
                        : Colors.black,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),

        ResponsiveHelper.isDesktop(context)
            ? const SizedBox(height: Dimensions.paddingSizeDefault)
            : const SizedBox(),
        ResponsiveHelper.isDesktop(context)
            ? const SizedBox(height: Dimensions.paddingSizeDefault)
            : const SizedBox(),

        ResponsiveHelper.isDesktop(context)
            ? Text('how_to_use'.tr,
                style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Get.find<MarketThemeController>(tag: 'xmarket')
                            .darkTheme
                        ? Colors.white
                        : Colors.black))
            : const SizedBox(),
        ResponsiveHelper.isDesktop(context)
            ? const SizedBox(height: Dimensions.paddingSizeDefault)
            : const SizedBox(),

        !ResponsiveHelper.isDesktop(context)
            ? const SizedBox()
            : const LoyaltyStepper(),
      ]);
    });
  }
}

class LoyaltyStepper extends StatelessWidget {
  const LoyaltyStepper({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 70,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                margin: const EdgeInsets.only(
                    top: Dimensions.paddingSizeExtraSmall),
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Theme.of(context).primaryColor, width: 2)),
              ),
              Expanded(
                child: VerticalDivider(
                  thickness: 3,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.30),
                ),
              ),
              Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Theme.of(context).primaryColor, width: 2),
                ),
              ),
            ]),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('convert_your_loyalty_point_to_wallet_money'.tr,
                      style: robotoRegular),
                  Text(
                      '${'minimun'.tr} ${Get.find<MarketSplashController>(tag: 'xmarket').configModel!.loyaltyPointExchangeRate} ${'points_required_to_convert_into_currency'.tr}',
                      style: robotoRegular),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        CustomButtonWidget(
          radius: Dimensions.radiusSmall,
          isBold: true,
          buttonText: 'convert_to_currency_now'.tr,
          onPressed: () {
            Get.dialog(
              Dialog(
                  backgroundColor: Colors.transparent,
                  child: LoyaltyBottomSheetWidget(
                    amount: Get.find<MarketProfileController>()
                                .userInfoModel!
                                .loyaltyPoint ==
                            null
                        ? '0'
                        : Get.find<MarketProfileController>()
                            .userInfoModel!
                            .loyaltyPoint
                            .toString(),
                  )),
            );
          },
        ),
      ],
    );
  }
}
