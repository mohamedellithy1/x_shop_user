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
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart'
    as cart_model;
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';

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
              title: widget.variantTitle,
              isBackButtonExist: true),
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

              print('----- DEBUG SUMMARY -----');
              print('estimatedTotal: ${summary?.estimatedTotal}');
              print('totalBeforeDiscount: ${summary?.totalBeforeDiscount}');
              print('totalDiscount: ${summary?.totalDiscount}');
              double calcLineTotal = 0;
              double calcLineTotalAfter = 0;
              for (var it in items) {
                print('Item: ${it.name}, lineTotal: ${it.lineTotal}, lineTotalAfter: ${it.lineTotalAfterDiscount}, before: ${it.lineTotalBeforeDiscount}');
                calcLineTotal += (it.lineTotal ?? 0);
                calcLineTotalAfter += (it.lineTotalAfterDiscount ?? 0);
              }
              print('Sum of lineTotal: $calcLineTotal, Sum of lineTotalAfter: $calcLineTotalAfter');
              print('-------------------------');

              return Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: GetBuilder<ShoppingPlanController>(
                          builder: (planController) {
                            final extraItems =
                                planController.getExtraItems(widget.variantId);

                            return RefreshIndicator(
                              color: const Color(0xFF55745a),
                              onRefresh: () =>
                                  controller.getVariantItems(widget.variantId),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeDefault),
                                itemCount: items.length +
                                    (extraItems.isNotEmpty
                                        ? extraItems.length + 1
                                        : 0) +
                                    1,
                                itemBuilder: (context, index) {
                                  if (index < items.length) {
                                    return _ItemCard(
                                      item: items[index],
                                      isDark: isDark,
                                      onRemove: () =>
                                          controller.removeItem(index),
                                      onIncrement: () =>
                                          controller.incrementQuantity(index),
                                      onDecrement: () =>
                                          controller.decrementQuantity(index),
                                      onManualSet: (val) => controller
                                          .setManualQuantity(index, val),
                                    );
                                  } else if (extraItems.isNotEmpty &&
                                      index == items.length) {
                                    return Column(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical:
                                                  Dimensions.paddingSizeSmall),
                                          child: Divider(
                                              thickness: 1, color: Colors.grey),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('منتجات إضافية من المتجر',
                                                style: robotoBold.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeDefault,
                                                    color: const Color(
                                                        0xFF55745a))),
                                            TextButton.icon(
                                              onPressed: () {
                                                planController.clearExtraItems(
                                                    widget.variantId);
                                              },
                                              icon: const Icon(
                                                  Icons.delete_sweep,
                                                  color: Colors.red,
                                                  size: 18),
                                              label: Text('حذف الكل',
                                                  style: robotoRegular.copyWith(
                                                      color: Colors.red,
                                                      fontSize: Dimensions
                                                          .fontSizeSmall)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall),
                                      ],
                                    );
                                  } else if (extraItems.isNotEmpty &&
                                      index <
                                          items.length +
                                              extraItems.length +
                                              1) {
                                    final extraItem =
                                        extraItems[index - items.length - 1];
                                    final extraIndex = index - items.length - 1;
                                    return _CartItemCard(
                                      cartItem: extraItem,
                                      isDark: isDark,
                                      onIncrement: () {
                                        planController.incrementExtraItem(
                                            widget.variantId, extraIndex);
                                      },
                                      onDecrement: () {
                                        planController.decrementExtraItem(
                                            widget.variantId, extraIndex);
                                      },
                                    );
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          top: Dimensions.paddingSizeDefault,
                                          bottom:
                                              Dimensions.paddingSizeExtraLarge),
                                      child: InkWell(
                                        onTap: () {
                                          // Store active plan context so ProductBottomSheet can find it
                                          Get.find<ShoppingPlanController>()
                                              .setActivePlanContext(
                                            controller
                                                .variantItemsDetails?.plan?.id,
                                            controller.variantItemsDetails
                                                    ?.variant?.id ??
                                                widget.variantId,
                                          );
                                          Get.toNamed(
                                              RouteHelper.getCategoryRoute(
                                            planId: controller
                                                .variantItemsDetails?.plan?.id,
                                            variantId: controller
                                                .variantItemsDetails
                                                ?.variant
                                                ?.id,
                                            variantTitle: widget.variantTitle,
                                          ));
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF55745a)
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusDefault),
                                            border: Border.all(
                                                color: const Color(0xFF55745a)
                                                    .withValues(alpha: 0.3)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.add_circle,
                                                  color: Color(0xFF55745a),
                                                  size: 24),
                                              const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeSmall),
                                              Text(
                                                'أضف منتجات خارج الباكدجات',
                                                style: robotoBold.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeDefault,
                                                    color: const Color(
                                                        0xFF55745a)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      // Summary Bottom Bar
                      if (summary != null)
                        GetBuilder<ShoppingPlanController>(
                          builder: (planCtrl) {
                            final extraList =
                                planCtrl.getExtraItems(widget.variantId);
                            double extraTotal = 0;
                            for (var item in extraList) {
                              extraTotal +=
                                  ((item.price ?? 0) * (item.quantity ?? 0));
                            }
                            int totalItems =
                                (summary.itemsCount ?? 0) + extraList.length;
                            double totalCost =
                                (summary.estimatedTotal ?? 0) + extraTotal;
                            double totalBeforeDiscount =
                                (summary.totalBeforeDiscount ?? totalCost) + extraTotal;

                            return _buildBottomBar(
                                totalItems, totalCost, totalBeforeDiscount, isDark);
                          },
                        ),
                    ],
                  ),
                  if (controller.isPreviewLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white24,
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF55745a)),
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

  Widget _buildBottomBar(int itemsCount, double totalCost, double totalBeforeDiscount, bool isDark) {
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
                'إجمالي الأصناف ($itemsCount)',
                style:
                    robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (totalBeforeDiscount > totalCost) ...[
                    Text(
                      PriceConverter.convertPrice(totalBeforeDiscount),
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Colors.redAccent,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    PriceConverter.convertPrice(totalCost),
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                      color: const Color(0xFF55745a),
                    ),
                  ),
                ],
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
              child: Text('تأكيد ',
                  style: robotoBold.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final cart_model.CartModel cartItem;
  final bool isDark;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CartItemCard({
    required this.cartItem,
    required this.isDark,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C1C1E).withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
            color: const Color(0xFF55745a).withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          // Remove button (always allowed for added items)
          IconButton(
            icon: const Icon(Icons.remove_circle_outline,
                color: Colors.redAccent, size: 22),
            onPressed: onDecrement,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          const SizedBox(width: 8),

          // Food Image
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: CustomImageWidget(
              image: cartItem.product?.imageFullUrl ?? '',
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
                Row(
                  children: [
                    Text(
                      cartItem.product?.name ?? '',
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF55745a).withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Text('إضافي',
                          style: robotoRegular.copyWith(
                              fontSize: 8, color: const Color(0xFF55745a))),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'الكمية: ${cartItem.quantity}',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  PriceConverter.convertPrice(
                      (cartItem.price ?? 0) * (cartItem.quantity ?? 0)),
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: isDark ? Colors.white70 : const Color(0xFF55745a),
                  ),
                ),
              ],
            ),
          ),

          // Increment/Decrement controls
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF55745a).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: onDecrement,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '${cartItem.quantity}',
                    style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: const Color(0xFF55745a)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: onIncrement,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
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

