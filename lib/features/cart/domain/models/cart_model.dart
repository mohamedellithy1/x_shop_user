
import 'package:stackfood_multivendor/common/models/product_model.dart';

class CartModel {
  int? _id;
  double? _price;
  double? _discountedPrice;
  List<List<bool?>>? _variations;
  double? _discountAmount;
  int? _quantity;
  List<AddOn>? _addOnIds;
  List<AddOns>? _addOns;
  bool? _isCampaign;
  Product? _product;
  int? _quantityLimit;
  List<List<int?>>? _variationsStock;
  double? _requestedWeight;
  bool? _isFromPlan;
  int? _shoppingPlanId;
  int? _shoppingPlanVariantId;
  double? _planDiscountAmount;


  CartModel(
      int? id,
      double price,
      double? discountedPrice,
      double discountAmount,
      int? quantity,
      List<AddOn> addOnIds,
      List<AddOns> addOns,
      bool isCampaign,
      Product? product,
      List<List<bool?>> variations,
      int? quantityLimit,
      List<List<int?>> variationsStock,
      {double? requestedWeight,
      bool? isFromPlan,
      int? shoppingPlanId,
      int? shoppingPlanVariantId,
      double? planDiscountAmount}) {

    _id = id;
    _price = price;
    _discountedPrice = discountedPrice;
    _discountAmount = discountAmount;
    _quantity = quantity;
    _addOnIds = addOnIds;
    _addOns = addOns;
    _isCampaign = isCampaign;
    _product = product;
    _variations = variations;
    _quantityLimit = quantityLimit;
    _variationsStock = variationsStock;
    _requestedWeight = requestedWeight;
    _isFromPlan = isFromPlan;
    _shoppingPlanId = shoppingPlanId;
    _shoppingPlanVariantId = shoppingPlanVariantId;
    _planDiscountAmount = planDiscountAmount;
  }


  int? get id => _id;
  double? get price => _price;
  double? get discountedPrice => _discountedPrice;
  double? get discountAmount => _discountAmount;
  // ignore: unnecessary_getters_setters
  int? get quantity => _quantity;
  // ignore: unnecessary_getters_setters
  set quantity(int? qty) => _quantity = qty;
  List<AddOn>? get addOnIds => _addOnIds;
  List<AddOns>? get addOns => _addOns;
  bool? get isCampaign => _isCampaign;
  Product? get product => _product;
  List<List<bool?>>? get variations => _variations;
  int? get quantityLimit => _quantityLimit;
  List<List<int?>>? get variationsStock => _variationsStock;
  double? get requestedWeight => _requestedWeight;
  set requestedWeight(double? weight) => _requestedWeight = weight;
  bool? get isFromPlan => _isFromPlan;
  int? get shoppingPlanId => _shoppingPlanId;
  int? get shoppingPlanVariantId => _shoppingPlanVariantId;
  double? get planDiscountAmount => _planDiscountAmount;


  CartModel.fromJson(Map<String, dynamic> json) {
    _id = json['cart_id'];
    _price = json['price'].toDouble();
    _discountedPrice = json['discounted_price']?.toDouble();
    _discountAmount = json['discount_amount']?.toDouble();
    _quantity = json['quantity'];
    if (json['add_on_ids'] != null) {
      _addOnIds = [];
      json['add_on_ids'].forEach((v) {
        _addOnIds!.add(AddOn.fromJson(v));
      });
    }
    if (json['add_ons'] != null) {
      _addOns = [];
      json['add_ons'].forEach((v) {
        _addOns!.add(AddOns.fromJson(v));
      });
    }
    _isCampaign = json['is_campaign'];
    if (json['product'] != null) {
      _product = Product.fromJson(json['product']);
    }
    if (json['variations'] != null) {
      _variations = [];
      for (int index = 0; index < json['variations'].length; index++) {
        _variations!.add([]);
        for (int i = 0; i < json['variations'][index].length; i++) {
          _variations![index].add(json['variations'][index][i]);
        }
      }
    }
    if (json['quantity_limit'] != null) {
      _quantityLimit = int.parse(json['quantity_limit']);
    }
    if (json['variations_stock'] != null) {
      _variationsStock = [];
      for (int index = 0; index < json['variations_stock'].length; index++) {
        _variationsStock!.add([]);
        for (int i = 0; i < json['variations_stock'][index].length; i++) {
          _variationsStock![index].add(json['variations_stock'][index][i]);
        }
      }
    }
    if (json['requested_weight'] != null) {
      _requestedWeight = double.tryParse(json['requested_weight'].toString());
    }
    _isFromPlan = json['is_from_plan'] == 1 || json['is_from_plan'] == true;
    _shoppingPlanId = json['shopping_plan_id'];
    _shoppingPlanVariantId = json['shopping_plan_variant_id'];
    _planDiscountAmount = json['plan_discount_amount'] != null ? double.tryParse(json['plan_discount_amount'].toString()) : null;
  }



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['price'] = _price;
    data['discounted_price'] = _discountedPrice;
    data['discount_amount'] = _discountAmount;
    data['quantity'] = _quantity;
    if (_addOnIds != null) {
      data['add_on_ids'] = _addOnIds!.map((v) => v.toJson()).toList();
    }
    if (_addOns != null) {
      data['add_ons'] = _addOns!.map((v) => v.toJson()).toList();
    }
    data['is_campaign'] = _isCampaign;
    data['product'] = _product!.toJson();
    data['variations'] = _variations;
    data['quantity_limit'] = _quantityLimit?.toString();
    if (_requestedWeight != null) {
      data['requested_weight'] = _requestedWeight;
    }
    data['is_from_plan'] = _isFromPlan;
    data['shopping_plan_id'] = _shoppingPlanId;
    data['shopping_plan_variant_id'] = _shoppingPlanVariantId;
    data['plan_discount_amount'] = _planDiscountAmount;
    return data;
  }

}

class AddOn {
  int? _id;
  int? _quantity;

  AddOn({int? id, int? quantity}) {
    _id = id;
    _quantity = quantity;
  }

  int? get id => _id;
  int? get quantity => _quantity;

  AddOn.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['quantity'] = _quantity;
    return data;
  }
}
