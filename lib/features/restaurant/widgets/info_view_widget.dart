import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InfoViewWidget extends StatelessWidget {
  final Restaurant restaurant;
  final RestaurantController restController;
  final double scrollingRate;
  const InfoViewWidget({super.key, required this.restaurant, required this.restController, required this.scrollingRate});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [

        !isDesktop ? Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Theme.of(context).primaryColor, width: 0.2),
          ),
          padding: const EdgeInsets.all(2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Stack(children: [
              CustomImageWidget(
                image: '${restaurant.logoFullUrl}',
                height: 60 - (scrollingRate * 15), width: 60 - (scrollingRate * 15), fit: BoxFit.cover,
              ),
              restController.isRestaurantOpenNow(restaurant.active!, restaurant.schedules) ? const SizedBox() : Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Dimensions.radiusSmall)),
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                  child: Text(
                    'closed_now'.tr, textAlign: TextAlign.center,
                    style: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                  ),
                ),
              ),
            ]),
          ),
        ) : const SizedBox(),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            restaurant.name!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge - (scrollingRate * 3), color: Theme.of(context).textTheme.bodyMedium!.color),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          // Text(
          //   restaurant.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
          //   style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall - (scrollingRate * 2), color: Colors.black),
          // ),
          // SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : 0),

          // Row(children: [
          //   // Text('start_from'.tr, style: robotoRegular.copyWith(
          //   //   fontSize: Dimensions.fontSizeExtraSmall - (scrollingRate * 2), color: Theme.of(context).disabledColor,
          //   // )),
          //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          //   Text(
          //     PriceConverter.convertPrice(restaurant.priceStartFrom), textDirection: TextDirection.ltr,
          //     style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall - (scrollingRate * 2), color: Theme.of(context).primaryColor),
          //   ),
          // ]),

        ])),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        // Favorite icon only
        GetBuilder<FavouriteController>(builder: (favouriteController) {
          bool isWished = favouriteController.wishRestIdList.contains(restaurant.id);
          return CustomFavouriteWidget(
            isWished: isWished,
            isRestaurant: true,
            restaurant: restaurant,
            size: 24  - (scrollingRate * 4),
          );
        }),
        const SizedBox(width: Dimensions.paddingSizeLarge),

      ]),
      SizedBox(height: Dimensions.paddingSizeDefault - (scrollingRate * (isDesktop ? 2 : Dimensions.paddingSizeDefault))),

      // Rating and Free Delivery Row
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        InkWell(
          onTap: () => Get.toNamed(RouteHelper.getRestaurantReviewRoute(restaurant.id, restaurant.name, restaurant)),
          child: Row(children: [
            Icon(Icons.star, color: Theme.of(context).primaryColor, size: 18 - (scrollingRate * (isDesktop ? 2 : 18))),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              restaurant.avgRating!.toStringAsFixed(1),
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall - (scrollingRate * (isDesktop ? 2 : Dimensions.fontSizeSmall)), color: Theme.of(context).textTheme.bodyLarge!.color),
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              '(${restaurant.ratingCount})',
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall - (scrollingRate * (isDesktop ? 2 : Dimensions.fontSizeExtraSmall)), color: Colors.black),
            ),
          ]),
        ),

        if (restaurant.delivery! && restaurant.freeDelivery!) ...[
          const SizedBox(width: Dimensions.paddingSizeLarge),
          Row(children: [
            Icon(Icons.local_shipping, color: Theme.of(context).primaryColor, size: 18 - (scrollingRate * (isDesktop ? 2 : 18))),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              'free_delivery'.tr,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall - (scrollingRate * (isDesktop ? 2 : Dimensions.fontSizeExtraSmall)),
                color: Theme.of(context).primaryColor,
              ),
            ),
          ]),
        ],
      ]),
    ]);
  }
}