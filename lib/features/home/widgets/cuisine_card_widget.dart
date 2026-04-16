import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CuisineCardWidget extends StatelessWidget {
  final String image;
  final String name;
  final bool fromCuisinesPage;
  final bool fromSearchPage;
  const CuisineCardWidget(
      {super.key,
      required this.image,
      required this.name,
      this.fromCuisinesPage = false,
      this.fromSearchPage = false});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context)
        ? ClipRRect(
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(Dimensions.radiusDefault),
                bottomRight: Radius.circular(Dimensions.radiusDefault)),
            child: Stack(
              children: [
                Positioned(
                  bottom: ResponsiveHelper.isMobile(context) ? -75 : -55,
                  left: 0,
                  right: ResponsiveHelper.isMobile(context) ? -17 : 0,
                  child: Transform.rotate(
                    angle: 40,
                    child: Container(
                      height: ResponsiveHelper.isMobile(context) ? 132 : 120,
                      width: ResponsiveHelper.isMobile(context) ? 150 : 120,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(50)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CustomImageWidget(
                          image: image,
                          fit: BoxFit.cover,
                          height: 120,
                          width: 120),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    alignment: Alignment.center,
                    height: 30,
                    width: 120,
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeExtraSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[
                                Get.find<MarketThemeController>(tag: 'xmarket')
                                        .darkTheme
                                    ? 700
                                    : 300]!,
                            spreadRadius: 0.5,
                            blurRadius: 0.5)
                      ],
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(Dimensions.radiusDefault),
                          bottomRight:
                              Radius.circular(Dimensions.radiusDefault)),
                    ),
                    child: Text(
                      name,
                      style: robotoMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF55745a),
                          fontSize: Dimensions.fontSizeSmall),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // الصورة الدائرية
              Flexible(
                child: CircleAvatar(
                  radius: fromSearchPage || fromCuisinesPage ? 60 : 40,
                  backgroundColor: Theme.of(context).cardColor,
                  backgroundImage: NetworkImage(image),
                ),
              ),
              const SizedBox(height: 4),
              // اسم الفئة
              Text(
                name,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF55745a),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          );
  }
}
