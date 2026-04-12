import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/features/category/domain/models/category_model.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';

class RestaurantCategoryWithSubcategoriesWidget extends StatefulWidget {
  final CategoryModel category;
  final int? restaurantId;
  final ScrollController? scrollController;

  const RestaurantCategoryWithSubcategoriesWidget({
    super.key,
    required this.category,
    this.restaurantId,
    this.scrollController,
  });

  @override
  State<RestaurantCategoryWithSubcategoriesWidget> createState() =>
      _RestaurantCategoryWithSubcategoriesWidgetState();
}

class _RestaurantCategoryWithSubcategoriesWidgetState
    extends State<RestaurantCategoryWithSubcategoriesWidget> {
  @override
  void initState() {
    super.initState();
    _loadSubcategories();
  }

  @override
  void didUpdateWidget(
      covariant RestaurantCategoryWithSubcategoriesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category.id != widget.category.id) {
      _loadSubcategories();
    }
  }

  void _loadSubcategories() {
    if (widget.category.id != null) {
      Get.find<MarketCategoryController>()
          .getSubCategoryList(widget.category.id.toString());
      // Also ensure normal products are loaded in restaurant controller just in case we fallback
      if (widget.restaurantId != null) {
        Get.find<RestaurantController>().getRestaurantProductList(
            widget.restaurantId, 1, widget.category.id.toString(), false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarketCategoryController>(builder: (categoryController) {
      // Check if the loaded subcategories belong to this category
      // If not, reload them (this happens when returning from another screen that loaded its own subcategories)
      if (categoryController.parentCategoryId !=
          widget.category.id.toString()) {
        // Avoid infinite loop if loading fails or takes time
        if (!categoryController.isLoading) {
          // Use post frame callback to avoid build conflicts
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadSubcategories();
          });
        }
        // Show loading while we switch context
        return const Center(child: CircularProgressIndicator());
      }

      if (categoryController.isLoading) {
        return const Center(
            child: Padding(
          padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: CircularProgressIndicator(),
        ));
      }

      final subCategoryList = categoryController.subCategoryList;

      // Check if we have valid subcategories (excluding the parent itself/All)
      final hasSubCategories = subCategoryList != null &&
          subCategoryList
              .where((sub) => sub.id != widget.category.id)
              .isNotEmpty;

      if (hasSubCategories) {
        // Show grid of main categories from restaurant controller
        return GetBuilder<RestaurantController>(builder: (restController) {
          if (restController.categoryList == null ||
              restController.categoryList!.isEmpty) {
            return const SizedBox();
          }

          // Filter out "الجميع" category
          final categoriesToShow = restController.categoryList!
              .where((cat) => cat.name != 'الجميع')
              .toList();

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 cards per row
              crossAxisSpacing: Dimensions.paddingSizeDefault,
              mainAxisSpacing: Dimensions.paddingSizeDefault,
              childAspectRatio: 1.0, // Square cards
            ),
            itemCount: categoriesToShow.length,
            itemBuilder: (context, index) {
              final category = categoriesToShow[index];
              return InkWell(
                onTap: () async {
                  if (category.id != null) {
                    // Find the index of this category in the full categoryList
                    final categoryIndex =
                        restController.categoryList!.indexWhere(
                      (cat) => cat.id == category.id,
                    );

                    if (categoryIndex != -1) {
                      // Set the category index to show subcategories in the bar
                      restController.setCategoryIndex(categoryIndex);

                      // Load subcategories for this category
                      final catController =
                          Get.find<MarketCategoryController>();
                      await catController
                          .getSubCategoryList(category.id.toString());

                      // Load products: either first subcategory or all category items
                      if (widget.restaurantId != null && category.id != null) {
                        if (catController.subCategoryList != null &&
                            catController.subCategoryList!.isNotEmpty) {
                          // Automatically select the first sub-category (index 1)
                          final firstSubCategory =
                              catController.subCategoryList![0];
                          catController.setSubCategoryIndex(
                            1,
                            category.id.toString(),
                            dataLoad: false,
                          );

                          restController.getRestaurantProductListByCategoryId(
                            widget.restaurantId,
                            1,
                            firstSubCategory.id!,
                            restController.type,
                            false,
                          );
                        } else {
                          // Fallback to loading all if no subcategories exist
                          restController.getRestaurantProductListByCategoryId(
                            widget.restaurantId,
                            1,
                            category.id!,
                            restController.type,
                            false,
                          );
                        }
                      }
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Category Image or Icon
                      category.imageFullUrl != null &&
                              category.imageFullUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusSmall),
                              child: CustomImageWidget(
                                image: category.imageFullUrl!,
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.category,
                              size: 40,
                              color: Theme.of(context).primaryColor,
                            ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      // Category Name
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                        ),
                        child: Text(
                          category.name ?? '',
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
      } else {
        // Fallback: Show normal product list for this category
        return GetBuilder<RestaurantController>(builder: (restController) {
          return PaginatedListViewWidget(
            scrollController: widget.scrollController ?? ScrollController(),
            onPaginate: (int? offset) {
              restController.showFoodBottomLoader();
              restController.getRestaurantProductList(
                  widget.restaurantId, offset!, restController.type, false);
            },
            totalSize: restController.foodPageSize,
            offset: restController.foodPageOffset,
            productView: Column(
              children: [
                ProductViewWidget(
                  isRestaurant: false,
                  restaurants: null,
                  products: restController.restaurantProducts,
                  inRestaurantPage: true,
                  useGridCard: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: Dimensions.paddingSizeLarge,
                  ),
                ),
                if (restController.foodPaginate)
                  Padding(
                    padding:
                        const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Text(
                          'جاري تحميل المزيد...',
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        });
      }
    });
  }
}
