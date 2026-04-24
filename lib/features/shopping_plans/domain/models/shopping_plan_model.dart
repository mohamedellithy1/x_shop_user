import 'package:stackfood_multivendor/util/app_constants.dart';

class ShoppingPlanModel {
  final int? id;
  final String? name;
  final String? slug;
  final String? description;
  final String? image;
  final String? planScope;
  final bool? allowCustomization;
  final ShoppingPlanRestaurant? restaurant;
  final int? variantsCount;
  final ShoppingPlanPriceRange? priceRange;

  ShoppingPlanModel({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.image,
    this.planScope,
    this.allowCustomization,
    this.restaurant,
    this.variantsCount,
    this.priceRange,
  });

  String get imageFullUrl => '${AppConstants.baseUrl}/storage/product/$image';

  factory ShoppingPlanModel.fromJson(Map<String, dynamic> json) {
    return ShoppingPlanModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      image: json['image'],
      planScope: json['plan_scope'],
      allowCustomization: json['allow_customization'],
      restaurant: json['restaurant'] != null
          ? ShoppingPlanRestaurant.fromJson(json['restaurant'])
          : null,
      variantsCount: json['variants_count'],
      priceRange: json['price_range'] != null
          ? ShoppingPlanPriceRange.fromJson(json['price_range'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'image': image,
      'plan_scope': planScope,
      'allow_customization': allowCustomization,
      'restaurant': restaurant?.toJson(),
      'variants_count': variantsCount,
      'price_range': priceRange?.toJson(),
    };
  }
}

class ShoppingPlanRestaurant {
  final int? id;
  final String? name;
  final String? logo;

  ShoppingPlanRestaurant({this.id, this.name, this.logo});

  String get logoFullUrl => '${AppConstants.baseUrl}/storage/product/$logo';

  factory ShoppingPlanRestaurant.fromJson(Map<String, dynamic> json) {
    return ShoppingPlanRestaurant(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
    };
  }
}

class ShoppingPlanPriceRange {
  final double? min;
  final double? max;

  ShoppingPlanPriceRange({this.min, this.max});

