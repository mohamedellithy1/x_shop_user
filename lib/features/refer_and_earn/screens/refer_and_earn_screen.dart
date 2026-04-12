import 'package:stackfood_multivendor/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/refer_and_earn/controllers/refer_and_earn_controller.dart';
import 'package:stackfood_multivendor/features/refer_and_earn/widgets/bottom_sheet_view_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  @override
  void initState() {
    super.initState();
    _initCall();
  }

  void _initCall() {
    Get.find<MarketReferAndEarnController>().getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<MarketAuthController>().isLoggedIn();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBarWidget(
        title: 'refer_and_earn'.tr,
        actions: [
          isLoggedIn
              ? IconButton(
                  onPressed: () {
                    showCustomBottomSheet(child: const BottomSheetViewWidget());
                  },
                  icon: const Icon(Icons.info_outline),
                )
              : const SizedBox(),
        ],
      ),
      endDrawer: const MenuDrawerWidget(),
      endDrawerEnableOpenDragGesture: false,
      body: isLoggedIn
          ? GetBuilder<MarketReferAndEarnController>(
              builder: (referAndEarnController) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge),
                child: Column(
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    // Title
                    Text(
                      'invite_friend_getRewards'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeOverLarge,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    // Description with reward amount
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'referral_bottom_sheet_note'.tr,
                          style: robotoRegular.copyWith(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  '  ${PriceConverter.convertPrice(Get.find<MarketSplashController>(tag: 'xmarket').configModel?.refEarningExchangeRate ?? 0)}  ',
                              style: robotoBold.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                            TextSpan(
                              text: 'wallet_balance'.tr,
                              style: robotoRegular.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: Dimensions.paddingSizeExtraOverLarge),

                    // Three steps
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStepCard(
                          context,
                          stepNumber: '1',
                          icon: Icons.people_outline,
                          text: 'invite_or_share_the_code'.tr,
                        ),
                        _buildStepCard(
                          context,
                          stepNumber: '2',
                          icon: Icons.person_add_alt_1_outlined,
                          text: 'your_friend_sign_up'.tr,
                        ),
                        _buildStepCard(
                          context,
                          stepNumber: '3',
                          icon: Icons.celebration_outlined,
                          text: 'both_you_and_friend_will'.tr,
                        ),
                      ],
                    ),
                    const SizedBox(
                        height: Dimensions.paddingSizeExtraOverLarge),

                    // Referral code box
                    Container(
                      width: Get.width * 0.9,
                      padding: const EdgeInsets.only(
                          left: Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                        border: Border.all(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.25),
                        ),
                      ),
                      child: (referAndEarnController.userInfoModel != null)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  referAndEarnController
                                          .userInfoModel?.refCode ??
                                      '',
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (referAndEarnController.userInfoModel
                                            ?.refCode?.isNotEmpty ??
                                        false) {
                                      Clipboard.setData(ClipboardData(
                                        text: referAndEarnController
                                                .userInfoModel?.refCode ??
                                            '',
                                      )).then((_) {
                                        showCustomSnackBar('copied'.tr);
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeDefault,
                                      vertical: Dimensions.paddingSizeSmall,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(
                                            Dimensions.radiusDefault),
                                        bottomRight: Radius.circular(
                                            Dimensions.radiusDefault),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.copy_rounded,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const Center(
                              child: Padding(
                                padding:
                                    EdgeInsets.all(Dimensions.paddingSizeSmall),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // Invite Friends Button
                    Builder(builder: (context) {
                      return InkWell(
                        onTap: () async {
                          if (referAndEarnController.userInfoModel?.refCode !=
                              null) {
                            final box =
                                context.findRenderObject() as RenderBox?;
                            await Share.share(
                              Get.find<MarketSplashController>(tag: 'xmarket')
                                          .configModel
                                          ?.appUrlAndroid !=
                                      null
                                  ? '${AppConstants.appName} ${'referral_code'.tr}: ${referAndEarnController.userInfoModel!.refCode} \n${'download_app_from_this_link'.tr}: ${Get.find<MarketSplashController>(tag: 'xmarket').configModel?.appUrlAndroid}'
                                  : '${AppConstants.appName} ${'referral_code'.tr}: ${referAndEarnController.userInfoModel!.refCode}',
                              sharePositionOrigin: box != null
                                  ? box.localToGlobal(Offset.zero) & box.size
                                  : null,
                            );
                          }
                        },
                        child: Container(
                          width: Get.width * 0.5,
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeDefault,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color!
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'invite_friends'.tr,
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // How it works link
                    InkWell(
                      onTap: () => showCustomBottomSheet(
                          child: const BottomSheetViewWidget()),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'how_it_works'.tr,
                            style: robotoRegular.copyWith(
                              decoration: TextDecoration.underline,
                              color: Theme.of(context).primaryColor,
                              decorationColor: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Icon(
                            Icons.help_outline,
                            color: Theme.of(context).primaryColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    // // Earning history link
                    // InkWell(
                    //   onTap: () {
                    //     // Navigate to earning history if available
                    //     showCustomSnackBar('earning_history'.tr,
                    //         isError: false);
                    //   },
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Text(
                    //       'earning_history'.tr,
                    //       style: robotoRegular.copyWith(
                    //         color: Theme.of(context).primaryColor,
                    //         decoration: TextDecoration.underline,
                    //         decorationColor: Theme.of(context).primaryColor,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                ),
              );
            })
          : NotLoggedInScreen(callBack: (value) {
              _initCall();
              setState(() {});
            }),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required String stepNumber,
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: Get.width * 0.25,
      padding: const EdgeInsets.only(
        left: Dimensions.paddingSizeSmall,
        right: Dimensions.paddingSizeSmall,
        bottom: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Text(
                stepNumber,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                ),
              ),
            ),
          ),
          Icon(
            icon,
            size: 24,
            color: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.color
                ?.withValues(alpha: 0.8),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            text,
            textAlign: TextAlign.center,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
