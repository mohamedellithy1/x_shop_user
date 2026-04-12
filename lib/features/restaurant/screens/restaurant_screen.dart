import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/dashboard/screens/dashboard_screen.dart';
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/item_card_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_category_with_subcategories_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_info_section_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_screen_shimmer_widget.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/bottom_cart_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/veg_filter_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_menu_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/util/xmarket_images.dart';

class RestaurantScreen extends StatefulWidget {
  final Restaurant? restaurant;
  final String slug;
  final bool fromDineIn;
  const RestaurantScreen(
      {super.key,
      required this.restaurant,
      this.slug = '',
      this.fromDineIn = false});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _initDataCall();
  }

  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  Future<void> _initDataCall() async {
    if (Get.find<RestaurantController>().isSearching) {
      Get.find<RestaurantController>().changeSearchStatus(isUpdate: false);
    }
    await Get.find<RestaurantController>().getRestaurantDetails(
      Restaurant(id: widget.restaurant!.id), /*slug: widget.slug*/
    );
    if (Get.find<MarketCategoryController>().categoryList == null) {
      Get.find<MarketCategoryController>().getCategoryList(true, search: '');
    }
    Get.find<MarketCouponController>().getRestaurantCouponList(
        restaurantId: widget.restaurant!.id ??
            Get.find<RestaurantController>().restaurant!.id!);
    Get.find<RestaurantController>().getRestaurantRecommendedItemList(
        widget.restaurant!.id ??
            Get.find<RestaurantController>().restaurant!.id!,
        false);
    Get.find<RestaurantController>().getRestaurantProductList(
        widget.restaurant!.id ??
            Get.find<RestaurantController>().restaurant!.id!,
        1,
        'all',
        false);
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return GetBuilder<MarketThemeController>(
      init: Get.find<MarketThemeController>(tag: 'xmarket'),
      builder: (marketThemeController) {
        return Theme(
            data: marketThemeController.darkTheme ? darkTheme : lightTheme,
            child: Scaffold(
              appBar:
                  isDesktop ? WebMenuBar(fromDineIn: widget.fromDineIn) : null,
              endDrawer: const MenuDrawerWidget(),
              endDrawerEnableOpenDragGesture: false,
              backgroundColor: marketThemeController.darkTheme ? Colors.black : Colors.white,
              body: GetBuilder<RestaurantController>(builder: (restController) {
                return GetBuilder<MarketCouponController>(
                    builder: (couponController) {
                  return GetBuilder<MarketCategoryController>(
                      builder: (categoryController) {
                    Restaurant? restaurant;
                    if (restController.restaurant != null &&
                        restController.restaurant!.name != null &&
                        categoryController.categoryList != null) {
                      restaurant = restController.restaurant;
                    }
                    restController.setCategoryList();
                    bool hasCoupon = (couponController.couponList != null &&
                        couponController.couponList!.isNotEmpty);

                    return (restController.restaurant != null &&
                            restController.restaurant!.name != null &&
                            categoryController.categoryList != null)
                        ? CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            controller: scrollController,
                            slivers: [
                              RestaurantInfoSectionWidget(
                                  restaurant: restaurant!,
                                  restController: restController,
                                  hasCoupon: hasCoupon),
                              SliverToBoxAdapter(
                                  child: Center(
                                      child: Container(
                                width: Dimensions.webMaxWidth,
                                color: Theme.of(context).cardColor,
                                child: Column(children: [
                                  restaurant.discount != null
                                      ? Container(
                                          width: context.width,
                                          margin: const EdgeInsets.symmetric(
                                              vertical:
                                                  Dimensions.paddingSizeSmall,
                                              horizontal:
                                                  Dimensions.paddingSizeLarge),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radiusSmall),
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          padding: const EdgeInsets.all(
                                              Dimensions.paddingSizeSmall),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  restaurant.discount!
                                                              .discountType ==
                                                          'percent'
                                                      ? '${restaurant.discount!.discount}% ${'off'.tr}'
                                                      : '${PriceConverter.convertPrice(restaurant.discount!.discount)} ${'off'.tr}',
                                                  style: robotoMedium.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeLarge,
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black),
                                                ),
                                                Text(
                                                  restaurant.discount!
                                                              .discountType ==
                                                          'percent'
                                                      ? '${'enjoy'.tr} ${restaurant.discount!.discount}% ${'off_on_all_categories'.tr}'
                                                      : '${'enjoy'.tr} ${PriceConverter.convertPrice(restaurant.discount!.discount)}'
                                                          ' ${'off_on_all_categories'.tr}',
                                                  style: robotoMedium.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeSmall,
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black),
                                                ),
                                                SizedBox(
                                                    height: (restaurant
                                                                    .discount!
                                                                    .minPurchase !=
                                                                0 ||
                                                            restaurant.discount!
                                                                    .maxDiscount !=
                                                                0)
                                                        ? 5
                                                        : 0),
                                                restaurant.discount!
                                                            .minPurchase !=
                                                        0
                                                    ? Text(
                                                        '[ ${'minimum_purchase'.tr}: ${PriceConverter.convertPrice(restaurant.discount!.minPurchase)} ]',
                                                        style: robotoRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeExtraSmall,
                                                            color: Theme.of(context)
                                                                        .brightness ==
                                                                    Brightness
                                                                        .dark
                                                                ? Colors.white
                                                                : Colors.black),
                                                      )
                                                    : const SizedBox(),
                                                restaurant.discount!
                                                            .maxDiscount !=
                                                        0
                                                    ? Text(
                                                        '[ ${'maximum_discount'.tr}: ${PriceConverter.convertPrice(restaurant.discount!.maxDiscount)} ]',
                                                        style: robotoRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeExtraSmall,
                                                            color: Theme.of(context)
                                                                        .brightness ==
                                                                    Brightness
                                                                        .dark
                                                                ? Colors.white
                                                                : Colors.black),
                                                      )
                                                    : const SizedBox(),
                                                Text(
                                                  '[ ${'daily_time'.tr}: ${DateConverter.convertTimeToTime(restaurant.discount!.startTime!)} '
                                                  '- ${DateConverter.convertTimeToTime(restaurant.discount!.endTime!)} ]',
                                                  style: robotoRegular.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeExtraSmall,
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black),
                                                ),
                                              ]),
                                        )
                                      : const SizedBox(),
                                  SizedBox(
                                      height: (restaurant.announcementActive! &&
                                              restaurant.announcementMessage !=
                                                  null)
                                          ? 0
                                          : Dimensions.paddingSizeSmall),
                                  ResponsiveHelper.isMobile(context)
                                      ? (restaurant.announcementActive! &&
                                              restaurant.announcementMessage !=
                                                  null)
                                          ? Container(
                                              decoration: const BoxDecoration(
                                                  color: Colors.green),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: Dimensions
                                                          .paddingSizeSmall,
                                                      horizontal: Dimensions
                                                          .paddingSizeLarge),
                                              margin: const EdgeInsets.only(
                                                  bottom: Dimensions
                                                      .paddingSizeSmall),
                                              child: Row(children: [
                                                Image.asset(
                                                    XmarketImages.announcement,
                                                    height: 26,
                                                    width: 26),
                                                const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeSmall),
                                                Flexible(
                                                    child: Text(
                                                  restaurant
                                                          .announcementMessage ??
                                                      '',
                                                  style: robotoMedium.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeSmall,
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black),
                                                )),
                                              ]),
                                            )
                                          : const SizedBox()
                                      : const SizedBox(),
                                  restController.recommendedProductModel !=
                                              null &&
                                          restController
                                              .recommendedProductModel!
                                              .products!
                                              .isNotEmpty
                                      ? Container(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withValues(alpha: 0.10),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: Dimensions
                                                        .paddingSizeLarge,
                                                    left: Dimensions
                                                        .paddingSizeLarge,
                                                    bottom: Dimensions
                                                        .paddingSizeSmall,
                                                    right: Dimensions
                                                        .paddingSizeLarge,
                                                  ),
                                                  child: Row(children: [
                                                    Expanded(
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                'recommend_for_you'
                                                                    .tr,
                                                                style: robotoMedium.copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeLarge,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700)),
                                                            const SizedBox(
                                                                height: Dimensions
                                                                    .paddingSizeExtraSmall),
                                                            Text(
                                                                'here_is_what_you_might_like_to_test'
                                                                    .tr,
                                                                style: robotoRegular.copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeSmall,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .disabledColor)),
                                                          ]),
                                                    ),
                                                    ArrowIconButtonWidget(
                                                      onTap: () => Get.toNamed(
                                                          RouteHelper.getPopularFoodRoute(
                                                              false,
                                                              fromIsRestaurantFood:
                                                                  true,
                                                              restaurantId: widget
                                                                      .restaurant!
                                                                      .id ??
                                                                  Get.find<
                                                                          RestaurantController>()
                                                                      .restaurant!
                                                                      .id!)),
                                                    ),
                                                  ]),
                                                ),
                                                SizedBox(
                                                  height: ResponsiveHelper
                                                          .isDesktop(context)
                                                      ? 307
                                                      : 305,
                                                  width: context.width,
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount: restController
                                                        .recommendedProductModel!
                                                        .products!
                                                        .length,
                                                    physics:
                                                        const BouncingScrollPhysics(),
                                                    padding: const EdgeInsets
                                                        .only(
                                                        top: Dimensions
                                                            .paddingSizeExtraSmall,
                                                        bottom: Dimensions
                                                            .paddingSizeExtraSmall,
                                                        right: Dimensions
                                                            .paddingSizeDefault),
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            left: Dimensions
                                                                .paddingSizeDefault),
                                                        child: ItemCardWidget(
                                                          product: restController
                                                              .recommendedProductModel!
                                                              .products![index],
                                                          isBestItem: false,
                                                          isPopularNearbyItem:
                                                              false,
                                                          width: ResponsiveHelper
                                                                  .isDesktop(
                                                                      context)
                                                              ? 200
                                                              : MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.53,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeSmall),
                                              ]),
                                        )
                                      : const SizedBox(),
                                ]),
                              ))),
                              (restController.categoryList!.isNotEmpty)
                                  ? SliverPersistentHeader(
                                      pinned: true,
                                      delegate: SliverDelegate(
                                        height: 140,
                                        child: Center(
                                            child: Container(
                                          width: Dimensions.webMaxWidth,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            boxShadow: isDesktop
                                                ? []
                                                : [
                                                    BoxShadow(
                                                        color: Colors.grey
                                                            .withValues(
                                                                alpha: 0.1),
                                                        spreadRadius: 1,
                                                        blurRadius: 10,
                                                        offset:
                                                            const Offset(0, 1))
                                                  ],
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: Dimensions
                                                  .paddingSizeExtraSmall),
                                          child: Column(children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: Dimensions
                                                      .paddingSizeDefault,
                                                  right: Dimensions
                                                      .paddingSizeDefault,
                                                  top: Dimensions
                                                      .paddingSizeSmall),
                                              child: Row(children: [
                                                Text('all_food_items'.tr,
                                                    style: robotoBold.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeDefault)),
                                                const Expanded(
                                                    child: SizedBox()),
                                                isDesktop
                                                    ? Container(
                                                        padding: const EdgeInsets
                                                            .all(Dimensions
                                                                .paddingSizeExtraSmall),
                                                        height: 35,
                                                        width: 320,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(25),
                                                          color:
                                                              Theme.of(context)
                                                                  .cardColor,
                                                          border: Border.all(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              width: 0.3),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: TextField(
                                                                controller:
                                                                    _searchController,
                                                                textInputAction:
                                                                    TextInputAction
                                                                        .search,
                                                                decoration:
                                                                    InputDecoration(
                                                                  contentPadding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          0,
                                                                      vertical:
                                                                          0),
                                                                  hintText:
                                                                      'search_for_your_food'
                                                                          .tr,
                                                                  hintStyle: robotoRegular.copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeSmall,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .disabledColor),
                                                                  border: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(Dimensions
                                                                              .radiusSmall),
                                                                      borderSide:
                                                                          BorderSide
                                                                              .none),
                                                                  filled: true,
                                                                  fillColor: Theme.of(
                                                                          context)
                                                                      .cardColor,
                                                                  isDense: true,
                                                                  prefixIcon:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      if (!restController
                                                                          .isSearching) {
                                                                        Get.find<RestaurantController>()
                                                                            .getRestaurantSearchProductList(
                                                                          _searchController
                                                                              .text
                                                                              .trim(),
                                                                          Get.find<RestaurantController>()
                                                                              .restaurant!
                                                                              .id
                                                                              .toString(),
                                                                          1,
                                                                          restController
                                                                              .type,
                                                                        );
                                                                      } else {
                                                                        _searchController.text =
                                                                            '';
                                                                        restController
                                                                            .initSearchData();
                                                                        restController
                                                                            .changeSearchStatus();
                                                                      }
                                                                    },
                                                                    child: Icon(
                                                                        restController.isSearching
                                                                            ? Icons
                                                                                .clear
                                                                            : CupertinoIcons
                                                                                .search,
                                                                        color: Theme.of(context)
                                                                            .primaryColor
                                                                            .withValues(alpha: 0.50)),
                                                                  ),
                                                                ),
                                                                onSubmitted:
                                                                    (String?
                                                                        value) {
                                                                  if (value!
                                                                      .isNotEmpty) {
                                                                    restController
                                                                        .getRestaurantSearchProductList(
                                                                      _searchController
                                                                          .text
                                                                          .trim(),
                                                                      Get.find<
                                                                              RestaurantController>()
                                                                          .restaurant!
                                                                          .id
                                                                          .toString(),
                                                                      1,
                                                                      restController
                                                                          .type,
                                                                    );
                                                                  }
                                                                },
                                                                onChanged:
                                                                    (String?
                                                                        value) {},
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: Dimensions
                                                                    .paddingSizeSmall),
                                                          ],
                                                        ),
                                                      )
                                                    : InkWell(
                                                        onTap: () async {
                                                          await Get.toNamed(
                                                              RouteHelper
                                                                  .getSearchRestaurantProductRoute(
                                                                      restaurant!
                                                                          .id));
                                                          if (restController
                                                              .isSearching) {
                                                            restController
                                                                .changeSearchStatus();
                                                          }
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    Dimensions
                                                                        .radiusDefault),
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor
                                                                .withValues(
                                                                    alpha: 0.1),
                                                          ),
                                                          padding: const EdgeInsets
                                                              .all(Dimensions
                                                                      .paddingSizeSmall -
                                                                  2),
                                                          child: Image.asset(
                                                              XmarketImages
                                                                  .search,
                                                              height: 20,
                                                              width: 20,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              fit:
                                                                  BoxFit.cover),
                                                        ),
                                                      ),
                                                restController.type.isNotEmpty
                                                    ? VegFilterWidget(
                                                        type:
                                                            restController.type,
                                                        iconColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                        onSelected:
                                                            (String type) {
                                                          restController
                                                              .getRestaurantProductList(
                                                                  restController
                                                                      .restaurant!
                                                                      .id,
                                                                  1,
                                                                  type,
                                                                  true);
                                                        },
                                                      )
                                                    : const SizedBox(),
                                              ]),
                                            ),
                                            const Divider(
                                                thickness: 0.2, height: 10),
                                            // Show subcategories only when a category is selected (categoryIndex > 0)
                                            GetBuilder<
                                                MarketCategoryController>(
                                              builder: (categoryController) {
                                                // Determine subcategories for the selected category (if any)
                                                final subCategoryList = (restController
                                                                .categoryIndex >
                                                            0 &&
                                                        categoryController
                                                                .subCategoryList !=
                                                            null &&
                                                        categoryController
                                                                .parentCategoryId ==
                                                            restController
                                                                .categoryList![
                                                                    restController
                                                                        .categoryIndex]
                                                                .id
                                                                .toString())
                                                    ? categoryController
                                                        .subCategoryList!
                                                        .where((sub) =>
                                                            sub.id !=
                                                            restController
                                                                .categoryList![
                                                                    restController
                                                                        .categoryIndex]
                                                                .id)
                                                        .toList()
                                                    : [];

                                                return SizedBox(
                                                  height: 45,
                                                  child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount: subCategoryList
                                                            .length +
                                                        1, // +1 for "الجميع" button
                                                    padding: const EdgeInsets
                                                        .only(
                                                        left: Dimensions
                                                            .paddingSizeDefault),
                                                    physics:
                                                        const BouncingScrollPhysics(),
                                                    itemBuilder:
                                                        (context, index) {
                                                      // First item is "الجميع" button
                                                      if (index == 0) {
                                                        return InkWell(
                                                          onTap: () {
                                                            // Reset to show all categories grid
                                                            restController
                                                                .setCategoryIndex(
                                                                    0);
                                                            // Clear subcategories
                                                            Get.find<
                                                                    MarketCategoryController>()
                                                                .clearSubCategories();
                                                            // Load all products
                                                            if (restController
                                                                    .restaurant
                                                                    ?.id !=
                                                                null) {
                                                              restController
                                                                  .getRestaurantProductList(
                                                                restController
                                                                    .restaurant!
                                                                    .id,
                                                                1,
                                                                'all',
                                                                false,
                                                              );
                                                            }
                                                          },
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: Dimensions
                                                                  .paddingSizeSmall,
                                                              vertical: Dimensions
                                                                  .paddingSizeExtraSmall,
                                                            ),
                                                            margin: const EdgeInsets
                                                                .only(
                                                                right: Dimensions
                                                                    .paddingSizeSmall),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      Dimensions
                                                                          .radiusDefault),
                                                              color: restController
                                                                          .categoryIndex ==
                                                                      0
                                                                  ? Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                      .withValues(
                                                                          alpha:
                                                                              0.1)
                                                                  : Colors
                                                                      .transparent,
                                                              border:
                                                                  Border.all(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor
                                                                    .withValues(
                                                                        alpha:
                                                                            0.3),
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                  Icons.home,
                                                                  size: 16,
                                                                  color: restController
                                                                              .categoryIndex ==
                                                                          0
                                                                      ? Theme.of(
                                                                              context)
                                                                          .primaryColor
                                                                      : Theme.of(
                                                                              context)
                                                                          .disabledColor,
                                                                ),
                                                                const SizedBox(
                                                                    width: 4),
                                                                Text(
                                                                  'جميع الاقسام',
                                                                  style: restController
                                                                              .categoryIndex ==
                                                                          0
                                                                      ? robotoMedium
                                                                          .copyWith(
                                                                          fontSize:
                                                                              Dimensions.fontSizeSmall,
                                                                          color:
                                                                              Theme.of(context).primaryColor,
                                                                        )
                                                                      : robotoRegular
                                                                          .copyWith(
                                                                          fontSize:
                                                                              Dimensions.fontSizeSmall,
                                                                        ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }

                                                      // Other items are subcategories
                                                      final subCategory =
                                                          subCategoryList[index -
                                                              1]; // -1 because first item is "الجميع"
                                                      // Find the actual index in the full list in controller
                                                      int realIndex =
                                                          categoryController
                                                              .subCategoryList!
                                                              .indexOf(
                                                                  subCategory);

                                                      return InkWell(
                                                        onTap: () {
                                                          categoryController
                                                              .setSubCategoryIndex(
                                                            realIndex +
                                                                1, // +1 because 0 is "All" in controller
                                                            restController
                                                                .categoryList![
                                                                    restController
                                                                        .categoryIndex]
                                                                .id
                                                                .toString(),
                                                          );
                                                          // Load products for this subcategory
                                                          if (restController
                                                                      .restaurant
                                                                      ?.id !=
                                                                  null &&
                                                              subCategory.id !=
                                                                  null) {
                                                            restController
                                                                .getRestaurantProductListByCategoryId(
                                                              restController
                                                                  .restaurant!
                                                                  .id,
                                                              1,
                                                              subCategory.id!,
                                                              restController
                                                                  .type,
                                                              false,
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: Dimensions
                                                                  .paddingSizeSmall,
                                                              vertical: Dimensions
                                                                  .paddingSizeExtraSmall),
                                                          margin: const EdgeInsets
                                                              .only(
                                                              right: Dimensions
                                                                  .paddingSizeSmall),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    Dimensions
                                                                        .radiusDefault),
                                                            color: (realIndex +
                                                                        1) ==
                                                                    categoryController
                                                                        .subCategoryIndex
                                                                ? Theme.of(
                                                                        context)
                                                                    .primaryColor
                                                                    .withValues(
                                                                        alpha:
                                                                            0.1)
                                                                : Colors
                                                                    .transparent,
                                                          ),
                                                          child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const SizedBox(
                                                                    height: 4),
                                                                Text(
                                                                  subCategory
                                                                          .name ??
                                                                      '',
                                                                  style: (realIndex +
                                                                              1) ==
                                                                          categoryController
                                                                              .subCategoryIndex
                                                                      ? robotoMedium.copyWith(
                                                                          fontSize: Dimensions
                                                                              .fontSizeSmall,
                                                                          color: Theme.of(context)
                                                                              .primaryColor)
                                                                      : robotoRegular.copyWith(
                                                                          fontSize:
                                                                              Dimensions.fontSizeSmall),
                                                                ),
                                                              ]),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                          ]),
                                        )),
                                      ),
                                    )
                                  : const SliverToBoxAdapter(child: SizedBox()),
                              SliverToBoxAdapter(
                                child: Center(
                                    child: Container(
                                  width: Dimensions.webMaxWidth,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                  ),
                                  child: (!restController.isSearching &&
                                          restController.categoryList != null &&
                                          restController
                                              .categoryList!.isNotEmpty)
                                      ? (restController.categoryIndex > 0
                                          ? GetBuilder<
                                              MarketCategoryController>(
                                              builder: (categoryController) {
                                                // Check if we have subcategories for the selected category
                                                if (categoryController
                                                            .subCategoryList !=
                                                        null &&
                                                    categoryController
                                                        .subCategoryList!
                                                        .isNotEmpty &&
                                                    categoryController
                                                            .parentCategoryId ==
                                                        restController
                                                            .categoryList![
                                                                restController
                                                                    .categoryIndex]
                                                            .id
                                                            .toString()) {
                                                  // Show products for selected subcategory or all products of the category
                                                  return GetBuilder<
                                                      RestaurantController>(
                                                    builder: (restCtrl) {
                                                      return PaginatedListViewWidget(
                                                        scrollController:
                                                            scrollController,
                                                        onPaginate:
                                                            (int? offset) {
                                                          // Show bottom loader
                                                          restCtrl
                                                              .showFoodBottomLoader();

                                                          // Determine the ID to use for pagination
                                                          int categoryIdToLoad;
                                                          if (categoryController
                                                                  .subCategoryIndex ==
                                                              0) {
                                                            // If "All" subcategory selected, use main category ID
                                                            categoryIdToLoad =
                                                                restController
                                                                    .categoryList![
                                                                        restController
                                                                            .categoryIndex]
                                                                    .id!;
                                                          } else {
                                                            // Use the selected subcategory ID
                                                            categoryIdToLoad =
                                                                categoryController
                                                                    .subCategoryList![
                                                                        categoryController.subCategoryIndex -
                                                                            1]
                                                                    .id!;
                                                          }

                                                          restCtrl
                                                              .getRestaurantProductListByCategoryId(
                                                            restCtrl
                                                                .restaurant!.id,
                                                            offset!,
                                                            categoryIdToLoad,
                                                            restCtrl.type,
                                                            false,
                                                          );
                                                        },
                                                        totalSize: restCtrl
                                                            .foodPageSize,
                                                        offset: restCtrl
                                                            .foodPageOffset,
                                                        productView: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            ProductViewWidget(
                                                              isRestaurant:
                                                                  false,
                                                              restaurants: null,
                                                              products: restCtrl
                                                                  .restaurantProducts,
                                                              inRestaurantPage:
                                                                  true,
                                                              useGridCard: true,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal:
                                                                    Dimensions
                                                                        .paddingSizeSmall,
                                                                vertical: Dimensions
                                                                    .paddingSizeLarge,
                                                              ),
                                                            ),
                                                            if (restCtrl
                                                                .foodPaginate)
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .all(
                                                                    Dimensions
                                                                        .paddingSizeDefault),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    const SizedBox(
                                                                      height:
                                                                          20,
                                                                      width: 20,
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        color: Colors
                                                                            .black,
                                                                        strokeWidth:
                                                                            2,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width: Dimensions
                                                                            .paddingSizeSmall),
                                                                    Text(
                                                                      'جاري تحميل المزيد...',
                                                                      style: robotoRegular.copyWith(
                                                                          fontSize: Dimensions
                                                                              .fontSizeSmall,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }
                                                // Fallback to subcategories widget if no subcategories loaded yet
                                                return RestaurantCategoryWithSubcategoriesWidget(
                                                  category: restController
                                                          .categoryList![
                                                      restController
                                                          .categoryIndex],
                                                  restaurantId: restController
                                                      .restaurant?.id,
                                                  scrollController:
                                                      scrollController,
                                                );
                                              },
                                            )
                                          : // Show categories grid when categoryIndex == 0
                                          GetBuilder<RestaurantController>(
                                              builder: (restCtrl) {
                                                // Filter out "الجميع" category
                                                final categoriesToShow =
                                                    restCtrl.categoryList!
                                                        .where(
                                                            (cat) =>
                                                                cat.name !=
                                                                'الجميع')
                                                        .toList();

                                                return GridView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  padding: const EdgeInsets.all(
                                                      Dimensions
                                                          .paddingSizeDefault),
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount:
                                                        2, // 2 cards per row
                                                    crossAxisSpacing: Dimensions
                                                        .paddingSizeDefault,
                                                    mainAxisSpacing: Dimensions
                                                        .paddingSizeDefault,
                                                    childAspectRatio:
                                                        1.0, // Square cards
                                                  ),
                                                  itemCount:
                                                      categoriesToShow.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final category =
                                                        categoriesToShow[index];
                                                    return InkWell(
                                                      onTap: () async {
                                                        if (category.id !=
                                                            null) {
                                                          // Find the index of this category in the full categoryList
                                                          final categoryIndex =
                                                              restCtrl
                                                                  .categoryList!
                                                                  .indexWhere(
                                                            (cat) =>
                                                                cat.id ==
                                                                category.id,
                                                          );

                                                          if (categoryIndex !=
                                                              -1) {
                                                            // Set the category index to show subcategories in the bar
                                                            restCtrl
                                                                .setCategoryIndex(
                                                                    categoryIndex);

                                                            // Load subcategories for this category
                                                            final catController =
                                                                Get.find<
                                                                    MarketCategoryController>();
                                                            await catController
                                                                .getSubCategoryList(
                                                                    category.id
                                                                        .toString());

                                                            // Load products: either first subcategory or all category items
                                                            if (restCtrl.restaurant
                                                                        ?.id !=
                                                                    null &&
                                                                category.id !=
                                                                    null) {
                                                              if (catController
                                                                          .subCategoryList !=
                                                                      null &&
                                                                  catController
                                                                      .subCategoryList!
                                                                      .isNotEmpty) {
                                                                // Automatically select the first sub-category (index 1)
                                                                final firstSubCategory =
                                                                    catController
                                                                        .subCategoryList![0];
                                                                catController
                                                                    .setSubCategoryIndex(
                                                                  1,
                                                                  category.id
                                                                      .toString(),
                                                                  dataLoad:
                                                                      false,
                                                                );

                                                                restCtrl
                                                                    .getRestaurantProductListByCategoryId(
                                                                  restCtrl
                                                                      .restaurant!
                                                                      .id,
                                                                  1,
                                                                  firstSubCategory
                                                                      .id!,
                                                                  restCtrl.type,
                                                                  false,
                                                                );
                                                              } else {
                                                                // Fallback to loading all if no subcategories exist
                                                                restCtrl
                                                                    .getRestaurantProductListByCategoryId(
                                                                  restCtrl
                                                                      .restaurant!
                                                                      .id,
                                                                  1,
                                                                  category.id!,
                                                                  restCtrl.type,
                                                                  false,
                                                                );
                                                              }
                                                            }
                                                          }
                                                        }
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .cardColor,
                                                          borderRadius: BorderRadius
                                                              .circular(Dimensions
                                                                  .radiusDefault),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .withValues(
                                                                      alpha:
                                                                          0.1),
                                                              blurRadius: 4,
                                                              offset:
                                                                  const Offset(
                                                                      0, 1),
                                                            )
                                                          ],
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            // Category Image or Icon
                                                            category.imageFullUrl !=
                                                                        null &&
                                                                    category
                                                                        .imageFullUrl!
                                                                        .isNotEmpty
                                                                ? ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            Dimensions.radiusSmall),
                                                                    child:
                                                                        CustomImageWidget(
                                                                      image: category
                                                                          .imageFullUrl!,
                                                                      height:
                                                                          90,
                                                                      width: 90,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  )
                                                                : Icon(
                                                                    Icons
                                                                        .category,
                                                                    size: 90,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                  ),
                                                            const SizedBox(
                                                                height: Dimensions
                                                                    .paddingSizeSmall),
                                                            // Category Name
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal:
                                                                    Dimensions
                                                                        .paddingSizeSmall,
                                                              ),
                                                              child: Text(
                                                                category.name ??
                                                                    '',
                                                                style:
                                                                    robotoMedium
                                                                        .copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeDefault,
                                                                  color: Theme.of(context)
                                                                              .brightness ==
                                                                          Brightness
                                                                              .dark
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ))
                                      : PaginatedListViewWidget(
                                          scrollController: scrollController,
                                          onPaginate: (int? offset) {
                                            if (restController.isSearching) {
                                              restController
                                                  .getRestaurantSearchProductList(
                                                restController.searchText,
                                                Get.find<RestaurantController>()
                                                    .restaurant!
                                                    .id
                                                    .toString(),
                                                offset!,
                                                restController.type,
                                              );
                                            } else {
                                              restController
                                                  .getRestaurantProductList(
                                                      Get.find<
                                                              RestaurantController>()
                                                          .restaurant!
                                                          .id,
                                                      offset!,
                                                      restController.type,
                                                      false);
                                            }
                                          },
                                          totalSize: restController.isSearching
                                              ? restController
                                                  .restaurantSearchProductModel
                                                  ?.totalSize
                                              : restController
                                                          .restaurantProducts !=
                                                      null
                                                  ? restController.foodPageSize
                                                  : null,
                                          offset: restController.isSearching
                                              ? restController
                                                  .restaurantSearchProductModel
                                                  ?.offset
                                              : restController
                                                          .restaurantProducts !=
                                                      null
                                                  ? restController
                                                      .foodPageOffset
                                                  : null,
                                          productView: ProductViewWidget(
                                            isRestaurant: false,
                                            restaurants: null,
                                            products: restController.isSearching
                                                ? restController
                                                    .restaurantSearchProductModel
                                                    ?.products
                                                : restController.categoryList!
                                                        .isNotEmpty
                                                    ? restController
                                                        .restaurantProducts
                                                    : null,
                                            inRestaurantPage: true,
                                            useGridCard: true,
                                          ),
                                        ),
                                )),
                              )
                            ],
                          )
                        : const RestaurantScreenShimmerWidget();
                  });
                });
              }),
              bottomNavigationBar:
                  GetBuilder<MarketCartController>(builder: (cartController) {
                return cartController.cartList.isNotEmpty && !isDesktop
                    ? BottomCartWidget(
                        restaurantId:
                            cartController.cartList[0].product!.restaurantId!,
                        fromDineIn: widget.fromDineIn)
                    : const SizedBox();
              }),
            ));
      },
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 100});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height ||
        oldDelegate.minExtent != height ||
        child != oldDelegate.child;
  }
}

// class CategoryProduct {
//   CategoryModel category;
//   List<Product> products;
//   CategoryProduct(this.category, this.products);
// }
