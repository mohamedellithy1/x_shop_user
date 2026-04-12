import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CouponViewWidget extends StatelessWidget {
  final double scrollingRate;
  const CouponViewWidget({super.key, required this.scrollingRate});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return GetBuilder<MarketCouponController>(builder: (couponController) {
      return couponController.couponList != null &&
              couponController.couponList!.isNotEmpty
          ? Column(children: [
              SizedBox(
                height: isDesktop
                    ? 110 - (scrollingRate * 20)
                    : 110 - (scrollingRate * 40),
                width: double.infinity,
                child: CarouselSlider.builder(
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    disableCenter: true,
                    viewportFraction: 1,
                    autoPlayInterval: const Duration(seconds: 7),
                    onPageChanged: (index, reason) {
                      couponController.setCurrentIndex(index, true);
                    },
                  ),
                  itemCount: couponController.couponList!.length,
                  itemBuilder: (context, index, _) {
                    return Stack(children: [
                      // ClipRRect(
                      //   borderRadius:
                      //       BorderRadius.circular(Dimensions.radiusSmall),
                      //   child: Transform.rotate(
                      //     angle: Get.find<LocalizationController>(tag: 'xmarket')
                      //             .isLtr
                      //         ? 0
                      //         : pi,
                      //     child: Image.asset(
                      //       Get.find<MarketThemeController>(tag: 'xmarket')
                      //               .darkTheme
                      //           ? Images.couponBgDark
                      //           : Images.couponBgLight,
                      //       height: isDesktop ? 110 : 110,
                      //       width: double.infinity,
                      //       fit: BoxFit.fill,
                      //     ),
                      //   ),
                      // ),
                      Container(
                        alignment: Alignment.center,
                        child: Row(children: [
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  DottedBorder(
                                    color: Theme.of(context).primaryColor,
                                    strokeWidth: 1,
                                    strokeCap: StrokeCap.butt,
                                    dashPattern: const [3, 3],
                                    padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.paddingSizeDefault,
                                        vertical:
                                            Dimensions.paddingSizeExtraSmall),
                                    radius: const Radius.circular(50),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${couponController.couponList![index].code}',
                                            style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeSmall),
                                          InkWell(
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(
                                                  text: couponController
                                                      .couponList![index]
                                                      .code!));
                                              showCustomSnackBar(
                                                  'coupon_code_copied'.tr);
                                            },
                                            child: Icon(Icons.copy_rounded,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                size: 18),
                                          ),
                                        ]),
                                  ),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    DateConverter.stringToReadableString(
                                        couponController
                                            .couponList![index].startDate!),
                                    style: robotoMedium.copyWith(
                                        color: Colors.black,
                                        fontSize:
                                            Dimensions.fontSizeExtraSmall),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    ' ${'to'.tr} ${DateConverter.stringToReadableString(couponController.couponList![index].expireDate!)}',
                                    style: robotoMedium.copyWith(
                                        color: Colors.black,
                                        fontSize:
                                            Dimensions.fontSizeExtraSmall),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${'min_purchase'.tr} ',
                                          style: robotoRegular.copyWith(
                                              color: Colors.black,
                                              fontSize: Dimensions
                                                  .fontSizeExtraSmall),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          PriceConverter.convertPrice(
                                              couponController
                                                  .couponList![index]
                                                  .minPurchase),
                                          style: robotoMedium.copyWith(
                                              color: Colors.black,
                                              fontSize: Dimensions
                                                  .fontSizeExtraSmall),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textDirection: TextDirection.ltr,
                                        ),
                                      ]),
                                ]),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: isDesktop ? 150 : context.width * 0.3,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Image.asset(
                                  //   couponController.couponList![index]
                                  //               .discountType ==
                                  //           'percent'
                                  //       ? Images.percentCouponOffer
                                  //       : couponController.couponList![index]
                                  //                   .couponType ==
                                  //               'free_delivery'
                                  //           ? Images.freeDelivery
                                  //           : Images.money,
                                  //   height: 25,
                                  //   width: 25,
                                  // ),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    '${couponController.couponList![index].couponType == 'free_delivery' ? '' : couponController.couponList![index].discount}${couponController.couponList![index].discountType == 'percent' ? '%' : couponController.couponList![index].couponType == 'free_delivery' ? 'free_delivery'.tr : " EGP "} ${couponController.couponList![index].couponType == 'free_delivery' ? '' : 'off'.tr}',
                                    style: robotoBold.copyWith(
                                        color: Colors.black,
                                        fontSize: Dimensions.fontSizeDefault),
                                  ),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall),
                                  Flexible(
                                    child: Text(
                                      couponController.couponList![index]
                                                  .couponType ==
                                              'default'
                                          ? '${couponController.couponList![index].restaurant!.name}'
                                          : couponController.couponList![index]
                                                      .couponType ==
                                                  'restaurant_wise'
                                              ? '${couponController.couponList![index].restaurant!.name}'
                                              : '',
                                      style: robotoRegular.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeExtraSmall,
                                          color: Colors.black),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ]),
                          ),
                        ]),
                      ),
                    ]);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: couponController.couponList!.map((bnr) {
                  int index = couponController.couponList!.indexOf(bnr);
                  return TabPageSelectorIndicator(
                    backgroundColor: index == couponController.currentIndex
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor.withValues(alpha: 0.5),
                    borderColor: Theme.of(context).colorScheme.surface,
                    size: index == couponController.currentIndex
                        ? 7 - (scrollingRate * (isDesktop ? 2 : 7))
                        : 5 - (scrollingRate * (isDesktop ? 2 : 5)),
                  );
                }).toList(),
              ),
            ])
          : const SizedBox();
    });
  }
}
