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
    double totalBundleDiscount = 0;
    String? bundleDiscountType;
    double? bundleDiscountValue;

    for (var item in widget.planItems) {
      debugPrint('--- Item in Group: ${item.product?.name} ---');
      debugPrint('lineTotalBeforeDiscount: ${item.lineTotalBeforeDiscount}');
      debugPrint('lineTotalAfterDiscount: ${item.lineTotalAfterDiscount}');
      debugPrint('planDiscountAmount: ${item.planDiscountAmount}');
      debugPrint('planBundleDiscountAmount: ${item.planBundleDiscountAmount}');
      debugPrint('---------------------------');

      // 1. Calculate price before ANY discount
      double multiplier = (item.product?.isWeightBased ?? false)
          ? (((item.requestedWeight != null && item.requestedWeight! > 0) ? item.requestedWeight! : 1.0) * (item.quantity ?? 1).toDouble())
          : (item.quantity ?? 1).toDouble();
      double basePrice = (item.product?.price ?? 0) * multiplier;

      // 2. Use backend line totals if available, otherwise calculate locally
      double lineBefore = item.lineTotalBeforeDiscount ?? basePrice;
      double lineAfter = item.lineTotalAfterDiscount ?? (lineBefore - (item.planDiscountAmount ?? 0));
      
      totalPlanPrice += lineAfter; // This is price after item discount but BEFORE bundle discount
      totalPlanDiscount += (item.planDiscountAmount ?? 0);
      totalBundleDiscount += (item.planBundleDiscountAmount ?? 0);

      // Grab type/value from any item in the group
      bundleDiscountType ??= item.planBundleDiscountType;
      bundleDiscountValue ??= item.planBundleDiscountValue;
    }

    double finalPrice = totalPlanPrice - totalBundleDiscount;
    double totalSavings = totalPlanDiscount + totalBundleDiscount;

    debugPrint('=== CartPlanGroup Debug ===');
    debugPrint('totalPlanPrice (after item discounts): $totalPlanPrice');
    debugPrint('totalPlanDiscount (item-level): $totalPlanDiscount');
    debugPrint('bundleDiscountType: $bundleDiscountType');
    debugPrint('bundleDiscountValue: $bundleDiscountValue');
    debugPrint('totalBundleDiscount (bundle-level): $totalBundleDiscount');
    debugPrint('finalPrice: $finalPrice');
    debugPrint('totalSavings: $totalSavings');
    debugPrint('==========================');

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
                              PriceConverter.convertPrice(finalPrice),
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
                            Text(
                              'وفر ${PriceConverter.convertPrice(totalSavings)}',
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

          // Items list
          if (_isExpanded)
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.planItems.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return CartProductWidget(
                  cart: widget.planItems[index],
                  cartIndex: widget.originalIndices[index],
                  addOns: const [],
                  isAvailable: true,
                  isRestaurantOpen: widget.isRestaurantOpen,
                );
              },
            ),

          // Discount Summary Footer — always shown when expanded
          if (_isExpanded)
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeExtraSmall,
                  vertical: Dimensions.paddingSizeExtraSmall),
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'خصم المنتجات',
                    value: totalPlanDiscount > 0
                        ? '- ${PriceConverter.convertPrice(totalPlanDiscount)}'
                        : PriceConverter.convertPrice(0),
                    color: Colors.red,
                  ),
                  const SizedBox(height: 4),
                  _SummaryRow(
                    label: bundleDiscountType == 'percent'
                        ? 'خصم الباكدج (${bundleDiscountValue?.toStringAsFixed(0) ?? 0}%)'
                        : (bundleDiscountType == 'fixed' ? 'خصم الباكدج (ثابت)' : 'خصم الباكدج'),
                    value: totalBundleDiscount > 0
                        ? '- ${PriceConverter.convertPrice(totalBundleDiscount)}'
                        : PriceConverter.convertPrice(0),
                    color: Colors.red,
                  ),
                  const Divider(height: 12),
                  _SummaryRow(
                    label: 'إجمالي التوفير',
                    value: PriceConverter.convertPrice(totalSavings),
                    color: const Color(0xFF55745a),
                    isBold: true,
                  ),
                ],
              ),
            ),

          if (_isExpanded)
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall, color: color)
              : robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).disabledColor),
        ),
        Text(
          value,
          style: isBold
              ? robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall, color: color)
              : robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall, color: color),
        ),
      ],
    );
  }
}