  factory ShoppingPlanPriceRange.fromJson(Map<String, dynamic> json) {
    return ShoppingPlanPriceRange(
      min: (json['min'] as num?)?.toDouble(),
      max: (json['max'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
    };
  }
}

class ShoppingPlanDetailsModel {
  final ShoppingPlanModel? plan;
  final List<PlanVariantModel>? variants;

  ShoppingPlanDetailsModel({this.plan, this.variants});

  factory ShoppingPlanDetailsModel.fromJson(Map<String, dynamic> json) {
    return ShoppingPlanDetailsModel(
      plan: json['plan'] != null
          ? ShoppingPlanModel.fromJson(json['plan'])
          : null,
      variants: json['variants'] != null
          ? List<PlanVariantModel>.from(
              json['variants'].map((x) => PlanVariantModel.fromJson(x)))
          : null,
    );
  }
}

class PlanVariantModel {
  final int? id;
  final int? shoppingPlanId;
  final String? periodType;
  final int? peopleCount;
  final String? title;
  final String? notes;
  final int? itemsCount;
  final double? basePriceCached;

  PlanVariantModel({
    this.id,
    this.shoppingPlanId,
    this.periodType,
    this.peopleCount,
    this.title,
    this.notes,
    this.itemsCount,
    this.basePriceCached,
  });

  factory PlanVariantModel.fromJson(Map<String, dynamic> json) {
    return PlanVariantModel(
      id: json['id'],
      shoppingPlanId: json['shopping_plan_id'],
      periodType: json['period_type'],
      peopleCount: json['people_count'],
      title: json['title'],
      notes: json['notes'],
      itemsCount: json['items_count'],
      basePriceCached: (json['base_price_cached'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopping_plan_id': shoppingPlanId,
      'period_type': periodType,
      'people_count': peopleCount,
      'title': title,
      'notes': notes,
      'items_count': itemsCount,
      'base_price_cached': basePriceCached,
    };
  }
}

class VariantItemsDetailsModel {
  ShoppingPlanModel? plan;
  PlanVariantModel? variant;
  List<PlanItemModel>? items;
  PlanSummaryModel? summary;

  VariantItemsDetailsModel({this.plan, this.variant, this.items, this.summary});

  factory VariantItemsDetailsModel.fromJson(Map<String, dynamic> json) {
    return VariantItemsDetailsModel(
      plan: json['plan'] != null
          ? ShoppingPlanModel.fromJson(json['plan'])
          : null,
      variant: json['variant'] != null
          ? PlanVariantModel.fromJson(json['variant'])
          : null,
      items: json['items'] != null
          ? List<PlanItemModel>.from(
              json['items'].map((x) => PlanItemModel.fromJson(x)))
          : null,
      summary: json['summary'] != null
          ? PlanSummaryModel.fromJson(json['summary'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan?.toJson(),
      'variant': variant?.toJson(),
      'items': items?.map((x) => x.toJson()).toList(),
      'summary': summary?.toJson(),
    };
  }
}

class PlanItemModel {
  int? foodId;
  String? name;
  String? image;
  int? categoryId;
  int? restaurantId;
  bool? isWeightBased;
  double? requestedWeight;
  String? weightUnit;
  int? quantity;
  double? unitPrice;
  double? lineTotal;
  bool? isOptional;
  bool? allowUserIncrement;
  double? lineTotalBeforeDiscount;
  String? discountType;
  double? discountValue;
  double? discountAmount;
  double? lineTotalAfterDiscount;

  PlanItemModel({
    this.foodId,
    this.name,
    this.image,
    this.categoryId,
    this.restaurantId,
    this.isWeightBased,
    this.requestedWeight,
    this.weightUnit,
    this.quantity,
    this.unitPrice,
    this.lineTotal,
    this.isOptional,
    this.allowUserIncrement,
    this.lineTotalBeforeDiscount,
    this.discountType,
    this.discountValue,
    this.discountAmount,
    this.lineTotalAfterDiscount,
  });


  String get imageFullUrl => '${AppConstants.baseUrl}/storage/product/$image';

  factory PlanItemModel.fromJson(Map<String, dynamic> json) {
    return PlanItemModel(
      foodId: json['food_id'],
      name: json['name'],
      image: json['image'],
      categoryId: json['category_id'],
      restaurantId: json['restaurant_id'],
      isWeightBased: json['is_weight_based'],
      requestedWeight: (json['requested_weight'] as num?)?.toDouble(),
      weightUnit: json['weight_unit'],
      quantity: json['quantity'],
      unitPrice: (json['unit_price'] as num?)?.toDouble(),
      lineTotal: (json['line_total'] as num?)?.toDouble(),
      isOptional: json['is_optional'],
      allowUserIncrement: json['allow_user_increment'],
      lineTotalBeforeDiscount: json['line_total_before_discount'] != null ? double.tryParse(json['line_total_before_discount'].toString()) : null,
      discountType: json['discount_type'],
      discountValue: json['discount_value'] != null ? double.tryParse(json['discount_value'].toString()) : null,
      discountAmount: json['discount_amount'] != null ? double.tryParse(json['discount_amount'].toString()) : null,
      lineTotalAfterDiscount: json['line_total_after_discount'] != null ? double.tryParse(json['line_total_after_discount'].toString()) : null,
    );
  }



  Map<String, dynamic> toJson() {
    return {
      'food_id': foodId,
      'name': name,
      'image': image,
      'category_id': categoryId,
      'restaurant_id': restaurantId,
      'is_weight_based': isWeightBased,
      'requested_weight': requestedWeight,
      'weight_unit': weightUnit,
      'quantity': quantity,
      'unit_price': unitPrice,
      'line_total': lineTotal,
      'is_optional': isOptional,
      'allow_user_increment': allowUserIncrement,
      'line_total_before_discount': lineTotalBeforeDiscount,
      'discount_type': discountType,
      'discount_value': discountValue,
      'discount_amount': discountAmount,
      'line_total_after_discount': lineTotalAfterDiscount,
    };
  }

}

class PlanSummaryModel {
  int? itemsCount;
  double? estimatedTotal;
  double? totalBeforeDiscount;
  double? totalDiscount;

  PlanSummaryModel({this.itemsCount, this.estimatedTotal, this.totalBeforeDiscount, this.totalDiscount});


  factory PlanSummaryModel.fromJson(Map<String, dynamic> json) {
    return PlanSummaryModel(
      itemsCount: json['items_count'],
      estimatedTotal: json['estimated_total'] != null ? double.tryParse(json['estimated_total'].toString()) : null,
      totalBeforeDiscount: json['total_before_discount'] != null ? double.tryParse(json['total_before_discount'].toString()) : null,
      totalDiscount: json['total_discount'] != null ? double.tryParse(json['total_discount'].toString()) : null,
    );
  }



  Map<String, dynamic> toJson() {
    return {
      'items_count': itemsCount,
      'estimated_total': estimatedTotal,
      'total_before_discount': totalBeforeDiscount,
      'total_discount': totalDiscount,
    };
  }

}
