import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/api/api_checker.dart';
import 'package:stackfood_multivendor/common/models/online_cart_model.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/services/cart_service_interface.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/shopping_plans/controllers/shopping_plan_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';

class MarketCartController extends GetxController implements GetxService {
  final CartServiceInterface cartServiceInterface;

  MarketCartController({required this.cartServiceInterface});

  List<CartModel> _cartList = [];
  List<CartModel> get cartList => _cartList;

  double _subTotal = 0;
  double get subTotal => _subTotal;

  double _itemPrice = 0;
  double get itemPrice => _itemPrice;

  double _itemDiscountPrice = 0;
  double get itemDiscountPrice => _itemDiscountPrice;

  double _addOnsPrice = 0;
  double get addOns => _addOnsPrice;

  List<List<AddOns>> _addOnsList = [];
  List<List<AddOns>> get addOnsList => _addOnsList;

  List<bool> _availableList = [];
  List<bool> get availableList => _availableList;

  bool _addCutlery = false;
  bool get addCutlery => _addCutlery;

  int _notAvailableIndex = -1;
  int get notAvailableIndex => _notAvailableIndex;

  List<String> notAvailableList = [
    'Remove it from my cart',
    'I’ll wait until it’s restocked',
    'Please cancel the order',
    'Call me ASAP',
    'Notify me when it’s back'
  ];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isClearCartLoading = false;
  bool get isClearCartLoading => _isClearCartLoading;

  double _variationPrice = 0;
  double get variationPrice => _variationPrice;

  bool _needExtraPackage = true;
  bool get needExtraPackage => _needExtraPackage;

  bool _isExpanded = true;
  bool get isExpanded => _isExpanded;

  void toggleExtraPackage({bool willUpdate = true}) {
    _needExtraPackage = !_needExtraPackage;
    if (willUpdate) {
      update();
    }
  }

  void setNeedExtraPackage(bool needExtraPackage) {
    _needExtraPackage = needExtraPackage;
    update();
  }

  double calculationCart() {
    _itemPrice = 0;
    _itemDiscountPrice = 0;
    _subTotal = 0;
    _addOnsPrice = 0;
    _availableList = [];
    _addOnsList = [];
    _variationPrice = 0;
    double variationWithoutDiscountPrice = 0;
    double variationPrice = 0;
    for (var cartModel in _cartList) {
      variationWithoutDiscountPrice = 0;
      variationPrice = 0;

      double? discount = cartModel.product!.restaurantDiscount == 0
          ? cartModel.product!.discount
          : cartModel.product!.restaurantDiscount;
      String? discountType = cartModel.product!.restaurantDiscount == 0
          ? cartModel.product!.discountType
          : 'percent';

      List<AddOns> addOnList = cartServiceInterface.prepareAddonList(cartModel);

      _addOnsList.add(addOnList);
      _availableList.add(DateConverter.isAvailable(
          cartModel.product!.availableTimeStarts,
          cartModel.product!.availableTimeEnds));

      _addOnsPrice = cartServiceInterface.calculateAddonsPrice(
          addOnList, _addOnsPrice, cartModel);

      variationWithoutDiscountPrice =
          cartServiceInterface.calculateVariationWithoutDiscountPrice(
              cartModel, variationWithoutDiscountPrice, discount, discountType);
      variationPrice = cartServiceInterface.calculateVariationPrice(
          cartModel, variationPrice);

      double multiplier = (cartModel.product!.isWeightBased ?? false)
          ? (((cartModel.requestedWeight != null && cartModel.requestedWeight! > 0) ? cartModel.requestedWeight! : 1.0) * (cartModel.quantity ?? 1).toDouble())
          : cartModel.quantity!.toDouble();

      debugPrint('Cart Calculation Debug: Product: ${cartModel.product!.name}, isWeightBased: ${cartModel.product!.isWeightBased}, requestedWeight: ${cartModel.requestedWeight}, quantity: ${cartModel.quantity}, multiplier: $multiplier');

      double price = (cartModel.product!.price! * multiplier);
      double discountPrice = (price -
          (PriceConverter.convertWithDiscount(
                  cartModel.product!.price!, discount, discountType)! *
              multiplier));

      _variationPrice += variationPrice;
      _itemPrice = _itemPrice + price;
      
      double totalDiscount = discountPrice + (variationPrice - variationWithoutDiscountPrice);
      if (cartModel.isFromPlan == true && cartModel.planDiscountAmount != null) {
        totalDiscount += cartModel.planDiscountAmount!;
      }
      
      _itemDiscountPrice = _itemDiscountPrice + totalDiscount;


      debugPrint(
          '==check : ${_cartList.indexOf(cartModel)} ====> $_itemDiscountPrice = $_itemDiscountPrice + $totalDiscount');
    }

    _subTotal =
        (_itemPrice - _itemDiscountPrice) + _addOnsPrice + _variationPrice;

    if (Get.find<RestaurantController>().restaurant != null &&
        Get.find<RestaurantController>().restaurant!.discount != null) {
      if (Get.find<RestaurantController>().restaurant!.discount!.maxDiscount !=
              0 &&
          Get.find<RestaurantController>().restaurant!.discount!.maxDiscount! <
              _itemDiscountPrice) {
        _itemDiscountPrice =
            Get.find<RestaurantController>().restaurant!.discount!.maxDiscount!;
        _subTotal =
            (_itemPrice - _itemDiscountPrice) + _addOnsPrice + _variationPrice;
      }
      if (Get.find<RestaurantController>().restaurant!.discount!.minPurchase !=
              0 &&
          Get.find<RestaurantController>().restaurant!.discount!.minPurchase! >
              _subTotal) {
        _itemDiscountPrice = 0;
        _subTotal =
            (_itemPrice - _itemDiscountPrice) + _addOnsPrice + _variationPrice;
      }
    }
    return _subTotal;
  }

