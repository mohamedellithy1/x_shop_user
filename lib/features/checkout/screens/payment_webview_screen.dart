import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/animated_dialog_widget.dart';
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
import 'package:stackfood_multivendor/util/xmarket_images.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final OrderModel orderModel;
  final String paymentMethod;
  final String? addFundUrl;
  final String? subscriptionUrl;
  final String guestId;
  final String contactNumber;
  final int? restaurantId;
  final int? packageId;

  const PaymentWebViewScreen({
    super.key,
    required this.orderModel,
    required this.paymentMethod,
    this.addFundUrl,
    this.subscriptionUrl,
    required this.guestId,
    required this.contactNumber,
    this.restaurantId,
    this.packageId,
  });

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentWebViewScreen> {
  late String selectedUrl;
  bool _isLoading = true;
  bool _canRedirect = true;
  double? _maximumCodOrderAmount;
  PullToRefreshController? pullToRefreshController;
  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    debugPrint('--- PaymentWebViewScreen Initialized [Fix Applied] ---');

    if ((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
        (widget.subscriptionUrl == null || widget.subscriptionUrl!.isEmpty)) {
      String callbackUrl = 'https://xshop.x-ride.support/payment-success';
      String paymentMethod = widget.paymentMethod;
      String additionalParams = '';

      if (paymentMethod.toLowerCase().contains('paymob') ||
          paymentMethod.toLowerCase().contains('wallet')) {
        paymentMethod = 'paymob_accept';
        if (widget.paymentMethod.toLowerCase().contains('wallet')) {
          additionalParams = '&paymob_integration_type=wallet';
        }
      }

      selectedUrl =
          '${AppConstants.baseUrl}/payment-mobile/?order_id=${widget.orderModel.id}&customer_id=${widget.orderModel.userId == 0 ? widget.guestId : widget.orderModel.userId}'
          '&payment_method=$paymentMethod&payment_platform=mobile&callback=$callbackUrl$additionalParams';

      debugPrint('Generated Payment URL: $selectedUrl');
    } else if (widget.subscriptionUrl != null &&
        widget.subscriptionUrl!.isNotEmpty) {
      selectedUrl = widget.subscriptionUrl!;
      debugPrint('Using Subscription URL: $selectedUrl');
    } else {
      selectedUrl = widget.addFundUrl!;
      debugPrint('Using Add Fund URL: $selectedUrl');
    }

    _initData();
  }

  void _initData() async {
    if (widget.addFundUrl == null || widget.addFundUrl!.isEmpty) {
      AddressModel? address = AddressHelper.getAddressFromSharedPref();
      ZoneData? zoneData;
      if (address?.zoneData != null && address!.zoneData!.isNotEmpty) {
        zoneData = address.zoneData!.firstWhere(
          (data) => data.id == widget.orderModel.restaurant!.zoneId,
          orElse: () => address.zoneData!.first,
        );
      }
      _maximumCodOrderAmount = zoneData?.maxCodOrderAmount;
    }

    pullToRefreshController = GetPlatform.isWeb ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _exitApp();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        // ✅ AppBar عادي بدون CustomAppBarWidget
        appBar: AppBar(
          title: Text('payment'.tr),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _exitApp(),
            ),
          ],
        ),
        endDrawer: const MenuDrawerWidget(),
        endDrawerEnableOpenDragGesture: false,
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(selectedUrl)),
              pullToRefreshController: pullToRefreshController,
              initialSettings: InAppWebViewSettings(
                userAgent:
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.97 Safari/537.36',
                useHybridComposition: true,
                domStorageEnabled: true,
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
                allowsInlineMediaPlayback: true,
              ),
              onWebViewCreated: (controller) async {
                webViewController = controller;
              },
              onLoadStart: (controller, url) async {
                debugPrint('WebView Started: ${url.toString()}');
                _redirect(url.toString());
                setState(() {
                  _isLoading = true;
                });
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                Uri uri = navigationAction.request.url!;
                debugPrint('Override ${uri.toString()}');
                if (![
                  "http",
                  "https",
                  "file",
                  "chrome",
                  "data",
                  "javascript",
                  "about"
                ].contains(uri.scheme)) {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                    return NavigationActionPolicy.CANCEL;
                  }
                }
                _redirect(uri.toString());
                return NavigationActionPolicy.ALLOW;
              },
              onLoadStop: (controller, url) async {
                debugPrint('WebView Stopped: ${url.toString()}');
                pullToRefreshController?.endRefreshing();
                setState(() {
                  _isLoading = false;
                });
                _redirect(url.toString());
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  pullToRefreshController?.endRefreshing();
                  setState(() => _isLoading = false);
                }
              },
            ),
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
    );
  }

  Future<void> _exitApp() async {
    if ((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
        (widget.subscriptionUrl == null || widget.subscriptionUrl!.isEmpty)) {
      Get.dialog(PaymentFailedDialog(
        orderID: widget.orderModel.id.toString(),
        orderAmount: widget.orderModel.orderAmount,
        maxCodOrderAmount: _maximumCodOrderAmount,
        contactPersonNumber: widget.contactNumber,
      ));
    } else {
      Get.dialog(FundPaymentDialogWidget(
          isSubscription: widget.subscriptionUrl != null &&
              widget.subscriptionUrl!.isNotEmpty));
    }
  }

  void _redirect(String url) {
    if (!_canRedirect) return;

    bool forSubscription = (widget.subscriptionUrl != null &&
        widget.subscriptionUrl!.isNotEmpty &&
        (widget.addFundUrl == null || widget.addFundUrl!.isEmpty));

    bool isInitialUrl = url.contains('/payment-mobile');
    bool isOriginalUrl = url.startsWith(AppConstants.baseUrl);
    bool isNewCallback =
        url.startsWith('https://xshop.x-ride.support/payment-success');

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

    if (isSuccess || isFailed || isCancel) {
      _canRedirect = false;

      if ((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
          (widget.subscriptionUrl == null || widget.subscriptionUrl!.isEmpty)) {
        if (isSuccess) {
          double total = ((widget.orderModel.orderAmount! / 100) *
              Get.find<MarketSplashController>(tag: 'xmarket')
                  .configModel!
                  .loyaltyPointItemPurchasePoint!);
          Get.find<LoyaltyController>()
              .saveEarningPoint(total.toStringAsFixed(0));
          Get.offNamed(RouteHelper.getOrderSuccessRoute(
              widget.orderModel.id.toString(),
              'success',
              widget.orderModel.orderAmount,
              widget.contactNumber,
              isDeliveryOrder: widget.orderModel.orderType == 'delivery'));

          animatedDialogWidget(
              context,
              DigitalPaymentDialog(
                icon: XmarketImages.xshopLogo,
                title: 'payment_done'.tr,
                description: 'your_payment_successfully_done_xshop'.tr,
              ),
              dismissible: false,
              isFlip: true);
        } else {
          Get.offNamed(RouteHelper.getOrderSuccessRoute(
              widget.orderModel.id.toString(),
              'fail',
              widget.orderModel.orderAmount,
              widget.contactNumber,
              isDeliveryOrder: widget.orderModel.orderType == 'delivery'));

          animatedDialogWidget(
              context,
              DigitalPaymentDialog(
                icon: XmarketImages.xshopLogo,
                title: isCancel ? 'payment_cancelled'.tr : 'payment_failed'.tr,
                description: isCancel ? 'your_payment_cancelled'.tr : 'your_payment_failed'.tr,
                isFailed: true,
              ),
              dismissible: false,
              isFlip: true);
        }
      } else {
        if (widget.subscriptionUrl != null &&
            widget.subscriptionUrl!.isNotEmpty &&
            (widget.addFundUrl == null || widget.addFundUrl!.isEmpty)) {
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
            restaurantId: widget.restaurantId,
            packageId: widget.packageId,
          ));
        } else {
          Get.offAllNamed(RouteHelper.getWalletRoute(
            fundStatus: isSuccess
                ? 'success'
                : isFailed
                    ? 'fail'
                    : 'cancel',
          ));
        }
      }
    }
  }
}
