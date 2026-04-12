import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CartWidget extends StatelessWidget {
  final Color? color;
  final Color? iconColor;
  final Color? textColor;
  final double size;
  final bool fromRestaurant;
  const CartWidget(
      {super.key,
      required this.color,
      required this.size,
      this.iconColor,
      this.textColor,
      this.fromRestaurant = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_cart,
                    color: iconColor ?? Colors.orange, size: size),
                Text('السله',
                    style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: textColor ?? Colors.black,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            // CustomAssetImageWidget(Images.orderIcon, height: size, width: size),

            GetBuilder<MarketCartController>(builder: (cartController) {
              return cartController.cartList.isNotEmpty
                  ? Positioned(
                      top: -5,
                      right: -10,
                      child: Container(
                        height: size < 20 ? 10 : size / 2,
                        width: size < 20 ? 10 : size / 2,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: fromRestaurant
                              ? Theme.of(context).cardColor
                              : Colors.orange,
                          border: Border.all(
                              width: size < 20 ? 0.7 : 1,
                              color: fromRestaurant
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).cardColor),
                        ),
                        child: Text(
                          cartController.cartList.length.toString(),
                          style: robotoRegular.copyWith(
                            fontSize: size < 20 ? size / 3 : size / 3.8,
                            color: fromRestaurant
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).cardColor,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox();
            }),
          ]),
    );
  }
}
