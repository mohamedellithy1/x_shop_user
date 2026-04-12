import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/features/category/domain/models/category_model.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SubCategoryProductSection extends StatefulWidget {
  final CategoryModel subCategory;
  final MarketCategoryController categoryController;
  final bool showTitle;

  const SubCategoryProductSection({
    super.key,
    required this.subCategory,
    required this.categoryController,
    this.showTitle = true,
  });

  @override
  State<SubCategoryProductSection> createState() =>
      _SubCategoryProductSectionState();
}

class _SubCategoryProductSectionState extends State<SubCategoryProductSection> {
  List<Product>? _products;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _products = null; // Explicitly start with null
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (widget.subCategory.id == null) return;

    // Use the new method that doesn't affect global state
    final products = await widget.categoryController.getProductsForSubCategory(
      widget.subCategory.id.toString(),
    );

    if (mounted) {
      setState(() {
        _products = products;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Lottie.asset('assets/image/loading_gray.json',
              width: 150, height: 150),
        ),
      );
    }

    if (_products == null || _products!.isEmpty) {
      return const SizedBox();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Row(
                children: [
                  if (widget.subCategory.imageFullUrl != null &&
                      widget.subCategory.imageFullUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: CustomImageWidget(
                        height: 25,
                        width: 25,
                        fit: BoxFit.cover,
                        image: '${widget.subCategory.imageFullUrl}',
                      ),
                    ),
                  if (widget.subCategory.imageFullUrl != null &&
                      widget.subCategory.imageFullUrl!.isNotEmpty)
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text(
                    widget.subCategory.name ?? '',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ProductViewWidget(
            isRestaurant: false,
            products: _products,
            restaurants: null,
            useGridCard: true,
            noDataText: 'no_food_found'.tr,
          ),
        ],
      ),
    );
  }
}
