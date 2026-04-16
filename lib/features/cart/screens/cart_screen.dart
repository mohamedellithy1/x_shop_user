import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/theme/dark_theme.dart';
import 'package:stackfood_multivendor/theme/light_theme.dart';

import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_loader_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_constrained_box.dart';
import 'package:stackfood_multivendor/common/widgets/web_page_title_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/widgets/cart_product_widget.dart';
import 'package:stackfood_multivendor/features/cart/widgets/checkout_button_widget.dart';
import 'package:stackfood_multivendor/features/cart/widgets/pricing_view_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/coupon/domain/models/coupon_model.dart'
    hide Restaurant;
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CartScreen extends StatefulWidget {
  final bool fromNav;
  final bool fromReorder;
  final bool fromDineIn;
  const CartScreen(
      {super.key,
      required this.fromNav,
      this.fromReorder = false,
      this.fromDineIn = false});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ScrollController scrollController = ScrollController();

  ThemeData get darkTheme => dark;
  final ThemeData lightTheme = light;

  @override
  void initState() {
    super.initState();
    initCall();
  }

  Future<void> initCall() async {
    Get.find<RestaurantController>().makeEmptyRestaurant(willUpdate: false);
    Get.find<MarketCartController>().setAvailableIndex(-1, willUpdate: false);
    Get.find<CheckoutController>().setInstruction(-1, willUpdate: false);
    await Get.find<MarketCartController>().getCartDataOnline();
    if (Get.find<MarketCartController>().cartList.isNotEmpty) {
      if (Get.find<MarketCartController>().cartList[0].product != null) {
        await Get.find<RestaurantController>().getRestaurantDetails(
            Restaurant(
                id: Get.find<MarketCartController>()
                        .cartList[0]
                        .product!
                        .restaurantId ??
                    0,
                name: null),
            fromCart: true);
        Get.find<MarketCartController>().calculationCart();
        if (Get.find<MarketCartController>().addCutlery) {
          Get.find<MarketCartController>().updateCutlery(isUpdate: false);
        }
        if (Get.find<MarketCartController>().needExtraPackage) {
          Get.find<MarketCartController>()
              .toggleExtraPackage(willUpdate: false);
        }
        Get.find<RestaurantController>().getCartRestaurantSuggestedItemList(
            Get.find<MarketCartController>()
                    .cartList[0]
                    .product!
                    .restaurantId ??
                0);
        showReferAndEarnSnackBar();
      }
    }
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
              backgroundColor: marketThemeController.darkTheme
                  ? Colors.black
                  : Color(0xFFfafef5),
              appBar: CustomAppBarWidget(
                  title: 'my_cart'.tr,
                  isBackButtonExist: (isDesktop || !widget.fromNav)),
              endDrawer: const MenuDrawerWidget(),
              endDrawerEnableOpenDragGesture: false,
              body: GetBuilder<RestaurantController>(
                  builder: (restaurantController) {
                return GetBuilder<MarketCartController>(
                  builder: (cartController) {
                    bool isRestaurantOpen = true;

                    if (restaurantController.restaurant != null &&
                        restaurantController.restaurant!.active != null) {
                      isRestaurantOpen =
                          restaurantController.isRestaurantOpenNow(
                              restaurantController.restaurant!.active!,
                              restaurantController.restaurant!.schedules);
                    }

                    bool suggestionEmpty =
                        (restaurantController.suggestedItems != null &&
                            restaurantController.suggestedItems!.isEmpty);

                    double distance =
                        Get.find<RestaurantController>().getRestaurantDistance(
                      LatLng(
                          double.parse(
                              restaurantController.restaurant?.latitude ?? '0'),
                          double.parse(
                              restaurantController.restaurant?.longitude ??
                                  '0')),
                    );

                    return (cartController.isLoading && widget.fromReorder)
                        ? const CustomLoaderWidget()
                        : cartController.cartList.isNotEmpty
                            ? Column(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      controller: scrollController,
                                      padding: isDesktop
                                          ? const EdgeInsets.only(
                                              top: Dimensions.paddingSizeSmall)
                                          : EdgeInsets.zero,
                                      child: Center(
                                        child: SizedBox(
                                          width: Dimensions.webMaxWidth,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                WebScreenTitleWidget(
                                                    title: 'my_cart'.tr),
                                                Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        flex: 6,
                                                        child: Column(
                                                            children: [
                                                              // restaurantController
                                                              //             .restaurant !=
                                                              //         null
                                                              //     ? Container(
                                                              //         margin: isDesktop
                                                              //             ? null
                                                              //             : const EdgeInsets
                                                              //                 .only(
                                                              //                 top: Dimensions
                                                              //                     .paddingSizeDefault,
                                                              //                 left: Dimensions
                                                              //                     .paddingSizeDefault,
                                                              //                 right: Dimensions
                                                              //                     .paddingSizeDefault),
                                                              //         padding: const EdgeInsets
                                                              //             .symmetric(
                                                              //             horizontal: Dimensions
                                                              //                 .paddingSizeDefault,
                                                              //             vertical: Dimensions
                                                              //                 .paddingSizeSmall),
                                                              //         decoration:
                                                              //             BoxDecoration(
                                                              //           color: Theme.of(
                                                              //                   context)
                                                              //               .cardColor,
                                                              //           boxShadow: [
                                                              //             BoxShadow(
                                                              //                 color: Colors
                                                              //                     .grey
                                                              //                     .withValues(
                                                              //                         alpha:
                                                              //                             0.1),
                                                              //                 spreadRadius:
                                                              //                     1,
                                                              //                 blurRadius:
                                                              //                     10,
                                                              //                 offset:
                                                              //                     const Offset(
                                                              //                         0, 1))
                                                              //           ],
                                                              //           borderRadius:
                                                              //               BorderRadius.circular(
                                                              //                   Dimensions
                                                              //                       .radiusDefault),
                                                              //         ),
                                                              //         child: Row(children: [
                                                              //           Container(
                                                              //             decoration:
                                                              //                 BoxDecoration(
                                                              //               border: Border.all(
                                                              //                   color: Theme.of(
                                                              //                           context)
                                                              //                       .disabledColor
                                                              //                       .withValues(
                                                              //                           alpha:
                                                              //                               0.1)),
                                                              //               shape: BoxShape
                                                              //                   .circle,
                                                              //             ),
                                                              //             child: ClipOval(
                                                              //               child:
                                                              //                   CustomImageWidget(
                                                              //                 image: restaurantController
                                                              //                         .restaurant
                                                              //                         ?.logoFullUrl ??
                                                              //                     '',
                                                              //                 height: 50,
                                                              //                 width: 50,
                                                              //               ),
                                                              //             ),
                                                              //           ),
                                                              //           const SizedBox(
                                                              //               width: Dimensions
                                                              //                   .paddingSizeDefault),
                                                              //           Expanded(
                                                              //             child: Column(
                                                              //                 crossAxisAlignment:
                                                              //                     CrossAxisAlignment
                                                              //                         .start,
                                                              //                 children: [
                                                              //                   Text(
                                                              //                     restaurantController
                                                              //                             .restaurant
                                                              //                             ?.name ??
                                                              //                         '',
                                                              //                     style:
                                                              //                         robotoMedium,
                                                              //                     maxLines:
                                                              //                         1,
                                                              //                     overflow:
                                                              //                         TextOverflow
                                                              //                             .ellipsis,
                                                              //                   ),
                                                              //                   const SizedBox(
                                                              //                       height:
                                                              //                           Dimensions.paddingSizeExtraSmall),
                                                              //                   // Row(children: [
                                                              //                   //   Icon(Icons.access_time, color: Theme.of(context).disabledColor, size: 16),
                                                              //                   //   const SizedBox(width: 3),
                                                              //                   //   Text(restaurantController.restaurant!.deliveryTime ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                                                              //                   //   const SizedBox(width: 3),
                                                              //                   //   Text('(${distance.toStringAsFixed(2)} ${'km'.tr})', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                                                              //                   // ]),
                                                              //                 ]),
                                                              //           ),
                                                              //           const SizedBox(
                                                              //               width: Dimensions
                                                              //                   .paddingSizeDefault),
                                                              //           Row(children: [
                                                              //             Icon(Icons.star,
                                                              //                 size: 16,
                                                              //                 color: Theme.of(
                                                              //                         context)
                                                              //                     .primaryColor),
                                                              //             const SizedBox(
                                                              //                 width: Dimensions
                                                              //                     .paddingSizeExtraSmall),
                                                              //             Text(
                                                              //                 (restaurantController
                                                              //                             .restaurant!
                                                              //                             .avgRating ??
                                                              //                         0.0)
                                                              //                     .toStringAsFixed(
                                                              //                         1),
                                                              //                 style:
                                                              //                     robotoMedium),
                                                              //             const SizedBox(
                                                              //                 width: Dimensions
                                                              //                     .paddingSizeExtraSmall),
                                                              //             // Text(
                                                              //             //     '(${(restaurantController.restaurant!.ratingCount ?? 0) > 25 ? '25+' : (restaurantController.restaurant!.ratingCount ?? 0)})',
                                                              //             //     style: robotoRegular.copyWith(
                                                              //             //         fontSize:
                                                              //             //             Dimensions
                                                              //             //                 .fontSizeSmall,
                                                              //             //         color: Theme.of(
                                                              //             //                 context)
                                                              //             //             .disabledColor)),
                                                              //           ]),
                                                              //         ]),
                                                              //       )
                                                              //     : const CustomLoaderWidget(
                                                              //       size: 50,
                                                              //     ),
                                                              SizedBox(
                                                                  height: isDesktop
                                                                      ? Dimensions
                                                                          .paddingSizeSmall
                                                                      : 12),
                                                              Container(
                                                                decoration: isDesktop
                                                                    ? BoxDecoration(
                                                                        borderRadius: const BorderRadius
                                                                            .all(
                                                                            Radius.circular(Dimensions.radiusDefault)),
                                                                        color: Theme.of(context)
                                                                            .cardColor,
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                              color: Colors.grey.withValues(alpha: 0.1),
                                                                              spreadRadius: 1,
                                                                              blurRadius: 10,
                                                                              offset: const Offset(0, 1))
                                                                        ],
                                                                      )
                                                                    : const BoxDecoration(),
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      WebConstrainedBox(
                                                                        dataLength: cartController
                                                                            .cartList
                                                                            .length,
                                                                        minLength:
                                                                            5,
                                                                        minHeight: suggestionEmpty
                                                                            ? 0.6
                                                                            : 0.3,
                                                                        child: Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              !isRestaurantOpen && restaurantController.restaurant != null
                                                                                  ? !isDesktop
                                                                                      ? Center(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                                                                                            child: RichText(
                                                                                              textAlign: TextAlign.center,
                                                                                              text: TextSpan(children: [
                                                                                                TextSpan(text: 'currently_the_restaurant_is_unavailable_the_restaurant_will_be_available_at'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                                                                                                const TextSpan(text: ' '),
                                                                                                TextSpan(
                                                                                                  text: restaurantController.restaurant!.restaurantOpeningTime == 'closed' ? 'tomorrow'.tr : DateConverter.timeStringToTime(restaurantController.restaurant!.restaurantOpeningTime ?? ''),
                                                                                                  style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                                                                                                ),
                                                                                              ]),
                                                                                            ),
                                                                                          ),
                                                                                        )
                                                                                      : Container(
                                                                                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                                                                          decoration: BoxDecoration(
                                                                                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                                                                            borderRadius: const BorderRadius.only(
                                                                                              topLeft: Radius.circular(Dimensions.radiusDefault),
                                                                                              topRight: Radius.circular(Dimensions.radiusDefault),
                                                                                            ),
                                                                                          ),
                                                                                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                                                            RichText(
                                                                                              textAlign: TextAlign.start,
                                                                                              text: TextSpan(children: [
                                                                                                TextSpan(text: 'currently_the_restaurant_is_unavailable_the_restaurant_will_be_available_at'.tr, style: robotoRegular.copyWith(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
                                                                                                const TextSpan(text: ' '),
                                                                                                TextSpan(
                                                                                                  text: restaurantController.restaurant!.restaurantOpeningTime == 'closed' ? 'tomorrow'.tr : DateConverter.timeStringToTime(restaurantController.restaurant!.restaurantOpeningTime ?? ''),
                                                                                                  style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                                                                                                ),
                                                                                              ]),
                                                                                            ),
                                                                                            !isRestaurantOpen
                                                                                                ? Align(
                                                                                                    alignment: Alignment.center,
                                                                                                    child: InkWell(
                                                                                                      onTap: () {
                                                                                                        cartController.clearCartOnline();
                                                                                                      },
                                                                                                      child: Container(
                                                                                                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                                                                                        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                                                                                                        decoration: BoxDecoration(
                                                                                                          color: Colors.white,
                                                                                                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                                                                          border: Border.all(width: 1, color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                                                                                                        ),
                                                                                                        child: !cartController.isClearCartLoading
                                                                                                            ? Row(mainAxisSize: MainAxisSize.min, children: [
                                                                                                                Icon(CupertinoIcons.delete_solid, color: Theme.of(context).colorScheme.error, size: 20),
                                                                                                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                                                                                                Text(
                                                                                                                  cartController.cartList.length > 1 ? 'remove_all_from_cart'.tr : 'remove_from_cart'.tr,
                                                                                                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.7)),
                                                                                                                ),
                                                                                                              ])
                                                                                                            : const SizedBox(
                                                                                                                height: 20,
                                                                                                                width: 20,
                                                                                                                child: CircularProgressIndicator(
                                                                                                                  color: Color(0xFF9ebc67),
                                                                                                                )),
                                                                                                      ),
                                                                                                    ),
                                                                                                  )
                                                                                                : const SizedBox(),
                                                                                          ]),
                                                                                        )
                                                                                  : const SizedBox(),
                                                                              ConstrainedBox(
                                                                                constraints: BoxConstraints(maxHeight: isDesktop ? MediaQuery.of(context).size.height * 0.4 : double.infinity),
                                                                                child: ListView.builder(
                                                                                  physics: isDesktop ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
                                                                                  shrinkWrap: true,
                                                                                  padding: const EdgeInsets.only(
                                                                                    left: Dimensions.paddingSizeDefault,
                                                                                    right: Dimensions.paddingSizeDefault,
                                                                                    top: Dimensions.paddingSizeDefault,
                                                                                  ),
                                                                                  itemCount: cartController.cartList.length,
                                                                                  itemBuilder: (context, index) {
                                                                                    return CartProductWidget(
                                                                                      cart: cartController.cartList[index],
                                                                                      cartIndex: index,
                                                                                      addOns: cartController.addOnsList[index],
                                                                                      isAvailable: cartController.availableList[index],
                                                                                      isRestaurantOpen: isRestaurantOpen,
                                                                                    );
                                                                                  },
                                                                                ),
                                                                              ),
                                                                              !isRestaurantOpen
                                                                                  ? !isDesktop
                                                                                      ? Align(
                                                                                          alignment: Alignment.center,
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                                                                                            child: CustomInkWellWidget(
                                                                                              onTap: () {
                                                                                                cartController.clearCartOnline();
                                                                                              },
                                                                                              child: Container(
                                                                                                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                                                                                decoration: BoxDecoration(
                                                                                                  color: Theme.of(context).cardColor,
                                                                                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                                                                  border: Border.all(width: 1, color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                                                                                                ),
                                                                                                child: !cartController.isClearCartLoading
                                                                                                    ? Row(mainAxisSize: MainAxisSize.min, children: [
                                                                                                        Icon(CupertinoIcons.delete_solid, color: Theme.of(context).colorScheme.error, size: 20),
                                                                                                        const SizedBox(width: Dimensions.paddingSizeSmall),
                                                                                                        Text(cartController.cartList.length > 1 ? 'remove_all_from_cart'.tr : 'remove_from_cart'.tr, style: robotoMedium.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeSmall)),
                                                                                                      ])
                                                                                                    : const SizedBox(
                                                                                                        height: 20,
                                                                                                        width: 20,
                                                                                                        child: CircularProgressIndicator(
                                                                                                          color: Color(0xFF9ebc67),
                                                                                                        )),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        )
                                                                                      : const SizedBox()
                                                                                  : const SizedBox(),
                                                                              SizedBox(height: isDesktop ? 40 : 0),
                                                                              Container(
                                                                                alignment: Alignment.center,
                                                                                color: Theme.of(context).cardColor.withValues(alpha: 0.6),
                                                                                child: TextButton.icon(
                                                                                  onPressed: () {
                                                                                    Get.toNamed(RouteHelper.getCategoryRoute());
                                                                                  },
                                                                                  icon: Icon(Icons.add_circle_outline_sharp, color: Color(0xFF9ebc67)),
                                                                                  label: Text('add_more_items'.tr, style: robotoMedium.copyWith(color: Color(0xFF9ebc67), fontSize: Dimensions.fontSizeDefault)),
                                                                                ),
                                                                              ),
                                                                              SizedBox(height: !isDesktop ? 0 : 8),
                                                                            ]),
                                                                      ),
                                                                    ]),
                                                              ),
                                                            ]),
                                                      ),
                                                      if (isDesktop)
                                                        const SizedBox(
                                                            width: Dimensions
                                                                .paddingSizeLarge),
                                                      if (isDesktop)
                                                        pricingViewWidget(
                                                            cartController,
                                                            isRestaurantOpen),
                                                    ]),
                                              ]),
                                        ),
                                      ),
                                    ),
                                  ),
                                  isDesktop
                                      ? const SizedBox()
                                      : Container(
                                          width: context.width,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: const BorderRadius
                                                .only(
                                                topLeft: Radius.circular(
                                                    Dimensions.radiusDefault),
                                                topRight: Radius.circular(
                                                    Dimensions.radiusDefault)),
                                          ),
                                          child: Column(children: [
                                            Container(
                                              constraints:
                                                  const BoxConstraints.expand(
                                                      height: 30),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .disabledColor
                                                    .withValues(alpha: 0.5),
                                                borderRadius: const BorderRadius
                                                    .only(
                                                    topLeft: Radius.circular(
                                                        Dimensions
                                                            .radiusDefault),
                                                    topRight: Radius.circular(
                                                        Dimensions
                                                            .radiusDefault)),
                                              ),
                                              child: Icon(Icons.drag_handle,
                                                  color: Theme.of(context)
                                                      .hintColor,
                                                  size: 25),
                                            ),
                                            PricingViewWidget(
                                              cartController: cartController,
                                              isRestaurantOpen:
                                                  isRestaurantOpen,
                                              fromDineIn: widget.fromDineIn,
                                            ),
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeDefault),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: Dimensions
                                                          .paddingSizeDefault),
                                              child: Column(children: [
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text('item_price'.tr,
                                                          style: robotoRegular),
                                                      PriceConverter
                                                          .convertAnimationPrice(
                                                              cartController
                                                                  .itemPrice,
                                                              textStyle:
                                                                  robotoRegular),
                                                    ]),
                                                SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeSmall),
                                                cartController.variationPrice >
                                                        0
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text('variations'.tr,
                                                              style:
                                                                  robotoRegular),
                                                          Text(
                                                              PriceConverter
                                                                  .convertPrice(
                                                                      cartController
                                                                          .variationPrice),
                                                              style:
                                                                  robotoRegular,
                                                              textDirection:
                                                                  TextDirection
                                                                      .ltr),
                                                        ],
                                                      )
                                                    : const SizedBox(),
                                                SizedBox(
                                                    height: cartController
                                                                .variationPrice >
                                                            0
                                                        ? Dimensions
                                                            .paddingSizeSmall
                                                        : 0),
                                                cartController
                                                            .itemDiscountPrice >
                                                        0
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                            Text('discount'.tr,
                                                                style:
                                                                    robotoRegular),
                                                            restaurantController
                                                                        .restaurant !=
                                                                    null
                                                                ? Row(
                                                                    children: [
                                                                        Text(
                                                                            '(-)',
                                                                            style:
                                                                                robotoRegular),
                                                                        PriceConverter.convertAnimationPrice(
                                                                            cartController
                                                                                .itemDiscountPrice,
                                                                            textStyle:
                                                                                robotoRegular),
                                                                      ])
                                                                : Text(
                                                                    'calculating'
                                                                        .tr,
                                                                    style:
                                                                        robotoRegular),
                                                          ])
                                                    : const SizedBox(),
                                                SizedBox(
                                                    height: cartController
                                                                .itemDiscountPrice >
                                                            0
                                                        ? Dimensions
                                                            .paddingSizeSmall
                                                        : 0),
                                                // Row(
                                                //   mainAxisAlignment:
                                                //       MainAxisAlignment
                                                //           .spaceBetween,
                                                //   children: [
                                                //     Text('addons'.tr,
                                                //         style: robotoRegular),
                                                //     Row(children: [
                                                //       Text('(+)',
                                                //           style: robotoRegular),
                                                //       PriceConverter
                                                //           .convertAnimationPrice(
                                                //               cartController.addOns,
                                                //               textStyle:
                                                //                   robotoRegular),
                                                //     ]),
                                                //   ],
                                                // ),
                                                // ),
                                              ]),
                                            ),
                                          ]),
                                        ),
                                  isDesktop
                                      ? const SizedBox.shrink()
                                      : CheckoutButtonWidget(
                                          cartController: cartController,
                                          availableList:
                                              cartController.availableList,
                                          isRestaurantOpen: isRestaurantOpen,
                                          fromDineIn: widget.fromDineIn),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.only(top: 300),
                                child: Center(
                                  child: SingleChildScrollView(
                                    child: Center(
                                      child: Text(
                                        'you_have_not_add_to_cart_yet'.tr,
                                        style: robotoRegular.copyWith(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Color(0xFF55745a)),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                  },
                );
              }),
            ),
          );
        });
  }

  Widget pricingViewWidget(
      MarketCartController cartController, bool isRestaurantOpen) {
    return SizedBox(
      width: 400,
      child: PricingViewWidget(
        cartController: cartController,
        isRestaurantOpen: isRestaurantOpen,
        fromDineIn: widget.fromDineIn,
      ),
    );
  }

  Future<void> showReferAndEarnSnackBar() async {
    String text = 'your_referral_discount_added_on_your_first_order'.tr;
    if (Get.find<MarketProfileController>().userInfoModel != null &&
        (Get.find<MarketProfileController>()
                .userInfoModel!
                .isValidForDiscount ??
            false)) {
      showCustomSnackBar(text);
    }
  }
}
