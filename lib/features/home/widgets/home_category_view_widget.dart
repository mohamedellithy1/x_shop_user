import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/features/category/domain/models/category_model.dart';
import 'package:stackfood_multivendor/features/coupon/screens/coupon_screen.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';

class HomeCategoryViewWidget extends StatelessWidget {
  const HomeCategoryViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (categoryController) {
      List<CategoryModel>? categories = categoryController.categoryList;

      if (categories == null || categories.isEmpty) {
        if (categoryController.isLoading) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: CircularProgressIndicator(
              color: Color(0xFF9ebc67),
            ),
          ));
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeExtraOverLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "الخدمه غير متوفره الان",
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge,
                    color: Color(0xFF55745a),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Text(
                  "برجاء المحاوله لاحقا",
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Color(0xFF55745a),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.paddingSizeDefault),
          GridView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveHelper.isMobile(context) ? 3 : 6,
              mainAxisSpacing: Dimensions.paddingSizeExtraOverLarge,
              crossAxisSpacing: Dimensions.paddingSizeDefault,
              childAspectRatio: 0.9,
            ),
            itemCount: categories!.length,
            itemBuilder: (context, index) {
              CategoryModel category = categories[index];
              return InkWell(
                onTap: () => Get.toNamed(RouteHelper.getCategoryProductRoute(
                    category.id, category.name ?? '')),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                          child: CustomImageWidget(
                            image: '${category.imageFullUrl}',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(
                      category.name ?? '',
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Get.find<ThemeController>()
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
          ),
          SizedBox(
            height: 20,
          ),
          // InkWell(
          //   onTap: () => Get.to(() => CouponScreen(
          //         fromCheckout: false,
          //       )),
          //   child: SizedBox(
          //     width: MediaQuery.of(context).size.width * 0.5,
          //     child: Row(
          //       children: [
          //         Lottie.asset("assets/image/offer.json",
          //             width: MediaQuery.of(context).size.width * 0.17),
          //         Text(
          //           "عروض و خصومات",
          //           style: robotoBold.copyWith(
          //             fontSize: Dimensions.fontSizeLarge,
          //             fontWeight: FontWeight.w600,
          //           ),
          //         ),
          //       ],
          //     ),
          // ),
          // ),
        ],
      );
    });
  }
}
