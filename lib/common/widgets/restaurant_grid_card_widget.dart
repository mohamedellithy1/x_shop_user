import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class RestaurantGridCardWidget extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantGridCardWidget({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    bool isAvailable = restaurant.open == 1 && restaurant.active!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: CustomInkWellWidget(
        onTap: () {
          if (restaurant.restaurantStatus == 1) {
            Get.toNamed(
              RouteHelper.getRestaurantRoute(restaurant.id,
                  slug: restaurant.slug ?? ''),
              arguments: RestaurantScreen(restaurant: restaurant),
            );
          } else {
            showCustomSnackBar('restaurant_is_not_available'.tr);
          }
        },
        radius: Dimensions.radiusDefault,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // الصورة مع أيقونة المفضلة و حالة الإغلاق
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // صورة المطعم
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(Dimensions.radiusDefault),
                      topRight: Radius.circular(Dimensions.radiusDefault),
                    ),
                    child: CustomImageWidget(
                      image: restaurant.logoFullUrl ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      isRestaurant: true,
                    ),
                  ),

                  // حالة الإغلاق
                  if (!isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(Dimensions.radiusDefault),
                            topRight: Radius.circular(Dimensions.radiusDefault),
                          ),
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'closed_now'.tr,
                          style: robotoMedium.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                      ),
                    ),

                  // أيقونة المفضلة
                  Positioned(
                    top: Dimensions.paddingSizeExtraSmall,
                    left: Dimensions.paddingSizeExtraSmall,
                    child: GetBuilder<FavouriteController>(
                      builder: (favouriteController) {
                        bool isWished = favouriteController.wishRestIdList
                            .contains(restaurant.id);
                        return CustomFavouriteWidget(
                          isWished: isWished,
                          isRestaurant: true,
                          restaurant: restaurant,
                          size: 22,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // اسم المطعم
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: Dimensions.paddingSizeExtraSmall,
                ),
                child: Center(
                  child: Text(
                    restaurant.name ?? '',
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}