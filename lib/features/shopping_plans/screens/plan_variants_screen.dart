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

class PlanVariantsScreen extends StatefulWidget {
  final int planId;
  final String planName;
  const PlanVariantsScreen({super.key, required this.planId, required this.planName});

  @override
  State<PlanVariantsScreen> createState() => _PlanVariantsScreenState();
}

class _PlanVariantsScreenState extends State<PlanVariantsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ShoppingPlanController>().getShoppingPlanVariants(widget.planId);
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
          appBar: CustomAppBarWidget(title: widget.planName, isBackButtonExist: true),
          body: GetBuilder<ShoppingPlanController>(
            builder: (controller) {
              if (controller.isLoading || controller.shoppingPlanDetails == null) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF55745a)));
              }

              final details = controller.shoppingPlanDetails!;
              final plan = details.plan;
              final variants = details.variants ?? [];

              return RefreshIndicator(
                color: const Color(0xFF55745a),
                onRefresh: () => controller.getShoppingPlanVariants(widget.planId),
                child: CustomScrollView(
                  slivers: [
                    // Header Section
                    SliverToBoxAdapter(
                      child: _buildHeader(plan, isDark),
                    ),

                    // Variants List
                    SliverPadding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      sliver: variants.isEmpty
                          ? SliverToBoxAdapter(child: _buildEmptyState(isDark))
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _VariantCard(
                                  variant: variants[index],
                                  isDark: isDark,
                                  isLast: index == variants.length - 1,
                                ),
                                childCount: variants.length,
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(ShoppingPlanModel? plan, bool isDark) {
    if (plan == null) return const SizedBox();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(Dimensions.radiusExtraLarge),
          bottomRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (plan.image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: CustomImageWidget(
                    image: plan.imageFullUrl,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                )
              else
                _defaultIcon(),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name ?? '',
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                    ),
                    if (plan.slug != null)
                      Text(
                        '#${plan.slug}',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          if (plan.description != null)
            Text(
              plan.description!,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _defaultIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF55745a).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: const Icon(Icons.shopping_basket_rounded, color: Color(0xFF55745a), size: 30),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        children: [
          Icon(Icons.layers_clear_outlined, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'لا توجد باقات متاحة حالياً',
            style: robotoMedium.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _VariantCard extends StatelessWidget {
  final PlanVariantModel variant;
  final bool isDark;
  final bool isLast;

  const _VariantCard({
    required this.variant,
    required this.isDark,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: const Color(0xFF55745a).withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () {
          // Future action: maybe show details or add to cart
        },
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      variant.title ?? '',
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                  ),
                  Text(
                    PriceConverter.convertPrice(variant.basePriceCached),
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: const Color(0xFF55745a),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _IconLabel(
                    icon: Icons.people_outline,
                    label: '${variant.peopleCount ?? 0} أفراد',
                  ),
                  const SizedBox(width: 16),
                  _IconLabel(
                    icon: Icons.list_alt_rounded,
                    label: '${variant.itemsCount ?? 0} أصناف',
                  ),
                  if (variant.periodType != null) ...[
                    const SizedBox(width: 16),
                    _IconLabel(
                      icon: Icons.calendar_today_outlined,
                      label: variant.periodType == 'weekly' ? 'أسبوعي' : variant.periodType!,
                    ),
                  ],
                ],
              ),
              if (variant.notes != null && variant.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  variant.notes!,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(RouteHelper.getVariantItemsRoute(variant.id, variant.title)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF55745a),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    elevation: 0,
                  ),
                  child: Text('اختيار هذه الباقة', style: robotoMedium.copyWith(
                    color: Colors.white
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _IconLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          label,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.grey),
        ),
      ],
    );
  }
}
