import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_loader_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_widget.dart';
import 'package:stackfood_multivendor/common/widgets/restaurant_grid_card_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_restaurant_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/restaurant_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class ProductViewWidget extends StatelessWidget {
  final List<Product?>? products;
  final List<Restaurant?>? restaurants;
  final bool isRestaurant;
  final EdgeInsetsGeometry padding;
  final bool isScrollable;
  final int shimmerLength;
  final String? noDataText;
  final bool isCampaign;
  final bool inRestaurantPage;
  final bool showTheme1Restaurant;
  final bool? isWebRestaurant;
  final bool? fromFavorite;
  final bool? fromSearch;
  final bool useGridCard;
  final bool isCenter;
  const ProductViewWidget(
      {super.key,
      required this.restaurants,
      required this.products,
      required this.isRestaurant,
      this.isScrollable = false,
      this.shimmerLength = 20,
      this.padding = const EdgeInsets.all(Dimensions.paddingSizeDefault),
      this.noDataText,
      this.isCampaign = false,
      this.inRestaurantPage = false,
      this.showTheme1Restaurant = false,
      this.isWebRestaurant = false,
      this.fromFavorite = false,
      this.fromSearch = false,
      this.useGridCard = false,
      this.isCenter = false});

  @override
  Widget build(BuildContext context) {
    List<Product?>? filteredProducts = products;
    List<Restaurant?>? filteredRestaurants = restaurants;

    // Always filter for X Market
    if (isRestaurant && restaurants != null) {
      filteredRestaurants = restaurants!.where((r) => r?.name?.trim() == 'X Market').toList();
    } else if (!isRestaurant && products != null) {
      filteredProducts = products!.where((p) => p?.restaurantName?.trim() == 'X Market').toList();
    }

    final List<Restaurant?>? activeRestaurants = isRestaurant ? filteredRestaurants : null;
    final List<Product?>? activeProducts = isRestaurant ? null : filteredProducts;
    final bool isNull = isRestaurant ? activeRestaurants == null : activeProducts == null;
    final int length = isRestaurant ? (activeRestaurants?.length ?? 0) : (activeProducts?.length ?? 0);

    return Column(children: [
      !isNull
          ? length > 0
              ? GridView.builder(
                  key: UniqueKey(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: useGridCard
                        ? Dimensions.paddingSizeSmall
                        : Dimensions.paddingSizeLarge,
                    mainAxisSpacing: useGridCard
                        ? Dimensions.paddingSizeSmall
                        : (ResponsiveHelper.isDesktop(context) &&
                                !isWebRestaurant!
                            ? Dimensions.paddingSizeLarge
                            : isWebRestaurant!
                                ? Dimensions.paddingSizeLarge
                                : 0.01),
                    mainAxisExtent: useGridCard
                        ? 230
                        : (ResponsiveHelper.isDesktop(context) &&
                                !isWebRestaurant!
                            ? 142
                            : isWebRestaurant!
                                ? 280
                                : showTheme1Restaurant
                                    ? 200
                                    : isRestaurant
                                        ? 150
                                        : 120),
                    crossAxisCount: useGridCard
                        ? 2
                        : (ResponsiveHelper.isMobile(context) &&
                                !isWebRestaurant!
                            ? 1
                            : isWebRestaurant!
                                ? 4
                                : 3),
                  ),
                  physics: isScrollable
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  shrinkWrap: isScrollable ? false : true,
                  itemCount: length,
                  padding: padding,
                  itemBuilder: (context, index) {
                    if (isRestaurant) {
                      final restaurant = activeRestaurants![index];
                      if (useGridCard && restaurant != null) {
                        return RestaurantGridCardWidget(restaurant: restaurant);
                      } else if (showTheme1Restaurant) {
                        return RestaurantWidget(
                          restaurant: restaurant,
                          index: index,
                          inStore: inRestaurantPage,
                        );
                      } else if (isWebRestaurant!) {
                        return WebRestaurantWidget(restaurant: restaurant);
                      } else {
                        return ProductWidget.fromRestaurant(
                          restaurant: restaurant!,
                          index: index,
                          length: length,
                        );
                      }
                    } else {
                      final product = activeProducts![index];
                      return ProductWidget.fromProduct(
                        product: product!,
                        index: index,
                        length: length,
                        inRestaurant: inRestaurantPage,
                        isCampaign: isCampaign,
                      );
                    }
                  },
                )
              : isCenter
                  ? SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: NoDataScreen(
                          isEmptyRestaurant: isRestaurant,
                          isEmptyWishlist: fromFavorite ?? false,
                          isEmptySearchFood: fromSearch ?? false,
                          isCenter: true,
                          title: noDataText ??
                              (isRestaurant
                                  ? 'there_is_no_restaurant'.tr
                                  : 'there_is_no_food'.tr),
                        ),
                      ),
                    )
                  : NoDataScreen(
                      isEmptyRestaurant: isRestaurant,
                      isEmptyWishlist: fromFavorite ?? false,
                      isEmptySearchFood: fromSearch ?? false,
                      title: noDataText ??
                          (isRestaurant
                              ? 'there_is_no_restaurant'.tr
                              : 'there_is_no_food'.tr),
                    )
          : SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              width: double.infinity,
              child: const Center(child: CustomLoaderWidget()),
            ),
    ]);
  }
}
