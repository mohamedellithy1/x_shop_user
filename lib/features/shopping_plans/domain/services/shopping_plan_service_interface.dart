import 'package:stackfood_multivendor/features/shopping_plans/domain/models/shopping_plan_model.dart';

abstract class ShoppingPlanServiceInterface {
  Future<List<ShoppingPlanModel>?> getShoppingPlanList();
  Future<ShoppingPlanDetailsModel?> getShoppingPlanVariants(int planId);
  Future<VariantItemsDetailsModel?> getVariantItems(int variantId);
  Future<VariantItemsDetailsModel?> getVariantPreview(int variantId, Map<String, dynamic> body);
}
