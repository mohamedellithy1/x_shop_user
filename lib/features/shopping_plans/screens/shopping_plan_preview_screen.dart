import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/shopping_plans/controllers/shopping_plan_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
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
                                  Text(
                                    PriceConverter.convertPrice(item.lineTotal),
                                    style: robotoMedium.copyWith(color: const Color(0xFF55745a)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('الإجمالي النهائي', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                            Text(
                              PriceConverter.convertPrice(summary?.estimatedTotal),
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: const Color(0xFF55745a)),
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              // Action to add to cart
                              Get.snackbar('X-Market', 'جاري الإضافة للسلة...');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF55745a),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                            ),
                            child: Text('إضافة للسلة وتأكيد الطلب', style: robotoBold.copyWith(color: Colors.white)),
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
