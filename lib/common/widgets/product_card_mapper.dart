
import 'package:stackfood_multivendor/common/models/product_card_data.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';

/// Mapper functions to convert Product/Restaurant to unified ProductCardData
class ProductCardMapper {
  /// Convert Product to ProductCardData
  static ProductCardData fromProduct(Product product) {
    final discount = product.discount ?? 0.0;
    final discountType = product.discountType ?? 'percent';
    final price = product.price ?? 0.0;
    final discountPrice = PriceConverter.convertWithDiscount(
      price,
      discount,
      discountType,
    ) ?? price;

    return ProductCardData(
      id: product.id,
      name: product.name,
      imageUrl: product.imageFullUrl,
      price: price,
      discount: discount,
      discountType: discountType,
      discountPrice: discountPrice,
      isAvailable: DateConverter.isAvailable(
        product.availableTimeStarts,
        product.availableTimeEnds,
      ),
      avgRating: product.avgRating,
      ratingCount: product.ratingCount,
      freeDelivery: false, // Products don't have freeDelivery
      veg: product.veg,
      isRestaurantHalalActive: product.isRestaurantHalalActive ?? false,
      isHalalFood: product.isHalalFood ?? false,
      restaurantStatus: product.restaurantStatus,
      cartQuantityLimit: product.cartQuantityLimit,
      priceStartFrom: null,
      foods: null,
      foodsCount: null,
      isRestaurant: false,
      product: product,
      restaurant: null,
    );
  }

  /// Convert Restaurant to ProductCardData
  static ProductCardData fromRestaurant(Restaurant restaurant) {
    final discount = restaurant.discount?.discount ?? 0.0;
    final discountType = restaurant.discount?.discountType ?? 'percent';
    final isAvailable = restaurant.open == 1 && (restaurant.active ?? false);

    return ProductCardData(
      id: restaurant.id,
      name: restaurant.name,
      imageUrl: restaurant.logoFullUrl,
      price: null, // Restaurants don't have a single price
      discount: discount,
      discountType: discountType,
      discountPrice: null, // Restaurants don't have discountPrice
      isAvailable: isAvailable,
      avgRating: restaurant.avgRating,
      ratingCount: restaurant.ratingCount,
      freeDelivery: restaurant.freeDelivery ?? false,
      veg: null, // Restaurants don't have veg flag
      isRestaurantHalalActive: false, // Restaurants don't have this
      isHalalFood: false, // Restaurants don't have this
      restaurantStatus: restaurant.restaurantStatus,
      cartQuantityLimit: null,
      priceStartFrom: restaurant.priceStartFrom,
      foods: restaurant.foods,
      foodsCount: restaurant.foodsCount,
      isRestaurant: true,
      product: null,
      restaurant: restaurant,
    );
  }
}
