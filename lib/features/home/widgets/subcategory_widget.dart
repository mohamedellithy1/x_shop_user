import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';

class SubCategoryWidget extends StatelessWidget {
  final int? parentCategoryId;
  final String? parentCategoryName;
  const SubCategoryWidget({
    super.key,
    this.parentCategoryId,
    this.parentCategoryName,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarketCategoryController>(
      builder: (categoryController) {
        // Load subcategories when widget is built
        if (parentCategoryId != null) {
          // Check if we need to load subcategories
          final needsLoad = categoryController.subCategoryList == null ||
              categoryController.subCategoryList!.isEmpty ||
              (categoryController.subCategoryList!.isNotEmpty &&
                  categoryController.subCategoryList![0].id !=
                      parentCategoryId);

          if (needsLoad) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              categoryController
                  .getSubCategoryList(parentCategoryId.toString());
            });
            // Show loading state
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeExtraSmall,
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: const Center(child: CircularProgressIndicator()),
            );
          }
        }

        if (categoryController.subCategoryList == null ||
            categoryController.subCategoryList!.isEmpty) {
          return const SizedBox.shrink();
        }

        // Filter to show only subcategories (skip "الجميع" if it exists)
        // The first item is usually "الجميع" with parent ID, so we skip it
        final subCategories = categoryController.subCategoryList!
            .where((cat) => cat.id != parentCategoryId)
            .toList();

        if (subCategories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
            vertical: Dimensions.paddingSizeExtraSmall,
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Parent category title
              if (parentCategoryName != null)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeSmall,
                    right: Dimensions.paddingSizeExtraSmall,
                  ),
                  child: Text(
                    parentCategoryName!,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              // Subcategories grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.1,
                  mainAxisSpacing: Dimensions.paddingSizeSmall,
                  crossAxisSpacing: Dimensions.paddingSizeSmall,
                ),
                itemCount: subCategories.length,
                itemBuilder: (context, index) {
                  final subCategory = subCategories[index];
                  return InkWell(
                    onTap: () {
                      Get.toNamed(
                        RouteHelper.getCategoryProductRoute(
                          subCategory.id,
                          subCategory.name ?? '',
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (subCategory.imageFullUrl != null)
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusSmall),
                              child: CustomImageWidget(
                                image: subCategory.imageFullUrl!,
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Icon(
                              Icons.category,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                          const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeExtraSmall,
                            ),
                            child: Text(
                              subCategory.name ?? '',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
