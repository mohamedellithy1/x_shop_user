import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/coupon/widgets/coupon_card_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:stackfood_multivendor/common/widgets/web_page_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CouponScreen extends StatefulWidget {
  final bool fromCheckout;

  const CouponScreen({super.key, required this.fromCheckout});
  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  final ScrollController scrollController = ScrollController();
  bool _isLoggedIn = Get.find<MarketAuthController>().isLoggedIn();
  List<JustTheController>? _availableToolTipControllerList;
  List<JustTheController>? _unavailableToolTipControllerList;

  @override
  void initState() {
    super.initState();

    _initCall();
  }

  Future<void> _initCall() async {
    if (Get.find<MarketAuthController>().isLoggedIn()) {
      await Get.find<MarketCouponController>().getCouponList();
      _availableToolTipControllerList = [];
      _unavailableToolTipControllerList = [];

      if (Get.find<MarketCouponController>().customerCouponModel?.available !=
              null &&
          Get.find<MarketCouponController>()
              .customerCouponModel!
              .available!
              .isNotEmpty) {
        for (int i = 0;
            i <
                Get.find<MarketCouponController>()
                    .customerCouponModel!
                    .available!
                    .length;
            i++) {
          _availableToolTipControllerList!.add(JustTheController());
        }
      }

      if (Get.find<MarketCouponController>().customerCouponModel?.unavailable !=
              null &&
          Get.find<MarketCouponController>()
              .customerCouponModel!
              .unavailable!
              .isNotEmpty) {
        for (int i = 0;
            i <
                Get.find<MarketCouponController>()
                    .customerCouponModel!
                    .unavailable!
                    .length;
            i++) {
          _unavailableToolTipControllerList!.add(JustTheController());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _isLoggedIn = Get.find<MarketAuthController>().isLoggedIn();
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
          ? const Color(0xFF141313)
          : Color(0xFFfafef5),
      appBar: CustomAppBarWidget(title: 'coupon'.tr),
      endDrawer: const MenuDrawerWidget(),
      endDrawerEnableOpenDragGesture: false,
      body: _isLoggedIn
          ? GetBuilder<MarketCouponController>(builder: (couponController) {
              bool hasAvailable =
                  couponController.customerCouponModel?.available != null &&
                      couponController
                          .customerCouponModel!.available!.isNotEmpty;
              bool hasUnavailable =
                  couponController.customerCouponModel?.unavailable != null &&
                      couponController
                          .customerCouponModel!.unavailable!.isNotEmpty;

              return (couponController.customerCouponModel != null &&
                      _availableToolTipControllerList != null &&
                      _unavailableToolTipControllerList != null)
                  ? (hasAvailable || hasUnavailable)
                      ? RefreshIndicator(
                          onRefresh: () async {
                            await couponController.getCouponList();
                          },
                          child: SingleChildScrollView(
                            controller: scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                WebScreenTitleWidget(title: 'coupon'.tr),
                                Center(
                                    child: SizedBox(
                                        width: Dimensions.webMaxWidth,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (hasAvailable) ...[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: Dimensions
                                                        .paddingSizeLarge,
                                                    right: Dimensions
                                                        .paddingSizeLarge,
                                                    top: Dimensions
                                                        .paddingSizeDefault),
                                                child: Text(
                                                    'available_promo'.tr,
                                                    style: robotoBold.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeLarge,
                                                        color: Get.find<MarketThemeController>(
                                                                    tag:
                                                                        'xmarket')
                                                                .darkTheme
                                                            ? Colors.white
                                                            : Colors.black)),
                                              ),
                                              GridView.builder(
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount:
                                                      ResponsiveHelper
                                                              .isDesktop(
                                                                  context)
                                                          ? 3
                                                          : ResponsiveHelper
                                                                  .isTab(
                                                                      context)
                                                              ? 2
                                                              : 1,
                                                  mainAxisSpacing: Dimensions
                                                      .paddingSizeLarge,
                                                  crossAxisSpacing: Dimensions
                                                      .paddingSizeLarge,
                                                  childAspectRatio: 3,
                                                ),
                                                itemCount: couponController
                                                        .customerCouponModel
                                                        ?.available
                                                        ?.length ??
                                                    0,
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                padding: const EdgeInsets.all(
                                                    Dimensions
                                                        .paddingSizeDefault),
                                                itemBuilder: (context, index) {
                                                  return JustTheTooltip(
                                                    backgroundColor:
                                                        Get.find<MarketThemeController>(
                                                                    tag:
                                                                        'xmarket')
                                                                .darkTheme
                                                            ? const Color(
                                                                0xFF1b1b1b)
                                                            : Colors.black87,
                                                    controller:
                                                        _availableToolTipControllerList![
                                                            index],
                                                    preferredDirection:
                                                        AxisDirection.up,
                                                    tailLength: 14,
                                                    tailBaseWidth: 20,
                                                    triggerMode:
                                                        TooltipTriggerMode
                                                            .manual,
                                                    content: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                          '${'code_copied'.tr} !',
                                                          style: robotoRegular
                                                              .copyWith(
                                                                  color: Colors
                                                                      .white)),
                                                    ),
                                                    child: InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        _availableToolTipControllerList![
                                                                index]
                                                            .showTooltip();
                                                        Clipboard.setData(ClipboardData(
                                                            text: couponController
                                                                .customerCouponModel!
                                                                .available![
                                                                    index]
                                                                .code!));
                                                        Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    750), () {
                                                          _availableToolTipControllerList![
                                                                  index]
                                                              .hideTooltip();
                                                        });
                                                      },
                                                      child: CouponCardWidget(
                                                          couponList:
                                                              couponController
                                                                  .customerCouponModel!
                                                                  .available,
                                                          toolTipController:
                                                              _availableToolTipControllerList,
                                                          index: index),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                            if (hasUnavailable) ...[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: Dimensions
                                                        .paddingSizeLarge,
                                                    right: Dimensions
                                                        .paddingSizeLarge,
                                                    top: Dimensions
                                                        .paddingSizeDefault),
                                                child: Text(
                                                    'unavailable_promo'.tr,
                                                    style: robotoBold.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeLarge,
                                                        color: Get.find<MarketThemeController>(
                                                                    tag:
                                                                        'xmarket')
                                                                .darkTheme
                                                            ? Colors.white
                                                            : Colors.black)),
                                              ),
                                              GridView.builder(
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount:
                                                      ResponsiveHelper
                                                              .isDesktop(
                                                                  context)
                                                          ? 3
                                                          : ResponsiveHelper
                                                                  .isTab(
                                                                      context)
                                                              ? 2
                                                              : 1,
                                                  mainAxisSpacing: Dimensions
                                                      .paddingSizeLarge,
                                                  crossAxisSpacing: Dimensions
                                                      .paddingSizeLarge,
                                                  childAspectRatio: 3,
                                                ),
                                                itemCount: couponController
                                                        .customerCouponModel
                                                        ?.unavailable
                                                        ?.length ??
                                                    0,
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                padding: const EdgeInsets.all(
                                                    Dimensions
                                                        .paddingSizeDefault),
                                                itemBuilder: (context, index) {
                                                  return CouponCardWidget(
                                                    couponList: couponController
                                                        .customerCouponModel!
                                                        .unavailable,
                                                    toolTipController:
                                                        _unavailableToolTipControllerList,
                                                    index: index,
                                                    unavailable: true,
                                                  );
                                                },
                                              ),
                                            ]
                                          ],
                                        ))),
                              ],
                            ),
                          ),
                        )
                      : isDesktop
                          ? SingleChildScrollView(
                              child: Column(
                                children: [
                                  WebScreenTitleWidget(title: 'coupon'.tr),
                                  NoDataScreen(
                                      title: 'no_coupon_available'.tr,
                                      isEmptyCoupon: true),
                                ],
                              ),
                            )
                          : Center(
                              child: NoDataScreen(
                                  title: 'no_coupon_available'.tr,
                                  isEmptyCoupon: true),
                            )
                  : const Center(child: CircularProgressIndicator());
            })
          : NotLoggedInScreen(callBack: (bool value) {
              _initCall();
              setState(() {});
            }),
    );
  }
}