  Future<int?> reorderAddToCart(List<OnlineCart> cartList) async {
    await clearCartList();
    return addMultipleCartItemOnline(cartList);
  }

  Future<void> setQuantity(bool isIncrement, CartModel cart,
      {int? cartIndex}) async {
    _isLoading = true;
    update();
    int index = cartIndex ?? _cartList.indexOf(cart);
    _cartList[index].quantity = await cartServiceInterface
        .decideProductQuantity(_cartList, isIncrement, index);
    cartServiceInterface.addToSharedPrefCartList(_cartList);

    calculationCart();
    await updateCartQuantityOnline(_cartList[index].id!,
        _cartList[index].price!, _cartList[index].quantity!);

    // Sync with ShoppingPlanController if it's a plan item
    if (_cartList[index].isFromPlan == true && _cartList[index].shoppingPlanVariantId != null) {
      Get.find<ShoppingPlanController>().updateExtraItemQuantityByProductId(
        _cartList[index].shoppingPlanVariantId!,
        _cartList[index].product!.id!,
        isIncrement,
      );
    }

    _isLoading = false;
    update();
  }

  void removeFromCart(int index) {
    _isLoading = true;
    int cartId = _cartList[index].id!;
    CartModel removedItem = _cartList[index];
    _cartList.removeAt(index);
    update();
    removeCartItemOnline(cartId);

    // Sync with ShoppingPlanController if it's a plan item
    if (removedItem.isFromPlan == true && removedItem.shoppingPlanVariantId != null) {
      final planController = Get.find<ShoppingPlanController>();
      final extraItems = planController.getExtraItems(removedItem.shoppingPlanVariantId!);
      final extraIdx = extraItems.indexWhere((e) => e.product?.id == removedItem.product?.id);
      if (extraIdx >= 0) {
        planController.removeExtraItem(removedItem.shoppingPlanVariantId!, extraIdx);
      }
    }
  }

  void removeAddOn(int index, int addOnIndex) {
    _cartList[index].addOnIds!.removeAt(addOnIndex);
    cartServiceInterface.addToSharedPrefCartList(_cartList);
    calculationCart();
    update();
  }

  Future<void> clearCartList() async {
    _cartList = [];
    if (AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) {
      await clearCartOnline();
    }
  }

  int isExistInCart(int? productID, int? cartIndex) {
    return cartServiceInterface.isExistInCart(productID, cartIndex, _cartList);
  }

  bool existAnotherRestaurantProduct(int? restaurantID) {
    return cartServiceInterface.existAnotherRestaurantProduct(
        restaurantID, _cartList);
  }

  void updateCutlery({bool isUpdate = true}) {
    _addCutlery = !_addCutlery;
    if (isUpdate) {
      update();
    }
  }

  void setAvailableIndex(int index, {bool willUpdate = true}) {
    _notAvailableIndex =
        cartServiceInterface.setAvailableIndex(index, _notAvailableIndex);
    if (willUpdate) {
      update();
    }
  }

  int cartQuantity(int productID) {
    return cartServiceInterface.cartQuantity(productID, _cartList);
  }

