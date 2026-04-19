import 'package:stackfood_multivendor/common/widgets/custom_loader_widget.dart';
import 'package:stackfood_multivendor/features/address/controllers/market_address_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';
import 'package:stackfood_multivendor/features/address/widgets/address_card_widget.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/xmarket_images.dart';

class AddressBottomSheet extends StatelessWidget {
  const AddressBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarketThemeController>(
        tag: 'xmarket',
        builder: (marketThemeController) {
          return Theme(
            data: marketThemeController.darkTheme
                ? ThemeData.dark().copyWith(
                    cardColor: const Color(0xFF141313),
                    primaryColor: Color(0xFF9ebc67),
                  )
                : ThemeData.light().copyWith(
                    cardColor: Colors.white,
                    primaryColor: Color(0xFF9ebc67),
                  ),
            child: Container(
              decoration: BoxDecoration(
                color: marketThemeController.darkTheme
                    ? const Color(0xFF141313)
                    : Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.paddingSizeExtraLarge),
                  topRight: Radius.circular(Dimensions.paddingSizeExtraLarge),
                ),
              ),
              child: GetBuilder<MarketAddressController>(
                  id: 'xmarket',
                  init: Get.find<MarketAddressController>(tag: 'xmarket'),
                  builder: (addressController) {
                    AddressModel? selectedAddress =
                        AddressHelper.getAddressFromSharedPref();
                    return Column(mainAxisSize: MainAxisSize.min, children: [
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: Dimensions.paddingSizeDefault,
                              bottom: Dimensions.paddingSizeDefault),
                          height: 3,
                          width: 40,
                          decoration: BoxDecoration(
                              color: marketThemeController.darkTheme
                                  ? Colors.white30
                                  : Theme.of(context).highlightColor,
                              borderRadius: BorderRadius.circular(
                                  Dimensions.paddingSizeExtraSmall)),
                        ),
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeLarge,
                              vertical: Dimensions.paddingSizeSmall),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    '${'hey_welcome_back'.tr}\n${'which_location_do_you_want_to_select'.tr}',
                                    style: robotoBold.copyWith(
                                        color: marketThemeController.darkTheme
                                            ? Colors.white
                                            : Color(0xFF55745a),
                                        fontSize: Dimensions.fontSizeDefault)),
                                const SizedBox(
                                    height: Dimensions.paddingSizeLarge),
                                addressController.addressList != null &&
                                        addressController.addressList!.isEmpty
                                    ? Column(children: [
                                        Image.asset(XmarketImages.address,
                                            width: 150,
                                            color:
                                                marketThemeController.darkTheme
                                                    ? Colors.white70
                                                    : null),
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeLarge),
                                        Text(
                                          'you_dont_have_any_saved_address_yet'
                                              .tr,
                                          textAlign: TextAlign.center,
                                          style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: marketThemeController
                                                      .darkTheme
                                                  ? Colors.white70
                                                  : Color(0xFF55745a)),
                                        ),
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeLarge),
                                      ])
                                    : const SizedBox(),
                                addressController.addressList != null &&
                                        addressController.addressList!.isEmpty
                                    ? const SizedBox(
                                        height: Dimensions.paddingSizeLarge)
                                    : const SizedBox(),
                                Align(
                                  alignment:
                                      addressController.addressList != null &&
                                              addressController
                                                  .addressList!.isNotEmpty
                                          ? Alignment.centerLeft
                                          : Alignment.center,
                                  child: TextButton.icon(
                                    onPressed: () =>
                                        _onCurrentLocationButtonPressed(),
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          addressController.addressList !=
                                                      null &&
                                                  addressController
                                                      .addressList!.isEmpty
                                              ? Color(0xFF9ebc67)
                                              : Colors.transparent,
                                    ),
                                    icon: Icon(Icons.my_location,
                                        color: addressController.addressList !=
                                                    null &&
                                                addressController
                                                    .addressList!.isEmpty
                                            ? Colors.black
                                            : Color(0xFF9ebc67)),
                                    label: Text('use_current_location'.tr,
                                        style: robotoMedium.copyWith(
                                            color:
                                                addressController.addressList !=
                                                            null &&
                                                        addressController
                                                            .addressList!
                                                            .isEmpty
                                                    ? Colors.black
                                                    : Color(0xFF9ebc67))),
                                  ),
                                ),
                                const SizedBox(
                                    height: Dimensions.paddingSizeSmall),
                                addressController.addressList != null
                                    ? addressController.addressList!.isNotEmpty
                                        ? Container(
                                            decoration: BoxDecoration(
                                              color: marketThemeController
                                                      .darkTheme
                                                  ? Colors.white
                                                      .withValues(alpha: 0.05)
                                                  : Theme.of(context)
                                                      .primaryColor
                                                      .withValues(alpha: 0.05),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radiusDefault),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal:
                                                    Dimensions.paddingSizeSmall,
                                                vertical: Dimensions
                                                    .paddingSizeSmall),
                                            child: ListView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: true,
                                              itemCount: addressController
                                                          .addressList!.length >
                                                      5
                                                  ? 5
                                                  : addressController
                                                      .addressList!.length,
                                              itemBuilder: (context, index) {
                                                bool selected = false;
                                                if (selectedAddress!.id ==
                                                    addressController
                                                        .addressList![index]
                                                        .id) {
                                                  selected = true;
                                                }
                                                return Center(
                                                    child: SizedBox(
                                                        width: 700,
                                                        child:
                                                            AddressCardWidget(
                                                          address: addressController
                                                                  .addressList![
                                                              index],
                                                          fromAddress: false,
                                                          isSelected: selected,
                                                          fromDashBoard: true,
                                                          onTap: () {
                                                            Get.dialog(
                                                                const CustomLoaderWidget(),
                                                                barrierDismissible:
                                                                    false);
                                                            AddressModel
                                                                address =
                                                                addressController
                                                                        .addressList![
                                                                    index];
                                                            Get.find<
                                                                    MarketLocationController>()
                                                                .saveAddressAndNavigate(
                                                              address,
                                                              false,
                                                              null,
                                                              false,
                                                              ResponsiveHelper
                                                                  .isDesktop(
                                                                      context),
                                                            );
                                                          },
                                                        )));
                                              },
                                            ),
                                          )
                                        : const SizedBox()
                                    : const Center(
                                        child: CircularProgressIndicator(
                                        color: Color(0xFF9ebc67),
                                      )),
                                SizedBox(
                                    height:
                                        addressController.addressList != null &&
                                                addressController
                                                    .addressList!.isEmpty
                                            ? 0
                                            : Dimensions.paddingSizeSmall),
                                addressController.addressList != null &&
                                        addressController
                                            .addressList!.isNotEmpty
                                    ? TextButton.icon(
                                        onPressed: () => Get.toNamed(
                                            RouteHelper.getAddAddressRoute(
                                                false, 0)),
                                        icon: const Icon(
                                            Icons.add_circle_outline_sharp,
                                            color: Color(0xFF55745a)),
                                        label: Text('add_new_address'.tr,
                                            style: robotoMedium.copyWith(
                                                color: marketThemeController
                                                        .darkTheme
                                                    ? Colors.white
                                                    : Color(0xFF55745a))),
                                      )
                                    : const SizedBox(),
                              ]),
                        ),
                      ),
                    ]);
                  }),
            ),
          );
        });
  }

  void _onCurrentLocationButtonPressed() {
    Get.find<MarketLocationController>().checkPermission(() async {
      Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
      AddressModel address =
          await Get.find<MarketLocationController>().getCurrentLocation(true);
      ZoneResponseModel response = await Get.find<MarketLocationController>()
          .getZone(address.latitude, address.longitude, false);
      if (response.isSuccess) {
        Get.find<MarketLocationController>().saveAddressAndNavigate(
          address,
          false,
          '',
          false,
          ResponsiveHelper.isDesktop(Get.context),
        );
      } else {
        Get.back();
        Get.toNamed(
            RouteHelper.getPickMapRoute(RouteHelper.accessLocation, false));
        showCustomSnackBar('service_not_available_in_current_location'.tr);
      }
    });
  }
}
