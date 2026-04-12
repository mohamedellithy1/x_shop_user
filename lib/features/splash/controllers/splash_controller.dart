import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/widgets/custom_loader_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/address/controllers/market_address_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/widgets/pick_map_dialog.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/deep_link_body.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/splash/domain/services/splash_service_interface.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
// import 'package:stackfood_multivendor/helper/maintance_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:stackfood_multivendor/helper/splash_route_helper.dart';
import 'package:universal_html/html.dart' as html;

class MarketSplashController extends GetxController implements GetxService {
  final SplashServiceInterface splashServiceInterface;

  MarketSplashController({required this.splashServiceInterface});

  ConfigModel? _configModel;
  ConfigModel? get configModel => _configModel;

  bool _firstTimeConnectionCheck = true;
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;

  bool _hasConnection = true;
  bool get hasConnection => _hasConnection;

  bool _savedCookiesData = false;
  bool get savedCookiesData => _savedCookiesData;

  // bool _isNavigatedFromSplash = false; // ✅ Prevent double navigation

  String? _htmlText;
  String? get htmlText => _htmlText;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _showReferBottomSheet = false;
  bool get showReferBottomSheet => _showReferBottomSheet;

  DateTime get currentTime => DateTime.now();

  Future<void> getConfigData(
      {bool handleMaintenanceMode = false,
      DataSourceEnum source = DataSourceEnum.local,
      NotificationBodyModel? notificationBody,
      bool fromMainFunction = false,
      bool fromDemoReset = false}) async {
    _hasConnection = true;
    _savedCookiesData = getCookiesData();
    Response response;
    if (source == DataSourceEnum.local) {
      response = await splashServiceInterface.getConfigData(
          source: DataSourceEnum.local);
      _handleConfigResponse(
          response, handleMaintenanceMode, fromMainFunction, fromDemoReset,
          notificationBody: notificationBody, linkBody: null);
      getConfigData(
          handleMaintenanceMode: handleMaintenanceMode,
          source: DataSourceEnum.client,
          notificationBody: notificationBody);
    } else {
      response = await splashServiceInterface.getConfigData(
          source: DataSourceEnum.client);
      _handleConfigResponse(
          response, handleMaintenanceMode, fromMainFunction, fromDemoReset,
          notificationBody: notificationBody, linkBody: null);
    }
  }

  void _handleConfigResponse(Response response, bool handleMaintenanceMode,
      bool fromMainFunction, bool fromDemoReset,
      {required NotificationBodyModel? notificationBody,
      required DeepLinkBody? linkBody}) {
    if (response.statusCode == 200) {
      _configModel = splashServiceInterface.prepareConfigData(response);
      debugPrint('Config: x_shop: ${_configModel?.xShop}');
      if (_configModel != null) {
        if (!GetPlatform.isWeb) {
//           bool isMaintenanceMode = _configModel!.maintenanceMode!;
//           bool isInMaintenance = MaintenanceHelper.isMaintenanceEnable();

//           if (isInMaintenance && handleMaintenanceMode) {
//             Get.offNamed(RouteHelper.getUpdateRoute(false));
//           } else if (handleMaintenanceMode &&
//               ((Get.currentRoute.contains(RouteHelper.update) &&
//                       !isMaintenanceMode) ||
//                   !isInMaintenance)) {
//             Get.offNamed(RouteHelper.getInitialRoute());
//           }
        }
//         if (fromMainFunction) {
//           _mainConfigRouting();
//         } else if (fromDemoReset) {
//           Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: true));
//         } else if (!_isNavigatedFromSplash) {
//           _isNavigatedFromSplash = true;
//           route(notificationBody: notificationBody, linkBody: linkBody);
//         }
        _onRemoveLoader();
      }
    } else {
      if (response.statusText == ApiClient.noInternetMessage) {
        _hasConnection = false;
      }
    }

    update(['xmarket']);
  }

  void _onRemoveLoader() {
    final preloader = html.document.querySelector('.preloader');
    if (preloader != null) {
      preloader.remove();
    }
  }

/*
  Future<void> _mainConfigRouting() async {
    if (GetPlatform.isWeb) {
      bool isInMaintenance = MaintenanceHelper.isMaintenanceEnable();

      if (isInMaintenance) {
        Get.offNamed(RouteHelper.getUpdateRoute(false));
      }
    }
  }
*/

  Future<bool> initSharedData() {
    return splashServiceInterface.initSharedData();
  }

  bool? showIntro() {
    return splashServiceInterface.showIntro();
  }

  void disableIntro() {
    splashServiceInterface.disableIntro();
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }

  void saveCookiesData(bool data) {
    splashServiceInterface.saveCookiesData(data);
    _savedCookiesData = true;
    update(['xmarket']);
  }

  bool getCookiesData() {
    return splashServiceInterface.getCookiesData();
  }

  void cookiesStatusChange(String? data) {
    splashServiceInterface.cookiesStatusChange(data);
  }

  bool getAcceptCookiesStatus(String data) {
    return splashServiceInterface.getAcceptCookiesStatus(data);
  }

  Future<bool> subscribeMail(String email) async {
    _isLoading = true;
    bool isSuccess = false;
    update(['xmarket']);
    isSuccess = await splashServiceInterface.subscribeMail(email);
    _isLoading = false;
    update(['xmarket']);
    return isSuccess;
  }

