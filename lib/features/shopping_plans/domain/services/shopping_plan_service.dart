import 'package:stackfood_multivendor/features/shopping_plans/domain/models/shopping_plan_model.dart';
import 'package:stackfood_multivendor/features/shopping_plans/domain/repositories/shopping_plan_repository_interface.dart';
import 'package:stackfood_multivendor/features/shopping_plans/domain/services/shopping_plan_service_interface.dart';

class ShoppingPlanService implements ShoppingPlanServiceInterface {
  final ShoppingPlanRepositoryInterface shoppingPlanRepositoryInterface;
  ShoppingPlanService({required this.shoppingPlanRepositoryInterface});

  @override
  Future<List<ShoppingPlanModel>?> getShoppingPlanList() async {
    return await shoppingPlanRepositoryInterface.getShoppingPlanList();
  }

  @override
  Future<ShoppingPlanDetailsModel?> getShoppingPlanVariants(int planId) async {
    return await shoppingPlanRepositoryInterface.getShoppingPlanVariants(planId);
  }

  @override
  Future<VariantItemsDetailsModel?> getVariantItems(int variantId) async {
    return await shoppingPlanRepositoryInterface.getVariantItems(variantId);
  }

  @override
  Future<VariantItemsDetailsModel?> getVariantPreview(int variantId, Map<String, dynamic> body) async {
    return await shoppingPlanRepositoryInterface.getVariantPreview(variantId, body);
  }

  @override
  Future<dynamic> addToCart(int variantId, Map<String, dynamic> body) async {
    return await shoppingPlanRepositoryInterface.addToCart(variantId, body);
  }
}
