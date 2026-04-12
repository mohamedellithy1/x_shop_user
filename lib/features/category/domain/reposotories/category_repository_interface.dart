import 'package:get/get_connect/http/src/response/response.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/category/domain/models/category_model.dart';
import 'package:stackfood_multivendor/interface/repository_interface.dart';

abstract class CategoryRepositoryInterface implements RepositoryInterface {
  @override
  Future<List<CategoryModel>?> getList({int? offset, DataSourceEnum? source, String? search, bool isXMarket = false});
  Future<List<CategoryModel>?> getSubCategoryList(String? parentID, {DataSourceEnum? source});
  Future<ProductModel?> getCategoryProductList(String? categoryID, int offset, String type, {DataSourceEnum? source});
  Future<RestaurantModel?> getCategoryRestaurantList(String? categoryID, int offset, String type, {DataSourceEnum? source});
  Future<Response> getSearchData(String? query, String? categoryID, bool isRestaurant, String type);
}