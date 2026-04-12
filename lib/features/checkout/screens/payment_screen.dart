import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/animated_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/digital_payment_dialog.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';
import 'package:stackfood_multivendor/features/loyalty/controllers/loyalty_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/wallet/widgets/fund_payment_dialog_widget.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/xmarket_images.dart';

class PaymentScreen extends StatefulWidget {
  final OrderModel orderModel;
  final String paymentMethod;
  final String? addFundUrl;
  final String? subscriptionUrl;
  final String guestId;
  final String contactNumber;
  final int? restaurantId;
  final int? packageId;
  const PaymentScreen(
      {super.key,
      required this.orderModel,
      required this.paymentMethod,
      this.addFundUrl,
      this.subscriptionUrl,
      required this.guestId,
      required this.contactNumber,
      this.restaurantId,
      this.packageId});

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  late String selectedUrl;
  double value = 0.0;
  final bool _isLoading = true;
  PullToRefreshController? pullToRefreshController;
  late MyInAppBrowser browser;
  double? maxCodOrderAmount;

  @override
  void initState() {
    super.initState();

    // Fixed: Proper null/empty check
    if ((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
        (widget.subscriptionUrl == null || widget.subscriptionUrl!.isEmpty)) {
      // Build payment URL with all required parameters
      String paymentMethod = widget.paymentMethod;
      String additionalParams = '';

      if (paymentMethod.toLowerCase().contains('paymob') ||
          paymentMethod.toLowerCase().contains('wallet')) {
        paymentMethod = 'paymob_accept';
        if (widget.paymentMethod.toLowerCase().contains('wallet')) {
          additionalParams = '&paymob_integration_type=wallet';
        }
      }

      String callbackUrl = 'https://xshop.x-ride.support//payment-success';
      selectedUrl =
          '${AppConstants.baseUrl}/payment-mobile?order_id=${widget.orderModel.id}'
          '&customer_id=${widget.orderModel.userId == 0 ? widget.guestId : widget.orderModel.userId}'
          '&payment_method=$paymentMethod&payment_platform=mobile&callback=$callbackUrl$additionalParams';

      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('PAYMENT URL: $selectedUrl');
      debugPrint('═══════════════════════════════════════════════════════');
    } else if (widget.subscriptionUrl != null &&
        widget.subscriptionUrl!.isNotEmpty) {
      selectedUrl = widget.subscriptionUrl!;
    } else {
      selectedUrl = widget.addFundUrl!;
    }
    _initData();
  }

  void _initData() async {
    // Fixed: Proper null/empty check
    if (widget.addFundUrl == null || widget.addFundUrl!.isEmpty) {
      AddressModel? address = AddressHelper.getAddressFromSharedPref();
      ZoneData? zoneData;
      if (address?.zoneData != null && address!.zoneData!.isNotEmpty) {
        zoneData = address.zoneData!.firstWhere(
          (data) => data.id == widget.orderModel.restaurant!.zoneId,
          orElse: () => address.zoneData!.first,
        );
      }
      maxCodOrderAmount = zoneData?.maxCodOrderAmount;
    }

    browser = MyInAppBrowser(
        orderID: widget.orderModel.id.toString(),
        orderAmount: widget.orderModel.orderAmount,
        maxCodOrderAmount: maxCodOrderAmount,
        addFundUrl: widget.addFundUrl,
        subscriptionUrl: widget.subscriptionUrl,
        contactNumber: widget.contactNumber,
        restaurantId: widget.restaurantId,
        packageId: widget.packageId,
        isDeliveryOrder: widget.orderModel.orderType == 'delivery');

    if (!GetPlatform.isIOS) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(true);

      bool swAvailable = await WebViewFeature.isFeatureSupported(
          WebViewFeature.SERVICE_WORKER_BASIC_USAGE);
      bool swInterceptAvailable = await WebViewFeature.isFeatureSupported(
          WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

      if (swAvailable && swInterceptAvailable) {
        ServiceWorkerController serviceWorkerController =
            ServiceWorkerController.instance();
        await serviceWorkerController
            .setServiceWorkerClient(ServiceWorkerClient(
          shouldInterceptRequest: (request) async {
            if (kDebugMode) {
              print(request);
            }
            return null;
          },
        ));
      }
    }

    await browser.openUrlRequest(
      urlRequest: URLRequest(url: WebUri(selectedUrl)),
      settings: InAppBrowserClassSettings(
        webViewSettings: InAppWebViewSettings(
            useShouldOverrideUrlLoading: true,
            useOnLoadResource: true,
            domStorageEnabled: true // Enable DOM storage for payment gateways
            ),
        browserSettings: InAppBrowserSettings(
            hideUrlBar: true, hideToolbarTop: GetPlatform.isAndroid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        _exitApp().then((value) => value!);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: CustomAppBarWidget(
            title: 'payment'.tr, onBackPressed: () => _exitApp()),
        endDrawer: const MenuDrawerWidget(),
        endDrawerEnableOpenDragGesture: false,
        body: Center(
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: Stack(
              children: [
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: Colors.orange,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor)),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _exitApp() async {
    if (kDebugMode) {
      print(
          '---------- : ${widget.orderModel.orderStatus} / ${widget.orderModel.paymentMethod}/ ${widget.orderModel.id}');
      print(
          '---check------- : ${widget.addFundUrl == null} && ${widget.addFundUrl?.isEmpty} && ${widget.subscriptionUrl == null} && ${widget.subscriptionUrl?.isEmpty}');
    }
    // Fixed: Proper null/empty check and logic
    if ((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
        (widget.subscriptionUrl == null || widget.subscriptionUrl!.isEmpty)) {
      return Get.dialog(PaymentFailedDialog(
          orderID: widget.orderModel.id.toString(),
          orderAmount: widget.orderModel.orderAmount,
          maxCodOrderAmount: maxCodOrderAmount,
          contactPersonNumber: widget.contactNumber));
    } else {
      return Get.dialog(FundPaymentDialogWidget(
          isSubscription: widget.subscriptionUrl != null &&
              widget.subscriptionUrl!.isNotEmpty));
    }
  }
}

class MyInAppBrowser extends InAppBrowser {
  final String orderID;
  final double? orderAmount;
  final double? maxCodOrderAmount;
  final String? addFundUrl;
  final String? subscriptionUrl;
  final String? contactNumber;
  final int? restaurantId;
  final int? packageId;
  final bool isDeliveryOrder;
  MyInAppBrowser(
      {required this.orderID,
      required this.orderAmount,
      required this.maxCodOrderAmount,
      this.contactNumber,
      super.windowId,
      super.initialUserScripts,
      this.addFundUrl,
      this.subscriptionUrl,
      this.restaurantId,
      this.packageId,
      this.isDeliveryOrder = false});

  bool _canRedirect = true;

  @override
  Future onBrowserCreated() async {
    if (kDebugMode) {
      print("\n\nBrowser Created!\n\n");
    }
  }

  @override
  Future onLoadStart(url) async {
    if (kDebugMode) {
      print("\n\nStarted: $url\n\n");
    }
    _redirect(url.toString(), contactNumber, restaurantId, packageId);
  }

  @override
  Future onLoadStop(url) async {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      print("\n\nStopped: $url\n\n");
    }
    _redirect(url.toString(), contactNumber, restaurantId, packageId);
  }

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      print("Can't load [$url] Error: $message");
    }
  }

  @override
  void onProgressChanged(progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
    if (kDebugMode) {
      print("Progress: $progress");
    }
  }

  @override
  void onExit() {
    if (_canRedirect) {
      // Fixed: Proper null/empty check and logic
      if ((addFundUrl == null || addFundUrl!.isEmpty) &&
          (subscriptionUrl == null || subscriptionUrl!.isEmpty)) {
        Get.dialog(PaymentFailedDialog(
          orderID: orderID,
          orderAmount: orderAmount,
          maxCodOrderAmount: maxCodOrderAmount,
          contactPersonNumber: contactNumber,
        ));
      } else {
        Get.dialog(FundPaymentDialogWidget(
            isSubscription:
                subscriptionUrl != null && subscriptionUrl!.isNotEmpty));
      }
    }
    if (kDebugMode) {
      print("\n\nBrowser closed!\n\n");
    }
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
      navigationAction) async {
    if (kDebugMode) {
      print("\n\nOverride ${navigationAction.request.url}\n\n");
    }
    return NavigationActionPolicy.ALLOW;
  }

  @override
  void onLoadResource(resource) {
    if (kDebugMode) {
      print(
          "Started at: ${resource.startTime}ms ---> duration: ${resource.duration}ms ${resource.url ?? ''}");
    }
  }

  @override
  void onConsoleMessage(consoleMessage) {
    if (kDebugMode) {
      print("""
    console output:
      message: ${consoleMessage.message}
      messageLevel: ${consoleMessage.messageLevel.toValue()}
   """);
    }
  }

  void _redirect(
      String url, String? contactNumber, int? restaurantId, int? packageId) {
    // Fixed: Proper null/empty check
    bool forSubscription = (subscriptionUrl != null &&
        subscriptionUrl!.isNotEmpty &&
        (addFundUrl == null || addFundUrl!.isEmpty));

    if (_canRedirect) {
      // Support both old callback URLs and new callback URLs
      bool isNewCallback =
          url.startsWith('https://yourapp.com/payment-success');
      bool isOriginalUrl = url.startsWith(AppConstants.baseUrl);
      // Avoid matching the initial URL which contains "success" in the callback param
      bool isInitialUrl = url.contains('/payment-mobile');

      bool isSuccess = isNewCallback ||
          (forSubscription
              ? url.startsWith('${AppConstants.baseUrl}/subscription-success')
              : (isOriginalUrl && !isInitialUrl && url.contains('success')));
      bool isFailed = forSubscription
          ? url.startsWith('${AppConstants.baseUrl}/subscription-fail')
          : (isOriginalUrl && !isInitialUrl && url.contains('fail'));
      bool isCancel = forSubscription
          ? url.startsWith('${AppConstants.baseUrl}/subscription-cancel')
          : (isOriginalUrl && !isInitialUrl && url.contains('cancel'));

      // Handle new callback URL format
      if (isNewCallback) {
        Uri uri = Uri.parse(url);
        String? success = uri.queryParameters['success'];
        if (success == 'true') {
          isSuccess = true;
          isFailed = false;
        } else if (success == 'false') {
          isSuccess = false;
          isFailed = true;
        }
      }

      // CRITICAL FIX: Only close browser and redirect if we actually detected success/fail/cancel
      // Don't close if user is still on payment page!
      if (isSuccess || isFailed || isCancel) {
        _canRedirect = false;
        close();

        // Fixed: Proper null/empty check
        if ((addFundUrl == null || addFundUrl!.isEmpty) &&
            (subscriptionUrl == null || subscriptionUrl!.isEmpty)) {
          _orderPaymentDoneDecision(isSuccess, isFailed, isCancel);
        } else {
          _decideSubscriptionOrWallet(
              isSuccess, isFailed, isCancel, restaurantId, packageId);
        }
      }
    }
  }

  void _orderPaymentDoneDecision(bool isSuccess, bool isFailed, bool isCancel) {
    if (isSuccess) {
      double total = ((orderAmount! / 100) *
          Get.find<MarketSplashController>(tag: 'xmarket')
              .configModel!
              .loyaltyPointItemPurchasePoint!);
      Get.find<LoyaltyController>().saveEarningPoint(total.toStringAsFixed(0));
      Get.offNamed(RouteHelper.getOrderSuccessRoute(
          orderID, 'success', orderAmount, contactNumber,
          isDeliveryOrder: isDeliveryOrder));

      animatedDialogWidget(
          Get.context!,
          DigitalPaymentDialog(
            icon: XmarketImages.xshopLogo,
            title: 'payment_done'.tr,
            description: 'your_payment_successfully_done_xshop'.tr,
          ),
          dismissible: false,
          isFlip: true);
    } else if (isFailed || isCancel) {
      Get.offNamed(RouteHelper.getOrderSuccessRoute(
          orderID, 'fail', orderAmount, contactNumber,
          isDeliveryOrder: isDeliveryOrder));

      animatedDialogWidget(
          Get.context!,
          DigitalPaymentDialog(
            icon: XmarketImages.xshopLogo,
            title: isCancel ? 'payment_cancelled'.tr : 'payment_failed'.tr,
            description: isCancel
                ? 'your_payment_cancelled'.tr
                : 'your_payment_failed'.tr,
            isFailed: true,
          ),
          dismissible: false,
          isFlip: true);
    }
  }

  void _decideSubscriptionOrWallet(bool isSuccess, bool isFailed, bool isCancel,
      int? restaurantId, int? packageId) {
    if (isSuccess || isFailed || isCancel) {
      if (Get.currentRoute.contains(RouteHelper.payment)) {
        Get.back();
      }
      // Fixed: Proper null/empty check
      if (subscriptionUrl != null &&
          subscriptionUrl!.isNotEmpty &&
          (addFundUrl == null || addFundUrl!.isEmpty)) {
        Get.find<DashboardController>()
            .saveRegistrationSuccessfulSharedPref(true);
        Get.find<DashboardController>()
            .saveIsRestaurantRegistrationSharedPref(true);
        Get.offAllNamed(RouteHelper.getSubscriptionSuccessRoute(
          status: isSuccess
              ? 'success'
              : isFailed
                  ? 'fail'
                  : 'cancel',
          fromSubscription: true,
          restaurantId: restaurantId,
          packageId: packageId,
        ));
      } else {
        Get.back();
        Get.offAllNamed(RouteHelper.getWalletRoute(
            fundStatus: isSuccess
                ? 'success'
                : isFailed
                    ? 'fail'
                    : 'cancel'));
      }
    }
  }
}
