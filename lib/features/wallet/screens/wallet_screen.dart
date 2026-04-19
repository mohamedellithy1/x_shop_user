import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/wallet/controllers/wallet_controller.dart';
import 'package:stackfood_multivendor/features/wallet/widgets/bonus_banner_widget.dart';
import 'package:stackfood_multivendor/features/wallet/widgets/wallet_card_widget.dart';
import 'package:stackfood_multivendor/features/wallet/widgets/wallet_history_widget.dart';
import 'package:stackfood_multivendor/features/wallet/widgets/web_bonus_banner_view_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:stackfood_multivendor/common/widgets/web_page_title_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/common/widgets/skeleton.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';

class WalletScreen extends StatefulWidget {
  final String? fundStatus;
  final String? token;
  final bool fromMenuPage;
  final bool fromNotification;
  const WalletScreen(
      {super.key,
      this.fundStatus,
      this.token,
      this.fromMenuPage = false,
      this.fromNotification = false});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ScrollController scrollController = ScrollController();
  final tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();

    _initCall();
  }

  void _initCall() {
    if (Get.find<MarketAuthController>().isLoggedIn()) {
      Get.find<MarketWalletController>().insertFilterList();
      Get.find<MarketWalletController>()
          .setWalletFilerType('all', isUpdate: false);

      if ((widget.fundStatus == 'success' ||
              widget.fundStatus == 'fail' ||
              widget.fundStatus == 'cancel') &&
          Get.find<MarketWalletController>().getWalletAccessToken() !=
              widget.token) {
        Future.delayed(const Duration(seconds: 2), () {
          showCustomSnackBar(
            widget.fundStatus == 'success'
                ? 'fund_successfully_added_to_wallet'.tr
                : 'fund_not_added_to_wallet'.tr,
          );
        }).then((value) {
          Get.find<MarketWalletController>()
              .setWalletAccessToken(widget.token ?? '');
        });
      }
      Get.find<MarketProfileController>().getUserInfo();
      Get.find<MarketWalletController>().getWalletBonusList(isUpdate: false);
      Get.find<MarketWalletController>().getWalletTransactionList(
          '1', false, Get.find<MarketWalletController>().type);

      Get.find<MarketWalletController>().setOffset(1);

      scrollController.addListener(() {
        if (scrollController.position.pixels ==
                scrollController.position.maxScrollExtent &&
            Get.find<MarketWalletController>().transactionList != null &&
            !Get.find<MarketWalletController>().isLoading) {
          int pageSize =
              (Get.find<MarketWalletController>().popularPageSize! / 10).ceil();
          if (Get.find<MarketWalletController>().offset < pageSize) {
            Get.find<MarketWalletController>()
                .setOffset(Get.find<MarketWalletController>().offset + 1);
            if (kDebugMode) {
              print('end of the page');
            }
            Get.find<MarketWalletController>().showBottomLoader();
            Get.find<MarketWalletController>().getWalletTransactionList(
                Get.find<MarketWalletController>().offset.toString(),
                false,
                Get.find<MarketWalletController>().type);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<MarketAuthController>().isLoggedIn();
    return PopScope(
      canPop: widget.fromNotification ? Navigator.canPop(context) : false,
      onPopInvokedWithResult: (didPop, result) async {
        if (widget.fromNotification) {
          if (widget.fromNotification) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          } else {
            return;
          }
        } else {
          if (widget.fromMenuPage) {
            Future.delayed(const Duration(milliseconds: 10), () {
              Get.back();
            });
          } else {
            Future.delayed(const Duration(milliseconds: 10), () {
              Get.offAllNamed(RouteHelper.getInitialRoute());
            });
          }
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBarWidget(
            title: 'wallet'.tr,
            isBackButtonExist: true,
            onBackPressed: () {
              if (Navigator.canPop(context)) {
                Get.back();
              } else {
                Get.offAllNamed(RouteHelper.getInitialRoute());
              }
            }),
        endDrawer: const MenuDrawerWidget(),
        endDrawerEnableOpenDragGesture: false,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: GetBuilder<MarketProfileController>(builder: (profileController) {
          return isLoggedIn
              ? profileController.userInfoModel != null
                  ? SafeArea(
                      child: RefreshIndicator(
                        color: Color(0xFF9ebc67),
                        onRefresh: () async {
                          Get.find<MarketWalletController>()
                              .setWalletFilerType('all');
                          Get.find<MarketWalletController>()
                              .getWalletTransactionList('1', true, 'all');
                          Get.find<MarketProfileController>().getUserInfo();
                        },
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              WebScreenTitleWidget(title: 'wallet'.tr),
                              SizedBox(
                                width: Dimensions.webMaxWidth,
                                child: GetBuilder<MarketWalletController>(
                                    builder: (walletController) {
                                  return ResponsiveHelper.isDesktop(context)
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: Dimensions
                                                  .paddingSizeDefault),
                                          child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                    flex: 4,
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              ResponsiveHelper
                                                                      .isDesktop(
                                                                          context)
                                                                  ? BoxDecoration(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .cardColor,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              Dimensions.radiusSmall),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                            color:
                                                                                Colors.grey.withValues(alpha: 0.1),
                                                                            spreadRadius: 1,
                                                                            blurRadius: 10,
                                                                            offset: const Offset(0, 1))
                                                                      ],
                                                                    )
                                                                  : null,
                                                          padding: const EdgeInsets
                                                              .all(Dimensions
                                                                  .paddingSizeLarge),
                                                          child: WalletCardWidget(
                                                              tooltipController:
                                                                  tooltipController),
                                                        ),
                                                      ],
                                                    )),
                                                const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeDefault),
                                                Expanded(
                                                    flex: 6,
                                                    child: Column(children: [
                                                      const WebBonusBannerViewWidget(),
                                                      Container(
                                                        decoration:
                                                            ResponsiveHelper
                                                                    .isDesktop(
                                                                        context)
                                                                ? BoxDecoration(
                                                                    color: Colors
                                                                        .black,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            Dimensions.radiusSmall),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                          color: Colors.grey.withValues(
                                                                              alpha:
                                                                                  0.1),
                                                                          spreadRadius:
                                                                              1,
                                                                          blurRadius:
                                                                              10,
                                                                          offset: const Offset(
                                                                              0,
                                                                              1))
                                                                    ],
                                                                  )
                                                                : null,
                                                        padding: const EdgeInsets
                                                            .all(Dimensions
                                                                .paddingSizeLarge),
                                                        child:
                                                            const WalletHistoryWidget(),
                                                      ),
                                                    ])),
                                              ]),
                                        )
                                      : Column(children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .paddingSizeLarge),
                                            child: WalletCardWidget(
                                                tooltipController:
                                                    tooltipController),
                                          ),
                                          const BonusBannerWidget(),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .paddingSizeLarge),
                                            child: WalletHistoryWidget(),
                                          )
                                        ]);
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator(
                    color: Color(0xFF9ebc67),
                  ))
              : NotLoggedInScreen(callBack: (value) {
                  _initCall();
                  setState(() {});
                });
        }),
      ),
    );
  }
}

class WalletShimmer extends StatelessWidget {
  final MarketWalletController walletController;
  const WalletShimmer({super.key, required this.walletController});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: UniqueKey(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 50,
        mainAxisSpacing: ResponsiveHelper.isDesktop(context)
            ? Dimensions.paddingSizeLarge
            : 0.01,
        childAspectRatio: ResponsiveHelper.isDesktop(context) ? 5 : 4.1,
        crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 10,
      padding:
          EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? 28 : 25),
      itemBuilder: (context, index) {
        return Padding(
          padding:
              const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: walletController.transactionList == null,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height: 10,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2))),
                          const SizedBox(height: 10),
                          Container(
                              height: 10,
                              width: 70,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2))),
                        ]),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                              height: 10,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2))),
                          const SizedBox(height: 10),
                          Container(
                              height: 10,
                              width: 70,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2))),
                        ]),
                  ],
                ),
                Padding(
                    padding:
                        const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                    child: Divider(color: Theme.of(context).disabledColor)),
              ],
            ),
          ),
        );
      },
    );
  }
}
