import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';

/// Service for caching products data using Hive
/// This allows offline access and faster loading times
class ProductCacheService {
  static const String _boxName = 'products_cache';
  static const String _cacheTimeKey = 'cache_time_';
  static const Duration _cacheValidDuration = Duration(hours: 24);

  late Box _box;

  /// Initialize Hive and open the products cache box
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  /// Generate cache key based on restaurant ID and category ID
  String _getCacheKey(int restaurantId, int categoryId, int offset) {
    return 'restaurant_${restaurantId}_category_${categoryId}_offset_$offset';
  }

  /// Get cache time key
  String _getCacheTimeKey(int restaurantId, int categoryId, int offset) {
    return '$_cacheTimeKey${_getCacheKey(restaurantId, categoryId, offset)}';
  }

  /// Check if cached data is still valid
  bool _isCacheValid(String cacheTimeKey) {
    final cacheTime = _box.get(cacheTimeKey);
    if (cacheTime == null) return false;

    final cachedDateTime = DateTime.parse(cacheTime);
    final now = DateTime.now();
    return now.difference(cachedDateTime) < _cacheValidDuration;
  }

  /// Save products to cache
  Future<void> saveProducts({
    required int restaurantId,
    required int categoryId,
    required int offset,
    required ProductModel productModel,
  }) async {
    try {
      final cacheKey = _getCacheKey(restaurantId, categoryId, offset);
      final cacheTimeKey = _getCacheTimeKey(restaurantId, categoryId, offset);

      // Convert ProductModel to JSON string
      final jsonString = jsonEncode(productModel.toJson());

      // Save to cache
      await _box.put(cacheKey, jsonString);
      await _box.put(cacheTimeKey, DateTime.now().toIso8601String());

      print('✅ Products cached: $cacheKey');
    } catch (e) {
      print('❌ Error saving products to cache: $e');
    }
  }

  /// Get products from cache
  Future<ProductModel?> getProducts({
    required int restaurantId,
    required int categoryId,
    required int offset,
  }) async {
    try {
      final cacheKey = _getCacheKey(restaurantId, categoryId, offset);
      final cacheTimeKey = _getCacheTimeKey(restaurantId, categoryId, offset);

      // Check if cache is valid
      if (!_isCacheValid(cacheTimeKey)) {
        print('⏰ Cache expired for: $cacheKey');
        return null;
      }

      // Get cached data
      final jsonString = _box.get(cacheKey);
      if (jsonString == null) {
        print('❌ No cache found for: $cacheKey');
        return null;
      }

      // Parse JSON and return ProductModel
      final jsonMap = jsonDecode(jsonString);
      final productModel = ProductModel.fromJson(jsonMap);

      print(
          '✅ Products loaded from cache: $cacheKey (${productModel.products?.length ?? 0} products)');
      return productModel;
    } catch (e) {
      print('❌ Error loading products from cache: $e');
      return null;
    }
  }

  /// Clear all cached products
  Future<void> clearCache() async {
    try {
      await _box.clear();
      print('✅ All cache cleared');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  /// Clear cache for specific restaurant
  Future<void> clearRestaurantCache(int restaurantId) async {
    try {
      final keys = _box.keys
          .where((key) => key.toString().contains('restaurant_$restaurantId'));
      for (var key in keys) {
        await _box.delete(key);
      }
      print('✅ Cache cleared for restaurant: $restaurantId');
    } catch (e) {
      print('❌ Error clearing restaurant cache: $e');
    }
  }

  /// Clear cache for specific category
  Future<void> clearCategoryCache(int restaurantId, int categoryId) async {
    try {
      final keys = _box.keys.where((key) => key
          .toString()
          .contains('restaurant_${restaurantId}_category_$categoryId'));
      for (var key in keys) {
        await _box.delete(key);
      }
      print('✅ Cache cleared for category: $categoryId');
    } catch (e) {
      print('❌ Error clearing category cache: $e');
    }
  }

  /// Get cache size in bytes
  int getCacheSize() {
    try {
      int totalSize = 0;
      for (var value in _box.values) {
        if (value is String) {
          totalSize += value.length;
        }
      }
      return totalSize;
    } catch (e) {
      print('❌ Error calculating cache size: $e');
      return 0;
    }
  }

  /// Check if cache exists for specific parameters
  bool hasCachedData({
    required int restaurantId,
    required int categoryId,
    required int offset,
  }) {
    final cacheKey = _getCacheKey(restaurantId, categoryId, offset);
    final cacheTimeKey = _getCacheTimeKey(restaurantId, categoryId, offset);
    return _box.containsKey(cacheKey) && _isCacheValid(cacheTimeKey);
  }
}