class _ItemCard extends StatelessWidget {
  final PlanItemModel item;
  final bool isDark;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Function(double) onManualSet;

  const _ItemCard({
    required this.item,
    required this.isDark,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
    required this.onManualSet,
  });

  Widget build(BuildContext context) {
    double displayPrice = item.lineTotalAfterDiscount ?? item.lineTotal ?? 0;
    double? oldPrice = (item.lineTotalAfterDiscount != null && item.lineTotalAfterDiscount != (item.lineTotalBeforeDiscount ?? item.lineTotal))
        ? (item.lineTotalBeforeDiscount ?? item.lineTotal)
        : null;

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
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      PriceConverter.convertPrice(displayPrice),
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: isDark ? Colors.white70 : const Color(0xFF55745a),
                      ),
                    ),
                    if (oldPrice != null && oldPrice > displayPrice) ...[
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        PriceConverter.convertPrice(oldPrice),
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Colors.redAccent,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Increment/Decrement controls
          if (item.allowUserIncrement == true)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF55745a).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: onDecrement,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                  InkWell(
                    onTap: () {
                      _showManualInputDialog(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '${item.isWeightBased! ? item.requestedWeight : item.quantity}',
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: const Color(0xFF55745a)),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: onIncrement,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showManualInputDialog(BuildContext context) {
    TextEditingController controller = TextEditingController(
      text: '${item.isWeightBased! ? item.requestedWeight : item.quantity}',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.isWeightBased! ? 'تعديل الوزن' : 'تعديل الكمية',
            style: robotoBold),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'أدخل القيمة الجديدة',
            suffixText: item.isWeightBased! ? item.weightUnit : 'عدد',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('إلغاء'.tr)),
          TextButton(
            onPressed: () {
              double? val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                onManualSet(val);
                Navigator.pop(context);
              }
            },
            child: Text('تعديل'.tr),
          ),
        ],
      ),
    );
  }
}
