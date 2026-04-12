import 'package:get/get_connect/connect.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/category/domain/models/category_model.dart';
import 'package:stackfood_multivendor/features/category/domain/reposotories/category_repository_interface.dart';
import 'package:stackfood_multivendor/features/category/domain/services/category_service_interface.dart';

class CategoryService implements CategoryServiceInterface {
  final CategoryRepositoryInterface categoryRepositoryInterface;

  CategoryService({required this.categoryRepositoryInterface});

  @override
  Future<List<CategoryModel>?> getCategoryList({DataSourceEnum? source, String? search, bool isXMarket = false}) async {
    return await categoryRepositoryInterface.getList(source: source, search: search, isXMarket: isXMarket);
  }

  @override
  Future<List<CategoryModel>?> getSubCategoryList(String? parentID, {DataSourceEnum? source}) async {
    return await categoryRepositoryInterface.getSubCategoryList(parentID, source: source);
  }

  @override
  Future<ProductModel?> getCategoryProductList(String? categoryID, int offset, String type, {DataSourceEnum? source}) async {
    return await categoryRepositoryInterface.getCategoryProductList(categoryID, offset, type, source: source);
  }

  @override
  Future<RestaurantModel?> getCategoryRestaurantList(String? categoryID, int offset, String type, {DataSourceEnum? source}) async {
    return await categoryRepositoryInterface.getCategoryRestaurantList(categoryID, offset, type, source: source);
  }

  @override
  Future<Response> getSearchData(String? query, String? categoryID, bool isRestaurant, String type) async {
    return await categoryRepositoryInterface.getSearchData(query, categoryID, isRestaurant, type);
  }

}