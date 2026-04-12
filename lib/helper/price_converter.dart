import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PriceConverter {
  static String convertPrice(double? price,
      {double? discount,
      String? discountType,
      bool forDM = false,
      bool isVariation = false}) {
    if (discount != null && discountType != null) {
      if (discountType == 'amount' && !isVariation) {
        price = price! - discount;
      } else if (discountType == 'percent') {
        price = price! - ((discount / 100) * price);
      }
    }

    int digitAfterDecimalPoint =
        Get.find<MarketSplashController>(tag: 'xmarket')
                .configModel!
                .digitAfterDecimalPoint ??
            2;

    /* int tempPrice = price!.floor();
    if((price - tempPrice) == 0) {
      digitAfterDecimalPoint = 0;
    }*/

    bool isRightSide = Get.find<MarketSplashController>(tag: 'xmarket')
            .configModel!
            .currencySymbolDirection ==
        'right';
    return '${isRightSide ? '' : '${!isRightSide ? '  ' : ''} '}'
        '${(toFixed(price!)).toStringAsFixed(forDM ? 0 : digitAfterDecimalPoint).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'
        '${isRightSide ? '  ' : ''}';
  }

  static Widget convertAnimationPrice(double? price,
      {double? discount,
      String? discountType,
      bool forDM = false,
      TextStyle? textStyle}) {
    if (discount != null && discountType != null) {
      if (discountType == 'amount') {
        price = price! - discount;
      } else if (discountType == 'percent') {
        price = price! - ((discount / 100) * price);
      }
    }
    bool isRightSide = Get.find<MarketSplashController>(tag: 'xmarket')
            .configModel!
            .currencySymbolDirection ==
        'right';
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedFlipCounter(
        duration: const Duration(milliseconds: 500),
        value: toFixed(price!),
        textStyle: textStyle ?? robotoMedium,
        fractionDigits: forDM
            ? 0
            : Get.find<MarketSplashController>(tag: 'xmarket')
                .configModel!
                .digitAfterDecimalPoint!,
        prefix: isRightSide ? '' : ' ',
        suffix: isRightSide ? ' ' : '',
      ),
    );
  }

  static double? convertWithDiscount(
      double? price, double? discount, String? discountType,
      {bool isVariation = false}) {
    if (discountType == 'amount' && !isVariation) {
      price = price! - discount!;
    } else if (discountType == 'percent') {
      price = price! - ((discount! / 100) * price);
    }
    return price;
  }

  static double calculation(
      double amount, double? discount, String type, int quantity) {
    double calculatedAmount = 0;
    if (type == 'amount') {
      calculatedAmount = discount! * quantity;
    } else if (type == 'percent') {
      calculatedAmount = (discount! / 100) * (amount * quantity);
    }
    return calculatedAmount;
  }

  static String percentageCalculation(
      String price, String discount, String discountType) {
    return '$discount${discountType == 'percent' ? '%' : ''} OFF';
  }

  static double toFixed(double val) {
    num mod = power(
        10,
        Get.find<MarketSplashController>(tag: 'xmarket')
            .configModel!
            .digitAfterDecimalPoint!);
    return (((val * mod).toPrecision(
                Get.find<MarketSplashController>(tag: 'xmarket')
                    .configModel!
                    .digitAfterDecimalPoint!))
            .floor()
            .toDouble() /
        mod);
  }

  static int power(int x, int n) {
    int retval = 1;
    for (int i = 0; i < n; i++) {
      retval *= x;
    }
    return retval;
  }
}
