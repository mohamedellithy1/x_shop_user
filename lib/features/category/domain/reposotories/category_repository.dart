import 'dart:convert';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/api/local_client.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/category/domain/models/category_model.dart';
import 'package:stackfood_multivendor/features/category/domain/reposotories/category_repository_interface.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';

class CategoryRepository implements CategoryRepositoryInterface {
  final ApiClient apiClient;

  CategoryRepository({required this.apiClient});

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future<List<CategoryModel>?> getList(
      {int? offset,
      DataSourceEnum? source,
      String? search,
      bool isXMarket = false}) async {
    List<CategoryModel>? categoryList;
    String uri = isXMarket
        ? AppConstants.xMarketCategoryUri
        : AppConstants.categoryUri;
    String cacheId = uri;

    switch (source!) {
      case DataSourceEnum.client:
        if (search != null && search.isNotEmpty) {
          uri += '${uri.contains('?') ? '&' : '?'}name=$search';
        }
        Response response = await apiClient.getData(uri);

        if (response.statusCode == 200) {
          categoryList = [];
          response.body.forEach((category) {
            categoryList!.add(CategoryModel.fromJson(category));
          });
          LocalClient.organize(DataSourceEnum.client, cacheId,
              jsonEncode(response.body), apiClient.getHeader());
        }

      case DataSourceEnum.local:
        String? cacheResponseData =
            await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        categoryList = [];
        jsonDecode(cacheResponseData!).forEach((category) {
          categoryList!.add(CategoryModel.fromJson(category));
        });
          }
    return categoryList;
  }

  @override
  Future<List<CategoryModel>?> getSubCategoryList(String? parentID, {DataSourceEnum? source}) async {
    List<CategoryModel>? subCategoryList;
    String uri = '${AppConstants.subCategoryUri}$parentID';
    String cacheId = '${AppConstants.subCategoryUri}/$parentID';

    switch (source!) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(uri);
        if (response.statusCode == 200) {
          subCategoryList = [];
          subCategoryList.add(CategoryModel(id: int.parse(parentID!), name: 'all'.tr));
          response.body.forEach((category) => subCategoryList!.add(CategoryModel.fromJson(category)));
          LocalClient.organize(DataSourceEnum.client, cacheId,
              jsonEncode(response.body), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData =
        await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        subCategoryList = [];
        subCategoryList.add(CategoryModel(id: int.parse(parentID!), name: 'all'.tr));
        jsonDecode(cacheResponseData!).forEach((category) {
          subCategoryList!.add(CategoryModel.fromJson(category));
        });
          }
    return subCategoryList;
  }

  @override
  Future<ProductModel?> getCategoryProductList(
      String? categoryID, int offset, String type, {DataSourceEnum? source}) async {
    ProductModel? productModel;
    String uri = '${AppConstants.restaurantProductUri}?restaurant_id=8&category_id=$categoryID&limit=50&offset=$offset';
    String cacheId = '${AppConstants.restaurantProductUri}/$categoryID/$offset';

    switch (source!) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(uri);
        if (response.statusCode == 200) {
          productModel = ProductModel.fromJson(response.body);
          LocalClient.organize(DataSourceEnum.client, cacheId,
              jsonEncode(response.body), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData =
        await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        productModel = ProductModel.fromJson(jsonDecode(cacheResponseData!));
          }
    return productModel;
  }

  @override
  Future<RestaurantModel?> getCategoryRestaurantList(String? categoryID, int offset, String type, {DataSourceEnum? source}) async {
    RestaurantModel? restaurantModel;
    String uri = '${AppConstants.categoryRestaurantUri}$categoryID?limit=10&offset=$offset&type=$type';
    String cacheId = '${AppConstants.categoryRestaurantUri}/$categoryID/$offset/$type';

    switch (source!) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(uri);
        if (response.statusCode == 200) {
          restaurantModel = RestaurantModel.fromJson(response.body);
          LocalClient.organize(DataSourceEnum.client, cacheId,
              jsonEncode(response.body), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData =
        await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        restaurantModel = RestaurantModel.fromJson(jsonDecode(cacheResponseData!));
          }
    return restaurantModel;
  }

  @override
  Future<Response> getSearchData(String? query, String? categoryID, bool isRestaurant, String type) async {
    return await apiClient.getData(
      '${AppConstants.searchUri}${isRestaurant ? 'restaurants' : 'products'}/search?name=$query&category_id=$categoryID&type=$type&offset=1&limit=50',
    );
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}