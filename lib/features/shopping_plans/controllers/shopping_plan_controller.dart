import 'package:stackfood_multivendor/features/shopping_plans/domain/models/shopping_plan_model.dart';
import 'package:stackfood_multivendor/features/shopping_plans/domain/services/shopping_plan_service_interface.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';

class ShoppingPlanController extends GetxController implements GetxService {
  final ShoppingPlanServiceInterface shoppingPlanServiceInterface;
  ShoppingPlanController({required this.shoppingPlanServiceInterface});

  List<ShoppingPlanModel>? _shoppingPlanList;
  List<ShoppingPlanModel>? get shoppingPlanList => _shoppingPlanList;

  ShoppingPlanDetailsModel? _shoppingPlanDetails;
  ShoppingPlanDetailsModel? get shoppingPlanDetails => _shoppingPlanDetails;

  VariantItemsDetailsModel? _variantItemsDetails;
  VariantItemsDetailsModel? get variantItemsDetails => _variantItemsDetails;

  VariantItemsDetailsModel? _originalVariantItemsDetails;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPreviewLoading = false;
  bool get isPreviewLoading => _isPreviewLoading;

  bool _isAddToCartLoading = false;
  bool get isAddToCartLoading => _isAddToCartLoading;

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
    _originalVariantItemsDetails = null;
    update();
    VariantItemsDetailsModel? details = await shoppingPlanServiceInterface.getVariantItems(variantId);
    if (details != null) {
      _variantItemsDetails = details;
      // Store a deep copy for original comparison
      _originalVariantItemsDetails = VariantItemsDetailsModel.fromJson(details.toJson());
    }
    _isLoading = false;
    update();
  }

  void incrementQuantity(int index) {
    if (_variantItemsDetails != null && _variantItemsDetails!.items![index].allowUserIncrement!) {
      if (_variantItemsDetails!.items![index].isWeightBased!) {
        // Increment weight by 1 (or common step)
        _variantItemsDetails!.items![index].requestedWeight = (_variantItemsDetails!.items![index].requestedWeight ?? 0) + 1.0;
      } else {
        _variantItemsDetails!.items![index].quantity = (_variantItemsDetails!.items![index].quantity ?? 0) + 1;
      }
      _getPreview();
    }
  }

  void decrementQuantity(int index) {
    if (_variantItemsDetails != null && _variantItemsDetails!.items![index].allowUserIncrement!) {
      if (_variantItemsDetails!.items![index].isWeightBased!) {
        double currentWeight = _variantItemsDetails!.items![index].requestedWeight ?? 0;
        double originalWeight = _originalVariantItemsDetails!.items!.firstWhere((it) => it.foodId == _variantItemsDetails!.items![index].foodId).requestedWeight ?? 0;
        
        if (currentWeight > originalWeight) {
          _variantItemsDetails!.items![index].requestedWeight = currentWeight - 1.0;
          _getPreview();
        }
      } else {
        int currentQty = _variantItemsDetails!.items![index].quantity ?? 0;
        int originalQty = _originalVariantItemsDetails!.items!.firstWhere((it) => it.foodId == _variantItemsDetails!.items![index].foodId).quantity ?? 0;

        if (currentQty > originalQty) {
          _variantItemsDetails!.items![index].quantity = currentQty - 1;
          _getPreview();
        } else if (_variantItemsDetails!.items![index].isOptional!) {
          removeItem(index);
        }
      }
    } else if (_variantItemsDetails != null && _variantItemsDetails!.items![index].isOptional!) {
      removeItem(index);
    }
  }

  void removeItem(int index) {
    if (_variantItemsDetails != null && _variantItemsDetails!.items![index].isOptional!) {
      _variantItemsDetails!.items!.removeAt(index);
      _getPreview();
    }
  }

  Future<void> _getPreview() async {
    if (_variantItemsDetails == null || _originalVariantItemsDetails == null) return;

    _isPreviewLoading = true;
    update();

    List<Map<String, dynamic>> customizations = _getCustomizations();

    VariantItemsDetailsModel? previewResponse = await shoppingPlanServiceInterface.getVariantPreview(
      _variantItemsDetails!.variant!.id!,
      {"customizations": customizations},
    );

    if (previewResponse != null) {
      _variantItemsDetails = previewResponse;
    }
    
    _isPreviewLoading = false;
    update();
  }

  List<Map<String, dynamic>> _getCustomizations() {
    List<Map<String, dynamic>> customizations = [];
    
    // Check for removed items
    for (var originalItem in _originalVariantItemsDetails!.items!) {
      bool stillExists = _variantItemsDetails!.items!.any((it) => it.foodId == originalItem.foodId);
      if (!stillExists) {
        customizations.add({
          "food_id": originalItem.foodId,
          "remove": true,
        });
      }
    }

    // Check for weight/quantity increments
    for (var currentItem in _variantItemsDetails!.items!) {
      var originalItem = _originalVariantItemsDetails!.items!.firstWhereOrNull((it) => it.foodId == currentItem.foodId);
      if (originalItem == null) continue; // Should not happen if only increments/removals allowed
      
      if (currentItem.isWeightBased!) {
        double deltaWeight = (currentItem.requestedWeight ?? 0) - (originalItem.requestedWeight ?? 0);
        if (deltaWeight > 0) {
          customizations.add({
            "food_id": currentItem.foodId,
            "extra_weight": deltaWeight,
          });
        }
      } else {
        int deltaQty = (currentItem.quantity ?? 0) - (originalItem.quantity ?? 0);
        if (deltaQty > 0) {
          customizations.add({
            "food_id": currentItem.foodId,
            "extra_quantity": deltaQty,
          });
        }
      }
    }
    return customizations;
  }

  Future<void> addToCart() async {
    if (_variantItemsDetails == null || _variantItemsDetails!.variant == null) return;

    _isAddToCartLoading = true;
    update();

    Map<String, dynamic> body = {
      "customizations": _getCustomizations(),
    };

    if (!AuthHelper.isLoggedIn()) {
      body["guest_id"] = AuthHelper.getGuestId();
    }

    Response response = await shoppingPlanServiceInterface.addToCart(
      _variantItemsDetails!.variant!.id!,
      body,
    );

    if (response.statusCode == 200) {
      showCustomSnackBar('تمت الإضافة للسلة بنجاح'.tr);
      Get.offAllNamed(RouteHelper.getCartRoute()); // Go directly to Cart
    } else {
       // ApiClient usually handles errors, but we can be explicit
       showCustomSnackBar(response.statusText ?? 'حدث خطأ ما'.tr);
    }

    _isAddToCartLoading = false;
    update();
  }
}
