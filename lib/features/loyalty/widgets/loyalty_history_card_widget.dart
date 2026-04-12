import 'package:stackfood_multivendor/features/wallet/domain/models/wallet_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';

class LoyaltyHistoryCardWidget extends StatelessWidget {
  final int index;
  final List<Transaction>? data;
  const LoyaltyHistoryCardWidget(
      {super.key, required this.index, required this.data});

  @override
  Widget build(BuildContext context) {
    bool isDebit = data![index].transactionType == 'point_to_wallet';

    return Column(children: [
      Padding(
        padding:
            const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Row(
          children: [
            // Icon at the start
            // Container(
            //   padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
            //     borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            //   ),
            //   child: Image.asset(
            //     Images.loyaltyIcon,
            //     height: 24,
            //     width: 24,
            //     color: Colors.black,
            //   ),
            // ),
            const SizedBox(width: Dimensions.paddingSizeDefault),

            // Transaction details in the middle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTransactionTitle(data![index]),
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text(
                    DateConverter.localDateToIsoStringAMPM(
                        data![index].createdAt!),
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? Colors.white70 : Colors.black.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Points at the end
            Text(
              isDebit
                  ? '${data![index].debit!.toStringAsFixed(0)}-'
                  : '${data![index].credit!.toStringAsFixed(0)}+',
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: isDebit ? Colors.red : (Get.find<MarketThemeController>(tag: 'xmarket').darkTheme ? Colors.white : Colors.black),
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),

      // Dashed Divider
      index == data!.length - 1
          ? const SizedBox()
          : CustomDashedDivider(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
            ),
    ]);
  }

  String _getTransactionTitle(Transaction transaction) {
    switch (transaction.transactionType) {
      case 'point_to_wallet':
        return 'point_converted'.tr;
      case 'add_fund':
        return 'added_via'.tr;
      case 'partial_payment':
        return '${'spend_on_order'.tr} # ${transaction.reference}';
      case 'loyalty_point':
        return 'converted_from_loyalty_point'.tr;
      case 'referrer':
        return 'earned_by_referral'.tr;
      case 'order_place':
        return '${'order_place'.tr} # ${transaction.reference}';
      default:
        return transaction.transactionType!.tr;
    }
  }
}

// Custom Dashed Divider Widget
class CustomDashedDivider extends StatelessWidget {
  final Color color;
  final double height;
  final double dashWidth;
  final double dashSpace;

  const CustomDashedDivider({
    super.key,
    this.color = Colors.grey,
    this.height = 1,
    this.dashWidth = 5,
    this.dashSpace = 3,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
