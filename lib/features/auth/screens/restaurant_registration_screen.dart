import 'dart:convert';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:stackfood_multivendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/restaurant_registration_controller.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/restaurant_body_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/translation_body_model.dart';
import 'package:stackfood_multivendor/features/auth/widgets/select_location_view_widget.dart';
import 'package:stackfood_multivendor/features/business/widgets/base_card_widget.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/xmarket_images.dart';

class RestaurantRegistrationScreen extends StatefulWidget {
  const RestaurantRegistrationScreen({super.key});

  @override
  State<RestaurantRegistrationScreen> createState() =>
      _RestaurantRegistrationScreenState();
}

class _RestaurantRegistrationScreenState
    extends State<RestaurantRegistrationScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final List<TextEditingController> _nameController = [];
  final List<TextEditingController> _addressController = [];

  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final List<FocusNode> _nameFocus = [];
  final List<FocusNode> _addressFocus = [];

  final FocusNode _fNameFocus = FocusNode();
  final FocusNode _lNameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  bool firstTime = true;
  TabController? _tabController;
  final List<Tab> _tabs = [];

  final List<Language>? _languageList =
      Get.find<MarketSplashController>(tag: 'xmarket').configModel!.language;
  String? _countryDialCode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _languageList!.length,
      initialIndex: 0,
      vsync: this,
    );
    _countryDialCode = CountryCode.fromCountryCode(
      Get.find<MarketSplashController>(tag: 'xmarket').configModel!.country!,
    ).dialCode;
    for (var language in _languageList) {
      _nameController.add(TextEditingController());
      _addressController.add(TextEditingController());
      _nameFocus.add(FocusNode());
      _addressFocus.add(FocusNode());
    }

    for (var language in _languageList) {
      _tabs.add(Tab(text: language.value));
    }

    Get.find<RestaurantRegistrationController>().resetData();
    Get.find<RestaurantRegistrationController>().pickImage(false, true);
    Get.find<RestaurantRegistrationController>()
        .setRestaurantAdditionalJoinUsPageData(isUpdate: false);
    Get.find<RestaurantRegistrationController>()
        .storeStatusChange(0.1, isUpdate: false);
    Get.find<CuisineController>().getCuisineList();
    Get.find<RestaurantRegistrationController>().getZoneList();
    Get.find<RestaurantRegistrationController>().resetBusiness();
    Get.find<RestaurantRegistrationController>()
        .getPackageList(isUpdate: false);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantRegistrationController>(
      builder: (restaurantRegController) {
        if (restaurantRegController.restaurantAddress != null &&
            _languageList!.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _addressController[0].text =
                  restaurantRegController.restaurantAddress.toString();
            }
          });
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (restaurantRegController.storeStatus == 0.6 && firstTime) {
              restaurantRegController.storeStatusChange(0.1);
              firstTime = false;
            } else if (restaurantRegController.storeStatus == 0.9) {
              restaurantRegController.storeStatusChange(0.6);
            } else {
              await _showBackPressedDialogue(
                'your_registration_not_setup_yet'.tr,
              );
            }
          },
          child: Scaffold(
            backgroundColor:
                Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
                    ? const Color(0xFF141313)
                    : const Color(0xFFfafef5),
            resizeToAvoidBottomInset: false,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight + 3),
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
                  title: Text(
                    'restaurant_registration'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () async {
                      Get.back();
                    },
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(3),
                    child: Row(
                      children: [
                        Expanded(
                          flex: (restaurantRegController.storeStatus * 100)
                              .toInt(),
                          child: Container(
                            height: 3,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          flex: (100 -
                                  (restaurantRegController.storeStatus * 100))
                              .toInt(),
                          child: Container(
                            height: 3,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeDefault,
                    ),
                    child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: Column(
                        children: [
                          Visibility(
                            visible: restaurantRegController.storeStatus == 0.1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'store_name'.tr,
                                  style: robotoBold.copyWith(
                                      color: Get.find<MarketThemeController>(
                                                  tag: 'xmarket')
                                              .darkTheme
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeSmall,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Get.find<MarketThemeController>(
                                                tag: 'xmarket')
                                            .darkTheme
                                        ? const Color(0xFF1b1b1b)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault - 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: Dimensions.paddingSizeLarge,
                                      ),
                                      CustomTextFieldWidget(
                                        hintText: '${'store_name'.tr} ',
                                        labelText: 'store_name'.tr,
                                        controller: _nameController[
                                            _tabController!.index],
                                        focusNode:
                                            _nameFocus[_tabController!.index],
                                        nextFocus: _tabController!.index !=
                                                _languageList!.length - 1
                                            ? _addressFocus[
                                                _tabController!.index]
                                            : _addressFocus[0],
                                        inputType: TextInputType.name,
                                        capitalization:
                                            TextCapitalization.words,
                                        required: true,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge,
                                ),
                                Text(
                                  'select_work_area'.tr,
                                  style: robotoBold.copyWith(
                                      color: Get.find<MarketThemeController>(
                                                  tag: 'xmarket')
                                              .darkTheme
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeSmall,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Get.find<MarketThemeController>(
                                                tag: 'xmarket')
                                            .darkTheme
                                        ? const Color(0xFF1b1b1b)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault - 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      restaurantRegController.zoneList != null
                                          ? InkWell(
                                              onTap: () {
                                                Get.to(Scaffold(
                                                  backgroundColor:
                                                      Get.find<MarketThemeController>(
                                                                  tag:
                                                                      'xmarket')
                                                              .darkTheme
                                                          ? const Color(
                                                              0xFF141313)
                                                          : Color(0xFFfafef5),
                                                  appBar: AppBar(
                                                      title: Text(
                                                          'set_your_store_location'
                                                              .tr)),
                                                  body:
                                                      SelectLocationViewWidget(
                                                    fromView: false,
                                                    addressController:
                                                        _addressController[0],
                                                    addressFocus:
                                                        _addressFocus[0],
                                                  ),
                                                ));
                                              },
                                              child: Container(
                                                height: 50,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: Dimensions
                                                      .paddingSizeSmall,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(
                                                    context,
                                                  ).cardColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    Dimensions.radiusDefault,
                                                  ),
                                                  border: Border.all(
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor.withValues(
                                                          alpha: 0.5,
                                                        ),
                                                    width: 0.5,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      color: Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                    ),
                                                    const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeSmall,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        'حدد عنوان المتجر',
                                                        style: robotoRegular
                                                            .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .color,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.arrow_forward_ios,
                                                      size: 15,
                                                      color: Theme.of(
                                                        context,
                                                      ).hintColor,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Shimmer(
                                              child: Container(
                                                height: 50,
                                                width: context.width,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(
                                                    context,
                                                  ).shadowColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    Dimensions.radiusDefault,
                                                  ),
                                                ),
                                              ),
                                            ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeLarge,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge,
                                ),
                                Container(
                                  width: context.width,
                                  padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeSmall,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Get.find<MarketThemeController>(
                                                tag: 'xmarket')
                                            .darkTheme
                                        ? const Color(0xFF1b1b1b)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault - 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'store_logo'.tr,
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                                color:
                                                    Get.find<MarketThemeController>(
                                                                tag: 'xmarket')
                                                            .darkTheme
                                                        ? Colors.white
                                                        : Theme.of(
                                                            context,
                                                          )
                                                            .textTheme
                                                            .bodyLarge!
                                                            .color,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '*',
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraSmall,
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeLarge,
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                2,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  Dimensions.radiusDefault,
                                                ),
                                                child: restaurantRegController
                                                            .pickedLogo !=
                                                        null
                                                    ? GetPlatform.isWeb
                                                        ? Image.network(
                                                            restaurantRegController
                                                                .pickedLogo!
                                                                .path,
                                                            width: 120,
                                                            height: 120,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Image.file(
                                                            File(
                                                              restaurantRegController
                                                                  .pickedLogo!
                                                                  .path,
                                                            ),
                                                            width: 120,
                                                            height: 120,
                                                            fit: BoxFit.cover,
                                                          )
                                                    : SizedBox(
                                                        width: 120,
                                                        height: 120,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            CustomAssetImageWidget(
                                                              XmarketImages
                                                                  .pictureIcon,
                                                              height: 30,
                                                              width: 30,
                                                              color: Theme.of(
                                                                context,
                                                              ).hintColor,
                                                            ),
                                                            const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeSmall,
                                                            ),
                                                            Text(
                                                              'click_to_add'.tr,
                                                              style:
                                                                  robotoMedium
                                                                      .copyWith(
                                                                color:
                                                                    Colors.blue,
                                                                fontSize: Dimensions
                                                                    .fontSizeSmall,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              top: 0,
                                              left: 0,
                                              child: InkWell(
                                                onTap: () =>
                                                    restaurantRegController
                                                        .pickImage(
                                                  true,
                                                  false,
                                                ),
                                                child: DottedBorder(
                                                  color: Theme.of(
                                                    context,
                                                  ).hintColor,
                                                  strokeWidth: 1,
                                                  strokeCap: StrokeCap.butt,
                                                  dashPattern: const [
                                                    5,
                                                    5,
                                                  ],
                                                  padding: const EdgeInsets.all(
                                                    0,
                                                  ),
                                                  borderType: BorderType.RRect,
                                                  radius: const Radius.circular(
                                                    Dimensions.radiusDefault,
                                                  ),
                                                  child: const SizedBox(
                                                    width: 120,
                                                    height: 120,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeLarge,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge,
                                ),
                                Container(
                                  width: context.width,
                                  padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeSmall,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Get.find<MarketThemeController>(
                                                tag: 'xmarket')
                                            .darkTheme
                                        ? const Color(0xFF1b1b1b)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault - 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'store_cover_photo'.tr,
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                                color:
                                                    Get.find<MarketThemeController>(
                                                                tag: 'xmarket')
                                                            .darkTheme
                                                        ? Colors.white
                                                        : Theme.of(
                                                            context,
                                                          )
                                                            .textTheme
                                                            .bodyLarge!
                                                            .color,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '*',
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraSmall,
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeLarge,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 40,
                                          right: 40,
                                          top: 20,
                                          bottom: 20,
                                        ),
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                2,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  Dimensions.radiusDefault,
                                                ),
                                                child: restaurantRegController
                                                            .pickedCover !=
                                                        null
                                                    ? GetPlatform.isWeb
                                                        ? Image.network(
                                                            restaurantRegController
                                                                .pickedCover!
                                                                .path,
                                                            width:
                                                                context.width,
                                                            height: 140,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Image.file(
                                                            File(
                                                              restaurantRegController
                                                                  .pickedCover!
                                                                  .path,
                                                            ),
                                                            width:
                                                                context.width,
                                                            height: 140,
                                                            fit: BoxFit.cover,
                                                          )
                                                    : SizedBox(
                                                        width: context.width,
                                                        height: 140,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            CustomAssetImageWidget(
                                                              XmarketImages
                                                                  .pictureIcon,
                                                              height: 30,
                                                              width: 30,
                                                              color: Theme.of(
                                                                context,
                                                              ).hintColor,
                                                            ),
                                                            const SizedBox(
                                                              width: Dimensions
                                                                  .paddingSizeSmall,
                                                            ),
                                                            Text(
                                                              'click_to_add'.tr,
                                                              style:
                                                                  robotoMedium
                                                                      .copyWith(
                                                                color:
                                                                    Colors.blue,
                                                                fontSize: Dimensions
                                                                    .fontSizeSmall,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              top: 0,
                                              left: 0,
                                              child: InkWell(
                                                onTap: () =>
                                                    restaurantRegController
                                                        .pickImage(
                                                  false,
                                                  false,
                                                ),
                                                child: DottedBorder(
                                                  color: Theme.of(
                                                    context,
                                                  ).hintColor,
                                                  strokeWidth: 1,
                                                  strokeCap: StrokeCap.butt,
                                                  dashPattern: const [
                                                    5,
                                                    5,
                                                  ],
                                                  padding: const EdgeInsets.all(
                                                    0,
                                                  ),
                                                  borderType: BorderType.RRect,
                                                  radius: const Radius.circular(
                                                    Dimensions.radiusDefault,
                                                  ),
                                                  child: SizedBox(
                                                    width: context.width,
                                                    height: 140,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeLarge,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: restaurantRegController.storeStatus == 0.6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'owner_information'.tr,
                                  style: robotoBold.copyWith(
                                      color: Get.find<MarketThemeController>(
                                                  tag: 'xmarket')
                                              .darkTheme
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeSmall,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Get.find<MarketThemeController>(
                                                tag: 'xmarket')
                                            .darkTheme
                                        ? const Color(0xFF1b1b1b)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault - 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      CustomTextFieldWidget(
                                        hintText: 'full_name'.tr,
                                        labelText: 'full_name'.tr,
                                        controller: _fNameController,
                                        focusNode: _fNameFocus,
                                        nextFocus: _phoneFocus,
                                        inputType: TextInputType.name,
                                        capitalization:
                                            TextCapitalization.words,
                                        required: true,
                                      ),
                                      const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraLarge,
                                      ),
                                      CustomTextFieldWidget(
                                        hintText: 'enter_phone_number'.tr,
                                        labelText: 'phone_number'.tr,
                                        controller: _phoneController,
                                        focusNode: _phoneFocus,
                                        nextFocus: _passwordFocus,
                                        inputType: TextInputType.phone,
                                        required: true,
                                        showTitle: ResponsiveHelper.isDesktop(
                                          context,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraLarge,
                                ),
                                Text(
                                  'account_information'.tr,
                                  style: robotoBold.copyWith(
                                      color: Get.find<MarketThemeController>(
                                                  tag: 'xmarket')
                                              .darkTheme
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeSmall,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Get.find<MarketThemeController>(
                                                tag: 'xmarket')
                                            .darkTheme
                                        ? const Color(0xFF1b1b1b)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault - 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomTextFieldWidget(
                                        hintText: 'password'.tr,
                                        labelText: 'password'.tr,
                                        controller: _passwordController,
                                        focusNode: _passwordFocus,
                                        nextFocus: _confirmPasswordFocus,
                                        inputType:
                                            TextInputType.visiblePassword,
                                        isPassword: true,
                                        required: true,
                                      ),
                                      const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraLarge,
                                      ),
                                      CustomTextFieldWidget(
                                        hintText: 'confirm_password'.tr,
                                        labelText: 'confirm_password'.tr,
                                        controller: _confirmPasswordController,
                                        focusNode: _confirmPasswordFocus,
                                        inputType:
                                            TextInputType.visiblePassword,
                                        isPassword: true,
                                        required: true,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraLarge,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: restaurantRegController.storeStatus == 0.9,
                            child: (Get.find<MarketSplashController>(
                                                tag: 'xmarket')
                                            .configModel!
                                            .commissionBusinessModel ==
                                        0) &&
                                    (restaurantRegController.packageModel !=
                                            null &&
                                        restaurantRegController
                                            .packageModel!.packages!.isEmpty)
                                ? Padding(
                                    padding: EdgeInsets.only(
                                      top: context.height * 0.3,
                                    ),
                                    child: Text(
                                      'no_subscription_package_is_available'.tr,
                                      style: robotoMedium,
                                    ),
                                  )
                                : Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: Dimensions.paddingSizeLarge,
                                          bottom:
                                              Dimensions.paddingSizeOverLarge,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'choose_your_business_plan'.tr,
                                            style: robotoBold.copyWith(
                                                color:
                                                    Get.find<MarketThemeController>(
                                                                tag: 'xmarket')
                                                            .darkTheme
                                                        ? Colors.white
                                                        : Colors.black),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeLarge,
                                        ),
                                        child: Row(
                                          children: [
                                            Get.find<MarketSplashController>(
                                                            tag: 'xmarket')
                                                        .configModel!
                                                        .commissionBusinessModel !=
                                                    0
                                                ? Expanded(
                                                    child: BaseCardWidget(
                                                      title:
                                                          'commission_base'.tr,
                                                      index: 0,
                                                      onTap: () =>
                                                          restaurantRegController
                                                              .setBusiness(
                                                        0,
                                                      ),
                                                      restaurantRegistrationController:
                                                          restaurantRegController,
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeDefault,
                                            ),
                                            (Get.find<MarketSplashController>(
                                                                tag: 'xmarket')
                                                            .configModel!
                                                            .subscriptionBusinessModel !=
                                                        0) &&
                                                    (restaurantRegController
                                                                .packageModel !=
                                                            null &&
                                                        restaurantRegController
                                                            .packageModel!
                                                            .packages!
                                                            .isNotEmpty)
                                                ? Expanded(
                                                    child: BaseCardWidget(
                                                      title: 'subscription_base'
                                                          .tr,
                                                      index: 1,
                                                      onTap: () =>
                                                          restaurantRegController
                                                              .setBusiness(
                                                        1,
                                                      ),
                                                      restaurantRegistrationController:
                                                          restaurantRegController,
                                                    ),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraLarge,
                                      ),
                                      restaurantRegController.businessIndex == 0
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal:
                                                    Dimensions.paddingSizeLarge,
                                              ),
                                              child: RichText(
                                                text: TextSpan(
                                                  style: robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color: Theme.of(
                                                      context,
                                                    )
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color
                                                        ?.withValues(
                                                          alpha: 0.7,
                                                        ),
                                                  ),
                                                  children: [
                                                    const TextSpan(
                                                      text:
                                                          "يتم احتساب ٥٪  عموله لتطبيق X Ride من كل اوردر اذا كان لديك اي ملاحظات او استفسارات يمكنك التواصل مع خدمة العملاء علي هذا الرقم ",
                                                    ),
                                                    TextSpan(
                                                      text: "01000052154",
                                                      style:
                                                          robotoBold.copyWith(
                                                        color: Colors.blue,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () async {
                                                              final Uri
                                                                  launchUri =
                                                                  Uri(
                                                                scheme: 'tel',
                                                                path:
                                                                    '01000052154',
                                                              );
                                                              if (await canLaunchUrl(
                                                                launchUri,
                                                              )) {
                                                                await launchUrl(
                                                                  launchUri,
                                                                );
                                                              }
                                                            },
                                                    ),
                                                  ],
                                                ),
                                                textAlign: TextAlign.justify,
                                                textScaler:
                                                    const TextScaler.linear(
                                                  1.1,
                                                ),
                                              ),
                                            )
                                          : (restaurantRegController
                                                          .packageModel !=
                                                      null &&
                                                  restaurantRegController
                                                      .packageModel!
                                                      .packages!
                                                      .isNotEmpty)
                                              ? Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: Dimensions
                                                          .paddingSizeLarge),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .all(Dimensions
                                                            .paddingSizeSmall),
                                                    child: Text.rich(
                                                      TextSpan(
                                                        style: robotoRegular
                                                            .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          color: Theme.of(context)
                                                                      .brightness ==
                                                                  Brightness
                                                                      .dark
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                "اشتراك شهري قيمته ${PriceConverter.convertPrice(restaurantRegController.packageModel!.packages![restaurantRegController.activeSubscriptionIndex].price, forDM: true)} اذا كان لديك اي استفسار يمكن التواصل مع الاداره من خلال هذا الرقم ",
                                                          ),
                                                          TextSpan(
                                                            text: "01000052154",
                                                            style: robotoBold
                                                                .copyWith(
                                                              color:
                                                                  Colors.blue,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                            ),
                                                            recognizer:
                                                                TapGestureRecognizer()
                                                                  ..onTap =
                                                                      () async {
                                                                    final Uri
                                                                        launchUri =
                                                                        Uri(
                                                                      scheme:
                                                                          'tel',
                                                                      path:
                                                                          '01000052154',
                                                                    );
                                                                    if (await canLaunchUrl(
                                                                        launchUri)) {
                                                                      await launchUrl(
                                                                          launchUri);
                                                                    }
                                                                  },
                                                          ),
                                                        ],
                                                      ),
                                                      textAlign:
                                                          TextAlign.justify,
                                                      textScaler:
                                                          const TextScaler
                                                              .linear(1.1),
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ((restaurantRegController.storeStatus == 0.9) &&
                        (Get.find<MarketSplashController>(tag: 'xmarket')
                                .configModel!
                                .commissionBusinessModel ==
                            0) &&
                        (restaurantRegController.packageModel != null &&
                            restaurantRegController
                                .packageModel!.packages!.isEmpty))
                    ? const SizedBox()
                    : !restaurantRegController.isLoading
                        ? Container(
                            width: context.width,
                            padding: const EdgeInsets.all(
                              Dimensions.paddingSizeDefault,
                            ),
                            decoration: BoxDecoration(
                              color: Get.find<MarketThemeController>(
                                          tag: 'xmarket')
                                      .darkTheme
                                  ? const Color(0xFF1b1b1b)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusSmall,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: CustomButtonWidget(
                              buttonText: restaurantRegController.storeStatus ==
                                          0.1 ||
                                      restaurantRegController.storeStatus == 0.6
                                  ? 'next'.tr
                                  : 'submit'.tr,
                              color: Color(0xFF9ebc67),
                              textColor: Colors.white,
                              onPressed: () {
                                bool defaultNameNull = false;
                                bool defaultAddressNull = false;
                                bool customFieldEmpty = false;

                                for (int index = 0;
                                    index < _languageList.length;
                                    index++) {
                                  if (_languageList[index].key == 'en') {
                                    if (_nameController[index]
                                        .text
                                        .trim()
                                        .isEmpty) {
                                      defaultNameNull = true;
                                    }
                                    if (_addressController[index]
                                        .text
                                        .trim()
                                        .isEmpty) {
                                      defaultAddressNull = true;
                                    }
                                    break;
                                  }
                                }

                                Map<String, dynamic> additionalData = {};
                                List<FilePickerResult> additionalDocuments = [];
                                List<String> additionalDocumentsInputType = [];

                                if (restaurantRegController.storeStatus !=
                                    0.1) {
                                  for (DataModel data
                                      in restaurantRegController.dataList!) {
                                    bool isTextField =
                                        data.fieldType == 'text' ||
                                            data.fieldType == 'number' ||
                                            data.fieldType == 'email' ||
                                            data.fieldType == 'phone';
                                    bool isDate = data.fieldType == 'date';
                                    bool isCheckBox =
                                        data.fieldType == 'check_box';
                                    bool isFile = data.fieldType == 'file';
                                    int index = restaurantRegController
                                        .dataList!
                                        .indexOf(data);
                                    bool isRequired = data.isRequired == 1;

                                    if (isTextField) {
                                      if (restaurantRegController
                                              .additionalList![index].text !=
                                          '') {
                                        additionalData.addAll({
                                          data.inputData!:
                                              restaurantRegController
                                                  .additionalList![index].text
                                        });
                                      } else if (isRequired) {
                                        customFieldEmpty = true;
                                        showCustomSnackBar(
                                            '${data.placeholderData} ${'can_not_be_empty'.tr}');
                                        break;
                                      }
                                    } else if (isDate) {
                                      if (restaurantRegController
                                              .additionalList![index] !=
                                          null) {
                                        additionalData.addAll({
                                          data.inputData!:
                                              restaurantRegController
                                                  .additionalList![index]
                                        });
                                      } else if (isRequired) {
                                        customFieldEmpty = true;
                                        showCustomSnackBar(
                                            '${data.placeholderData} ${'can_not_be_empty'.tr}');
                                        break;
                                      }
                                    } else if (isCheckBox) {
                                      List<String> checkData = [];
                                      for (var e in restaurantRegController
                                          .additionalList![index]) {
                                        if (e != 0) checkData.add(e);
                                      }
                                      if (checkData.isEmpty && isRequired) {
                                        customFieldEmpty = true;
                                        showCustomSnackBar(
                                            '${'please_set_data_in'.tr} ${restaurantRegController.dataList![index].inputData!.replaceAll('_', ' ')} ${'field'.tr}');
                                        break;
                                      } else {
                                        additionalData.addAll(
                                            {data.inputData!: checkData});
                                      }
                                    } else if (isFile) {
                                      if (restaurantRegController
                                              .additionalList![index].isEmpty &&
                                          isRequired) {
                                        customFieldEmpty = true;
                                        showCustomSnackBar(
                                            '${'please_add'.tr} ${restaurantRegController.dataList![index].inputData!.replaceAll('_', ' ')}');
                                        break;
                                      } else {
                                        for (var file in restaurantRegController
                                            .additionalList![index]) {
                                          additionalDocuments.add(file);
                                          additionalDocumentsInputType.add(
                                              restaurantRegController
                                                  .dataList![index].inputData!);
                                        }
                                      }
                                    }
                                  }
                                }

                                String tin = '';
                                String minTime = '30';
                                String maxTime = '60';
                                String fName = _fNameController.text.trim();
                                String lName = _lNameController.text.trim();
                                String phone = _phoneController.text.trim();
                                String email = _emailController.text.trim();
                                String password =
                                    _passwordController.text.trim();
                                String confirmPassword =
                                    _confirmPasswordController.text.trim();
                                String phoneWithCountryCode =
                                    _countryDialCode != null
                                        ? _countryDialCode! + phone
                                        : phone;
                                if (phoneWithCountryCode.startsWith('+20')) {
                                  phoneWithCountryCode =
                                      '0${phoneWithCountryCode.substring(3)}';
                                } else if (phoneWithCountryCode
                                    .startsWith('20')) {
                                  phoneWithCountryCode =
                                      '0${phoneWithCountryCode.substring(2)}';
                                } else if (phoneWithCountryCode
                                    .startsWith('+2')) {
                                  phoneWithCountryCode =
                                      phoneWithCountryCode.substring(2);
                                } else if (phoneWithCountryCode
                                        .startsWith('2') &&
                                    phoneWithCountryCode.length > 10) {
                                  phoneWithCountryCode =
                                      phoneWithCountryCode.substring(1);
                                }

                                if (phoneWithCountryCode.startsWith('00')) {
                                  phoneWithCountryCode =
                                      phoneWithCountryCode.substring(1);
                                }
                                debugPrint(
                                    '🛰️🛰️🛰️ SANITIZED PHONE: $phoneWithCountryCode');

                                if (restaurantRegController.storeStatus ==
                                        0.1 ||
                                    restaurantRegController.storeStatus ==
                                        0.6) {
                                  if (restaurantRegController.storeStatus ==
                                      0.1) {
                                    if (defaultNameNull) {
                                      showCustomSnackBar(
                                          'enter_restaurant_name'.tr);
                                      FocusScope.of(context)
                                          .requestFocus(_nameFocus[0]);
                                    } else if (restaurantRegController
                                            .selectedZoneIndex ==
                                        -1) {
                                      showCustomSnackBar(
                                          'please_select_zone'.tr);
                                    } else if (restaurantRegController
                                            .restaurantLocation ==
                                        null) {
                                      showCustomSnackBar(
                                          'set_restaurant_location'.tr);
                                    } else if (defaultAddressNull) {
                                      showCustomSnackBar(
                                          'enter_restaurant_address'.tr);
                                      FocusScope.of(context)
                                          .requestFocus(_addressFocus[0]);
                                    } else if (restaurantRegController
                                            .pickedLogo ==
                                        null) {
                                      showCustomSnackBar(
                                          'select_restaurant_logo'.tr);
                                    } else if (restaurantRegController
                                            .pickedCover ==
                                        null) {
                                      showCustomSnackBar(
                                          'select_restaurant_cover_photo'.tr);
                                    } else {
                                      _scrollController.jumpTo(_scrollController
                                          .position.minScrollExtent);
                                      restaurantRegController
                                          .storeStatusChange(0.6);
                                      firstTime = true;
                                    }
                                  } else if (restaurantRegController
                                          .storeStatus ==
                                      0.6) {
                                    if (fName.isEmpty) {
                                      showCustomSnackBar(
                                          'enter_your_first_name'.tr);
                                      FocusScope.of(context)
                                          .requestFocus(_fNameFocus);
                                    } else if (phone.isEmpty) {
                                      showCustomSnackBar(
                                          'enter_your_phone_number'.tr);
                                      FocusScope.of(context)
                                          .requestFocus(_phoneFocus);
                                    } else if (password.isEmpty) {
                                      showCustomSnackBar('enter_password'.tr);
                                      FocusScope.of(context)
                                          .requestFocus(_passwordFocus);
                                    } else if (password != confirmPassword) {
                                      showCustomSnackBar(
                                          'confirm_password_does_not_matched'
                                              .tr);
                                      FocusScope.of(context)
                                          .requestFocus(_confirmPasswordFocus);
                                    } else if (customFieldEmpty) {
                                      if (kDebugMode) {
                                        print('Missing additional data');
                                      }
                                    } else {
                                      _scrollController.jumpTo(_scrollController
                                          .position.minScrollExtent);
                                      restaurantRegController
                                          .storeStatusChange(0.9);
                                    }
                                  }
                                } else {
                                  List<TranslationBodyModel> translation = [];
                                  for (int index = 0;
                                      index < _languageList.length;
                                      index++) {
                                    translation.add(TranslationBodyModel(
                                      locale: _languageList[index].key,
                                      key: 'name',
                                      value: _nameController[index]
                                              .text
                                              .trim()
                                              .isNotEmpty
                                          ? _nameController[index].text.trim()
                                          : _nameController[0].text.trim(),
                                    ));
                                    translation.add(TranslationBodyModel(
                                      locale: _languageList[index].key,
                                      key: 'address',
                                      value: _addressController[index]
                                              .text
                                              .trim()
                                              .isNotEmpty
                                          ? _addressController[index]
                                              .text
                                              .trim()
                                          : _addressController[0].text.trim(),
                                    ));
                                  }

                                  List<String> cuisines = [];
                                  Map<String, String> data = {};
                                  data.addAll(RestaurantBodyModel(
                                    deliveryTimeType: 'minute',
                                    translation: jsonEncode(translation),
                                    minDeliveryTime: minTime,
                                    maxDeliveryTime: maxTime,
                                    lat: restaurantRegController
                                        .restaurantLocation!.latitude
                                        .toString(),
                                    lng: restaurantRegController
                                        .restaurantLocation!.longitude
                                        .toString(),
                                    email: email,
                                    fName: fName,
                                    lName: lName,
                                    phone: phoneWithCountryCode,
                                    password: password,
                                    zoneId: restaurantRegController
                                        .zoneList![restaurantRegController
                                            .selectedZoneIndex!]
                                        .id
                                        .toString(),
                                    cuisineId: cuisines,
                                    businessPlan:
                                        restaurantRegController.businessIndex ==
                                                0
                                            ? 'commission'
                                            : 'subscription',
                                    packageId: (restaurantRegController
                                                .packageModel
                                                ?.packages
                                                ?.isNotEmpty ??
                                            false)
                                        ? restaurantRegController
                                            .packageModel!
                                            .packages![restaurantRegController
                                                .activeSubscriptionIndex]
                                            .id!
                                            .toString()
                                        : '',
                                    tin: tin,
                                    tinExpireDate:
                                        restaurantRegController.tinExpireDate,
                                  ).toJson());

                                  data.addAll({
                                    'additional_data':
                                        jsonEncode(additionalData)
                                  });

                                  restaurantRegController.registerRestaurant(
                                      data,
                                      additionalDocuments,
                                      additionalDocumentsInputType);
                                }
                              },
                            ),
                          )
                        : const Center(
                            child: Padding(
                                padding: EdgeInsets.all(
                                    Dimensions.paddingSizeDefault),
                                child: CircularProgressIndicator(
                                  color: Color(0xFF9ebc67),
                                ))),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showBackPressedDialogue(String title) async {
    Get.dialog(
      ConfirmationDialogWidget(
        icon: XmarketImages.support,
        title: title,
        description: 'are_you_sure_to_go_back'.tr,
        isLogOut: true,
        onYesPressed: () =>
            Get.offAllNamed(RouteHelper.getSignInRoute('registration')),
      ),
      useSafeArea: false,
    );
  }
}
