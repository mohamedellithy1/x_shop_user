import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/cart/widgets/cart_product_widget.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CartPlanGroupWidget extends StatefulWidget {
  final List<CartModel> planItems;
  final List<int> originalIndices;
  final bool isRestaurantOpen;

  const CartPlanGroupWidget({
    super.key,
    required this.planItems,
    required this.originalIndices,
    required this.isRestaurantOpen,
  });

  @override
  State<CartPlanGroupWidget> createState() => _CartPlanGroupWidgetState();
}

class _CartPlanGroupWidgetState extends State<CartPlanGroupWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    double totalPlanDiscount = 0;
    double totalPlanPrice = 0;

    for (var item in widget.planItems) {
      if (item.planDiscountAmount != null) {
        totalPlanDiscount += item.planDiscountAmount!;
      }

      double multiplier = (item.product?.isWeightBased ?? false)
          ? (((item.requestedWeight != null && item.requestedWeight! > 0) ? item.requestedWeight! : 1.0) * (item.quantity ?? 1).toDouble())
          : (item.quantity ?? 1).toDouble();

      double? discount = item.product?.restaurantDiscount == 0
          ? item.product?.discount
          : item.product?.restaurantDiscount;
      String? discountType = item.product?.restaurantDiscount == 0
          ? item.product?.discountType
          : 'percent';

      double price = (item.product?.price ?? 0) * multiplier;
      double discountPrice = price - (PriceConverter.convertWithDiscount(item.product?.price ?? 0, discount, discountType) ?? 0) * multiplier;
      
      double totalItemDiscount = discountPrice;
      if (item.isFromPlan == true && item.planDiscountAmount != null) {
        totalItemDiscount += item.planDiscountAmount!;
      }
      totalPlanPrice += (price - totalItemDiscount);
    }

    String periodTypeText = widget.planItems.isNotEmpty
        ? (widget.planItems[0].periodType == 'monthly' ? 'شهرية' : 'أسبوعية')
        : 'أسبوعية';

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Clickable to Toggle)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(
                // color: const Color(0xFF55745a).withValues(alpha: 0.05),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(Dimensions.radiusDefault),
                  bottom: Radius.circular(
                      _isExpanded ? 0 : Dimensions.radiusDefault),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF55745a),
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: const Icon(Icons.auto_awesome_motion_outlined,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'الباكدجات التسويقية $periodTypeText',
                                style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: const Color(0xFF55745a)),
                              ),
                            ),
                            Text(
                              PriceConverter.convertPrice(totalPlanPrice),
                              style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: const Color(0xFF55745a)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (widget.planItems.isNotEmpty &&
                                widget.planItems[0].peopleCount != null)
                              Text(
                                'تكفي لـ ${widget.planItems[0].peopleCount} أفراد  •  ',
                                style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: Theme.of(context).disabledColor),
                              ),
                            if (totalPlanDiscount > 0)
                              Text(
                                'وفر حتى ${PriceConverter.convertPrice(totalPlanDiscount)}',
                                style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: Colors.red),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF55745a),
                  ),
                ],
              ),
            ),
          ),

          // Items (Conditional View)
          if (_isExpanded)
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.planItems.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: CartProductWidget(
                    cart: widget.planItems[index],
                    cartIndex: widget.originalIndices[index],
                    addOns: const [],
                    isAvailable: true,
                    isRestaurantOpen: widget.isRestaurantOpen,
                  ),
                );
              },
            ),
          if (_isExpanded)
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        ],
      ),
    );
  }
}
