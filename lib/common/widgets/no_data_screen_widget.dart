import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/xmarket_images.dart';

class NoDataScreen extends StatelessWidget {
  final String? title;
  final bool fromAddress;
  final bool isEmptyAddress;
  final bool isEmptyCart;
  final bool isEmptyChat;
  final bool isEmptyOrder;
  final bool isEmptyCoupon;
  final bool isEmptyFood;
  final bool isEmptyNotification;
  final bool isEmptyRestaurant;
  final bool isEmptySearchFood;
  final bool isEmptyTransaction;
  final bool isEmptyWishlist;
  final bool isCenter;
  const NoDataScreen(
      {super.key,
      required this.title,
      /*this.isCart = false, this.fromAddress = false, this.isRestaurant = false,*/ this.fromAddress =
          false,
      this.isEmptyAddress = false,
      this.isEmptyCart = false,
      this.isEmptyChat = false,
      this.isEmptyOrder = false,
      this.isEmptyCoupon = false,
      this.isEmptyFood = false,
      this.isEmptyNotification = false,
      this.isEmptyRestaurant = false,
      this.isEmptySearchFood = false,
      this.isEmptyTransaction = false,
      this.isEmptyWishlist = false,
      this.isCenter = false});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Center(
        child: Column(
            mainAxisAlignment:
                fromAddress ? MainAxisAlignment.start : MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (fromAddress || isCenter)
                  ? const SizedBox()
                  : SizedBox(
                      height: isEmptyTransaction || isEmptyCoupon
                          ? height * 0.15
                          : isDesktop
                              ? height * 0.2
                              : height * 0.3,
                    ),
              isEmptyWishlist || isEmptyTransaction
                  ? Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color:
                            Color(0xFF9ebc67).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isEmptyWishlist
                            ? Icons.favorite_border_rounded
                            : Icons.account_balance_wallet_outlined,
                        color: Color(0xFF9ebc67),
                        size: 60,
                      ),
                    )
                  : CustomAssetImageWidget(
                      color: Theme.of(context).disabledColor,
                      isEmptyAddress
                          ? XmarketImages.emptyAddress
                          : isEmptyCart
                              ? XmarketImages.emptyCart
                              : isEmptyChat
                                  ? XmarketImages.emptyChat
                                  : isEmptyOrder
                                      ? XmarketImages.emptyOrder
                                      : isEmptyCoupon
                                          ? XmarketImages.emptyCoupon
                                          : isEmptyFood
                                              ? XmarketImages.emptyFood
                                              : isEmptyNotification
                                                  ? XmarketImages
                                                      .emptyNotification
                                                  : isEmptyRestaurant
                                                      ? XmarketImages
                                                          .emptyRestaurant
                                                      : isEmptySearchFood
                                                          ? XmarketImages
                                                              .emptySearchFood
                                                          : isEmptyTransaction
                                                              ? XmarketImages
                                                                  .emptyTransaction
                                                              : isEmptyWishlist
                                                                  ? XmarketImages
                                                                      .emptyWishlist
                                                                  : XmarketImages
                                                                      .emptyFood,
                      width: isDesktop ? 130 : 80,
                      height: isDesktop ? 130 : 80,
                    ),
              SizedBox(height: fromAddress ? 10 : 10),
              Text(
                title ?? '',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  // color: fromAddress ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).disabledColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                  height: fromAddress
                      ? 10
                      : MediaQuery.of(context).size.height * 0.03),
              fromAddress
                  ? Text(
                      'please_add_your_address_for_your_better_experience'.tr,
                      style: robotoRegular.copyWith(
                          color: Theme.of(context).disabledColor),
                      textAlign: TextAlign.center,
                    )
                  : const SizedBox(),
              SizedBox(
                  height: isEmptyAddress
                      ? 30
                      : MediaQuery.of(context).size.height * 0.05),
              fromAddress
                  ? InkWell(
                      onTap: () =>
                          Get.toNamed(RouteHelper.getAddAddressRoute(false, 0)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                          color: Theme.of(context).primaryColor,
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeDefault,
                            horizontal: Dimensions.paddingSizeExtraOverLarge),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_circle_outline_sharp,
                                size: 18.0, color: Theme.of(context).cardColor),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Text('add_address'.tr,
                                style: robotoBold.copyWith(
                                    color: Theme.of(context).cardColor)),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(),
            ]),
      ),
    );
  }
}
