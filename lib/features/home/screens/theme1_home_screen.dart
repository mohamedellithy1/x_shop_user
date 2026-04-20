import 'package:stackfood_multivendor/features/home/widgets/home_category_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/location_dropdown.dart';
import 'package:stackfood_multivendor/features/home/screens/home_screen.dart';
import 'package:stackfood_multivendor/features/home/widgets/bad_weather_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/dine_in_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/enjoy_off_banner_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/filter_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/highlight_widget_view.dart';
import 'package:stackfood_multivendor/features/home/widgets/order_again_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/refer_banner_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/banner_view.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/banner_view_widget1.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/best_reviewed_item_widget1.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/category_widget1.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/cuisine_widget1.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/item_campaign_widget1.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/near_by_button_widget1.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/popular_item_widget1.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/popular_store_widget1.dart';
import 'package:stackfood_multivendor/features/notification/controllers/notification_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';

class Theme1HomeScreen extends StatelessWidget {
  final ScrollController scrollController;
  const Theme1HomeScreen({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    ConfigModel configModel =
        Get.find<MarketSplashController>(tag: 'xmarket').configModel!;
    bool isLogin = Get.find<MarketAuthController>().isLoggedIn();

    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // App Bar
        SliverAppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          pinned: true,
          floating: false,
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFe3ebd5),
                  Color(0xFFfafff4),
                  Color(0xFFe3ebd5),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),

