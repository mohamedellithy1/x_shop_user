import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/shopping_plans/domain/models/shopping_plan_model.dart';
import 'package:stackfood_multivendor/features/shopping_plans/domain/repositories/shopping_plan_repository_interface.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:get/get_connect/connect.dart';

class ShoppingPlanRepository implements ShoppingPlanRepositoryInterface {
  final ApiClient apiClient;
  ShoppingPlanRepository({required this.apiClient});

  @override
  Future<List<ShoppingPlanModel>?> getShoppingPlanList() async {
    List<ShoppingPlanModel>? planList;
    Response response = await apiClient.getData(AppConstants.shoppingPlansUri);
    if (response.statusCode == 200) {
      planList = [];
      response.body.forEach((plan) {
        planList!.add(ShoppingPlanModel.fromJson(plan));
      });
    }
    return planList;
  }

  @override
  Future<ShoppingPlanDetailsModel?> getShoppingPlanVariants(int planId) async {
    ShoppingPlanDetailsModel? planDetails;
    Response response = await apiClient.getData('${AppConstants.shoppingPlanVariantsUri}$planId/variants');
    if (response.statusCode == 200) {
      planDetails = ShoppingPlanDetailsModel.fromJson(response.body);
    }
    return planDetails;
  }

  @override
  Future<VariantItemsDetailsModel?> getVariantItems(int variantId) async {
    VariantItemsDetailsModel? variantDetails;
    Response response = await apiClient.getData('${AppConstants.variantDetailsUri}$variantId');
    if (response.statusCode == 200) {
      variantDetails = VariantItemsDetailsModel.fromJson(response.body);
    }
    return variantDetails;
  }

  @override
  Future<VariantItemsDetailsModel?> getVariantPreview(int variantId, Map<String, dynamic> body) async {
    VariantItemsDetailsModel? variantDetails;
    Response response = await apiClient.postData('${AppConstants.variantDetailsUri}$variantId/preview', body);
    if (response.statusCode == 200) {
      variantDetails = VariantItemsDetailsModel.fromJson(response.body);
    }
    return variantDetails;
  }
}
