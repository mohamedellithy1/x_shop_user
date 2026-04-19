import 'package:stackfood_multivendor/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_screen_title_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/favourite/widgets/clear_all_bottom_sheet.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/theme/dark_theme.dart';
import 'package:stackfood_multivendor/theme/light_theme.dart';

import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  FavouriteScreenState createState() => FavouriteScreenState();
}

class FavouriteScreenState extends State<FavouriteScreen> {
  final ThemeData darkTheme = dark;
  final ThemeData lightTheme = light;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  void _initCall() {
    if (Get.find<MarketAuthController>().isLoggedIn()) {
      Get.find<FavouriteController>().getFavouriteList(fromFavScreen: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarketThemeController>(
        init: Get.find<MarketThemeController>(tag: 'xmarket'),
        builder: (marketThemeController) {
          return Theme(
            data: marketThemeController.darkTheme ? darkTheme : lightTheme,
            child: Scaffold(
              backgroundColor: marketThemeController.darkTheme
                  ? Colors.black
                  : Color(0xFFfafef5),
              appBar: CustomAppBarWidget(
                title: 'wishlist'.tr,
                isBackButtonExist: true,
                actions: [
                  TextButton(
                    onPressed: () {
                      showCustomBottomSheet(child: ClearAllBottomSheet());
                    },
                    child: Text('clear_all'.tr,
                        style: robotoMedium.copyWith(
                            color: marketThemeController.darkTheme
                                ? Colors.white
                                : Colors.black)),
                  ),
                ],
              ),
              endDrawer: const MenuDrawerWidget(),
              endDrawerEnableOpenDragGesture: false,
              body: GetBuilder<MarketAuthController>(builder: (authController) {
                return authController.isLoggedIn()
                    ? GetBuilder<FavouriteController>(
                        builder: (favouriteController) {
                        if (favouriteController.wishProductList == null ||
                            favouriteController.wishRestList == null) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF9ebc67)));
                        }

                        bool hasData =
                            favouriteController.wishProductList!.isNotEmpty ||
                                favouriteController.wishRestList!.isNotEmpty;

                        return SafeArea(
                            child: RefreshIndicator(
                          color: Colors.greenAccent,
                          onRefresh: () async {
                            await favouriteController.getFavouriteList();
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(children: [
                              WebScreenTitleWidget(title: 'wishlist'.tr),
                              !hasData
                                  ? SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.7,
                                      child: Center(
                                        child: NoDataScreen(
                                          isEmptyWishlist: true,
                                          isCenter: true,
                                          title:
                                              'you_have_not_add_any_item_to_wishlist'
                                                  .tr,
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: SizedBox(
                                        width: Dimensions.webMaxWidth,
                                        child: Column(children: [
                                          if (favouriteController
                                                      .wishProductList !=
                                                  null &&
                                              favouriteController
                                                  .wishProductList!.isNotEmpty)
                                            ProductViewWidget(
                                              isRestaurant: false,
                                              products: favouriteController
                                                  .wishProductList,
                                              restaurants: favouriteController
                                                  .wishRestList,
                                              noDataText: '',
                                              fromFavorite: true,
                                              useGridCard: true,
                                            ),
                                          if (favouriteController
                                                      .wishRestList !=
                                                  null &&
                                              favouriteController
                                                  .wishRestList!.isNotEmpty)
                                            ProductViewWidget(
                                              isRestaurant: true,
                                              products: favouriteController
                                                  .wishProductList,
                                              restaurants: favouriteController
                                                  .wishRestList,
                                              noDataText: '',
                                              fromFavorite: true,
                                              useGridCard: true,
                                            ),
                                        ]),
                                      ),
                                    ),
                            ]),
                          ),
                        ));
                      })
                    : NotLoggedInScreen(callBack: (value) {
                        _initCall();
                        setState(() {});
                      });
              }),
            ),
          );
        });
  }
}
