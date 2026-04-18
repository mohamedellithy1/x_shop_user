import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:lottie/lottie.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
// import 'package:lottie/lottie.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/features/coupon/screens/coupon_screen.dart';
import 'package:stackfood_multivendor/features/dashboard/screens/dashboard_screen.dart';
// import 'package:stackfood_multivendor/features/coupon/screens/coupon_screen.dart';
import 'package:stackfood_multivendor/features/dine_in/controllers/dine_in_controller.dart';
import 'package:stackfood_multivendor/features/home/controllers/advertisement_controller.dart';
// import 'package:stackfood_multivendor/features/home/widgets/cashback_dialog_widget.dart';
// import 'package:stackfood_multivendor/features/home/widgets/cashback_logo_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/dine_in_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/highlight_widget_view.dart';
import 'package:stackfood_multivendor/features/home/widgets/refer_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/product/controllers/campaign_controller.dart';
import 'package:stackfood_multivendor/features/home/controllers/home_controller.dart';
import 'package:stackfood_multivendor/features/home/screens/web_home_screen.dart';
// import 'package:stackfood_multivendor/features/home/widgets/all_restaurant_filter_widget.dart';
// import 'package:stackfood_multivendor/features/home/widgets/all_restaurants_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/bad_weather_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/banner_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/best_review_item_view_widget.dart';
// import 'package:stackfood_multivendor/features/home/widgets/cuisine_view_widget.dart';
// import 'package:stackfood_multivendor/features/home/widgets/enjoy_off_banner_view_widget.dart';
// import 'package:stackfood_multivendor/features/home/widgets/location_banner_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/new_on_stackfood_view_widget.dart';
// import 'package:stackfood_multivendor/features/home/widgets/order_again_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/popular_foods_nearby_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/popular_restaurants_view_widget.dart';
// import 'package:stackfood_multivendor/features/home/widgets/refer_banner_view_widget.dart';
import 'package:stackfood_multivendor/features/home/screens/theme1_home_screen.dart';
// import 'package:stackfood_multivendor/features/home/widgets/today_trends_view_widget.dart';
// import 'package:stackfood_multivendor/features/home/widgets/what_on_your_mind_view_widget.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/notification/controllers/notification_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/common/widgets/customizable_space_bar_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
// // import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';
import 'package:stackfood_multivendor/features/address/controllers/market_address_controller.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/features/review/controllers/review_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/localization/localization_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
// import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
// WebSocket/Reverb initialization
import 'package:stackfood_multivendor/core/realtime/delivery_realtime_service.dart';
import 'package:stackfood_multivendor/features/home/widgets/location_dropdown.dart';
import 'package:stackfood_multivendor/features/search/controllers/search_controller.dart'
    as search;
import 'package:stackfood_multivendor/features/search/widgets/search_result_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/cuisine_card_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/home_category_view_widget.dart';
import 'package:stackfood_multivendor/helper/custom_debouncer_helper.dart';

class XMarketHomeScreen extends StatefulWidget {
  const XMarketHomeScreen({super.key});

