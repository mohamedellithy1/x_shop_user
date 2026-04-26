import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/hover_widgets/on_hover_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/widgets/auth_dialog_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/xmarket_images.dart';

class MenuDrawerWidget extends StatefulWidget {
  const MenuDrawerWidget({super.key});

  @override
  MenuDrawerWidgetState createState() => MenuDrawerWidgetState();
}

class MenuDrawerWidgetState extends State<MenuDrawerWidget>
    with SingleTickerProviderStateMixin {
  final List<Menu> _menuList = [
    Menu(
        icon: XmarketImages.profileIcon,
        title: 'profile'.tr,
        onTap: () {
          Get.offNamed(RouteHelper.getProfileRoute());
        }),
    Menu(
        icon: XmarketImages.orderMenuIcon,
        title: 'my_orders'.tr,
        onTap: () {
          Get.offNamed(RouteHelper.getOrderRoute());
        }),
    Menu(
        icon: XmarketImages.location,
        title: 'my_address'.tr,
        onTap: () {
          Get.offNamed(RouteHelper.getAddressRoute());
        }),
    Menu(
        icon: XmarketImages.language,
        title: 'language'.tr,
        onTap: () {
          Get.offNamed(RouteHelper.getLanguageRoute('menu'));
        }),
    Menu(
        icon: XmarketImages.coupon,
        title: 'coupon'.tr,
        onTap: () {
          Get.offNamed(RouteHelper.getCouponRoute(fromCheckout: false));
        }),
    Menu(
        icon: Icons.shopping_cart_checkout_rounded,
        title: 'الباكدجات تسويقية',
        onTap: () {
          Get.offNamed(RouteHelper.getShoppingPlansRoute());
        }),
    Menu(
        icon: XmarketImages.support,
        title: 'help_support'.tr,
        onTap: () {
          Get.offNamed(RouteHelper.getSupportRoute());
        }),
    Menu(
        icon: Icons.favorite,
        title: 'wishlist'.tr,
        onTap: () {
          Get.offNamed(RouteHelper.getFavouriteScreen());
        }),
    Menu(
        icon: XmarketImages.chat,
        title: 'live_chat'.tr,
        onTap: () {
          Get.offNamed(RouteHelper.getConversationRoute());
        }),
  ];

  static const _initialDelayTime = Duration(milliseconds: 200);
  static const _itemSlideTime = Duration(milliseconds: 250);
  static const _staggerTime = Duration(milliseconds: 50);
  static const _buttonDelayTime = Duration(milliseconds: 150);
  static const _buttonTime = Duration(milliseconds: 500);
  final _animationDuration =
      _initialDelayTime + (_staggerTime * 7) + _buttonDelayTime + _buttonTime;

  late AnimationController _staggeredController;
  final List<Interval> _itemSlideIntervals = [];

  @override
  void initState() {
    super.initState();

    if (Get.find<MarketSplashController>(tag: 'xmarket')
        .configModel!
        .refundPolicyStatus!) {
      _menuList.add(Menu(
          icon: XmarketImages.refund,
          title: 'refund_policy'.tr,
          onTap: () {
            Get.offNamed(RouteHelper.getRefundPolicyRoute());
          }));
    }
    if (Get.find<MarketSplashController>(tag: 'xmarket')
        .configModel!
        .cancellationPolicyStatus!) {
      _menuList.add(Menu(
          icon: XmarketImages.cancellation,
          title: 'cancellation_policy'.tr,
          onTap: () {
            Get.offNamed(RouteHelper.getCancellationPolicyRoute());
          }));
    }
    if (Get.find<MarketSplashController>(tag: 'xmarket')
        .configModel!
        .shippingPolicyStatus!) {
      _menuList.add(Menu(
          icon: XmarketImages.shippingPolicy,
          title: 'shipping_policy'.tr,
          onTap: () {
            Get.offNamed(RouteHelper.getShippingPolicyRoute());
          }));
    }

    if (Get.find<MarketSplashController>(tag: 'xmarket')
        .configModel!
        .customerWalletStatus!) {
      _menuList.add(Menu(
          icon: XmarketImages.wallet,
          title: 'wallet'.tr,
          onTap: () {
            Get.offNamed(RouteHelper.getWalletRoute());
          }));
    }

    if (Get.find<MarketSplashController>(tag: 'xmarket')
        .configModel!
        .loyaltyPointStatus!) {
      _menuList.add(Menu(
          icon: XmarketImages.loyal,
          title: 'loyalty_points'.tr,
          onTap: () {
            Get.offNamed(RouteHelper.getLoyaltyRoute());
          }));
    }
    if (Get.find<MarketSplashController>(tag: 'xmarket')
        .configModel!
        .refEarningStatus!) {
      _menuList.add(Menu(
          icon: XmarketImages.referCode,
          title: 'refer_and_earn'.tr,
          onTap: () {
            Get.offNamed(RouteHelper.getReferAndEarnRoute());
          }));
    }
    if (Get.find<MarketSplashController>(tag: 'xmarket')
        .configModel!
        .toggleDmRegistration!) {
      _menuList.add(Menu(
          icon: XmarketImages.deliveryManJoin,
          title: 'join_as_a_delivery_man'.tr,
          onTap: () {
            Get.toNamed(RouteHelper.getDeliverymanRegistrationRoute());
          }));
    }
    if (Get.find<MarketSplashController>(tag: 'xmarket')
        .configModel!
        .toggleRestaurantRegistration!) {
      _menuList.add(Menu(
        icon: XmarketImages.restaurantJoin,
        title: 'join_as_a_restaurant'.tr,
        onTap: () => Get.toNamed(RouteHelper.getRestaurantRegistrationRoute()),
      ));
    }

    _menuList.add(Menu(
        icon: XmarketImages.logOut,
        title: Get.find<MarketAuthController>().isLoggedIn()
            ? 'logout'.tr
            : 'sign_in'.tr,
        onTap: () {
          Get.back();
          if (Get.find<MarketAuthController>().isLoggedIn()) {
            Get.dialog(
                ConfirmationDialogWidget(
                    icon: XmarketImages.support,
                    description: 'are_you_sure_to_logout'.tr,
                    isLogOut: true,
                    onYesPressed: () {
                      Get.find<MarketAuthController>().resetOtpView();
                      Get.find<MarketAuthController>().clearSharedData();
                      Get.find<MarketCartController>().clearCartList();
                      // Get.find<MarketAuthController>().socialLogout();
                      Get.find<FavouriteController>().removeFavourites();
                      if (ResponsiveHelper.isDesktop(Get.context)) {
                        Get.offAllNamed(RouteHelper.getInitialRoute());
                      } else {
                        Get.offAllNamed(
                            RouteHelper.getSignInRoute(RouteHelper.splash));
                      }
                    }),
                useSafeArea: false);
          } else {
            Get.find<FavouriteController>().removeFavourites();
            if (ResponsiveHelper.isDesktop(context)) {
              Get.dialog(
                const Center(
                    child: AuthDialogWidget(
                        exitFromApp: false, backFromThis: false)),
                barrierDismissible: false,
              );
            } else {
              Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
            }
          }
        }));

    _createAnimationIntervals();

    _staggeredController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..forward();
  }

  void _createAnimationIntervals() {
    for (var i = 0; i < _menuList.length; ++i) {
      final startTime = _initialDelayTime + (_staggerTime * i);
      final endTime = startTime + _itemSlideTime;
      _itemSlideIntervals.add(
        Interval(
          startTime.inMilliseconds / _animationDuration.inMilliseconds,
          endTime.inMilliseconds / _animationDuration.inMilliseconds,
        ),
      );
    }
  }

  @override
  void dispose() {
    _staggeredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context)
        ? _buildContent()
        : const SizedBox();
  }

  Widget _buildContent() {
    return Align(
        alignment: Alignment.topRight,
        child: Container(
          width: 300,
          decoration: BoxDecoration(color: Theme.of(context).cardColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeLarge, horizontal: 25),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('menu'.tr, style: robotoBold.copyWith(fontSize: 20)),
                    IconButton(
                        padding: const EdgeInsets.all(0),
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close))
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _menuList.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _staggeredController,
                      builder: (context, child) {
                        final animationPercent = Curves.easeOut.transform(
                          _itemSlideIntervals[index]
                              .transform(_staggeredController.value),
                        );
                        final opacity = animationPercent;
                        final slideDistance = (1.0 - animationPercent) * 150;

                        return Opacity(
                          opacity: opacity,
                          child: Transform.translate(
                            offset: Offset(slideDistance, 0),
                            child: child,
                          ),
                        );
                      },
                      child: OnHoverWidget(
                        isItem: true,
                        fromMenu: true,
                        child: InkWell(
                          onTap: _menuList[index].onTap as void Function()?,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                                vertical: Dimensions.paddingSizeExtraSmall),
                            child: Row(children: [
                              Container(
                                height: 55,
                                width: 55,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                  color: index != _menuList.length - 1
                                      ? Theme.of(context).primaryColor
                                      : Get.find<MarketAuthController>()
                                              .isLoggedIn()
                                          ? Theme.of(context).colorScheme.error
                                          : Colors.green,
                                ),
                                child: _menuList[index].icon is String
                                    ? Image.asset(_menuList[index].icon,
                                        color: Colors.white,
                                        height: 30,
                                        width: 30)
                                    : Icon(_menuList[index].icon as IconData,
                                        color: Colors.white, size: 30),
                              ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeSmall),
                              Expanded(
                                  child: Text(_menuList[index].title,
                                      style: robotoMedium,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1)),
                            ]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

class Menu {
  dynamic icon;
  String title;
  Function onTap;

  Menu({required this.icon, required this.title, required this.onTap});
}
