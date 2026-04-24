import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/shopping_plans/controllers/shopping_plan_controller.dart';
import 'package:stackfood_multivendor/features/shopping_plans/domain/models/shopping_plan_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';


class PlanVariantsBottomSheet extends StatefulWidget {
  final List<ShoppingPlanModel> plans;
  final int initialIndex;
  const PlanVariantsBottomSheet({super.key, required this.plans, required this.initialIndex});

  @override
  State<PlanVariantsBottomSheet> createState() => _PlanVariantsBottomSheetState();
}

class _PlanVariantsBottomSheetState extends State<PlanVariantsBottomSheet> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _fetchVariants(_currentIndex);
  }

  void _fetchVariants(int index) {
    if (widget.plans[index].id != null) {
      Future.microtask(() {
        Get.find<ShoppingPlanController>().getShoppingPlanVariants(widget.plans[index].id!);
      });
    }
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarketThemeController>(
      tag: 'xmarket',
      builder: (themeController) {
        bool isDark = themeController.darkTheme;
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141313) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radiusExtraLarge),
                  topRight: Radius.circular(Dimensions.radiusExtraLarge),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Container(
                    height: 5, width: 50,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.plans.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                        _fetchVariants(index);
                      },
                      itemBuilder: (context, index) {
                        final plan = widget.plans[index];
                        return _PlanView(
                          plan: plan,
                          isDark: isDark,
                          scrollController: scrollController,
                          isCurrent: index == _currentIndex,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PlanView extends StatelessWidget {
  final ShoppingPlanModel plan;
  final bool isDark;
  final ScrollController scrollController;
  final bool isCurrent;

  const _PlanView({
    required this.plan,
    required this.isDark,
    required this.scrollController,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Text(
            plan.name ?? '',
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Expanded(
          child: GetBuilder<ShoppingPlanController>(
            builder: (controller) {
              // Simplified check: if not loading and we have details, show them.
              // The controller handles clearing old data via getShoppingPlanVariants.
              bool isDataReady = isCurrent && !controller.isLoading && controller.shoppingPlanDetails != null;

              if (!isDataReady) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 50),
                    child: CircularProgressIndicator(color: Color(0xFF55745a)),
                  ),
                );
              }

              final variants = controller.shoppingPlanDetails?.variants ?? [];

              if (variants.isEmpty) {
                return _buildEmptyState(isDark);
              }

              return SizedBox(
                height: 380, // Fixed height for horizontal cards
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  physics: const BouncingScrollPhysics(),
                  itemCount: variants.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: _VariantCard(
                        variant: variants[index],
                        isDark: isDark,
                        isLast: index == variants.length - 1,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.layers_clear_outlined, size: 60, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(
          'لا توجد باقات متاحة حالياً',
          style: robotoMedium.copyWith(color: Colors.grey),
        ),
      ],
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
    bool isLtr = Directionality.of(context) == TextDirection.ltr;
    return Container(
      margin: EdgeInsets.only(
        left: isLtr ? 0 : (isLast ? 0 : Dimensions.paddingSizeDefault),
        right: isLtr ? (isLast ? 0 : Dimensions.paddingSizeDefault) : 0,
        bottom: Dimensions.paddingSizeSmall,
        top: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: const Color(0xFF55745a).withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10, offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
           Get.toNamed(RouteHelper.getVariantItemsRoute(variant.id, variant.title));
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
