import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

void showCustomBottomSheet({required Widget child, double? maxHeight, bool isDismissible = true, bool enableDrag = true}) {
  Get.bottomSheet(
    ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight ?? MediaQuery.of(Get.context!).size.height * 0.8),
      child: Container(
        decoration: BoxDecoration(
          color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? const Color(0xFF141313) : Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
        ),
        child: child,
      ),
    ),
    isScrollControlled: true, useRootNavigator: true,
    backgroundColor: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? const Color(0xFF141313) : Colors.white,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
    ),
  );
}