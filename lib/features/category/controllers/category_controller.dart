import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/category/domain/models/category_model.dart';
import 'package:stackfood_multivendor/features/category/domain/services/category_service_interface.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';

class CategoryController extends GetxController implements GetxService {
  final CategoryServiceInterface categoryServiceInterface;
  CategoryController({required this.categoryServiceInterface});

  List<CategoryModel>? _categoryList;
  List<CategoryModel>? get categoryList => _categoryList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CategoryModel>? _subCategoryList;
  List<CategoryModel>? get subCategoryList => _subCategoryList;

  List<Product>? _categoryProductList;
  List<Product>? get categoryProductList => _categoryProductList;

  List<Restaurant>? _categoryRestaurantList;
  List<Restaurant>? get categoryRestaurantList => _categoryRestaurantList;

  List<Product>? _searchProductList = [];
  List<Product>? get searchProductList => _searchProductList;

  List<Restaurant>? _searchRestaurantList = [];
  List<Restaurant>? get searchRestaurantList => _searchRestaurantList;

  int? _pageSize;
  int? get pageSize => _pageSize;

  int? _restaurantPageSize;
  int? get restaurantPageSize => _restaurantPageSize;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  bool _paginate = false;
  bool get paginate => _paginate;

  int _subCategoryIndex = 0;
  int get subCategoryIndex => _subCategoryIndex;

  String _type = 'all';
  String get type => _type;

  bool _isRestaurant = false;
  bool get isRestaurant => _isRestaurant;

  String? _searchText = '';
  String? get searchText => _searchText;

  int _offset = 1;
  int get offset => _offset;

  bool _hasNetworkError = false;
  bool get hasNetworkError => _hasNetworkError;

