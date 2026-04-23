import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_card.dart';
import 'package:stackfood_multivendor/common/widgets/app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/body_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/dashboard/screens/dashboard_screen.dart';
import 'package:stackfood_multivendor/features/menu/widgets/portion_widget.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/features/auth/screens/sign_in_screen.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/support/screens/complaints_suggestions_screen.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/xmarket_images.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isRightSide = Get.find<MarketSplashController>(tag: 'xmarket')
            .configModel!
            .currencySymbolDirection ==
        'right';

    return GetBuilder<MarketThemeController>(
      init: Get.find<MarketThemeController>(tag: 'xmarket'),
      builder: (marketThemeController) {
        return Theme(
          data: marketThemeController.darkTheme ? darkTheme : lightTheme,
          child: Scaffold(
            backgroundColor: marketThemeController.darkTheme
                ? Colors.black
                : Color(0xFFfafef5),
            body: GetBuilder<MarketProfileController>(
              builder: (profileController) {
                return GetBuilder<MarketSplashController>(
                  tag: 'xmarket',
                  builder: (splashController) {
                    bool isLoggedIn =
                        Get.find<MarketAuthController>().isLoggedIn();
                    final configModel = splashController.configModel;

                    return BodyWidget(
                      appBar: AppBarWidget(
                          title: ' القائمة الرئيسية', showBackButton: false),
                      body: SingleChildScrollView(
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: Column(children: [
                          Stack(clipBehavior: Clip.none, children: [
                            Container(
                              height: 180,
                              width: Get.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusExtraLarge),
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.black
                                    : Colors.white,
                              ),
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeSmall),
                                      child: Row(children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: (Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black)
                                                    .withAlpha(9),
                                                width: 1),
                                          ),
                                          child: ClipOval(
                                              child: CustomImageWidget(
                                            placeholder: isLoggedIn
                                                ? XmarketImages
                                                    .profilePlaceholder
                                                : XmarketImages.guestIcon,
                                            image:
                                                '${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.imageFullUrl : ''}',
                                            height: 70,
                                            width: 70,
                                            fit: BoxFit.cover,
                                            imageColor: isLoggedIn
                                                ? null
                                                : Theme.of(context).hintColor,
                                          )),
                                        ),
                                        const SizedBox(
                                            width: Dimensions.paddingSizeSmall),
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: Get.width * 0.5,
                                                child: Text(
                                                  isLoggedIn
                                                      ? '${profileController.userInfoModel?.fName} ${profileController.userInfoModel?.lName}'
                                                      : 'guest_user'.tr,
                                                  style: robotoBold.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeExtraLarge,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .color!
                                                          .withValues(
                                                              alpha: 0.9)),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeExtraSmall),
                                              // if (isLoggedIn &&
                                              //     profileController.userInfoModel !=
                                              //         null)
                                              //   Text(
                                              //     DateConverter
                                              //         .containTAndZToUTCFormat(
                                              //             profileController
                                              //                 .userInfoModel!
                                              //                 .createdAt!),
                                              //     style: robotoMedium.copyWith(
                                              //       color: Theme.of(context)
                                              //           .textTheme
                                              //           .bodyMedium!
                                              //           .color!
                                              //           .withValues(alpha: 0.8),
                                              //       fontSize:
                                              //           Dimensions.fontSizeSmall,
                                              //     ),
                                              //   ),
                                              // Text(
                                              //   'Version 2.0',
                                              //   style: robotoMedium.copyWith(
                                              //     fontSize: Dimensions.fontSizeSmall,
                                              //     color: Colors.black
                                              //         .withValues(alpha: 0.5),
                                              //   ),
                                              // ),
                                            ]),
                                      ]),
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(children: [
                                              Text(
                                                  '${profileController.userInfoModel?.orderCount ?? 0}',
                                                  style: robotoBold.copyWith(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        :Color(0xFF55745a),
                                                    fontSize: Dimensions
                                                        .fontSizeExtraLarge,
                                                  )),
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeExtraSmall),
                                              Text('total_order'.tr,
                                                  style: robotoMedium.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeSmall,
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Color(0xFF55745a))),
                                            ]),
                                          ),
                                          Container(
                                              width: 1,
                                              height: 40,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black),
                                          Expanded(
                                            child: Column(children: [
                                              Text(
                                                  '${profileController.userInfoModel?.loyaltyPoint ?? 0}',
                                                  style: robotoBold.copyWith(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Color(0xFF55745a),
                                                    fontSize: Dimensions
                                                        .fontSizeExtraLarge,
                                                  )),
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeExtraSmall),
                                              Text('loyalty_point'.tr,
                                                  style: robotoMedium.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeSmall,
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Color(0xFF55745a))),
                                            ]),
                                          ),
                                          Container(
                                              width: 1,
                                              height: 40,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black),
                                          Expanded(
                                            child: Column(children: [
                                              Text(
                                                  '${profileController.userInfoModel?.walletBalance?.toStringAsFixed(0) ?? 0}',
                                                  style: robotoBold.copyWith(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Color(0xFF55745a),
                                                    fontSize: Dimensions
                                                        .fontSizeExtraLarge,
                                                  )),
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeExtraSmall),
                                              Text('wallet'.tr,
                                                  style: robotoMedium.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeSmall,
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Color(0xFF55745a))),
                                            ]),
                                          ),
                                        ]),
                                  ]),
                            ),
                            if (isLoggedIn)
                              Positioned(
                                  child: Align(
                                      alignment: Alignment.topRight,
                                      child: InkWell(
                                        onTap: () => Get.toNamed(RouteHelper
                                            .getUpdateProfileRoute()),
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                              Dimensions.paddingSizeDefault),
                                          child: SizedBox(
                                              width: 20,
                                              child: Icon(Icons.edit,
                                                  size: 20,
                                                  color: Colors.black54)),
                                        ),
                                      )))
                          ]),
                          const SizedBox(
                              height: Dimensions.paddingSizeExtraLarge),
                          if (!isLoggedIn)
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: Dimensions.paddingSizeLarge),
                              child: CustomButtonWidget(
                                buttonText: '${'login'.tr}/ ${'signup'.tr}',
                                height: 45,
                                onPressed: () async {
                                  if (!isDesktop) {
                                    Get.toNamed(RouteHelper.getSignInRoute(
                                            Get.currentRoute))
                                        ?.then((value) {
                                      if (AuthHelper.isLoggedIn()) {
                                        profileController.getUserInfo();
                                      }
                                    });
                                  } else {
                                    Get.dialog(const SignInScreen(
                                            exitFromApp: true,
                                            backFromThis: true))
                                        .then((value) {
                                      if (AuthHelper.isLoggedIn()) {
                                        profileController.getUserInfo();
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          // SizedBox(
                          //     height:
                          //         isLoggedIn ? Dimensions.paddingSizeSmall : 0),
                          // Text(
                          //   'general'.tr,
                          //   style: robotoSemiBold.copyWith(
                          //       fontSize: Dimensions.fontSizeDefault,
                          //       color: Theme.of(context).hintColor),
                          // ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          CustomCard(
                            borderColor: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1),
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeLarge,
                                vertical: Dimensions.paddingSizeDefault),
                            child: Column(children: [
                              // isLoggedIn
                              //     ? PortionWidget(
                              //         icon: Images.editProfileIcon,
                              //         title: 'edit_profile'.tr,
                              //         hideDivider: isLoggedIn ? false : true,
                              //         route: RouteHelper.getUpdateProfileRoute())
                              //     : SizedBox(),
                              PortionWidget(
                                  icon: Icons.favorite_border_outlined,
                                  title: 'wishlist'.tr,
                                  route: RouteHelper.getFavouriteScreen()),
                              PortionWidget(
                                  icon: XmarketImages.addressIcon,
                                  title: 'my_address'.tr,
                                  route: RouteHelper.getAddressRoute()),
                              PortionWidget(
                                  icon: XmarketImages.settingsIcon,
                                  title: 'settings'.tr,
                                  hideDivider: true,
                                  route: RouteHelper.getSettingsRoute()),
                            ]),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          // Text(
                          //   'promotional_activity'.tr,
                          //   style: robotoSemiBold.copyWith(
                          //       fontSize: Dimensions.fontSizeDefault,
                          //       color: Theme.of(context).hintColor),
                          // ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          CustomCard(
                            borderColor: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1),
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeLarge,
                                vertical: Dimensions.paddingSizeDefault),
                            child: Column(children: [
                               PortionWidget(
                                  icon: XmarketImages.couponIcon,
                                  title: 'coupon'.tr,
                                  route: RouteHelper.getCouponRoute(
                                      fromCheckout: false)),
                              PortionWidget(
                                  icon: Icons.shopping_cart_checkout_rounded,
                                  title: 'خطط تسويقية',
                                  route: RouteHelper.getShoppingPlansRoute()),
                              configModel!.loyaltyPointStatus!
                                  ? PortionWidget(
                                      icon: XmarketImages.pointIcon,
                                      title: 'loyalty_points'.tr,
                                      route: RouteHelper.getLoyaltyRoute(),
                                      hideDivider:
                                          configModel.customerWalletStatus!
                                              ? false
                                              : true,
                                      suffix: !isLoggedIn
                                          ? null
                                          : '${profileController.userInfoModel?.loyaltyPoint != null ? Get.find<MarketProfileController>().userInfoModel!.loyaltyPoint.toString() : '0'} ${'points'.tr}',
                                    )
                                  : const SizedBox(),
                              configModel.customerWalletStatus!
                                  ? PortionWidget(
                                      icon: XmarketImages.walletIcon,
                                      title: 'my_wallet'.tr,
                                      hideDivider: true,
                                      route: RouteHelper.getWalletRoute(
                                          fromMenuPage: true),
                                      suffix: !isLoggedIn
                                          ? null
                                          : PriceConverter.convertPrice(
                                              profileController.userInfoModel !=
                                                      null
                                                  ? Get.find<
                                                          MarketProfileController>()
                                                      .userInfoModel!
                                                      .walletBalance
                                                  : 0),
                                    )
                                  : const SizedBox(),
                            ]),
                          ),
                          configModel.refEarningStatus! ||
                                  (configModel.toggleDmRegistration! &&
                                      !isDesktop) ||
                                  (configModel.toggleRestaurantRegistration! &&
                                      !isDesktop)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      const SizedBox(
                                          height:
                                              Dimensions.paddingSizeDefault),
                                      Text(
                                        'join_us'.tr,
                                        style: robotoSemiBold.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color: Theme.of(context).hintColor),
                                      ),
                                      const SizedBox(
                                          height: Dimensions.paddingSizeSmall),
                                      CustomCard(
                                        borderColor: Theme.of(context)
                                            .primaryColor
                                            .withValues(alpha: 0.1),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeLarge,
                                            vertical:
                                                Dimensions.paddingSizeDefault),
                                        child: Column(children: [
                                          // configModel.refEarningStatus!
                                          //     ? PortionWidget(
                                          //         icon: Images.referIcon,
                                          //         title: 'refer_and_earn'.tr,
                                          //         route: RouteHelper
                                          //             .getReferAndEarnRoute(),
                                          //       )
                                          //     : const SizedBox(),
                                          (configModel.toggleDmRegistration! &&
                                                  !isDesktop)
                                              ? PortionWidget(
                                                  icon: XmarketImages.dmIcon,
                                                  title:
                                                      'join_as_a_delivery_man'
                                                          .tr,
                                                  route: RouteHelper
                                                      .getDeliverymanRegistrationRoute(),
                                                )
                                              : const SizedBox(),
                                          (configModel.toggleRestaurantRegistration! &&
                                                  !isDesktop)
                                              ? PortionWidget(
                                                  icon: XmarketImages.storeIcon,
                                                  title: 'open_store'.tr,
                                                  hideDivider: true,
                                                  route: RouteHelper
                                                      .getRestaurantRegistrationRoute(),
                                                )
                                              : const SizedBox(),
                                        ]),
                                      ),
                                      const SizedBox(
                                          height:
                                              Dimensions.paddingSizeDefault),
                                    ])
                              : const SizedBox(),
                          Text(
                            'help_and_support'.tr,
                            style: robotoSemiBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).hintColor),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          CustomCard(
                            borderColor: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1),
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeLarge,
                                vertical: Dimensions.paddingSizeDefault),
                            child: Column(children: [
                              PortionWidget(
                                  icon: XmarketImages.chatIcon,
                                  title: 'live_chat'.tr,
                                  route: RouteHelper.getConversationRoute()),
                              PortionWidget(
                                  icon: XmarketImages.helpIcon,
                                  title: 'help_and_support'.tr,
                                  route: RouteHelper.getSupportRoute()),
                              PortionWidget(
                                icon: XmarketImages.helpAndSupportBg,
                                title: 'الشكاوي والاقتراحات',
                                hideDivider: true,
                                route: '',
                                onTap: () => Get.to(
                                    () => const ComplaintsSuggestionsScreen()),
                              ),

                              // PortionWidget(
                              //     icon: Images.aboutIcon,
                              //     title: 'about_us'.tr,
                              //     route: RouteHelper.getAboutUsRoute()),
                              // PortionWidget(
                              //     icon: Images.termsIcon,
                              //     title: 'terms_conditions'.tr,
                              //     route: RouteHelper.getTermsAndConditionRoute()),
                              // PortionWidget(
                              //     icon: Images.privacyIcon,
                              //     title: 'privacy_policy'.tr,
                              //     route: RouteHelper.getPrivacyPolicyRoute()),
                              configModel.refundPolicyStatus!
                                  ? PortionWidget(
                                      icon: XmarketImages.refundIcon,
                                      title: 'refund_policy'.tr,
                                      route: RouteHelper.getRefundPolicyRoute(),
                                    )
                                  : const SizedBox(),
                              configModel.cancellationPolicyStatus!
                                  ? PortionWidget(
                                      icon: XmarketImages.cancelationIcon,
                                      title: 'cancellation_policy'.tr,
                                      route: RouteHelper
                                          .getCancellationPolicyRoute(),
                                    )
                                  : const SizedBox(),
                              configModel.shippingPolicyStatus!
                                  ? PortionWidget(
                                      icon: XmarketImages.shippingIcon,
                                      title: 'shipping_policy'.tr,
                                      hideDivider: true,
                                      route:
                                          RouteHelper.getShippingPolicyRoute(),
                                    )
                                  : const SizedBox(),
                            ]),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          // isLoggedIn
                          //     ? InkWell(
                          //         onTap: () async {
                          //           Get.dialog(
                          //               ConfirmationDialogWidget(
                          //                   icon: Images.support,
                          //                   description:
                          //                       'are_you_sure_to_logout'.tr,
                          //                   isLogOut: true,
                          //                   onYesPressed: () async {
                          //                     // Get.to(SignInScreen(
                          //                     //     exitFromApp: false,
                          //                     //     backFromThis: false));
                          //                     Get.to(XRideDashboardScreen());
                          //                     //   Get.find<MarketProfileController>()
                          //                     //       .setForceFullyUserEmpty();
                          //                     //   // Get.find<MarketAuthController>().socialLogout();
                          //                     //   Get.find<MarketAuthController>()
                          //                     //       .resetOtpView();
                          //                     //   Get.find<MarketCartController>()
                          //                     //       .clearCartList();
                          //                     //   Get.find<FavouriteController>()
                          //                     //       .removeFavourites();
                          //                     //   await Get.find<MarketAuthController>()
                          //                     //       .clearSharedData();
                          //                     //   Get.offAllNamed(
                          //                     //       RouteHelper.getInitialRoute());
                          //                   }),
                          //               useSafeArea: false);
                          //         },
                          //         child: Padding(
                          //           padding: const EdgeInsets.symmetric(
                          //               vertical: Dimensions.paddingSizeSmall),
                          //           child: Row(
                          //               mainAxisAlignment: MainAxisAlignment.center,
                          //               children: [
                          //                 Container(
                          //                   padding: const EdgeInsets.all(2),
                          //                   decoration: const BoxDecoration(
                          //                       shape: BoxShape.circle,
                          //                       color: Colors.red),
                          //                   child: Icon(
                          //                       Icons.power_settings_new_sharp,
                          //                       size: 14,
                          //                       color: Theme.of(context).cardColor),
                          //                 ),
                          //                 const SizedBox(
                          //                     width:
                          //                         Dimensions.paddingSizeExtraSmall),
                          //                 Text('logout'.tr, style: robotoMedium),
                          //               ]),
                          //         ),
                          //       )
                          //     : SizedBox(),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          GetBuilder<MarketSplashController>(
                              tag: 'xmarket',
                              builder: (splashController) {
                                return splashController.configModel != null &&
                                        splashController
                                                .configModel!.socialMedia !=
                                            null &&
                                        splashController.configModel!
                                            .socialMedia!.isNotEmpty
                                    ? Column(children: [
                                        Text('follow_us_on'.tr,
                                            style: robotoRegular.copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color,
                                                fontSize:
                                                    Dimensions.fontSizeSmall)),
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeSmall),
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                padding: EdgeInsets.zero,
                                                itemCount: splashController
                                                    .configModel!
                                                    .socialMedia!
                                                    .length,
                                                itemBuilder: (context, index) {
                                                  String? name =
                                                      splashController
                                                          .configModel!
                                                          .socialMedia![index]
                                                          .name;
                                                  print("nameeeeeeeee$name");
                                                  late String icon;
                                                  if (name == 'facebook') {
                                                    icon =
                                                        XmarketImages.facebook;
                                                  } else if (name ==
                                                      'linkedin') {
                                                    icon =
                                                        XmarketImages.linkedin;
                                                  } else if (name ==
                                                      'youtube') {
                                                    icon =
                                                        XmarketImages.youtube;
                                                  } else if (name ==
                                                      'twitter') {
                                                    icon =
                                                        XmarketImages.twitter;
                                                  } else if (name ==
                                                      'instagram') {
                                                    icon =
                                                        XmarketImages.instagram;
                                                  } else if (name ==
                                                      'pinterest') {
                                                    icon =
                                                        XmarketImages.pinterest;
                                                  }
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeExtraSmall),
                                                    child: InkWell(
                                                      onTap: () async {
                                                        String url =
                                                            splashController
                                                                .configModel!
                                                                .socialMedia![
                                                                    index]
                                                                .link!;
                                                        if (!url.startsWith(
                                                            'https://')) {
                                                          url = 'https://$url';
                                                        }
                                                        url = url.replaceFirst(
                                                            'www.', '');
                                                        if (await canLaunchUrlString(
                                                            url)) {
                                                          await launchUrlString(
                                                              url,
                                                              mode: LaunchMode
                                                                  .externalApplication);
                                                        }
                                                      },
                                                      child: Image.asset(icon,
                                                          height: 30,
                                                          width: 30,
                                                          fit: BoxFit.contain,
                                                          color: Theme.of(context)
                                                                      .brightness ==
                                                                  Brightness
                                                                      .dark
                                                              ? Colors.white
                                                              : Colors.black),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )),
                                      ])
                                    : const SizedBox();
                              }),

                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          GetBuilder<MarketSplashController>(
                              tag: 'xmarket',
                              builder: (splashController) {
                                return (splashController.configModel != null &&
                                        splashController
                                                .configModel!.footerText !=
                                            null &&
                                        splashController.configModel!
                                            .footerText!.isNotEmpty)
                                    ? Center(
                                        child: Text(
                                          '© ${splashController.configModel!.footerText}',
                                          style: robotoRegular.copyWith(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Color(0xFF55745a),
                                            fontSize:
                                                Dimensions.fontSizeExtraSmall,
                                          ),
                                        ),
                                      )
                                    : const SizedBox();
                              }),

                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          if (isLoggedIn)
                            InkWell(
                              onTap: () {
                                Get.dialog(
                                  ConfirmationDialogWidget(
                                    icon: XmarketImages.logOut,
                                    description: 'are_you_sure_to_logout'.tr,
                                    isLogOut: true,
                                    onYesPressed: () async {
                                      Get.find<MarketAuthController>()
                                          .clearSharedData();
                                      Get.find<MarketProfileController>()
                                          .setForceFullyUserEmpty();
                                      Get.offAllNamed(
                                          RouteHelper.getSignInRoute(
                                              RouteHelper.initial));
                                    },
                                  ),
                                  useSafeArea: false,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.paddingSizeSmall),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF9ebc67)),
                                        child: Icon(
                                            Icons.power_settings_new_sharp,
                                            size: 14,
                                            color: Theme.of(context).cardColor),
                                      ),
                                      const SizedBox(
                                          width:
                                              Dimensions.paddingSizeExtraSmall),
                                      Text('logout'.tr, style: robotoMedium),
                                    ]),
                              ),
                            ),

                          const SizedBox(height: Dimensions.paddingSizeLarge),
                        ]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
