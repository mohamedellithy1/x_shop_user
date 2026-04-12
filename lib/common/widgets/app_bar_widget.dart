import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/address/screens/add_address_screen.dart';
import 'package:stackfood_multivendor/features/dashboard/screens/dashboard_screen.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/screens/access_location_screen.dart';
import 'package:stackfood_multivendor/features/location/screens/pick_map_screen.dart';
import 'package:stackfood_multivendor/localization/localization_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? icon;
  final Function()? onIconTap;
  final bool showBackButton;
  final bool showActionButton;
  final Function()? onBackPressed;
  final bool centerTitle;
  final double? fontSize;
  final bool isHome;
  final String? subTitle;
  final bool showTripHistoryFilter;
  const AppBarWidget(
      {super.key,
      required this.title,
      this.icon,
      this.onIconTap,
      this.subTitle,
      this.showBackButton = true,
      this.onBackPressed,
      this.centerTitle = false,
      this.showActionButton = true,
      this.isHome = false,
      this.showTripHistoryFilter = false,
      this.fontSize});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(150.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.red],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          toolbarHeight: 60,
          automaticallyImplyLeading: false,
          title: InkWell(
            onTap: isHome ? () {} : null,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(
                      title.tr,
                      style: robotoRegular.copyWith(
                        fontSize: fontSize ?? Dimensions.fontSizeLarge,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    if (icon != null)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: .21, color: Theme.of(context).cardColor),
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.black),
                        child: InkWell(
                          onTap: onIconTap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeExtraSmall),
                            child: Lottie.asset(icon!, height: 50, width: 50),
                          ),
                        ),
                      ),
                    // if (showTripHistoryFilter)
                    //   GetBuilder<TripController>(builder: (tripController) {
                    //     return Expanded(
                    //       child: Padding(
                    //         padding: const EdgeInsets.symmetric(
                    //             horizontal: Dimensions.paddingSizeDefault),
                    //         child: DropDownWidget<int>(
                    //           showText: false,
                    //           showLeftSide: false,
                    //           menuItemWidth: 120,
                    //           icon: Container(
                    //             height: 30,
                    //             width: 30,
                    //             decoration: BoxDecoration(
                    //                 color: Colors.white,
                    //                 shape: BoxShape.circle),
                    //             child: Icon(Icons.filter_list_sharp,
                    //                 color: Colors.black, size: 16),
                    //           ),
                    //           maxListHeight: 200,
                    //           items: tripController.filterList
                    //               .map((item) => CustomDropdownMenuItem<int>(
                    //                     value: tripController.filterList
                    //                         .indexOf(item),
                    //                     child: Text(
                    //                       item.tr,
                    //                       style: textRegular.copyWith(
                    //                           color: Get.isDarkMode
                    //                               ? Get.find<TripController>()
                    //                                           .filterIndex ==
                    //                                       Get.find<
                    //                                               TripController>()
                    //                                           .filterList
                    //                                           .indexOf(item)
                    //                                   ? Colors.black
                    //                                   : Colors.black
                    //                               : Get.find<TripController>()
                    //                                           .filterIndex ==
                    //                                       Get.find<
                    //                                               TripController>()
                    //                                           .filterList
                    //                                           .indexOf(item)
                    //                                   ? Colors.black
                    //                                   : Colors.black),
                    //                     ),
                    //                   ))
                    //               .toList(),
                    //           hintText: tripController
                    //               .filterList[
                    //                   Get.find<TripController>().filterIndex]
                    //               .tr,
                    //           borderRadius: 5,
                    //           onChanged: (int selectedItem) {
                    //             if (selectedItem ==
                    //                 tripController.filterList.length - 1) {
                    //               showDialog(
                    //                 context: context,
                    //                 builder: (_) => CalenderWidget(
                    //                     onChanged: (value) => Get.back()),
                    //               );
                    //             } else {
                    //               tripController
                    //                   .setFilterTypeName(selectedItem);
                    //             }
                    //           },
                    //         ),
                    //       ),
                    //     );
                    //   }),
                  ]),

                  subTitle != null
                      ? Text(
                          '${'trip'.tr} #$subTitle',
                          style: robotoRegular.copyWith(
                            fontSize: fontSize ??
                                (isHome
                                    ? Dimensions.fontSizeLarge
                                    : Dimensions.fontSizeLarge),
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                        )
                      : const SizedBox(),

                  //isHome ?
                  /*GetBuilder<LocationController>(builder: (locationController) {
                    return Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                      child: Row(children: [
                        Icon(Icons.place_outlined,color: Get.isDarkMode ? Colors.white.withValues(alpha:0.8) : Colors.white, size: 16),
                        const SizedBox(width: Dimensions.paddingSizeSeven),
        
                        Expanded(child: Text(
                          locationController.getUserAddress()?.address ?? '',
                          maxLines: 1,overflow: TextOverflow.ellipsis,
                          style: textRegular.copyWith(color:Get.isDarkMode ? Colors.white.withValues(alpha:0.8) : Colors.white,
                              fontSize: Dimensions.fontSizeExtraSmall),
                        )),
                      ]),
                    );
                  }) :
                  const SizedBox.shrink(),*/
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ],
              ),
            ),
          ),
          centerTitle: centerTitle,
          excludeHeaderSemantics: true,
          titleSpacing: 0,
          leading: showBackButton
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                  ),
                  color: Colors.white,
                  onPressed: () => onBackPressed != null
                      ? onBackPressed!()
                      : Navigator.canPop(context)
                          ? Get.back()
                          : Get.offAll(() => const DashboardScreen(
                                pageIndex: 0,
                              )),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size(Dimensions.webMaxWidth, 150);

  // void _navigateToHomeWithCleanup() {
  //   // مسح بيانات المسارات الإضافية قبل الانتقال للصفحة الرئيسية
  //   try {
  //     if (Get.isRegistered<BottomMenuController>()) {
  //       Get.find<BottomMenuController>().navigateToDashboard();
  //     } else {
  //       Get.offAll(() => const XRideDashboardScreen());
  //     }
  //   } catch (e) {
  //     Get.offAll(() => const XRideDashboardScreen());
  //   }
  // }
}
