import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';

class CancellationDialogue extends StatefulWidget {
  final int? orderId;
  const CancellationDialogue({super.key, required this.orderId});

  @override
  State<CancellationDialogue> createState() => _CancellationDialogueState();
}

class _CancellationDialogueState extends State<CancellationDialogue> {
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.find<OrderController>().getOrderCancelReasons();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
          ? const Color(0xFF141313)
          : Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: GetBuilder<OrderController>(builder: (orderController) {
        return SizedBox(
          width: 500,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => Get.back(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.cancel_outlined,
                      size: 25, color: Theme.of(context).disabledColor),
                ),
              ),
            ),
            Text('select_cancellation_reasons'.tr,
                style: robotoSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Get.find<MarketThemeController>(tag: 'xmarket')
                            .darkTheme
                        ? Colors.white
                        : Color(0xFF55745a))),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: Dimensions.paddingSizeDefault,
                    right: Dimensions.paddingSizeDefault),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      orderController.orderCancelReasons != null
                          ? orderController.orderCancelReasons!.isNotEmpty
                              ? Flexible(
                                  child: ListView.builder(
                                    itemCount: orderController
                                        .orderCancelReasons!.length,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.only(
                                        top: Dimensions.paddingSizeLarge,
                                        bottom: Dimensions.paddingSizeSmall),
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: EdgeInsets.only(
                                            bottom:
                                                Dimensions.paddingSizeSmall),
                                        padding: EdgeInsets.all(
                                            Dimensions.paddingSizeDefault),
                                        decoration: BoxDecoration(
                                          color:
                                              Get.find<MarketThemeController>(
                                                          tag: 'xmarket')
                                                      .darkTheme
                                                  ? const Color(0xFF1b1b1b)
                                                  : Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                          boxShadow: orderController
                                                      .orderCancelReasons![
                                                          index]
                                                      .reason ==
                                                  orderController.cancelReason
                                              ? [
                                                  BoxShadow(
                                                      color: Get.find<MarketThemeController>(
                                                                  tag:
                                                                      'xmarket')
                                                              .darkTheme
                                                          ? Colors.black
                                                              .withValues(
                                                                  alpha: 0.2)
                                                          : Colors.black12,
                                                      blurRadius: 5,
                                                      spreadRadius: 1)
                                                ]
                                              : [],
                                          border: Border.all(
                                              color:
                                                  Get.find<MarketThemeController>(
                                                              tag: 'xmarket')
                                                          .darkTheme
                                                      ? Colors.white10
                                                      : Theme.of(context)
                                                          .disabledColor
                                                          .withValues(
                                                              alpha: 0.2)),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            orderController
                                                .setOrderCancelReason(
                                                    orderController
                                                        .orderCancelReasons![
                                                            index]
                                                        .reason);
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                  orderController
                                                              .orderCancelReasons![
                                                                  index]
                                                              .reason ==
                                                          orderController
                                                              .cancelReason
                                                      ? Icons
                                                          .radio_button_checked
                                                      : Icons.radio_button_off,
                                                  color: orderController
                                                              .orderCancelReasons![
                                                                  index]
                                                              .reason ==
                                                          orderController
                                                              .cancelReason
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Theme.of(context)
                                                          .disabledColor,
                                                  size: 18),
                                              const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall),
                                              Flexible(
                                                  child: Text(
                                                      orderController
                                                          .orderCancelReasons![
                                                              index]
                                                          .reason!,
                                                      style: robotoRegular.copyWith(
                                                          color: Get.find<MarketThemeController>(
                                                                      tag:
                                                                          'xmarket')
                                                                  .darkTheme
                                                              ? Colors.white
                                                              : Color(
                                                                  0xFF55745a)),
                                                      maxLines: 3,
                                                      overflow: TextOverflow
                                                          .ellipsis)),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : SizedBox()
                          : const Center(
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: Dimensions.paddingSizeDefault),
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF9ebc67),
                                  ))),
                      Text(
                        'comments'.tr,
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color:
                                Get.find<MarketThemeController>(tag: 'xmarket')
                                        .darkTheme
                                    ? Colors.white
                                    : Color(0xFF55745a)),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      CustomTextFieldWidget(
                        controller: commentController,
                        titleText: 'type_here'.tr,
                        showLabelText: false,
                        maxLines: 2,
                        inputType: TextInputType.multiline,
                        inputAction: TextInputAction.done,
                        capitalization: TextCapitalization.sentences,
                        maxLength: 100,
                      ),
                    ]),
              ),
            ),
            SizedBox(height: Dimensions.paddingSizeSmall),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeDefault),
              child: !orderController.isCancelLoading
                  ? Row(children: [
                      Expanded(
                          child: CustomButtonWidget(
                        buttonText: 'cancel'.tr,
                        color: Get.find<MarketThemeController>(tag: 'xmarket')
                                .darkTheme
                            ? Colors.white10
                            : Theme.of(context)
                                .disabledColor
                                .withValues(alpha: 0.2),
                        textColor:
                            Get.find<MarketThemeController>(tag: 'xmarket')
                                    .darkTheme
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyLarge?.color,
                        onPressed: () => Get.back(),
                      )),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                          child: CustomButtonWidget(
                        color: Colors.orange,
                        buttonText: 'submit'.tr,
                        onPressed: () {
                          if ((orderController.cancelReason != '' &&
                                  orderController.cancelReason != null) ||
                              commentController.text.isNotEmpty) {
                            orderController
                                .cancelOrder(widget.orderId,
                                    orderController.cancelReason,
                                    comment: commentController.text)
                                .then((success) {
                              if (success) {
                                orderController.trackOrder(
                                    widget.orderId.toString(), null, true);
                              }
                            });
                          } else {
                            if (orderController.cancelReason == '' ||
                                orderController.cancelReason == null) {
                              showCustomSnackBar(
                                  'you_did_not_select_any_reason'.tr);
                            } else if (commentController.text.isEmpty) {
                              showCustomSnackBar(
                                  'you_did_not_write_any_comment'.tr);
                            }
                          }
                        },
                      )),
                    ])
                  : const Center(
                      child: CircularProgressIndicator(
                      color: Color(0xFF9ebc67),
                    )),
            ),
          ]),
        );
      }),
    );
  }
}
