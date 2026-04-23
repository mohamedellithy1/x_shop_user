import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/features/shopping_plans/controllers/shopping_plan_controller.dart';
import 'package:stackfood_multivendor/features/shopping_plans/domain/models/shopping_plan_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';

class VariantItemsScreen extends StatefulWidget {
  final int variantId;
  final String variantTitle;
  const VariantItemsScreen(
      {super.key, required this.variantId, required this.variantTitle});

  @override
  State<VariantItemsScreen> createState() => _VariantItemsScreenState();
}

class _VariantItemsScreenState extends State<VariantItemsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ShoppingPlanController>().getVariantItems(widget.variantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarketThemeController>(
      tag: 'xmarket',
      builder: (themeController) {
        bool isDark = themeController.darkTheme;
        return Scaffold(
          backgroundColor: isDark ? Colors.black : const Color(0xFFfafef5),
          appBar: CustomAppBarWidget(
              title: widget.variantTitle, isBackButtonExist: true),
          body: GetBuilder<ShoppingPlanController>(
            builder: (controller) {
              if (controller.isLoading ||
                  controller.variantItemsDetails == null) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF55745a)));
              }

              final details = controller.variantItemsDetails!;
              final items = details.items ?? [];
              final summary = details.summary;

              return Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          color: const Color(0xFF55745a),
                          onRefresh: () =>
                              controller.getVariantItems(widget.variantId),
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.all(Dimensions.paddingSizeDefault),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return _ItemCard(
                                item: items[index],
                                isDark: isDark,
                                onRemove: () => controller.removeItem(index),
                                onIncrement: () => controller.incrementQuantity(index),
                                onDecrement: () => controller.decrementQuantity(index),
                              );
                            },
                          ),
                        ),
                      ),

                      // Summary Bottom Bar
                      if (summary != null) _buildBottomBar(summary, isDark),
                    ],
                  ),

                  if (controller.isPreviewLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white24,
                        child: const Center(
                          child: CircularProgressIndicator(color: Color(0xFF55745a)),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(PlanSummaryModel summary, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge),
          topRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إجمالي الأصناف (${summary.itemsCount ?? 0})',
                style:
                    robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              Text(
                PriceConverter.convertPrice(summary.estimatedTotal),
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge,
                  color: const Color(0xFF55745a),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Get.toNamed(RouteHelper.getShoppingPlanOrderPreviewRoute());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF55745a),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                elevation: 0,
              ),
              child: Text('تأكيد ', style: robotoBold.copyWith(
                color: Colors.white
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final PlanItemModel item;
  final bool isDark;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ItemCard({
    required this.item,
    required this.isDark,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    double displayPrice = item.lineTotal ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C1C1E).withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Remove button if optional
          if (item.isOptional == true)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: Colors.redAccent, size: 22),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),

          const SizedBox(width: 8),

          // Food Image
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: CustomImageWidget(
              image: item.imageFullUrl,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name ?? '',
                  style:
                      robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (item.isWeightBased == true)
                      Text(
                        '${item.requestedWeight} ${item.weightUnit}',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Colors.grey,
                        ),
                      )
                    else
                      Text(
                        'الكمية: ${item.quantity}',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  PriceConverter.convertPrice(displayPrice),
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: isDark ? Colors.white70 : const Color(0xFF55745a),
                  ),
                ),
              ],
            ),
          ),

          // Increment/Decrement controls
          if (item.allowUserIncrement == true)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF55745a).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: onDecrement,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                  Text(
                    '${item.isWeightBased! ? item.requestedWeight : item.quantity}',
                    style:
                        robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: onIncrement,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
