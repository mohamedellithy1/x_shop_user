
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';

/// Unified data model for ProductWidget that represents both Product and Restaurant
class ProductCardData {
  final int? id;
  final String? name;
  final String? imageUrl;
  final double? price;
  final double? discount;
  final String? discountType;
  final double? discountPrice;
  final bool isAvailable;
  final double? avgRating;
  final int? ratingCount;
  final bool freeDelivery;
  final int? veg;
  final bool isRestaurantHalalActive;
  final bool isHalalFood;
  final int? restaurantStatus;
  final int? cartQuantityLimit;
  final double? priceStartFrom;
  final List<Foods>? foods;
  final int? foodsCount;
  final bool isRestaurant;

  // Original models for actions that need them
  final Product? product;
  final Restaurant? restaurant;

  ProductCardData({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.discount,
    required this.discountType,
    required this.discountPrice,
    required this.isAvailable,
    required this.avgRating,
    required this.ratingCount,
    required this.freeDelivery,
    required this.veg,
    required this.isRestaurantHalalActive,
    required this.isHalalFood,
    required this.restaurantStatus,
    required this.cartQuantityLimit,
    required this.priceStartFrom,
    required this.foods,
    required this.foodsCount,
    required this.isRestaurant,
    this.product,
    this.restaurant,
  });

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasRating => ratingCount != null && ratingCount! > 0;
  bool get hasDiscount => discount != null && discount! > 0;
  bool get hasFoods => foods != null && foods!.isNotEmpty;
}
