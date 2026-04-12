import 'package:stackfood_multivendor/features/address/controllers/market_address_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomButton extends StatelessWidget {
  final MarketAddressController addressController;
  final bool fromSignUp;
  final String? route;
  const BottomButton(
      {super.key,
      required this.addressController,
      required this.fromSignUp,
      required this.route});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
            width: 700,
            child: Padding(
              padding: Get.width > 700
                  ? const EdgeInsets.all(0)
                  : const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
              child: Column(children: [
                // تم إزالة الأزرار - الموقع يُرسل تلقائياً عند فتح الشاشة
              ]),
            )));
  }
}