  Future<void> navigateToLocationScreen(String page,
      {bool offNamed = false, bool offAll = false}) async {
    int? restaurantId;
    if (Get.currentRoute.startsWith(RouteHelper.restaurant)) {
      restaurantId =
          Get.parameters['id'] != 'null' && Get.parameters['id'] != null
              ? int.parse(Get.parameters['id']!)
              : null;
    }
    bool fromSignup = page == RouteHelper.signUp;
    bool fromHome = page == 'home';
    if (!fromHome && AddressHelper.getAddressFromSharedPref() != null) {
      Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
      Get.find<MarketLocationController>().autoNavigate(
          AddressHelper.getAddressFromSharedPref(),
          fromSignup,
          null,
          false,
          ResponsiveHelper.isDesktop(Get.context));
    } else if (Get.find<MarketAuthController>().isLoggedIn()) {
      Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
      await Get.find<MarketAddressController>(tag: 'xmarket').getAddressList();
      Get.back();
      if (Get.find<MarketAddressController>(tag: 'xmarket').addressList !=
              null &&
          Get.find<MarketAddressController>(tag: 'xmarket')
              .addressList!
              .isEmpty) {
        if (ResponsiveHelper.isDesktop(Get.context)) {
          showGeneralDialog(
              context: Get.context!,
              pageBuilder: (context, animation, secondaryAnimation) {
                return SizedBox(
                  height: 300,
                  width: 300,
                  child: PickMapDialog(
                    fromSignUp: (page == RouteHelper.signUp),
                    canRoute: false,
                    fromAddAddress: false,
                    route: page,
                    restaurantId: restaurantId,
                    // canTakeCurrentLocation: !AuthHelper.isLoggedIn(),
                  ),
                );
              });
        } else {
          Get.toNamed(RouteHelper.getPickMapRoute(page, false));
        }
      } else {
        if (ResponsiveHelper.isDesktop(Get.context)) {
          Get.back();
          showGeneralDialog(
              context: Get.context!,
              pageBuilder: (context, animation, secondaryAnimation) {
                return SizedBox(
                  height: 300,
                  width: 300,
                  child: PickMapDialog(
                    fromSignUp: (page == RouteHelper.signUp),
                    canRoute: false,
                    fromAddAddress: false,
                    route: page,
                    restaurantId: restaurantId,
                    // canTakeCurrentLocation: !AuthHelper.isLoggedIn(),
                  ),
                );
              });
        } else {
          if (offNamed) {
            Get.offNamed(RouteHelper.getAccessLocationRoute(page));
          } else if (offAll) {
            Get.offAllNamed(RouteHelper.getAccessLocationRoute(page));
          } else {
            Get.toNamed(RouteHelper.getAccessLocationRoute(page));
          }
        }
      }
    } else {
      if (ResponsiveHelper.isDesktop(Get.context)) {
        showGeneralDialog(
            context: Get.context!,
            pageBuilder: (context, animation, secondaryAnimation) {
              return SizedBox(
                height: 300,
                width: 300,
                child: PickMapDialog(
                  fromSignUp: (page == RouteHelper.signUp),
                  canRoute: false,
                  fromAddAddress: false,
                  route: page,
                  restaurantId: restaurantId,
                  // canTakeCurrentLocation: !fromHome,
                ),
              );
            });
      } else {
        _checkPermission(page);
      }
    }
  }

  void _checkPermission(String page) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Get.toNamed(RouteHelper.getPickMapRoute(page, false));
    } else {
      if (await _locationCheck()) {
        Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
        await Get.find<MarketLocationController>()
            .getCurrentLocation(false)
            .then((value) {
          if (value.latitude != null) {
            _onPickAddressButtonPressed(
                Get.find<MarketLocationController>(), page);
          }
        });
      } else {
        Get.toNamed(RouteHelper.getPickMapRoute(page, false));
      }
    }
  }

  Future<bool> _locationCheck() async {
    // bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if(!serviceEnabled) {
    //   await Geolocator.openLocationSettings();
    //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // }
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }
    return serviceEnabled;
  }

  void _onPickAddressButtonPressed(
      MarketLocationController locationController, String page) {
    if (locationController.pickPosition.latitude != 0 &&
        locationController.pickAddress!.isNotEmpty) {
      AddressModel address = AddressModel(
        latitude: locationController.pickPosition.latitude.toString(),
        longitude: locationController.pickPosition.longitude.toString(),
        addressType: 'others',
        address: locationController.pickAddress,
      );
      locationController.saveAddressAndNavigate(
          address, false, page, false, ResponsiveHelper.isDesktop(Get.context));
    } else {
      showCustomSnackBar('pick_an_address'.tr);
    }
  }

  void saveReferBottomSheetStatus(bool data) {
    splashServiceInterface.saveReferBottomSheetStatus(data);
    _showReferBottomSheet = data;
    update(['xmarket']);
  }

  void getReferBottomSheetStatus() {
    _showReferBottomSheet = splashServiceInterface.getReferBottomSheetStatus();
  }

  List<Product> filterXMarketProducts(List<Product>? list) {
    if (list == null || list.isEmpty) return [];

    const String xMarketName = 'X Market';
    const int xMarketId = 8;

    // Debug: print all unique restaurant names
    final names =
        list.map((p) => '${p.restaurantName} (id:${p.restaurantId})').toSet();
    print(
        '📦 [filterXMarketProducts] Input: ${list.length} products from restaurants: $names');

    final filtered = list
        .where((p) =>
            p.restaurantName?.trim() == xMarketName ||
            p.restaurantId == xMarketId)
        .toList();

    print(
        '📦 [filterXMarketProducts] Output: ${filtered.length} X Market products');
    return filtered;
  }

  List<Restaurant> filterXMarketRestaurants(List<Restaurant>? list) {
    const String xMarketName = 'X Market';
    return list?.where((r) => r.name?.trim() == xMarketName).toList() ?? [];
  }
}
