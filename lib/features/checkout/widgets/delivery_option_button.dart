import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/common/widgets/custom_tool_tip.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/custom_validator.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class DeliveryOptionButton extends StatelessWidget {
  final String value;
  final String title;
  final double? charge;
  final bool? isFree;
  final double total;
  final String? chargeForView;
  final JustTheController? deliveryFeeTooltipController;
  final double badWeatherCharge;
  final double extraChargeForToolTip;
  final TextEditingController? guestNameTextEditingController;
  final TextEditingController? guestNumberTextEditingController;
  final TextEditingController? guestEmailController;
  const DeliveryOptionButton(
      {super.key,
      required this.value,
      required this.title,
      required this.charge,
      required this.isFree,
      required this.total,
      this.chargeForView,
      this.deliveryFeeTooltipController,
      required this.badWeatherCharge,
      required this.extraChargeForToolTip,
      this.guestNameTextEditingController,
      this.guestNumberTextEditingController,
      this.guestEmailController});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(
      builder: (checkoutController) {
        bool select = checkoutController.orderType == value;
        return InkWell(
          onTap: () async {
            checkoutController.setOrderType(value);
            checkoutController.setInstruction(-1);

            if (checkoutController.orderType == 'take_away') {
              checkoutController.addTips(0);
              if (checkoutController.isPartialPay ||
                  checkoutController.paymentMethodIndex == 1) {
                double tips = 0;
                try {
                  tips = double.parse(checkoutController.tipController.text);
                } catch (_) {}
                checkoutController.checkBalanceStatus(total,
                    discount: charge! + tips);
              }
            } else if (checkoutController.orderType == 'dine_in') {
              checkoutController.addTips(0);
              if (checkoutController.isPartialPay ||
                  checkoutController.paymentMethodIndex == 1) {
                double tips = 0;
                try {
                  tips = double.parse(checkoutController.tipController.text);
                } catch (_) {}
                checkoutController.checkBalanceStatus(total,
                    discount: charge! + tips);
              }

              if (AuthHelper.isLoggedIn()) {
                String phone = await _splitPhoneNumber(
                    Get.find<MarketProfileController>()
                            .userInfoModel
                            ?.userInfo
                            ?.phone ??
                        '');

                guestNameTextEditingController?.text =
                    '${Get.find<MarketProfileController>().userInfoModel?.userInfo?.fName ?? ''} ${Get.find<MarketProfileController>().userInfoModel?.userInfo?.fName ?? ''}';
                guestNumberTextEditingController?.text = phone;
                guestEmailController?.text = Get.find<MarketProfileController>()
                        .userInfoModel
                        ?.userInfo
                        ?.email ??
                    '';
              }
            } else {
              checkoutController.updateTips(
                checkoutController.getDmTipIndex().isNotEmpty
                    ? int.parse(checkoutController.getDmTipIndex())
                    : 0,
                notify: false,
              );

              if (checkoutController.isPartialPay) {
                checkoutController.changePartialPayment();
              } else {
                checkoutController.setPaymentMethod(-1);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: select ? (Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? const Color(0xFF1b1b1b) : Theme.of(context).cardColor) : Colors.transparent,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(
                  color: select
                      ? Theme.of(context).primaryColor
                      : (Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? Colors.white10 : Theme.of(context).disabledColor),
                  width: 0.5),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeSmall),
            child: Row(
              children: [
                RadioGroup(
                  groupValue: checkoutController.orderType,
                  onChanged: (String? value) {
                    checkoutController.setOrderType(value!);
                  },
                  child: Radio(
                    value: value,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeColor: Theme.of(context).primaryColor,
                    visualDensity:
                        const VisualDensity(horizontal: -3, vertical: -3),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title,
                      style: robotoMedium.copyWith(
                          color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? Colors.white : Theme.of(context).textTheme.bodyMedium!.color)),
                  if (value == 'delivery')
                    Row(children: [
                      Text('${'charge'.tr}: +$chargeForView',
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? Colors.white60 : Theme.of(context).textTheme.bodyMedium!.color)),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      checkoutController.extraCharge != null &&
                              (chargeForView! != '0') &&
                              extraChargeForToolTip > 0
                          ? CustomToolTip(
                              message:
                                  '${'this_charge_include_extra_vehicle_charge'.tr} ${PriceConverter.convertPrice(extraChargeForToolTip)} ${badWeatherCharge > 0 ? '${'and_bad_weather_charge'.tr} ${PriceConverter.convertPrice(badWeatherCharge)}' : ''}',
                              tooltipController: deliveryFeeTooltipController,
                              preferredDirection: AxisDirection.right,
                              child: const Icon(Icons.info,
                                  color: Colors.blue, size: 14),
                            )
                          : const SizedBox(),
                    ]),
                ]),
                const SizedBox(width: Dimensions.paddingSizeSmall),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> _splitPhoneNumber(String number) async {
    PhoneValid phoneNumber = await CustomValidator.isPhoneValid(number);
    Get.find<CheckoutController>().countryDialCode =
        '+${phoneNumber.countryCode}';
    return phoneNumber.phone.replaceFirst('+${phoneNumber.countryCode}', '');
  }
}
