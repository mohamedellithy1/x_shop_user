import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/product_card_data.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/discount_tag_widget.dart';
import 'package:stackfood_multivendor/common/widgets/discount_tag_without_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_card_mapper.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/overflow_container_widget.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/xmarket_images.dart';

class ProductWidget extends StatelessWidget {
  final ProductCardData cardData;
  final int index;
  final int? length;
  final bool inRestaurant;
  final bool isCampaign;
  final bool fromCartSuggestion;

  const ProductWidget({
    super.key,
    required this.cardData,
    required this.index,
    required this.length,
    this.inRestaurant = false,
    this.isCampaign = false,
    this.fromCartSuggestion = false,
  });

  /// Factory constructor for Product
  factory ProductWidget.fromProduct({
    required Product product,
    required int index,
    required int? length,
    bool inRestaurant = false,
    bool isCampaign = false,
    bool fromCartSuggestion = false,
  }) {
    return ProductWidget(
      cardData: ProductCardMapper.fromProduct(product),
      index: index,
      length: length,
      inRestaurant: inRestaurant,
      isCampaign: isCampaign,
      fromCartSuggestion: fromCartSuggestion,
    );
  }

  /// Factory constructor for Restaurant
  factory ProductWidget.fromRestaurant({
    required Restaurant restaurant,
    required int index,
    required int? length,
  }) {
    return ProductWidget(
      cardData: ProductCardMapper.fromRestaurant(restaurant),
      index: index,
      length: length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      child: Container(
        margin: EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
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
          onTap: () => _handleTap(context),
          radius: Dimensions.radiusDefault,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: _buildImageSection(context)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    _buildTitleRow(context),
                    const SizedBox(height: 4),
                    Center(child: _buildPriceSection(context)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    if (!cardData.isRestaurant) _buildCartControls(context),
                  ],
                ),
              ),
              Positioned(
                top: Dimensions.paddingSizeExtraSmall,
                right: Dimensions.paddingSizeExtraSmall,
                child: !fromCartSuggestion
                    ? _buildFavoriteButton(context)
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    if (cardData.isRestaurant) {
      _handleRestaurantTap(context);
    } else {
      _handleProductTap(context);
    }
  }

  void _handleRestaurantTap(BuildContext context) {
    if (cardData.restaurant == null) return;

    if (cardData.restaurant!.restaurantStatus == 1) {
      Get.toNamed(
        RouteHelper.getRestaurantRoute(
          cardData.restaurant!.id,
          slug: cardData.restaurant!.slug ?? '',
        ),
        arguments: RestaurantScreen(restaurant: cardData.restaurant),
      );
    } else if (cardData.restaurant!.restaurantStatus == 0) {
      showCustomSnackBar('restaurant_is_not_available'.tr);
    }
  }

  void _handleProductTap(BuildContext context) {
    if (cardData.product == null) return;

    if (cardData.product!.restaurantStatus == 1) {
      if (ResponsiveHelper.isMobile(context)) {
        Get.bottomSheet(
          ProductBottomSheetWidget(
            product: cardData.product,
            inRestaurantPage: inRestaurant,
            isCampaign: isCampaign,
          ),
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
        );
      } else {
        Get.dialog(
          Dialog(
            child: ProductBottomSheetWidget(
              product: cardData.product,
              inRestaurantPage: inRestaurant,
            ),
          ),
        );
      }
    } else {
      showCustomSnackBar('item_is_not_available'.tr);
    }
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (cardData.hasImage || cardData.isRestaurant)
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: CustomImageWidget(
              image: cardData.imageUrl ?? '',
              height: 90,
              width: 90,
              fit: BoxFit.cover,
              isFood: !cardData.isRestaurant,
              isRestaurant: cardData.isRestaurant,
            ),
          )
        else if (!cardData.isAvailable)
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Get.isDarkMode ? Theme.of(context).disabledColor : null,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
          )
        else
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
          ),
        if (cardData.hasImage || cardData.isRestaurant)
          DiscountTagWidget(
            discount: cardData.discount,
            discountType: cardData.discountType,
            freeDelivery: cardData.freeDelivery,
            fromTop: Dimensions.paddingSizeExtraSmall,
            fromLeft: cardData.isAvailable ? -7 : -3,
            paddingVertical: ResponsiveHelper.isDesktop(context) ? 5 : 10,
          ),
        // Positioned(
        //   top: Dimensions.paddingSizeExtraSmall,
        //   right: Dimensions.paddingSizeExtraSmall,
        //   child: !fromCartSuggestion
        //       ? _buildFavoriteButton(context)
        //       : const SizedBox(),
        // ),
      ],
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            cardData.name ?? '',
            style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                fontWeight: FontWeight.bold),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!cardData.isRestaurant &&
            Get.find<MarketSplashController>(tag: 'xmarket')
                .configModel!
                .toggleVegNonVeg!)
          ..._buildVegNonVegIcons(context),
      ],
    );
  }

  List<Widget> _buildVegNonVegIcons(BuildContext context) {
    return [
      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
      Image.asset(
        cardData.veg == 0 ? XmarketImages.nonVegImage : XmarketImages.vegImage,
        height: 10,
        width: 10,
        fit: BoxFit.contain,
      ),
      SizedBox(
        width: cardData.isRestaurantHalalActive && cardData.isHalalFood ? 5 : 0,
      ),
      if (cardData.isRestaurantHalalActive && cardData.isHalalFood)
        const CustomAssetImageWidget(
          XmarketImages.halalIcon,
          height: 13,
          width: 13,
        ),
    ];
  }

  Widget _buildRatingRow(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.star,
          size: 16,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        Text(
          cardData.avgRating?.toStringAsFixed(1) ?? '0.0',
          style: robotoMedium,
        ),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        Text(
          '(${cardData.ratingCount! > 25 ? '25+' : cardData.ratingCount})',
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).hintColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    if (cardData.isRestaurant) {
      return _buildRestaurantPrice(context);
    } else {
      return _buildProductPrice(context);
    }
  }

  Widget _buildRestaurantPrice(BuildContext context) {
    if (!cardData.hasFoods) return const SizedBox();

    return Row(
      children: [
        Text(
          'start_from'.tr,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        Text(
          PriceConverter.convertPrice(cardData.priceStartFrom ?? 0),
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
      ],
    );
  }

  Widget _buildProductPrice(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (cardData.hasDiscount)
          Text(
            PriceConverter.convertPrice(cardData.price),
            textDirection: TextDirection.ltr,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).hintColor,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        SizedBox(
          width: cardData.hasDiscount ? Dimensions.paddingSizeExtraSmall : 0,
        ),
        Text(
          PriceConverter.convertPrice(
            cardData.price,
            discount: cardData.discount,
            discountType: cardData.discountType,
          ),
          textDirection: TextDirection.ltr,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Color(0xFF55745a),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        if (!cardData.hasImage)
          DiscountTagWithoutImageWidget(
            discount: cardData.discount,
            discountType: cardData.discountType,
            freeDelivery: cardData.freeDelivery,
          ),
      ],
    );
  }

  Widget _buildRestaurantFoodsPreview(BuildContext context) {
    if (!cardData.hasFoods) return const SizedBox();

    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          OverFlowContainerWidget(
            image: cardData.foods![0].imageFullUrl ?? '',
          ),
          if (cardData.foods!.length > 1)
            Positioned(
              left: 22,
              bottom: 0,
              child: OverFlowContainerWidget(
                image: cardData.foods![1].imageFullUrl ?? '',
              ),
            ),
          if (cardData.foods!.length > 2)
            Positioned(
              left: 42,
              bottom: 0,
              child: OverFlowContainerWidget(
                image: cardData.foods![2].imageFullUrl ?? '',
              ),
            ),
          if (cardData.foods!.length > 3)
            Positioned(
              left: 62,
              bottom: 0,
              child: OverFlowContainerWidget(
                image: cardData.foods![3].imageFullUrl ?? '',
              ),
            ),
          if (cardData.foods!.length > 4)
            Positioned(
              left: 82,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(
                  Dimensions.paddingSizeExtraSmall,
                ),
                height: 30,
                width: 80,
                decoration: BoxDecoration(
                  color: Color(0xFF55745a),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${cardData.foodsCount! > 11 ? '12 +' : '${cardData.foodsCount! - 4} +'} ',
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Color(0xFF55745a),
                      ),
                    ),
                    Text(
                      'items'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: 10,
                        color: Color(0xFF55745a),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return GetBuilder<FavouriteController>(
      builder: (favouriteController) {
        final isWished = cardData.isRestaurant
            ? favouriteController.wishRestIdList.contains(cardData.id)
            : favouriteController.wishProductIdList.contains(cardData.id);

        return CustomFavouriteWidget(
          isWished: isWished,
          isRestaurant: cardData.isRestaurant,
          restaurant: cardData.restaurant,
          product: cardData.product,
        );
      },
    );
  }

  Widget _buildCartControls(BuildContext context) {
    if (cardData.product == null) return const SizedBox();

    return GetBuilder<MarketCartController>(
      builder: (cartController) {
        final cartQty = cartController.cartQuantity(cardData.product!.id!);
        final cartIndex =
            cartController.isExistInCart(cardData.product!.id, null);

        if (cardData.product!.isWeightBased == true) {
          return _buildAddToCartButton(context);
        }

        if (cartQty == 0) {
          return _buildAddToCartButton(context);
        } else {
          return _buildCartQuantityControls(
            context,
            cartController,
            cartQty,
            cartIndex,
          );
        }
      },
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return InkWell(
      onTap: () {
        if (cardData.product?.isWeightBased == true) {
          _handleProductTap(context);
        } else {
          Get.find<ProductController>().productDirectlyAddToCart(
            cardData.product,
            context,
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Icon(
          Icons.add,
          size: 25,
          color: Color(0xFF55745a),
        ),
      ),
    );
  }

  Widget _buildCartQuantityControls(
    BuildContext context,
    MarketCartController cartController,
    int cartQty,
    int cartIndex,
  ) {
    final cartModel = CartModel(
      null,
      cardData.price ?? 0,
      cardData.discountPrice ?? 0,
      (cardData.price ?? 0) - (cardData.discountPrice ?? 0),
      1,
      [],
      [],
      false,
      cardData.product,
      [],
      cardData.cartQuantityLimit,
      [],
    );

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF55745a),
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: cartController.isLoading
                ? null
                : () {
                    if (cartController.cartList[cartIndex].quantity! > 1) {
                      cartController.setQuantity(
                        false,
                        cartModel,
                        cartIndex: cartIndex,
                      );
                    } else {
                      cartController.removeFromCart(cartIndex);
                    }
                  },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFF55745a),
                ),
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Icon(
                Icons.remove,
                size: 16,
                color: Color(0xFF55745a),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
            ),
            child: Text(
              cartQty.toString(),
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).cardColor,
              ),
            ),
          ),
          InkWell(
            onTap: cartController.isLoading
                ? null
                : () {
                    cartController.setQuantity(
                      true,
                      cartModel,
                      cartIndex: cartIndex,
                    );
                  },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Icon(
                Icons.add,
                size: 16,
                color: Color(0xFF55745a),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
