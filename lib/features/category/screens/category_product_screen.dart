import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/bottom_cart_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/search_field_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_menu_bar.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CategoryProductScreen extends StatefulWidget {
  final String? categoryID;
  final String categoryName;
  final bool forceProductView;

  const CategoryProductScreen({
    super.key,
    required this.categoryID,
    required this.categoryName,
    this.forceProductView = false,
  });

  @override
  CategoryProductScreenState createState() => CategoryProductScreenState();
}

class CategoryProductScreenState extends State<CategoryProductScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    debugPrint(
        'CategoryProductScreen: initState - categoryID: ${widget.categoryID}, force: ${widget.forceProductView}');

    Get.find<MarketCategoryController>().clearCategoryData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.forceProductView) {
        Get.find<MarketCategoryController>()
            .getCategoryProductList(widget.categoryID, 1, 'all', true);
      } else {
        _loadData();
      }
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          Get.find<MarketCategoryController>().categoryProductList != null &&
          !Get.find<MarketCategoryController>().isLoading &&
          !Get.find<MarketCategoryController>().paginate) {
        int pageSize =
            (Get.find<MarketCategoryController>().pageSize! / 10).ceil();
        if (Get.find<MarketCategoryController>().offset < pageSize) {
          Get.find<MarketCategoryController>().getCategoryProductList(
              widget.categoryID,
              Get.find<MarketCategoryController>().offset + 1,
              'all',
              true);
        }
      }
    });
  }

  void _loadData() {
    Get.find<MarketCategoryController>().getSubCategoryList(widget.categoryID);
  }

  @override
  void didUpdateWidget(CategoryProductScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryID != widget.categoryID) {
      debugPrint(
          'CategoryProductScreen: didUpdateWidget - new ID: ${widget.categoryID}');

      Get.find<MarketCategoryController>().clearCategoryData();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.forceProductView) {
          Get.find<MarketCategoryController>()
              .getCategoryProductList(widget.categoryID, 1, 'all', true);
        } else {
          _loadData();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarketCategoryController>(builder: (catController) {
      bool showSubCategories = false;
      List<dynamic> subCategories = [];

      if (!widget.forceProductView) {
        if (catController.subCategoryList != null) {
          subCategories = catController.subCategoryList!
              .where((sub) =>
                  sub.name != 'all'.tr &&
                  sub.name?.toLowerCase() != 'all' &&
                  sub.name != 'الجميع')
              .toList();
          showSubCategories = subCategories.isNotEmpty;

          if (_searchController.text.isNotEmpty && showSubCategories) {
            subCategories = subCategories
                .where((sub) => sub.name!
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
                .toList();
          }
        }
      } else {
        showSubCategories = false;
      }

      if (!catController.isLoading &&
          catController.categoryProductList == null &&
          !catController.hasNetworkError) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (catController.categoryProductList == null &&
              !catController.hasNetworkError) {
            catController.getCategoryProductList(
                widget.categoryID, 1, 'all', true);
          }
        });
      }

      return Scaffold(
        backgroundColor:
            Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
                ? Colors.black
                : Color(0xFFfafef5),
        appBar: (ResponsiveHelper.isDesktop(context)
            ? const WebMenuBar()
            : PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFe3ebd5),
                        Color(0xFFfafff4),
                        Color(0xFFe3ebd5),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),

                    // gradient: LinearGradient(
                    //   colors: [Color(0xFFd6e0c4), Color(0xFFe7feba)],
                    //   begin: Alignment.topLeft,
                    //   end: Alignment.bottomRight,
                    // ),
                  ),
                  child: AppBar(
                    title: Text(widget.categoryName,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Colors.white,
                        )),
                    centerTitle: true,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      color: Colors.white,
                      onPressed: () => Get.back(),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    actions: [
                      // IconButton(
                      //   // padding: EdgeInsets.zero,
                      //   // constraints: const BoxConstraints(),
                      //   // onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
                      //   // icon: const CartWidget(color: Colors.white, size: 25),
                      // ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    ],
                  ),
                ),
              )) as PreferredSizeWidget?,
        endDrawer: const MenuDrawerWidget(),
        endDrawerEnableOpenDragGesture: false,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeExtraSmall),
              child: SearchFieldWidget(
                controller: _searchController,
                hint: showSubCategories
                    ? 'search_by_category'.tr
                    : 'search_product_category'.tr,
                suffixIcon:
                    (showSubCategories && _searchController.text.isNotEmpty) ||
                            catController.isSearching
                        ? Icons.close
                        : Icons.search,
                iconPressed: () {
                  if (showSubCategories) {
                    setState(() {
                      _searchController.clear();
                    });
                  } else if (catController.isSearching) {
                    _searchController.text = '';
                    catController.toggleSearch();
                  } else {
                    if (_searchController.text.isNotEmpty) {
                      catController.searchDataLocal(_searchController.text);
                    }
                  }
                },
                onSubmit: (query) {
                  if (showSubCategories) {
                    setState(() {});
                  } else if (query.isNotEmpty) {
                    catController.searchDataLocal(query);
                  }
                },
                onChanged: (query) {
                  if (showSubCategories) {
                    setState(() {});
                  } else if (query.isEmpty && catController.isSearching) {
                    catController.toggleSearch();
                  } else if (query.isNotEmpty) {
                    catController.searchDataLocal(query);
                  }
                },
              ),
            ),
            Expanded(
              child: catController.isLoading
                  ? Center(
                      child: Lottie.asset('assets/image/loading_gray.json',
                          width: 150, height: 150))
                  : (showSubCategories && !widget.forceProductView)
                      ? subCategories.isNotEmpty
                          ? GridView.builder(
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeDefault),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    ResponsiveHelper.isDesktop(context)
                                        ? 6
                                        : ResponsiveHelper.isTab(context)
                                            ? 4
                                            : 2,
                                mainAxisSpacing: 25,
                                crossAxisSpacing: 10,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: subCategories.length,
                              itemBuilder: (context, index) {
                                final sub = subCategories[index];
                                String name = sub.name ?? '';
                                String? image = sub.imageFullUrl;

                                return InkWell(
                                  onTap: () {
                                    Get.toNamed(
                                        RouteHelper.getCategoryProductRoute(
                                      sub.id,
                                      sub.name ?? '',
                                      forceProductView: true,
                                    ))?.then((value) {
                                      if (widget.forceProductView) {
                                        Get.find<MarketCategoryController>()
                                            .getCategoryProductList(
                                                widget.categoryID,
                                                1,
                                                'all',
                                                true);
                                      } else {
                                        _loadData();
                                      }
                                    });
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 15),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusDefault),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withValues(alpha: 0.1),
                                                spreadRadius: 1,
                                                blurRadius: 5,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusDefault),
                                            child: CustomImageWidget(
                                              height: double.infinity,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              image: image ?? '',
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                          height:
                                              Dimensions.paddingSizeExtraSmall),
                                      Text(
                                        name,
                                        style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color:
                                                Get.find<MarketThemeController>(
                                                            tag: 'xmarket')
                                                        .darkTheme
                                                    ? Colors.white
                                                    : Color(0xFF55745a)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                'no_category_found'.tr,
                                style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: Theme.of(context).disabledColor),
                              ),
                            )
                      : catController.hasNetworkError
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.wifi_off_rounded,
                                      size: 80,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'no_internet_connection'.tr,
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                        color: Color(0xFF55745a),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'check_your_internet_connection'.tr,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Colors.grey.shade600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 32),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        if (widget.forceProductView) {
                                          catController.getCategoryProductList(
                                              widget.categoryID,
                                              1,
                                              'all',
                                              true);
                                        } else {
                                          _loadData();
                                          catController.getCategoryProductList(
                                              widget.categoryID,
                                              1,
                                              'all',
                                              true);
                                        }
                                      },
                                      icon: const Icon(Icons.refresh_rounded),
                                      label: Text('retry'.tr),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              controller: scrollController,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight:
                                      MediaQuery.of(context).size.height -
                                          MediaQuery.of(context).padding.top -
                                          kToolbarHeight -
                                          60,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      (catController.categoryProductList ==
                                                  null ||
                                              catController
                                                  .categoryProductList!.isEmpty)
                                          ? MainAxisAlignment.center
                                          : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ProductViewWidget(
                                      isRestaurant: false,
                                      products: catController.isSearching
                                          ? catController.searchProductList
                                          : catController.categoryProductList,
                                      restaurants: null,
                                      useGridCard: true,
                                      noDataText: 'no_category_food_found'.tr,
                                      isCenter: true,
                                    ),
                                    catController.paginate
                                        ? Center(
                                            child: Padding(
                                            padding: const EdgeInsets.all(
                                                Dimensions.paddingSizeDefault),
                                            child: CircularProgressIndicator(
                                                color: Color(0xFF9ebc67)),
                                          ))
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                            ),
            ),
          ],
        ),
        bottomNavigationBar:
            GetBuilder<MarketCartController>(builder: (cartController) {
          return cartController.cartList.isNotEmpty &&
                  !ResponsiveHelper.isDesktop(context)
              ? BottomCartWidget(
                  restaurantId:
                      cartController.cartList[0].product!.restaurantId!,
                  fromDineIn: false)
              : const SizedBox();
        }),
      );
    });
  }
}
