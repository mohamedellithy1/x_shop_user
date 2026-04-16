import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/delivery_info_fields.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/saved_address_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/xmarket_images.dart';

class DeliverySection extends StatefulWidget {
  final CheckoutController checkoutController;
  final MarketLocationController locationController;
  final TextEditingController guestNameController;
  final TextEditingController guestNumberController;
  final TextEditingController guestEmailController;
  final TextEditingController guestAddressController;
  final TextEditingController guestStreetNumberController;
  final TextEditingController guestHouseController;
  final TextEditingController guestFloorController;
  final FocusNode guestNameNode;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  final FocusNode guestAddressNode;
  final FocusNode guestStreetNumberNode;
  final FocusNode guestHouseNode;
  final FocusNode guestFloorNode;

  const DeliverySection(
      {super.key,
      required this.checkoutController,
      required this.locationController,
      required this.guestNameController,
      required this.guestNumberController,
      required this.guestEmailController,
      required this.guestAddressController,
      required this.guestStreetNumberController,
      required this.guestHouseController,
      required this.guestFloorController,
      required this.guestNameNode,
      required this.guestNumberNode,
      required this.guestEmailNode,
      required this.guestAddressNode,
      required this.guestStreetNumberNode,
      required this.guestHouseNode,
      required this.guestFloorNode});

  @override
  State<DeliverySection> createState() => _DeliverySectionState();
}

class _DeliverySectionState extends State<DeliverySection> {
  @override
  void initState() {
    super.initState();
    widget.checkoutController.setShowMoreDetails(false, willUpdate: false);
    widget.checkoutController
        .insertAddresses(AddressHelper.getAddressFromSharedPref());
  }

  @override
  Widget build(BuildContext context) {
    bool isGuestLoggedIn = Get.find<MarketAuthController>().isGuestLoggedIn();
    bool takeAway = (widget.checkoutController.orderType == 'take_away');
    bool isDineIn = (widget.checkoutController.orderType == 'dine_in');
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      return Column(children: [
        if (isGuestLoggedIn || isDineIn)
          DeliveryInfoFields(
            checkoutController: widget.checkoutController,
            guestNameController: widget.guestNameController,
            guestNumberController: widget.guestNumberController,
            guestEmailController: widget.guestEmailController,
            guestAddressController: widget.guestAddressController,
            guestNameNode: widget.guestNameNode,
            guestNumberNode: widget.guestNumberNode,
            guestEmailNode: widget.guestEmailNode,
            guestAddressNode: widget.guestAddressNode,
            guestStreetNumberNode: widget.guestStreetNumberNode,
            guestHouseNode: widget.guestHouseNode,
            guestFloorNode: widget.guestFloorNode,
          )
        else if (!takeAway && !isDineIn)
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: isDesktop ? 0 : Dimensions.fontSizeDefault),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop
                  ? Dimensions.paddingSizeLarge
                  : Dimensions.paddingSizeSmall,
              vertical: Dimensions.paddingSizeSmall,
            ),
            decoration: BoxDecoration(
              color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
                  ? const Color(0xFF1b1b1b)
                  : Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.grey.withValues(alpha: 0.1),
              //     spreadRadius: 1,
              //     blurRadius: 10,
              //     offset: const Offset(0, 1),
              //   )
              // ],
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: MediaQuery.of(context).size.width * 0.3,
                  children: [
                    Text('حدد عنوان التسليم',
                        style: robotoMedium.copyWith(
                            color:
                                Get.find<MarketThemeController>(tag: 'xmarket')
                                        .darkTheme
                                    ? Colors.white
                                    : Color(0xFF55745a),
                            fontSize: 17)),
                    InkWell(
                      onTap: () {
                        if (isDesktop) {
                          Get.dialog(Dialog(child: SavedAddressBottomSheet()));
                        } else {
                          showCustomBottomSheet(
                              child: SavedAddressBottomSheet());
                        }
                      },
                      child: Image.asset(XmarketImages.paymentSelect,
                          height: 24, width: 24),
                    ),
                  ]),
              Divider(
                  height: 25,
                  color:
                      Theme.of(context).disabledColor.withValues(alpha: 0.5)),
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color:
                      Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
                          ? const Color(0xFF141313).withValues(alpha: 0.5)
                          : Colors.white,
                  border: Border.all(
                      color: Get.find<MarketThemeController>(tag: 'xmarket')
                              .darkTheme
                          ? Colors.white10
                          : Theme.of(context).disabledColor,
                      width: 0.3),
                ),
                child: Row(children: [
                  Image.asset(
                    checkoutController.addressType == 'home'
                        ? XmarketImages.homeIcon
                        : checkoutController.addressType == 'office'
                            ? XmarketImages.workIcon
                            : XmarketImages.otherIcon,
                    color: Theme.of(context).primaryColor,
                    height: ResponsiveHelper.isDesktop(context) ? 25 : 20,
                    width: ResponsiveHelper.isDesktop(context) ? 25 : 20,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            checkoutController.addressType.tr,
                            style: robotoMedium.copyWith(
                                color: Get.find<MarketThemeController>(
                                            tag: 'xmarket')
                                        .darkTheme
                                    ? Colors.white70
                                    : Color(0xFF55745a),
                                fontSize: Dimensions.fontSizeDefault),
                          ),
                          const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall),
                          Text(
                            checkoutController.addressController.text,
                            style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Get.find<MarketThemeController>(
                                            tag: 'xmarket')
                                        .darkTheme
                                    ? Colors.white60
                                    : Color(0xFF55745a)),
                          ),
                        ]),
                  ),
                ]),
              ),
            ]),
          )
        else
          const SizedBox(),
      ]);
    });
  }
}