  Future<void> addToCartOnline(OnlineCart onlineCart,
      {existCartData, bool fromDirectlyAdd = false}) async {
    if (AddressHelper.getAddressFromSharedPref() == null) {
      Get.find<MarketSplashController>(tag: 'xmarket').navigateToLocationScreen('home');
      return;
    }

    _isLoading = true;
    update();
    Response response = await cartServiceInterface.addToCartOnline(
        onlineCart, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());

    if (response.statusCode == 200) {
      List<OnlineCartModel> onlineCartList = [];
      response.body.forEach(
          (cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
      _cartList = [];
      _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(
          onlineCartModel: onlineCartList));
      cartServiceInterface.addToSharedPrefCartList(_cartList);
      calculationCart();
      if (!fromDirectlyAdd) {
        Get.back();
      }
      if (!Get.currentRoute.contains(RouteHelper.restaurant)) {
        // showCartSnackBarWidget();
      }
    } else if (response.statusCode == 403 &&
        response.body['errors'][0]['code'] == 'stock_out') {
      showCustomSnackBar(response.body['errors'][0]['message']);
      Get.find<ProductController>()
          .getProductDetails(onlineCart.itemId!, existCartData);
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  Future<int?> addMultipleCartItemOnline(List<OnlineCart> cartList) async {
    _isLoading = true;
    update();
    Response response =
        await cartServiceInterface.addMultipleCartItemOnline(cartList);
    if (response.statusCode == 200) {
      List<OnlineCartModel> onlineCartList = [];
      response.body.forEach(
          (cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
      Map<int, double> localWeights = {};
      for (var cart in _cartList) {
        if (cart.product != null && cart.requestedWeight != null) {
          localWeights[cart.product!.id!] = cart.requestedWeight!;
        }
      }
      for (var oc in cartList) {
        if (oc.requestedWeight != null && oc.itemId != null) {
          localWeights[oc.itemId!] = oc.requestedWeight!;
        }
      }

      _cartList = [];
      _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(
          onlineCartModel: onlineCartList));
          
      for (var cart in _cartList) {
        if (cart.product != null && localWeights.containsKey(cart.product!.id)) {
          cart.requestedWeight = localWeights[cart.product!.id];
        }
      }
      cartServiceInterface.addToSharedPrefCartList(_cartList);
      calculationCart();
    }
    _isLoading = false;
    update();
    return response.statusCode;
  }

  Future<void> updateCartOnline(OnlineCart onlineCart,
      {CartModel? existCartData}) async {
    _isLoading = true;
    update();
    Response response = await cartServiceInterface.updateCartOnline(onlineCart,
        AuthHelper.isLoggedIn() ? null : int.parse(AuthHelper.getGuestId()));
    if (response.statusCode == 200) {
      List<OnlineCartModel> onlineCartList = [];
      response.body.forEach(
          (cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
      _cartList = [];
      _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(
          onlineCartModel: onlineCartList));
      cartServiceInterface.addToSharedPrefCartList(_cartList);
      calculationCart();
      Get.back();
      if (!Get.currentRoute.contains(RouteHelper.restaurant)) {
        // showCartSnackBarWidget();
      }
    } else if (response.statusCode == 403 &&
        response.body['errors'][0]['code'] == 'stock_out') {
      showCustomSnackBar(response.body['errors'][0]['message']);
      Get.find<ProductController>()
          .getProductDetails(onlineCart.itemId!, existCartData);
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> updateCartQuantityOnline(
      int cartId, double price, int quantity) async {
    // _isLoading = true;
    // update();
    bool success = await cartServiceInterface.updateCartQuantityOnline(
        cartId,
        price,
        quantity,
        AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());
    if (success) {
      getCartDataOnline();
      calculationCart();
    }
    // _isLoading = false;
    // update();
  }

  Future<void> getCartDataOnline() async {
    _isLoading = true;
    List<OnlineCartModel> onlineCartList =
        await cartServiceInterface.getCartDataOnline(
            AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());
    _cartList = [];
    _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(
        onlineCartModel: onlineCartList));
    cartServiceInterface.addToSharedPrefCartList(_cartList);
    calculationCart();
    _isLoading = false;
    update();
  }

  Future<bool> removeCartItemOnline(int cartId) async {
    _isLoading = true;
    update();
    bool isSuccess = await cartServiceInterface.removeCartItemOnline(
        cartId, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());
    getCartDataOnline();
    _isLoading = false;
    update();
    return isSuccess;
  }

  Future<bool> clearCartOnline() async {
    _isLoading = true;
    _isClearCartLoading = true;
    update();
    bool success = await cartServiceInterface.clearCartOnline(
        AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());
    if (success) {
      getCartDataOnline();
    }
    _isLoading = false;
    _isClearCartLoading = false;
    update();
    return success;
  }

  void setExpanded(bool setExpand) {
    _isExpanded = setExpand;
    update();
  }
}
