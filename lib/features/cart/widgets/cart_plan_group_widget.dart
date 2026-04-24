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
    for (var item in widget.planItems) {
      if (item.planDiscountAmount != null) {
        totalPlanDiscount += item.planDiscountAmount!;
      }
    }

    String periodTypeText = widget.planItems.isNotEmpty
        ? (widget.planItems[0].periodType == 'monthly' ? 'شهرية' : 'أسبوعية')
        : 'أسبوعية';

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeExtraSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border:
            Border.all(color: const Color(0xFF55745a).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: const Color(0xFF55745a).withValues(alpha: 0.05),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(Dimensions.radiusDefault),
                  bottom: Radius.circular(
                      _isExpanded ? 0 : Dimensions.radiusDefault),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF55745a),
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: const Icon(Icons.auto_awesome_motion_outlined,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'خطة تسويقية $periodTypeText',
                          style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: const Color(0xFF55745a)),
                        ),
                        Row(
                          children: [
                            if (widget.planItems.isNotEmpty &&
                                widget.planItems[0].peopleCount != null)
                              Text(
                                'تكفي لـ ${widget.planItems[0].peopleCount} أفراد  •  ',
                                style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).disabledColor),
                              ),
                            if (totalPlanDiscount > 0)
                              Text(
                                'وفر حتى ${PriceConverter.convertPrice(totalPlanDiscount)}',
                                style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
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
