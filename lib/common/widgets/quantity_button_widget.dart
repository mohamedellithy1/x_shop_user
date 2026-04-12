import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class QuantityButton extends StatelessWidget {
  final bool isIncrement;
  final Function? onTap;
  final bool showRemoveIcon;
  final Color? color;
  const QuantityButton(
      {super.key,
      required this.isIncrement,
      required this.onTap,
      this.showRemoveIcon = false,
      this.color});

  @override
  Widget build(BuildContext context) {
    final marketThemeController =
        Get.find<MarketThemeController>(tag: 'xmarket');
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        height: 22,
        width: 22,
        margin:
            const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              width: 1,
              color: showRemoveIcon
                  ? Colors.transparent
                  : Theme.of(context).disabledColor),
          color: showRemoveIcon
              ? (marketThemeController.darkTheme
                  ? Colors.grey[800]
                  : Theme.of(context).cardColor)
              : (marketThemeController.darkTheme ? Colors.black : Colors.white),
        ),
        alignment: Alignment.center,
        child: Icon(
          showRemoveIcon
              ? Icons.delete
              : isIncrement
                  ? Icons.add
                  : Icons.remove,
          size: 20,
          color: showRemoveIcon
              ? Theme.of(context).colorScheme.error
              : (marketThemeController.darkTheme ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
