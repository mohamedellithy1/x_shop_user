import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/features/wallet/domain/models/wallet_filter_body_model.dart';
import 'package:stackfood_multivendor/features/wallet/controllers/wallet_controller.dart';
import 'package:stackfood_multivendor/features/wallet/widgets/history_cart_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/skeleton.dart';

class WalletHistoryWidget extends StatelessWidget {
  const WalletHistoryWidget({super.key});

  List<PopupMenuEntry> _generateFilteredMethod(
      BuildContext context,
      List<WalletFilterBodyModel>? walletFilterList,
      MarketWalletController walletController) {
    List<PopupMenuEntry> entryList = [];
    for (int i = 0; i < walletFilterList!.length; i++) {
      entryList.add(PopupMenuItem<int>(
          value: i,
          child: Text(
            walletFilterList[i].title!.tr,
            style: robotoMedium.copyWith(
              color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
                  ? Colors.white
                  : Colors.black,
            ),
          )));
    }
    return entryList;
  }

  String _setUpFilteredName(List<WalletFilterBodyModel>? walletFilterList,
      MarketWalletController walletController) {
    String filterName = '';
    for (int i = 0; i < walletController.walletFilterList.length; i++) {
      if (walletController.walletFilterList[i].value == walletController.type) {
        filterName = walletController.walletFilterList[i].title!.tr;
      } else if (walletController.type == 'all') {
        filterName = '';
      }
    }
    return filterName;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarketWalletController>(builder: (walletController) {
      List<PopupMenuEntry> entryList = _generateFilteredMethod(
          context, walletController.walletFilterList, walletController);
      String filterName = _setUpFilteredName(
          walletController.walletFilterList, walletController);

      return Column(children: [
        Padding(
          padding: EdgeInsets.only(
              top: ResponsiveHelper.isDesktop(context)
                  ? Dimensions.paddingSizeExtraSmall
                  : Dimensions.paddingSizeExtraLarge),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'wallet_history'.tr,
                style:
                    robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                filterName,
                style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).primaryColor),
              ),
            ]),
            PopupMenuButton<dynamic>(
              offset: const Offset(-20, 20),
              itemBuilder: (BuildContext context) => entryList,
              onSelected: (dynamic value) {
                walletController.setWalletFilerType(
                    walletController.walletFilterList[value].value!);
                walletController.getWalletTransactionList(
                    '1', false, walletController.type);
              },
              padding: const EdgeInsets.symmetric(horizontal: 2),
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  border: Border.all(
                      color: Theme.of(context).disabledColor, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeExtraSmall,
                      vertical: 2),
                  child: Row(children: [
                    Text(
                      'filter'.tr,
                      style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 18),
                  ]),
                ),
              ),
            ),
          ]),
        ),
        walletController.transactionList != null
            ? walletController.transactionList!.isNotEmpty
                ? GridView.builder(
                    key: UniqueKey(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 50,
                      mainAxisSpacing: ResponsiveHelper.isDesktop(context)
                          ? Dimensions.paddingSizeSmall
                          : 0.01,
                      childAspectRatio:
                          ResponsiveHelper.isDesktop(context) ? 7 : 4.45,
                      crossAxisCount:
                          ResponsiveHelper.isMobile(context) ? 1 : 1,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: walletController.transactionList!.length,
                    padding: EdgeInsets.only(
                        top: ResponsiveHelper.isDesktop(context) ? 28 : 15),
                    itemBuilder: (context, index) {
                      return HistoryCartWidget(
                          index: index, data: walletController.transactionList);
                    },
                  )
                : NoDataScreen(
                    title: 'no_transaction_yet'.tr, isEmptyTransaction: true)
            : WalletShimmer(walletController: walletController),
        walletController.isLoading
            ? const Center(
                child: Padding(
                padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: CircularProgressIndicator(),
              ))
            : const SizedBox(),
      ]);
    });
  }
}

class WalletShimmer extends StatelessWidget {
  final MarketWalletController walletController;
  const WalletShimmer({super.key, required this.walletController});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: UniqueKey(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 50,
        mainAxisSpacing: ResponsiveHelper.isDesktop(context)
            ? Dimensions.paddingSizeLarge
            : 0.01,
        childAspectRatio: ResponsiveHelper.isDesktop(context) ? 5 : 4.1,
        crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 1,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 10,
      padding:
          EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? 28 : 25),
      itemBuilder: (context, index) {
        return Padding(
          padding:
              const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(height: 10, width: 50),
                        SizedBox(height: 10),
                        Skeleton(height: 10, width: 70),
                      ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Skeleton(height: 10, width: 50),
                    SizedBox(height: 10),
                    Skeleton(height: 10, width: 70),
                  ]),
                ],
              ),
              Padding(
                  padding:
                      const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                  child: Divider(color: Theme.of(context).disabledColor)),
            ],
          ),
        );
      },
    );
  }
}