  static Future<void> loadData(bool reload) async {
    print(
        '📦 [XMarketHomeScreen] Loading all data from backend... (Reload: $reload)');
    MarketSplashController splashController =
        Get.find<MarketSplashController>(tag: 'xmarket');

    if (splashController.configModel == null) {
      debugPrint('📦 [XMarketHomeScreen] Config is null, fetching it now...');
      await splashController.getConfigData();
    }
    Get.find<HomeController>().getBannerList(reload);
    Get.find<MarketCategoryController>().getCategoryList(reload, search: '');
    Get.find<CuisineController>().getCuisineList();
    Get.find<AdvertisementController>().getAdvertisementList();
    Get.find<DineInController>().getDineInRestaurantList(1, reload);

    if (splashController.configModel?.popularRestaurant == 1) {
      Get.find<RestaurantController>()
          .getPopularRestaurantList(reload, 'all', false);
    }
    Get.find<CampaignController>().getItemCampaignList(reload);
    if (splashController.configModel?.popularFood == 1) {
      Get.find<ProductController>().getPopularProductList(reload, 'all', false);
    }
    if (splashController.configModel?.newRestaurant == 1) {
      Get.find<RestaurantController>()
          .getLatestRestaurantList(reload, 'all', false);
    }
    if (splashController.configModel?.mostReviewedFoods == 1) {
      Get.find<ReviewController>().getReviewedProductList(reload, 'all', false);
    }
    Get.find<RestaurantController>().getRestaurantList(1, reload);
    if (Get.find<MarketAuthController>().isLoggedIn()) {
      Get.find<MarketAuthController>().updateToken();

      await Get.find<MarketProfileController>().getUserInfo();
      Get.find<RestaurantController>()
          .getRecentlyViewedRestaurantList(reload, 'all', false);
      Get.find<RestaurantController>().getOrderAgainRestaurantList(reload);
      Get.find<MarketNotificationController>().getNotificationList(reload);
      Get.find<OrderController>().getRunningOrders(1, notify: false);
      Get.find<MarketAddressController>(tag: 'xmarket').getAddressList();
      Get.find<HomeController>().getCashBackOfferList();
    }
  }

  @override
  State<XMarketHomeScreen> createState() => _XMarketHomeScreenState();
}

