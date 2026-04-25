import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/features/shopping_plans/controllers/shopping_plan_controller.dart';
import 'package:stackfood_multivendor/features/shopping_plans/domain/models/shopping_plan_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/theme/dark_theme.dart';
import 'package:stackfood_multivendor/theme/light_theme.dart';
import 'package:stackfood_multivendor/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/shopping_plans/screens/widgets/plan_variants_bottom_sheet.dart';



class ShoppingPlansScreen extends StatefulWidget {
  const ShoppingPlansScreen({super.key});

  @override
  State<ShoppingPlansScreen> createState() => _ShoppingPlansScreenState();
}

class _ShoppingPlansScreenState extends State<ShoppingPlansScreen> {
  final ThemeData darkTheme = dark;
  final ThemeData lightTheme = light;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCall();
    });
  }

  void _initCall() {
    Get.find<ShoppingPlanController>().getShoppingPlanList();
  }

  String _getScopeLabel(String? scope) {
    switch (scope) {
      case 'weekly':
        return 'أسبوعية';
      case 'monthly':
        return 'شهرية';
      case 'daily':
        return 'يومية';
      default:
        return scope ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarketThemeController>(
      init: Get.find<MarketThemeController>(tag: 'xmarket'),
      builder: (themeController) {
        final bool isDark = themeController.darkTheme;
        return Theme(
          data: isDark ? darkTheme : lightTheme,
          child: Scaffold(
            backgroundColor: isDark ? Colors.black : const Color(0xFFfafef5),
            appBar: CustomAppBarWidget(
              title: 'خطط تسويقية',
              isBackButtonExist: true,
              onBackPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
            ),
            endDrawer: const MenuDrawerWidget(),
            endDrawerEnableOpenDragGesture: false,
            body: GetBuilder<ShoppingPlanController>(
              builder: (controller) {
                if (controller.isLoading || controller.shoppingPlanList == null) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF55745a),
                    ),
                  );
                }

                if (controller.shoppingPlanList!.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                return RefreshIndicator(
                  color: const Color(0xFF55745a),
                  onRefresh: () => controller.getShoppingPlanList(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    itemCount: controller.shoppingPlanList!.length,
                    itemBuilder: (context, index) {
                      return _ShoppingPlanCard(
                        plan: controller.shoppingPlanList![index],
                        isDark: isDark,
                        scopeLabel: _getScopeLabel(
                          controller.shoppingPlanList![index].planScope,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFF55745a).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 54,
              color: Color(0xFF55745a),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد خطط تسويقية متاحة',
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: isDark ? Colors.white : const Color(0xFF263238),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تحقق لاحقاً للعثور على خططنا المميزة',
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingPlanCard extends StatelessWidget {
  final ShoppingPlanModel plan;
  final bool isDark;
  final String scopeLabel;

  const _ShoppingPlanCard({
    required this.plan,
    required this.isDark,
    required this.scopeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showCustomBottomSheet(
          child: PlanVariantsBottomSheet(
            plans: Get.find<ShoppingPlanController>().shoppingPlanList!,
            initialIndex: Get.find<ShoppingPlanController>().shoppingPlanList!.indexOf(plan),
          ),
        );
      },


      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header banner
              // Body
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plan name + scope badge
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.name ?? '',
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeExtraLarge,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF263238),
                                ),
                              ),
                              if (plan.slug != null)
                                Text(
                                  '#${plan.slug}',
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.grey.shade500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        _ScopeBadge(label: scopeLabel),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Description
                    if (plan.description != null &&
                        plan.description!.isNotEmpty) ...[
                      Text(
                        plan.description!,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Divider
                    Divider(
                      color: isDark ? Colors.white12 : Colors.grey.shade200,
                      thickness: 1,
                    ),
                    const SizedBox(height: 10),

                    // Info row
                    Row(
                      children: [
                        // Variants count
                        _InfoChip(
                          icon: Icons.layers_outlined,
                          label: '${plan.variantsCount ?? 0} باقات',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),

                        // Customizable
                        if (plan.allowCustomization == true)
                          _InfoChip(
                            icon: Icons.tune_rounded,
                            label: 'قابل للتخصيص',
                            isDark: isDark,
                            isGreen: true,
                          ),

                        const Spacer(),

                        // Price range
                        _PriceRangeWidget(
                          min: plan.priceRange?.min,
                          max: plan.priceRange?.max,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScopeBadge extends StatelessWidget {
  final String label;
  const _ScopeBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF55745a).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF55745a).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: robotoMedium.copyWith(
          fontSize: 11,
          color: const Color(0xFF55745a),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final bool isGreen;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
    this.isGreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isGreen
        ? const Color(0xFF55745a)
        : (isDark ? Colors.white60 : Colors.grey.shade600);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PriceRangeWidget extends StatelessWidget {
  final double? min;
  final double? max;
  final bool isDark;

  const _PriceRangeWidget({this.min, this.max, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (min == null || max == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'نطاق السعر',
          style: robotoRegular.copyWith(
            fontSize: 10,
            color: isDark ? Colors.white38 : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${PriceConverter.convertPrice(min)} – ${PriceConverter.convertPrice(max)}',
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: const Color(0xFF55745a),
          ),
        ),
      ],
    );
  }
}