              // gradient: LinearGradient(
              //   colors: [Color(0xFFd6e0c4), Color(0xFFe7feba)],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
              // color: Color(0xFFd6e0c4),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: Dimensions.webMaxWidth,
                      height: 50,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFe3ebd5),
                            Color(0xFFfafff4),
                            Color(0xFFe3ebd5),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),

                        // gradient: LinearGradient(
                        //   colors: [Color(0xFFd6e0c4), Color(0xFFe7feba)],
                        //   begin: Alignment.topLeft,
                        //   end: Alignment.bottomRight,
                        // ),
                        // color: Color(0xFFd6e0c4),
                      ),
                      child: Row(children: [
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Expanded(
                            child: LocationDropdown(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                                vertical: Dimensions.paddingSizeExtraSmall),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Color(0xFFfafef5)
                                  : const Color(0xFFfafef5),
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radiusExtraLarge),
                              border:
                                  Border.all(color: Colors.black, width: 1.2),
                            ),
                            child: GetBuilder<MarketLocationController>(
                                builder: (locationController) {
                              final address =
                                  AddressHelper.getAddressFromSharedPref();
                              return Row(
                                children: [
                                  const Icon(Icons.keyboard_arrow_down,
                                      color: Colors.black, size: 20),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeExtraSmall),
                                  Expanded(
                                    child: Text(
                                      address?.address ?? 'your_location'.tr,
                                      style: robotoRegular.copyWith(
                                        color: Color(0xFF55745a),
                                        fontSize: Dimensions.fontSizeSmall,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeExtraSmall),
                                  const Icon(Icons.location_on,
                                      color: Color(0xFFacb566), size: 20),
                                ],
                              );
                            }),
                          ),
                        )),
                        const SizedBox(
                            width: 20), // مسافة بين العنوان والإشعارات
                        InkWell(
                          child: GetBuilder<MarketNotificationController>(
                              builder: (notificationController) {
                            return Stack(children: [
                              Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusExtraLarge),
                                  border: Border.all(
                                      color: Colors.white, width: 1.2),
                                ),
                                child: Icon(Icons.notifications,
                                    size: 30, color: Colors.green),
                              ),
                              if (notificationController.hasNotification)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF9ebc67),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          width: 1, color: Colors.white),
                                    ),
                                  ),
                                ),
                            ]);
                          }),
                          onTap: () =>
                              Get.toNamed(RouteHelper.getNotificationRoute()),
                        ),
                        const SizedBox(
                            width: Dimensions
                                .paddingSizeDefault), // مسافة من حافة الشاشة للايقونة
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: const [SizedBox()],
        ),
        // SliverToBoxAdapter(
        //   child: SizedBox(height: 1),
        // ),

        // Banner فوق السيرش
        SliverToBoxAdapter(
          child: const BannerViewWidget1(),
        ),
        // Banner فوق السيرش
        // SliverToBoxAdapter(
        //   child: SizedBox(height: 10),
        // ),

        // Search Button
        SliverPersistentHeader(
          pinned: true,
          delegate: CommonSliverDelegate(
              child: Center(
                  child: Container(
            height: 50,
            width: Dimensions.webMaxWidth,
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall),
            child: InkWell(
              onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                        spreadRadius: 1,
                        blurRadius: 5)
                  ],
                ),
                child: Row(children: [
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Icon(
                    Icons.search,
                    size: 25,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Expanded(
                      child: Text(
                    'search_food_or_restaurant'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  )),
                ]),
              ),
            ),
          ))),
        ),

        SliverToBoxAdapter(
          child: Center(
              child: SizedBox(
            width: Dimensions.webMaxWidth,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: Dimensions.paddingSizeSmall),
              // const BadWeatherWidget(),
              // const CategoryWidget1(),
              const HomeCategoryViewWidget(),

              // const ItemCampaignWidget1(),
              // const HighlightWidgetView(),
              // isLogin
              //     ? const PopularStoreWidget1(
              //         isOrderAgainViewed: true, isPopular: false)
              //     : const SizedBox(),
              // isLogin ? const OrderAgainViewWidget() : const SizedBox(),
              // configModel.mostReviewedFoods == 1
              //     ? const BestReviewedItemWidget1()
              //     : const SizedBox(),
              // (configModel.dineInOrderOption ?? false)
              //     ? DineInWidget()
              //     : const SizedBox(),
              // const ReferBannerViewWidget(fromTheme1: true),
              /*isLogin
                  ? const PopularStoreWidget1(
                      isPopular: false, isRecentlyViewed: true)
                  : const SizedBox(),*/
              // const CuisinesWidget1(),
              // configModel.popularRestaurant == 1
              //     ? const PopularStoreWidget1(isPopular: true)
              //     : const SizedBox(),
              // // const NearByButtonWidget1(),
              // configModel.popularFood == 1
              //     ? const PopularItemWidget1(isPopular: true)
              //     : const SizedBox(),
              // configModel.newRestaurant == 1
              //     ? const PopularStoreWidget1(isPopular: false)
              //     : const SizedBox(),
              // const PromotionalBannerViewWidget(),
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(10, 15, 0, 5),
              //   child: Row(children: [
              //     Expanded(
              //         child: Text(
              //       'all_restaurants'.tr,
              //       style: robotoMedium.copyWith(
              //           fontSize: Dimensions.fontSizeLarge),
              //     )),
              //     const FilterViewWidget(),
              //   ]),
              // ),
              // GetBuilder<RestaurantController>(builder: (restaurantController) {
              //   return PaginatedListViewWidget(
              //     scrollController: scrollController,
              //     totalSize: restaurantController.restaurantModel?.totalSize,
              //     offset: restaurantController.restaurantModel?.offset,
              //     onPaginate: (int? offset) async => await restaurantController
              //         .getRestaurantList(offset!, false),
              //     productView: ProductViewWidget(
              //       isRestaurant: true,
              //       products: null,
              //       showTheme1Restaurant: true,
              //       restaurants:
              //           restaurantController.restaurantModel?.restaurants,
              //       padding: EdgeInsets.symmetric(
              //         horizontal: ResponsiveHelper.isDesktop(context)
              //             ? Dimensions.paddingSizeExtraSmall
              //             : Dimensions.paddingSizeSmall,
              //         vertical: ResponsiveHelper.isDesktop(context)
              //             ? Dimensions.paddingSizeExtraSmall
              //             : 0,
              //       ),
              //     ),
              //   );
              // }),
            ]),
          )),
        ),
      ],
    );
  }
}
