import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/loyalty/controllers/loyalty_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';

class LoyaltyBottomSheetWidget extends StatefulWidget {
  final String amount;
  const LoyaltyBottomSheetWidget({super.key, required this.amount});

  @override
  State<LoyaltyBottomSheetWidget> createState() => _WalletBottomSheetState();
}

class _WalletBottomSheetState extends State<LoyaltyBottomSheetWidget> {
  final TextEditingController _amountController = TextEditingController();

  int? exchangePointRate = Get.find<MarketSplashController>(tag: 'xmarket')
          .configModel!
          .loyaltyPointExchangeRate ??
      0;
  int? minimumExchangePoint = Get.find<MarketSplashController>(tag: 'xmarket')
          .configModel!
          .minimumPointToTransfer ??
      0;
  int selectedIndex = -1;
  final List<int> _suggestedAmount = [100, 200, 300, 400];

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.amount;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
          ? const Color(0xFF141313)
          : Colors.white,
      surfaceTintColor:
          Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
              ? const Color(0xFF141313)
              : Colors.white,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () => Get.back(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding:
                        const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    child: Icon(Icons.clear,
                        size: 16,
                        color: Get.find<MarketThemeController>(tag: 'xmarket')
                                .darkTheme
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeSmall),
                child: Text(
                  'convert_point_to_wallet_money'.tr,
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                      color: Get.find<MarketThemeController>(tag: 'xmarket')
                              .darkTheme
                          ? Colors.white
                          : Color(0xFF55745a)),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: Text(
                  '${'conversion_rate_is'.tr}: '
                  '$exchangePointRate ${'points'.tr} = '
                  ' 1 EGP ',
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Get.find<MarketThemeController>(tag: 'xmarket')
                            .darkTheme
                        ? Colors.white70
                        : Color(0xFF55745a),
                  ),
                ),
              ),
              IntrinsicWidth(
                child: TextFormField(
                  textAlign: TextAlign.center,
                  controller: _amountController,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                  ],
                  decoration: InputDecoration(
                    hintText: 'enter_point'.tr,
                    hintStyle: robotoRegular.copyWith(
                        color: Get.find<MarketThemeController>(tag: 'xmarket')
                                .darkTheme
                            ? Colors.white54
                            : Color(0xFF55745a)),
                    enabledBorder: const UnderlineInputBorder(
                        borderSide:
                            BorderSide(width: 0.0, color: Colors.transparent)),
                    focusedBorder: const UnderlineInputBorder(
                        borderSide:
                            BorderSide(width: 0.0, color: Colors.transparent)),
                  ),
                  style: robotoBold.copyWith(
                      fontSize: 24,
                      color: Get.find<MarketThemeController>(tag: 'xmarket')
                              .darkTheme
                          ? Colors.white
                          : Color(0xFF55745a)),
                  onChanged: (String value) {
                    selectedIndex = -1;
                    setState(() {});
                  },
                ),
              ),
              const Divider(thickness: 1, color: Colors.black12),
              Padding(
                padding: const EdgeInsets.only(
                    top: Dimensions.paddingSizeSmall,
                    bottom: Dimensions.paddingSizeDefault),
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    itemCount: _suggestedAmount.length,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _amountController.text = '${_suggestedAmount[index]}';
                          selectedIndex = index;
                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeExtraSmall,
                              vertical: Dimensions.paddingSizeSmall),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeLarge),
                            decoration: BoxDecoration(
                              color: index == selectedIndex
                                  ? (Get.find<MarketThemeController>(
                                              tag: 'xmarket')
                                          .darkTheme
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.1))
                                  : (Get.find<MarketThemeController>(
                                              tag: 'xmarket')
                                          .darkTheme
                                      ? const Color(0xFF1b1b1b)
                                      : Colors.white),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.2)),
                            ),
                            child: Center(
                              child: Text(
                                '${_suggestedAmount[index]}',
                                style: robotoRegular.copyWith(
                                    color: Get.find<MarketThemeController>(
                                                tag: 'xmarket')
                                            .darkTheme
                                        ? Colors.white
                                        : Color(0xFF55745a)),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Text(
                '${'convertible_amount'.tr}: '
                '${PriceConverter.convertPrice(_convertDouble(_amountController.text) / exchangePointRate!)}',
                style: robotoRegular.copyWith(
                    color: Get.find<MarketThemeController>(tag: 'xmarket')
                            .darkTheme
                        ? Colors.white70
                        : Color(0xFF55745a)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              GetBuilder<LoyaltyController>(builder: (loyaltyController) {
                return CustomButtonWidget(
                  width: 160,
                  buttonText: 'convert_point'.tr,
                  radius: 12,
                  isBorder: true,
                  color:
                      Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
                          ? const Color(0xFF1b1b1b)
                          : Colors.white,
                  textColor:
                      Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
                          ? Colors.white
                          : Colors.black,
                  isLoading: loyaltyController.isLoading,
                  onPressed: () {
                    String pointStr = _amountController.text.trim();
                    if (pointStr.isEmpty) {
                      showCustomSnackBar('enter_point'.tr);
                    } else {
                      int amount = int.parse(pointStr);
                      int? userPoints = Get.find<MarketProfileController>()
                          .userInfoModel!
                          .loyaltyPoint;

                      if (amount < minimumExchangePoint!) {
                        showCustomSnackBar(
                            '${'please_exchange_more_then'.tr} $minimumExchangePoint ${'points'.tr}');
                      } else if (userPoints! < amount) {
                        showCustomSnackBar(
                            'you_do_not_have_enough_point_to_exchange'.tr);
                      } else {
                        loyaltyController.convertPointToWallet(amount);
                      }
                    }
                  },
                );
              }),
            ]),
      ),
    );
  }

  double _convertDouble(String text) {
    try {
      return double.parse(text);
    } catch (e) {
      return 0;
    }
  }
}
