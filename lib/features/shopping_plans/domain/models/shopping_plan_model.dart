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

  String get imageFullUrl => '${AppConstants.baseUrl}/$image';

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

  String get logoFullUrl => '${AppConstants.baseUrl}/storage/restaurant/$logo';

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
      plan: json['plan'] != null ? ShoppingPlanModel.fromJson(json['plan']) : null,
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
}

class VariantItemsDetailsModel {
  final ShoppingPlanModel? plan;
  final PlanVariantModel? variant;
  final List<PlanItemModel>? items;
  final PlanSummaryModel? summary;

  VariantItemsDetailsModel({this.plan, this.variant, this.items, this.summary});

  factory VariantItemsDetailsModel.fromJson(Map<String, dynamic> json) {
    return VariantItemsDetailsModel(
      plan: json['plan'] != null ? ShoppingPlanModel.fromJson(json['plan']) : null,
      variant: json['variant'] != null ? PlanVariantModel.fromJson(json['variant']) : null,
      items: json['items'] != null
          ? List<PlanItemModel>.from(json['items'].map((x) => PlanItemModel.fromJson(x)))
          : null,
      summary: json['summary'] != null ? PlanSummaryModel.fromJson(json['summary']) : null,
    );
  }
}

class PlanItemModel {
  final int? foodId;
  final String? name;
  final String? image;
  final int? categoryId;
  final int? restaurantId;
  final bool? isWeightBased;
  final double? requestedWeight;
  final String? weightUnit;
  int? quantity;
  final double? unitPrice;
  final double? lineTotal;
  final bool? isOptional;
  final bool? allowUserIncrement;

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
    );
  }
}

class PlanSummaryModel {
  final int? itemsCount;
  final double? estimatedTotal;

  PlanSummaryModel({this.itemsCount, this.estimatedTotal});

  factory PlanSummaryModel.fromJson(Map<String, dynamic> json) {
    return PlanSummaryModel(
      itemsCount: json['items_count'],
      estimatedTotal: (json['estimated_total'] as num?)?.toDouble(),
    );
  }
}