  String? _requestedCategoryId;
  Future<void> getCategoryList(bool reload,
      {String? search,
      DataSourceEnum dataSource = DataSourceEnum.client,
      bool isXMarket = true}) async {
    try {
      _isLoading = true;
      if (reload) {
        _categoryList = null;
        WidgetsBinding.instance.addPostFrameCallback((_) => update());
      }
      if (_categoryList == null || reload) {
        _categoryList = await categoryServiceInterface.getCategoryList(
            source: dataSource, search: search);
      }
    } catch (e) {
      debugPrint('❌ [MarketCategoryController] Error fetching categories: $e');
    } finally {
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => update());
    }
  }

  String? _parentCategoryId;
  String? get parentCategoryId => _parentCategoryId;

  Future<void> getSubCategoryList(String? categoryID) async {
    _subCategoryIndex = 0;
    _parentCategoryId = categoryID;

    // Clear products immediately so old data doesn't flash
    _categoryProductList = null;
    _isRestaurant = false;

    if (categoryID == null) {
      _subCategoryList = null;
      _isLoading = false;
      update();
      return;
    }

    // الخطوة 1: جلب الفئات الفرعية من الكاش المحلي
    List<CategoryModel>? localSubCategoryList =
        await categoryServiceInterface.getSubCategoryList(categoryID);
    _subCategoryList = localSubCategoryList;
    _isLoading = false;
    _hasNetworkError = false;
    update();

    // الخطوة 2: جلب أحدث الفئات الفرعية من السيرفر
    List<CategoryModel>? remoteSubCategoryList =
        await categoryServiceInterface.getSubCategoryList(
      categoryID,
    );
    _subCategoryList = remoteSubCategoryList;
    _hasNetworkError = false;
    _isLoading = false;
    update();
  }

  void clearSubCategories() {
    _subCategoryList = null;
    _subCategoryIndex = 0;
    update();
  }

  void setSubCategoryIndex(int index, String? categoryID,
      {bool dataLoad = true}) {
    _subCategoryIndex = index;
    if (!dataLoad) {
      update();
      return;
    }
    String selectedType =
        index == 0 ? 'all' : _subCategoryList![index - 1].id.toString();
    if (_isRestaurant) {
      getCategoryRestaurantList(
          _subCategoryIndex == 0
              ? categoryID
              : _subCategoryList![index - 1].id.toString(),
          1,
          selectedType,
          true);
    } else {
      getCategoryProductList(
          _subCategoryIndex == 0
              ? categoryID
              : _subCategoryList![index - 1].id.toString(),
          1,
          selectedType,
          true);
    }
  }

  Future<List<Product>?> getProductsForSubCategory(String categoryID,
      {int offset = 1, String type = 'all'}) async {
    ProductModel? productModel = await categoryServiceInterface
        .getCategoryProductList(categoryID, offset, type);
    return Get.find<SplashController>()
        .filterXMarketProducts(productModel?.products);
  }

  void getCategoryProductList(
      String? categoryID, int offset, String type, bool notify) async {
    _offset = offset;
    if (offset == 1) {
      _type = type;
      _requestedCategoryId = categoryID; // تسجيل الـ ID المطلوب حالياً
      _categoryProductList = null; // تنظيف القائمة فوراً قبل البدء
      if (notify) {
        update();
      }

      // الخطوة 1: جلب البيانات من الكاش المحلي أولاً (بدون Loading) لو موجودة
      ProductModel? localProductModel = await categoryServiceInterface
          .getCategoryProductList(categoryID, offset, type);

      // تحقق أن هذه البيانات لنفس الفئة المطلوبة حالياً (قد يكون المستخدم غيّر الفئة أثناء الانتظار)
      if (localProductModel != null && _requestedCategoryId == categoryID) {
        _categoryProductList = [];
        _categoryProductList!.addAll(Get.find<SplashController>()
            .filterXMarketProducts(localProductModel.products));
        _pageSize = localProductModel.totalSize;
        _isLoading = false;
        if (notify) {
          update();
        }
      } else if (_requestedCategoryId == categoryID) {
        _isLoading = true;
        _categoryProductList = null;
        if (notify) {
          WidgetsBinding.instance.addPostFrameCallback((_) => update());
        }
      }
    } else {
      _paginate = true;
      if (notify) {
        update();
      }
    }

    // الخطوة 2: جلب البيانات من السيرفر في الخلفية لتحديث الكاش والشاشة
    ProductModel? productModel =
        await categoryServiceInterface.getCategoryProductList(
      categoryID,
      offset,
      type,
    );

    // تحقق مرة أخرى أن هذا الرد لنفس الفئة المطلوبة وليس فئة قديمة
    if (_requestedCategoryId != categoryID) return;

    if (productModel != null) {
      if (offset == 1) {
        _categoryProductList = [];
      }
      _categoryProductList!.addAll(Get.find<SplashController>()
          .filterXMarketProducts(productModel.products));
      _pageSize = productModel.totalSize;
      _hasNetworkError = false;
    } else {
      if (offset == 1 && _categoryProductList == null) {
        _categoryProductList = [];
        _hasNetworkError = true;
      }
    }

    _isLoading = false;
    _paginate = false;
    update();
  }

  void getCategoryRestaurantList(
      String? categoryID, int offset, String type, bool notify) async {
    _offset = offset;
    if (offset == 1) {
      if (_type == type) {
        _isSearching = false;
      }
      _type = type;
      _requestedCategoryId = categoryID; // تسجيل الـ ID المطلوب حالياً
      _categoryRestaurantList = null;
      if (notify) update();

      // كاش المطاعم
      RestaurantModel? localRestaurantModel =
          await categoryServiceInterface.getCategoryRestaurantList(
        categoryID,
        offset,
        type,
      );

      if (localRestaurantModel != null && _requestedCategoryId == categoryID) {
        _categoryRestaurantList = [];
        _categoryRestaurantList!.addAll(
            Get.find<SplashController>()
                .filterXMarketRestaurants(localRestaurantModel.restaurants));
        _restaurantPageSize = localRestaurantModel.totalSize;
        _isLoading = false;
        if (notify) update();
      }
    }

    RestaurantModel? restaurantModel =
        await categoryServiceInterface.getCategoryRestaurantList(
      categoryID,
      offset,
      type,
    );

    // تحقق أن الرد لنفس الفئة المطلوبة
    if (_requestedCategoryId != categoryID) return;

    if (restaurantModel != null) {
      if (offset == 1) {
        _categoryRestaurantList = [];
      }
      _categoryRestaurantList!.addAll(Get.find<SplashController>()
          .filterXMarketRestaurants(restaurantModel.restaurants));
      _restaurantPageSize = restaurantModel.totalSize;
    } else {
      if (offset == 1 && _categoryRestaurantList == null) {
        _categoryRestaurantList = [];
      }
    }
    _isLoading = false;
    update();
  }

  void searchDataLocal(String query) {
    _searchText = query;
    _isSearching = query.isNotEmpty;
    if (_isSearching && _categoryProductList != null) {
      _searchProductList = _categoryProductList!
          .where((product) =>
              product.name!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      _searchProductList = [];
      if (_categoryProductList != null) {
        _searchProductList!.addAll(_categoryProductList!);
      }
    }
    update();
  }

  void searchData(String? query, String? categoryID, String type) async {
    if ((_isRestaurant && query!.isNotEmpty) ||
        (!_isRestaurant && query!.isNotEmpty)) {
      _searchText = query;
      _type = type;
      if (_isRestaurant) {
        _searchRestaurantList = null;
      } else {
        _searchProductList = null;
      }
      _isSearching = true;
      update();

      Response response = await categoryServiceInterface.getSearchData(
          query, categoryID, _isRestaurant, type);
      if (response.statusCode == 200) {
        if (query.isEmpty) {
          if (_isRestaurant) {
            _searchRestaurantList = [];
          } else {
            _searchProductList = [];
          }
        } else {
          if (_isRestaurant) {
            _searchRestaurantList = [];
            _searchRestaurantList!
                .addAll(RestaurantModel.fromJson(response.body).restaurants!);
          } else {
            _searchProductList = [];
            _searchProductList!
                .addAll(ProductModel.fromJson(response.body).products!);
          }
        }
      }
      update();
    }
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    _searchProductList = [];
    if (_categoryProductList != null) {
      _searchProductList!.addAll(_categoryProductList!);
    }
    update();
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void setRestaurant(bool isRestaurant) {
    _isRestaurant = isRestaurant;
    update();
  }

  void clearSearch({bool isUpdate = true}) {
    getCategoryList(isUpdate, search: '');
    if (isUpdate) {
      update();
    }
  }

  void clearCategoryData() {
    _categoryProductList = null;
    _subCategoryList = null;
    _requestedCategoryId = null;
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => update());
  }
}
