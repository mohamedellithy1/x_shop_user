import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_details_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/xmarket_images.dart';

class OrderProductWidget extends StatelessWidget {
  final OrderModel order;
  final OrderDetailsModel orderDetails;
  final int? itemLength;
  final int? index;
  const OrderProductWidget(
      {super.key,
      required this.order,
      required this.orderDetails,
      this.itemLength,
      this.index});

  @override
  Widget build(BuildContext context) {
    final MarketThemeController themeController = Get.find<MarketThemeController>(tag: 'xmarket');
    String addOnText = '';
    for (var addOn in orderDetails.addOns!) {
      addOnText =
          '$addOnText${(addOnText.isEmpty) ? '' : ',  '}${addOn.name} (${addOn.quantity})';
    }

    String? variationText = '';
    if (orderDetails.variation!.isNotEmpty) {
      for (Variation variation in orderDetails.variation!) {
        variationText =
            '${variationText!}${variationText.isNotEmpty ? ', ' : ''}${variation.name} (';
        for (VariationValue value in variation.variationValues!) {
          variationText =
              '${variationText!}${variationText.endsWith('(') ? '' : ', '}${value.level}';
        }
        variationText = '${variationText!})';
      }
    } else if (orderDetails.oldVariation!.isNotEmpty) {
      List<String> variationTypes =
          orderDetails.oldVariation![0].type!.split('-');
      if (variationTypes.length ==
          orderDetails.foodDetails!.choiceOptions!.length) {
        int index = 0;
        for (var choice in orderDetails.foodDetails!.choiceOptions!) {
          variationText =
              '${variationText!}${(index == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index]}';
          index = index + 1;
        }
      } else {
        variationText = orderDetails.oldVariation![0].type;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: themeController.darkTheme ? const Color(0xFF242424) : Colors.white,
      ),
      padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeSmall,
          horizontal: Dimensions.paddingSizeLarge),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          orderDetails.foodDetails!.imageFullUrl != null &&
                  orderDetails.foodDetails!.imageFullUrl!.isNotEmpty
              ? Padding(
                  padding:
                      const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: CustomImageWidget(
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      image: '${orderDetails.foodDetails!.imageFullUrl}',
                      isFood: true,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          SizedBox(
            width: 20,
          ),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                  child: Row(children: [
                    Flexible(
                      child: Text(
                        orderDetails.foodDetails?.name ?? '',
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Get.find<MarketSplashController>(tag: 'xmarket')
                            .configModel!
                            .toggleVegNonVeg!
                        ? CustomAssetImageWidget(
                            orderDetails.foodDetails!.veg == 0
                                ? XmarketImages.nonVegImage
                                : XmarketImages.vegImage,
                            height: 11,
                            width: 11,
                          )
                        : SizedBox(),
                  ]),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Text('${'quantity'.tr}: ',
                    style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall)),
                Text(
                  orderDetails.quantity.toString(),
                  style: robotoMedium.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: Dimensions.fontSizeSmall),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              orderDetails.requestedWeight != null
                  ? Padding(
                      padding: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeExtraSmall),
                      child: Row(children: [
                        Text('${'weight'.tr}: ',
                            style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: themeController.darkTheme ? Colors.white : Colors.black)),
                        Text(
                          orderDetails.requestedWeight.toString(),
                          style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: themeController.darkTheme ? Colors.white : Colors.black),
                        ),
                      ]),
                    )
                  : const SizedBox.shrink(),
              Row(children: [
                Expanded(
                    child: Text(
                  PriceConverter.convertPrice(
                    (orderDetails.foodDetails?.isWeightBased ?? false)
                        ? ((orderDetails.price ?? 0) * (orderDetails.requestedWeight ?? 1.0))
                        : (orderDetails.price ?? 0),
                  ),
                  style: robotoMedium,
                  textDirection: TextDirection.ltr,
                )),
                SizedBox(
                    width: orderDetails.foodDetails!.isRestaurantHalalActive! &&
                            orderDetails.foodDetails!.isHalalFood!
                        ? Dimensions.paddingSizeExtraSmall
                        : 0),
                orderDetails.foodDetails!.isRestaurantHalalActive! &&
                        orderDetails.foodDetails!.isHalalFood!
                    ? const CustomAssetImageWidget(XmarketImages.halalIcon,
                        height: 13, width: 13)
                    : const SizedBox(),
              ]),
              addOnText.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(
                          top: Dimensions.paddingSizeExtraSmall),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${'addons'.tr}: ',
                                style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).disabledColor)),
                            Flexible(
                                child: Text(addOnText,
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).disabledColor,
                                    ))),
                          ]),
                    )
                  : const SizedBox(),
              variationText != ''
                  ? (orderDetails.foodDetails!.variations != null &&
                          orderDetails.foodDetails!.variations!.isNotEmpty)
                      ? Padding(
                          padding: const EdgeInsets.only(
                              top: Dimensions.paddingSizeExtraSmall),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${'variations'.tr}: ',
                                    style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color:
                                            Theme.of(context).disabledColor)),
                                Flexible(
                                    child: Text(variationText!,
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color:
                                              Theme.of(context).disabledColor,
                                        ))),
                              ]),
                        )
                      : const SizedBox()
                  : const SizedBox(),
            ]),
          ),
        ]),
      ]),
    );
  }
}
