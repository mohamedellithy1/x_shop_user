import 'package:stackfood_multivendor/features/shopping_plans/domain/models/shopping_plan_model.dart';
import 'package:stackfood_multivendor/features/shopping_plans/domain/services/shopping_plan_service_interface.dart';
import 'package:get/get.dart';

class ShoppingPlanController extends GetxController implements GetxService {
  final ShoppingPlanServiceInterface shoppingPlanServiceInterface;
  ShoppingPlanController({required this.shoppingPlanServiceInterface});

  List<ShoppingPlanModel>? _shoppingPlanList;
  List<ShoppingPlanModel>? get shoppingPlanList => _shoppingPlanList;

  ShoppingPlanDetailsModel? _shoppingPlanDetails;
  ShoppingPlanDetailsModel? get shoppingPlanDetails => _shoppingPlanDetails;

  VariantItemsDetailsModel? _variantItemsDetails;
  VariantItemsDetailsModel? get variantItemsDetails => _variantItemsDetails;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getShoppingPlanList() async {
    _isLoading = true;
    _shoppingPlanList = null;
    update();
    _shoppingPlanList = await shoppingPlanServiceInterface.getShoppingPlanList();
    _isLoading = false;
    update();
  }

  Future<void> getShoppingPlanVariants(int planId) async {
    _isLoading = true;
    _shoppingPlanDetails = null;
    update();
    _shoppingPlanDetails = await shoppingPlanServiceInterface.getShoppingPlanVariants(planId);
    _isLoading = false;
    update();
  }

  Future<void> getVariantItems(int variantId) async {
    _isLoading = true;
    _variantItemsDetails = null;
    update();
    _variantItemsDetails = await shoppingPlanServiceInterface.getVariantItems(variantId);
    _isLoading = false;
    update();
  }

  void incrementQuantity(int index) {
    if (_variantItemsDetails != null && _variantItemsDetails!.items![index].allowUserIncrement!) {
      _variantItemsDetails!.items![index].quantity = (_variantItemsDetails!.items![index].quantity ?? 0) + 1;
      _calculateTotal();
      update();
    }
  }

  void decrementQuantity(int index) {
    if (_variantItemsDetails != null && 
        _variantItemsDetails!.items![index].allowUserIncrement! && 
        _variantItemsDetails!.items![index].quantity! > 1) {
      _variantItemsDetails!.items![index].quantity = _variantItemsDetails!.items![index].quantity! - 1;
      _calculateTotal();
      update();
    } else if (_variantItemsDetails != null && 
               _variantItemsDetails!.items![index].isOptional! && 
               _variantItemsDetails!.items![index].quantity! == 1) {
      removeItem(index);
    }
  }

  void removeItem(int index) {
    if (_variantItemsDetails != null && _variantItemsDetails!.items![index].isOptional!) {
      _variantItemsDetails!.items!.removeAt(index);
      _calculateTotal();
      update();
    }
  }

  void _calculateTotal() {
    double total = 0;
    int count = 0;
    for (var item in _variantItemsDetails!.items!) {
      double itemPrice = item.unitPrice ?? 0;
      if (item.isWeightBased!) {
        // Line total for weight based items might be unitPrice * weight * quantity
        // Based on the example: requested_weight: 2.5, unit_price: 25, line_total: 62.5 (25 * 2.5)
        total += itemPrice * (item.requestedWeight ?? 1) * (item.quantity ?? 1);
      } else {
        total += itemPrice * (item.quantity ?? 1);
      }
      count++;
    }
    _variantItemsDetails = VariantItemsDetailsModel(
      plan: _variantItemsDetails!.plan,
      variant: _variantItemsDetails!.variant,
      items: _variantItemsDetails!.items,
      summary: PlanSummaryModel(itemsCount: count, estimatedTotal: total),
    );
  }
}