class _XMarketHomeScreenState extends State<XMarketHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final CustomDebounceHelper _debouncer =
      CustomDebounceHelper(milliseconds: 500);
  bool _isLogin = false;
  static bool _firstTime = true;
  bool _isSearching = false;
  String _searchText = '';

  @override
  void initState() {
    super.initState();

    _isLogin = Get.find<MarketAuthController>().isLoggedIn();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_firstTime && !ResponsiveHelper.isDesktop(context)) {
        _firstTime = false;
        Get.find<MarketLocationController>()
            .getCurrentLocation(true, notify: false)
            .then((address) {
          if (address.latitude != null && address.address != null) {
            Get.find<MarketLocationController>().saveAddressAndNavigate(address,
                false, 'home', false, ResponsiveHelper.isDesktop(context));
          }
        });
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (Get.find<HomeController>().showFavButton) {
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800),
              () => Get.find<HomeController>().changeFavVisibility());
        }
      } else {
        if (Get.find<HomeController>().showFavButton) {
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800),
              () => Get.find<HomeController>().changeFavVisibility());
        }
      }
    });

    _initHome();
  }

  Future<void> _initHome() async {
    if (Get.find<MarketSplashController>(tag: 'xmarket').configModel == null) {
      await Get.find<MarketSplashController>(tag: 'xmarket').getConfigData();
    }
    await XMarketHomeScreen.loadData(true);

    Get.find<MarketSplashController>(tag: 'xmarket')
        .getReferBottomSheetStatus();

    if ((Get.find<MarketProfileController>()
                .userInfoModel
                ?.isValidForDiscount ??
            false) &&
        Get.find<MarketSplashController>(tag: 'xmarket').showReferBottomSheet) {
      Future.delayed(
          const Duration(milliseconds: 500), () => _showReferBottomSheet());
    }

    // Initialize WebSocket connection after data is loaded
    if (_isLogin) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _initializeWebSocketConnection();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showReferBottomSheet() {
    ResponsiveHelper.isDesktop(context)
        ? Get.dialog(
            Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusExtraLarge)),
              insetPadding: const EdgeInsets.all(22),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: const ReferBottomSheetWidget(),
            ),
            useSafeArea: false,
          ).then((value) => Get.find<MarketSplashController>(tag: 'xmarket')
            .saveReferBottomSheetStatus(false))
        : showModalBottomSheet(
            isScrollControlled: true,
            useRootNavigator: true,
            context: Get.context!,
            backgroundColor:
                Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
                    ? Colors.black
                    : Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radiusExtraLarge),
                  topRight: Radius.circular(Dimensions.radiusExtraLarge)),
            ),
            builder: (context) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8),
                child: const ReferBottomSheetWidget(),
              );
            },
          ).then((value) => Get.find<MarketSplashController>(tag: 'xmarket')
            .saveReferBottomSheetStatus(false));
  }

  /// Initialize WebSocket connection and subscribe to customer events
  Future<void> _initializeWebSocketConnection() async {
    try {
      debugPrint('🔌 [xMarket Home] Initializing WebSocket connection...');

      // Get customer ID from profile
      final profileController = Get.find<MarketProfileController>();

      // Wait a bit if profile is not loaded yet
      if (profileController.userInfoModel?.id == null) {
        debugPrint('⏳ [xMarket Home] Waiting for profile data...');
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      final customerId = profileController.userInfoModel?.id?.toString() ??
          (AuthHelper.isGuestLoggedIn() ? AuthHelper.getGuestId() : '');

      if (customerId.isNotEmpty) {
        // Initialize the centralized realtime service
        if (Get.isRegistered<UserRealtimeService>()) {
          await Get.find<UserRealtimeService>().initializeListeners(customerId);
          debugPrint(
              '📡 [xMarket Home] Realtime service initialized for: $customerId');
        }
      }
    } catch (e, stackTrace) {
      debugPrint(
          '❌ [xMarket Home] Failed to initialize WebSocket: $e\n$stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    double scrollPoint = 0.0;

    return GetBuilder<HomeController>(builder: (homeController) {
      return GetBuilder<MarketSplashController>(
          tag: 'xmarket',
          builder: (splashController) {
            final configModel = splashController.configModel;
            debugPrint(
                '🏠 [HomeScreen] ConfigModel is: ${configModel != null ? "READY (theme: ${configModel.theme})" : "NULL"}');
            return GetBuilder<LocalizationController>(
                tag: 'xmarket',
                builder: (localizationController) {
                  return GetBuilder<MarketThemeController>(
                    tag: 'xmarket',
                    builder: (marketThemeController) {
                      return Theme(
                        data: marketThemeController.darkTheme
                            ? darkTheme
                            : lightTheme,
                        child: Scaffold(
                          appBar: ResponsiveHelper.isDesktop(context)
                              ? const WebMenuBar()
                              : null,
                          endDrawer: const MenuDrawerWidget(),
                          endDrawerEnableOpenDragGesture: false,
                          backgroundColor: marketThemeController.darkTheme
                              ? Colors.black
                              : Theme.of(context).scaffoldBackgroundColor,
                          body: configModel == null
                              ? Builder(builder: (context) {
                                  // جلب الـ Config في الخلفية فوراً
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    debugPrint(
                                        '🔄 [HomeScreen] Config is null, fetching in background...');
                                    Get.find<MarketSplashController>(
                                            tag: 'xmarket')
                                        .getConfigData(
                                            source: DataSourceEnum.client);
                                  });
                                  return const Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.orange));
                                })
                              : Stack(
                                  children: [
                                    SafeArea(
                                      top: false,
                                      child: RefreshIndicator(
                                        color: Colors.orange,
                                        onRefresh: () async {
                                          await Get.find<HomeController>()
                                              .getBannerList(true);
                                          await Get.find<
                                                  MarketCategoryController>()
                                              .getCategoryList(true,
                                                  search: '');
                                          await Get.find<CuisineController>()
                                              .getCuisineList();
                                          Get.find<AdvertisementController>()
                                              .getAdvertisementList();
                                          await Get.find<RestaurantController>()
                                              .getPopularRestaurantList(
                                                  true, 'all', false);
                                          await Get.find<CampaignController>()
                                              .getItemCampaignList(true);
                                          await Get.find<ProductController>()
                                              .getPopularProductList(
                                                  true, 'all', false);
                                          await Get.find<RestaurantController>()
                                              .getLatestRestaurantList(
                                                  true, 'all', false);
                                          await Get.find<ReviewController>()
                                              .getReviewedProductList(
                                                  true, 'all', false);
                                          await Get.find<RestaurantController>()
                                              .getRestaurantList(1, true);
                                          if (Get.find<MarketAuthController>()
                                              .isLoggedIn()) {
                                            await Get.find<
                                                    MarketProfileController>()
                                                .getUserInfo();
                                            await Get.find<
                                                    MarketNotificationController>()
                                                .getNotificationList(true);
                                            await Get.find<
                                                    RestaurantController>()
                                                .getRecentlyViewedRestaurantList(
                                                    true, 'all', false);
                                            await Get.find<
                                                    RestaurantController>()
                                                .getOrderAgainRestaurantList(
                                                    true);
                                          }
                                        },
                                        child:
                                            ResponsiveHelper.isDesktop(context)
                                                ? WebHomeScreen(
                                                    scrollController:
                                                        _scrollController,
                                                  )
                                                : (configModel.theme == 2)
                                                    ? Theme1HomeScreen(
                                                        scrollController:
                                                            _scrollController,
                                                      )
                                                    : CustomScrollView(
                                                        controller:
                                                            _scrollController,
                                                        physics:
                                                            const AlwaysScrollableScrollPhysics(),
                                                        slivers: [
                                                          /// App Bar
                                                          SliverAppBar(
                                                            systemOverlayStyle:
                                                                const SystemUiOverlayStyle(
                                                              statusBarIconBrightness:
                                                                  Brightness
                                                                      .dark,
                                                              statusBarBrightness:
                                                                  Brightness
                                                                      .light,
                                                            ),
                                                            // leading: IconButton(onPressed: () => Get.to(XRideDashboardScreen()), icon: Icon(Icons.arrow_back_ios , color: Colors.black,)),
                                                            pinned: true,
                                                            toolbarHeight: 10,
                                                            expandedHeight:
                                                                ResponsiveHelper
                                                                        .isTab(
                                                                            context)
                                                                    ? 72
                                                                    : GetPlatform
                                                                            .isWeb
                                                                        ? 72
                                                                        : 50,
                                                            floating: false,
                                                            elevation: 0,
                                                            /*automaticallyImplyLeading: false,*/
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            flexibleSpace:
                                                                Container(
                                                              decoration:
                                                                  const BoxDecoration(
                                                                gradient:
                                                                    LinearGradient(
                                                                  colors: [
                                                                    Color(
                                                                        0xFFd6e0c4), // الجمب الشمال
                                                                    Color(
                                                                        0xFFfafef5), // اللون الخفيف اللي في النص (نفس لون الباك جراوند)
                                                                    Color(
                                                                        0xFFd6e0c4), // الجمب اليمين (نفس الشمال)
                                                                  ],
                                                                  begin: Alignment
                                                                      .centerLeft,
                                                                  end: Alignment
                                                                      .centerRight,
                                                                ),

                                                                // gradient:
                                                                //     LinearGradient(
                                                                //   colors: [
                                                                //     Color(
                                                                //         0xFFd6e0c4),
                                                                //     Color(
                                                                //         0xFFe7feba)
                                                                //   ],
                                                                //   begin: Alignment
                                                                //       .topLeft,
                                                                //   end: Alignment
                                                                //       .bottomRight,
                                                                // ),
                                                                // color: Color(
                                                                //     0xFFd6e0c4),
                                                              ),
                                                              child:
                                                                  FlexibleSpaceBar(
                                                                titlePadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                centerTitle:
                                                                    true,
                                                                expandedTitleScale:
                                                                    1,
                                                                background:
                                                                    Container(
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    gradient:
                                                                        LinearGradient(
                                                                      colors: [
                                                                        Color(
                                                                            0xFFd6e0c4), // الجمب الشمال
                                                                        Color(
                                                                            0xFFfafef5), // اللون الخفيف اللي في النص (نفس لون الباك جراوند)
                                                                        Color(
                                                                            0xFFd6e0c4), // الجمب اليمين (نفس الشمال)
                                                                      ],
                                                                      begin: Alignment
                                                                          .centerLeft,
                                                                      end: Alignment
                                                                          .centerRight,
                                                                    ),

                                                                    // gradient:
                                                                    //     LinearGradient(
                                                                    //   colors: [
                                                                    //     Color(
                                                                    //         0xFFd6e0c4),
                                                                    //     Color(
                                                                    //         0xFFe7feba)
                                                                    //   ],
                                                                    //   begin: Alignment
                                                                    //       .topLeft,
                                                                    //   end: Alignment
                                                                    //       .bottomRight,
                                                                    // ),
                                                                    // color: Color(
                                                                    //     0xFFd6e0c4),
                                                                  ),
                                                                ),
                                                                title:
                                                                    CustomizableSpaceBarWidget(
                                                                  builder: (context,
                                                                      scrollingRate) {
                                                                    scrollPoint =
                                                                        scrollingRate;
                                                                    return Center(
                                                                        child:
                                                                            Container(
                                                                      width: Dimensions
                                                                          .webMaxWidth,
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        color: Color(
                                                                            0xFFd6e0c4),
                                                                      ),
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              30),
                                                                      child:
                                                                          Opacity(
                                                                        opacity:
                                                                            1 - scrollPoint,
                                                                        child: Row(
                                                                            children: [
                                                                              // IconButton(
                                                                              //     onPressed: () => Get.to(const XRideDashboardScreen()),
                                                                              //     icon: Icon(
                                                                              //       Icons.arrow_back_ios,
                                                                              //       color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                                                                              //     )),
                                                                              Expanded(
                                                                                  child: Transform.translate(
                                                                                offset: Offset(0, -(scrollingRate * 20)),
                                                                                child: LocationDropdown(
                                                                                  child: Container(
                                                                                    margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                                                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                                                                    decoration: BoxDecoration(
                                                                                      color: Theme.of(context).brightness == Brightness.dark ? Color(0xFFfafef5) : const Color(0xFFfafef5),
                                                                                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                                                                                      border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white).withValues(alpha: 0.2), width: 1.2),
                                                                                    ),
                                                                                    child: GetBuilder<MarketLocationController>(builder: (locationController) {
                                                                                      final address = AddressHelper.getAddressFromSharedPref();
                                                                                      return Row(
                                                                                        children: [
                                                                                          Icon(Icons.keyboard_arrow_down, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, size: 20),
                                                                                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                                                          Expanded(
                                                                                            child: Text(
                                                                                              address?.address?.isNotEmpty == true ? address!.address! : 'your_location'.tr,
                                                                                              style: robotoRegular.copyWith(
                                                                                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF55745a),
                                                                                                fontSize: Dimensions.fontSizeSmall,
                                                                                              ),
                                                                                              maxLines: 1,
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                            ),
                                                                                          ),
                                                                                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                                                          const Icon(Icons.location_on, color: Colors.orange, size: 20),
                                                                                        ],
                                                                                      );
                                                                                    }),
                                                                                  ),
                                                                                ),
                                                                              )),
                                                                              Transform.translate(
                                                                                offset: Offset(0, -(scrollingRate * 10)),
                                                                                child: InkWell(
                                                                                  child: GetBuilder<MarketNotificationController>(builder: (notificationController) {
                                                                                    return Container(
                                                                                      decoration: BoxDecoration(
                                                                                        color: (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white).withValues(alpha: 0.2),
                                                                                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                                                      ),
                                                                                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                                                                      child: Stack(children: [
                                                                                        Transform.translate(
                                                                                          offset: Offset(0, -(scrollingRate * 10)),
                                                                                          child: Icon(Icons.notifications_outlined, size: 25, color: Colors.green),
                                                                                        ),
                                                                                        notificationController.hasNotification
                                                                                            ? Positioned(
                                                                                                top: 0,
                                                                                                right: 0,
                                                                                                child: Container(
                                                                                                  height: 10,
                                                                                                  width: 10,
                                                                                                  decoration: BoxDecoration(
                                                                                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                                                                                                    shape: BoxShape.circle,
                                                                                                    border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                                                                                                  ),
                                                                                                ))
                                                                                            : const SizedBox(),
                                                                                      ]),
                                                                                    );
                                                                                  }),
                                                                                  onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(width: Dimensions.paddingSizeSmall),
                                                                            ]),
                                                                      ),
                                                                    ));
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                            actions: const [
                                                              SizedBox()
                                                            ],
                                                          ),

                                                          // Search Button
                                                          SliverPersistentHeader(
                                                            pinned: true,
                                                            delegate:
                                                                CommonSliverDelegate(
                                                                    height: 65,
                                                                    child: Center(
                                                                        child: Stack(
                                                                      children: [
                                                                        Container(
                                                                          transform: Matrix4.translationValues(
                                                                              0,
                                                                              -1,
                                                                              0),
                                                                          height:
                                                                              65,
                                                                          width:
                                                                              Dimensions.webMaxWidth,
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .surface,
                                                                          child:
                                                                              Column(children: [
                                                                            Expanded(child: Container(color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white)),
                                                                            Expanded(child: Container(color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white)),
                                                                          ]),
                                                                        ),
                                                                        Positioned(
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              10,
                                                                          top:
                                                                              8,
                                                                          bottom:
                                                                              5,
                                                                          child:
                                                                              Container(
                                                                            transform: Matrix4.translationValues(
                                                                                0,
                                                                                -3,
                                                                                0),
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: Theme.of(context).cardColor,
                                                                              borderRadius: BorderRadius.circular(25),
                                                                              boxShadow: [
                                                                                BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))
                                                                              ],
                                                                            ),
                                                                            child:
                                                                                Row(children: [
                                                                              Icon(CupertinoIcons.search, size: 25, color: Theme.of(context).disabledColor),
                                                                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                                              Expanded(
                                                                                  child: TextField(
                                                                                controller: _searchController,
                                                                                textInputAction: TextInputAction.search,
                                                                                decoration: InputDecoration(
                                                                                  hintText: 'are_you_hungry'.tr,
                                                                                  border: InputBorder.none,
                                                                                  hintStyle: robotoRegular.copyWith(
                                                                                    fontSize: Dimensions.fontSizeSmall,
                                                                                    color: Theme.of(context).hintColor,
                                                                                  ),
                                                                                ),
                                                                                onTap: () {
                                                                                  if (!_isSearching) {
                                                                                    setState(() {
                                                                                      _isSearching = true;
                                                                                    });
                                                                                  }
                                                                                },
                                                                                onChanged: (value) {
                                                                                  setState(() {
                                                                                    _searchText = value.trim();
                                                                                  });
                                                                                  if (value.trim().isNotEmpty) {
                                                                                    _debouncer.run(() {
                                                                                      Get.find<search.SearchController>().searchData(value.trim(), 1);
                                                                                    });
                                                                                  } else {
                                                                                    Get.find<search.SearchController>().setSearchMode(true);
                                                                                  }
                                                                                },
                                                                                onSubmitted: (value) {
                                                                                  if (value.trim().isNotEmpty) {
                                                                                    Get.find<search.SearchController>().searchData(value.trim(), 1);
                                                                                  }
                                                                                },
                                                                              )),
                                                                              if (_isSearching)
                                                                                IconButton(
                                                                                  icon: Icon(Icons.close, size: 20, color: Theme.of(context).disabledColor),
                                                                                  onPressed: () {
                                                                                    setState(() {
                                                                                      _isSearching = false;
                                                                                      _searchController.clear();
                                                                                      _searchText = '';
                                                                                      Get.find<search.SearchController>().setSearchMode(true);
                                                                                    });
                                                                                  },
                                                                                ),
                                                                            ]),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ))),
                                                          ),

                                                          if (_isSearching)
                                                            SliverFillRemaining(
                                                              child: Container(
                                                                color: Theme.of(context)
                                                                            .brightness ==
                                                                        Brightness
                                                                            .dark
                                                                    ? Colors
                                                                        .black
                                                                    : Colors
                                                                        .white,
                                                                child: Column(
                                                                  children: [
                                                                    Expanded(
                                                                      child: GetBuilder<
                                                                              search
                                                                              .SearchController>(
                                                                          builder:
                                                                              (searchController) {
                                                                        if (searchController
                                                                            .isSearchMode) {
                                                                          return _showSuggestionView(
                                                                              searchController);
                                                                        } else {
                                                                          return SearchResultWidget(
                                                                              searchText: _searchText);
                                                                        }
                                                                      }),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),

                                                          if (!_isSearching)
                                                            SliverToBoxAdapter(
                                                              child: Center(
                                                                  child:
                                                                      SizedBox(
                                                                width: Dimensions
                                                                    .webMaxWidth,
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      const BannerViewWidget(),
                                                                      // const BadWeatherWidget(),
                                                                      // const WhatOnYourMindViewWidget(),∞
                                                                      // const TodayTrendsViewWidget(),
                                                                      // const LocationBannerViewWidget(),
                                                                      // const HighlightWidgetView(),
                                                                      // _isLogin
                                                                      //     ? const OrderAgainViewWidget()
                                                                      // : const SizedBox(),
                                                                      // configModel.mostReviewedFoods ==
                                                                      //         1
                                                                      //     ? const BestReviewItemViewWidget(
                                                                      //         isPopular: false)
                                                                      //     : const SizedBox(),
                                                                      // (configModel.dineInOrderOption ??
                                                                      //         false)
                                                                      //     ? DineInWidget()
                                                                      //     : const SizedBox(),
                                                                      const HomeCategoryViewWidget(),
                                                                      // configModel.popularRestaurant ==
                                                                      //         1
                                                                      //     ? const PopularRestaurantsViewWidget()
                                                                      //     : const SizedBox(),
                                                                      // configModel.popularFood ==
                                                                      //         1
                                                                      //     ? const PopularFoodNearbyViewWidget()
                                                                      //     : const SizedBox(),
                                                                      // configModel.newRestaurant ==
                                                                      //         1
                                                                      //     ? const NewOnStackFoodViewWidget(
                                                                      //         isLatest: true)
                                                                      //     : const SizedBox(),

                                                                      // const PromotionalBannerViewWidget(),
                                                                    ]),
                                                              )),
                                                            ),

                                                          // SliverPersistentHeader(
                                                          //   pinned: true,
                                                          //   delegate: SliverDelegate(
                                                          //     height: 90,
                                                          //     child: const AllRestaurantFilterWidget(),
                                                          //   ),
                                                          // ),

                                                          // SliverToBoxAdapter(
                                                          //     child: Center(
                                                          //         child: FooterViewWidget(
                                                          //   child: Padding(
                                                          //     padding: ResponsiveHelper.isDesktop(context)
                                                          //         ? EdgeInsets.zero
                                                          //         : const EdgeInsets.only(
                                                          //             bottom: Dimensions
                                                          //                 .paddingSizeOverLarge),
                                                          //     child: AllRestaurantsWidget(
                                                          //         scrollController: _scrollController),
                                                          //   ),
                                                          // ))),
                                                        ],
                                                      ),
                                      ),
                                    ),
                                    // Positioned(
                                    //   top: 220,
                                    //   right: 0,
                                    //   child: InkWell(
                                    //     onTap: () => Get.toNamed(
                                    //         RouteHelper.getCouponRoute(fromCheckout: false)),
                                    //     child: Container(
                                    //       decoration: BoxDecoration(
                                    //         color: Theme.of(context)
                                    //             .cardColor
                                    //             .withValues(alpha: 0.9),
                                    //         borderRadius: const BorderRadius.only(
                                    //           topLeft: Radius.circular(Dimensions.radiusDefault),
                                    //           bottomLeft:
                                    //               Radius.circular(Dimensions.radiusDefault),
                                    //         ),
                                    //         boxShadow: [
                                    //           BoxShadow(
                                    //               color: Colors.black.withValues(alpha: 0.1),
                                    //               blurRadius: 10,
                                    //               spreadRadius: 1)
                                    //         ],
                                    //       ),
                                    //       padding: const EdgeInsets.all(
                                    //           Dimensions.paddingSizeExtraSmall),
                                    //       child: Lottie.asset(
                                    //         'assets/image/offer.json',
                                    //         height: 45,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                          // floatingActionButton: AuthHelper.isLoggedIn() &&
                          //         homeController.cashBackOfferList != null &&
                          //         homeController.cashBackOfferList!.isNotEmpty
                          //     ? homeController.showFavButton
                          //         ? Padding(
                          //             padding: EdgeInsets.only(
                          //                 bottom:
                          //                     ResponsiveHelper.isDesktop(context) ? 50 : 0,
                          //                 right:
                          //                     ResponsiveHelper.isDesktop(context) ? 20 : 0),
                          //             child: InkWell(
                          //               onTap: () =>
                          //                   Get.dialog(const CashBackDialogWidget()),
                          //               child: const CashBackLogoWidget(),
                          //             ),
                          //           )
                          //         : null
                          //     : null,
                        ),
                      );
                    },
                  );
                });
          });
    });
  }
}

class CommonSliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  CommonSliverDelegate({required this.child, this.height = 50});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(CommonSliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height ||
        oldDelegate.minExtent != height ||
        child != oldDelegate.child;
  }
}

extension on _XMarketHomeScreenState {
  Widget _showSuggestionView(search.SearchController searchController) {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        searchController.historyList.isNotEmpty
            ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('recent_search'.tr,
                    style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge)),
                InkWell(
                  onTap: () => searchController.clearSearchAddress(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeSmall, horizontal: 4),
                    child: Text('clear_all'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).colorScheme.error,
                        )),
                  ),
                ),
              ])
            : const SizedBox(),
        SizedBox(
            height: searchController.historyList.isNotEmpty
                ? Dimensions.paddingSizeExtraSmall
                : 0),
        ListView.builder(
          itemCount: searchController.historyList.length > 10
              ? 10
              : searchController.historyList.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                _searchController.text = searchController.historyList[index];
                setState(() {
                  _searchText = searchController.historyList[index];
                });
                searchController.searchData(
                    searchController.historyList[index], 1);
              },
              child: Row(children: [
                Icon(CupertinoIcons.search,
                    size: 18, color: Theme.of(context).disabledColor),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeSmall),
                    child: Text(
                      searchController.historyList[index],
                      style: robotoRegular,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => searchController.removeHistory(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeExtraSmall),
                    child: Icon(Icons.close,
                        color: Theme.of(context).disabledColor, size: 20),
                  ),
                )
              ]),
            );
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        /*GetBuilder<CuisineController>(builder: (cuisineController) {
          return (cuisineController.cuisineModel != null &&
                  cuisineController.cuisineModel!.cuisines!.isEmpty)
              ? const SizedBox()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (cuisineController.cuisineModel != null)
                        ? Text(
                            'cuisines'.tr,
                            style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeLarge),
                          )
                        : const SizedBox(),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    (cuisineController.cuisineModel != null)
                        ? cuisineController.cuisineModel!.cuisines!.isNotEmpty
                            ? GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      ResponsiveHelper.isDesktop(context)
                                          ? 8
                                          : ResponsiveHelper.isTab(context)
                                              ? 6
                                              : 4,
                                  mainAxisSpacing: 15,
                                  crossAxisSpacing: 15,
                                  childAspectRatio: 1,
                                ),
                                shrinkWrap: true,
                                itemCount: cuisineController
                                    .cuisineModel!.cuisines!.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      Get.toNamed(
                                          RouteHelper.getCuisineRestaurantRoute(
                                              cuisineController.cuisineModel!
                                                  .cuisines![index].id,
                                              cuisineController.cuisineModel!
                                                  .cuisines![index].name));
                                    },
                                    child: CuisineCardWidget(
                                      image:
                                          '${cuisineController.cuisineModel!.cuisines![index].imageFullUrl}',
                                      name: cuisineController
                                          .cuisineModel!.cuisines![index].name!,
                                      fromSearchPage: true,
                                    ),
                                  );
                                },
                              )
                            : const SizedBox()
                        : const Center(child: CircularProgressIndicator()),
                  ],
                );
        }),*/
      ]),
    );
  }
}
