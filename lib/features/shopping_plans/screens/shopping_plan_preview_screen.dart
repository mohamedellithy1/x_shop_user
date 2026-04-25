import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/shopping_plans/controllers/shopping_plan_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ShoppingPlanPreviewScreen extends StatelessWidget {
  const ShoppingPlanPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarketThemeController>(
      tag: 'xmarket',
      builder: (themeController) {
        bool isDark = themeController.darkTheme;
        return Scaffold(
          backgroundColor: isDark ? Colors.black : const Color(0xFFfafef5),
          appBar: const CustomAppBarWidget(title: 'مراجعة الباكدج', isBackButtonExist: true),
          body: GetBuilder<ShoppingPlanController>(
            builder: (controller) {
              if (controller.variantItemsDetails == null) {
                return const Center(child: Text('لا توجد بيانات'));
              }

              final details = controller.variantItemsDetails!;
              final items = details.items ?? [];
              final summary = details.summary;
              final variantId = details.variant?.id;
              final extraItems = variantId != null ? controller.getExtraItems(variantId) : <dynamic>[];

              double extraTotal = 0;
              for (var item in extraItems) {
                extraTotal += ((item.price ?? 0) * (item.quantity ?? 0));
              }
              final totalCost = (summary?.estimatedTotal ?? 0) + extraTotal;

              return Column(
                children: [
                   Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      children: [
                        // Package Info Header
                        Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                child: CustomImageWidget(
                                  image: details.plan?.imageFullUrl ?? '',
                                  height: 60, width: 60, fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeDefault),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(details.plan?.name ?? '', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                    const SizedBox(height: 4),
                                    Text(details.variant?.title ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        Text('الأصناف المختارة', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        // Selected Items List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    child: CustomImageWidget(
                                      image: item.imageFullUrl,
                                      height: 40, width: 40, fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeDefault),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name ?? '', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                                        Text(
                                          item.isWeightBased! 
                                            ? '${item.requestedWeight} ${item.weightUnit}' 
                                            : 'الكمية: ${item.quantity}',
                                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (item.discountAmount != null && item.discountAmount! > 0)
                                        Text(
                                          PriceConverter.convertPrice(
                                            item.lineTotalBeforeDiscount,
                                            discount: item.discountAmount,
                                            discountType: 'amount',
                                          ),
                                          style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeExtraSmall,
                                            color: Colors.red,
                                            decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                      Text(
                                        PriceConverter.convertPrice(item.lineTotal),
                                        style: robotoMedium.copyWith(color: const Color(0xFF55745a)),
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            );
                          },
                        ),

                        // ── Extra Items Section ──────────────────────────────
                        if (extraItems.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                            child: Divider(thickness: 1, color: Colors.grey),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('منتجات إضافية من المتجر',
                                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: const Color(0xFF55745a))),
                              if (variantId != null)
                                TextButton.icon(
                                  onPressed: () => controller.clearExtraItems(variantId),
                                  icon: const Icon(Icons.delete_sweep, color: Colors.red, size: 18),
                                  label: Text('حذف الكل',
                                      style: robotoRegular.copyWith(color: Colors.red, fontSize: Dimensions.fontSizeSmall)),
                                ),
                            ],
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: extraItems.length,
                            itemBuilder: (context, i) {
                              final extraItem = extraItems[i];
                              return Container(
                                margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1C1C1E).withValues(alpha: 0.5) : Colors.white,
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  border: Border.all(color: const Color(0xFF55745a).withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                      child: CustomImageWidget(
                                        image: extraItem.product?.imageFullUrl ?? '',
                                        height: 45, width: 45, fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Expanded(child: Text(extraItem.product?.name ?? '',
                                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                                                maxLines: 1, overflow: TextOverflow.ellipsis)),
                                            const SizedBox(width: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF55745a).withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                              ),
                                              child: Text('إضافي',
                                                  style: robotoRegular.copyWith(fontSize: 8, color: const Color(0xFF55745a))),
                                            ),
                                          ]),
                                          const SizedBox(height: 4),
                                          Text('الكمية: ${extraItem.quantity}',
                                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          PriceConverter.convertPrice((extraItem.price ?? 0) * (extraItem.quantity ?? 0)),
                                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: const Color(0xFF55745a)),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove, size: 16),
                                              onPressed: variantId != null ? () => controller.decrementExtraItem(variantId, i) : null,
                                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                              padding: EdgeInsets.zero,
                                            ),
                                            Text('${extraItem.quantity}',
                                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: const Color(0xFF55745a))),
                                            IconButton(
                                              icon: const Icon(Icons.add, size: 16),
                                              onPressed: variantId != null ? () => controller.incrementExtraItem(variantId, i) : null,
                                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                              padding: EdgeInsets.zero,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                                      onPressed: variantId != null ? () => controller.removeExtraItem(variantId, i) : null,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                        // ─────────────────────────────────────────────────────

                        // const SizedBox(height: Dimensions.paddingSizeDefault),
                        // InkWell(
                        //   onTap: () {
                        //     // Store active plan context before navigating
                        //     controller.setActivePlanContext(
                        //       controller.variantItemsDetails?.plan?.id,
                        //       controller.variantItemsDetails?.variant?.id,
                        //     );
                        //     Get.toNamed(RouteHelper.getCategoryRoute(
                        //       planId: controller.variantItemsDetails?.plan?.id,
                        //       variantId: controller.variantItemsDetails?.variant?.id,
                        //       variantTitle: controller.variantItemsDetails?.variant?.title,
                        //     ));
                        //   },
                        //   child: Container(
                        //     padding: const EdgeInsets.symmetric(vertical: 12),
                        //     decoration: BoxDecoration(
                        //       color: const Color(0xFF55745a).withValues(alpha: 0.1),
                        //       borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        //       border: Border.all(color: const Color(0xFF55745a).withValues(alpha: 0.3)),
                        //     ),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         const Icon(Icons.add_circle_outline, color: Color(0xFF55745a), size: 20),
                        //         const SizedBox(width: Dimensions.paddingSizeSmall),
                        //         Text(
                        //           'أضف منتجات خارج الخطط',
                        //           style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: const Color(0xFF55745a)),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                      ],
                    ),
                  ),


                  // Bottom Summary & Add to Cart
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (summary?.totalDiscount != null && summary!.totalDiscount! > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('توفير الخطة', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.red)),
                              Text(
                                '- ${PriceConverter.convertPrice(summary.totalDiscount)}',
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.red),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],

                        if (extraItems.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('منتجات إضافية', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.grey)),
                              Text(
                                '+ ${PriceConverter.convertPrice(extraTotal)}',
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: const Color(0xFF55745a)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('الإجمالي النهائي', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                            Text(
                              PriceConverter.convertPrice(totalCost),
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: const Color(0xFF55745a)),
                            ),
                          ],
                        ),

                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: controller.isAddToCartLoading ? null : () {
                              controller.addToCart();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF55745a),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                            ),
                            child: controller.isAddToCartLoading 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text('إضافة للسلة وتأكيد الطلب', style: robotoBold.copyWith(color: Colors.white)),
                          ),
                        ),
                      ],
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
}

