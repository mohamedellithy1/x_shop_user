import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_dropdown_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/restaurant_registration_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class ZoneSelectionWidget extends StatelessWidget {
  final RestaurantRegistrationController restaurantRegController;
  final List<DropdownItem<int>> zoneList;
  final Function() callBack;
  const ZoneSelectionWidget(
      {super.key,
      required this.restaurantRegController,
      required this.zoneList,
      required this.callBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          border:
              Border.all(color: Theme.of(context).disabledColor, width: 0.3)),
      child: CustomDropdown<int>(
        onChange: (int? value, int index) {
          restaurantRegController.setZoneIndex(value);
          callBack();
        },
        dropdownButtonStyle: DropdownButtonStyle(
          height: 50,
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeExtraSmall,
            horizontal: Dimensions.paddingSizeExtraSmall,
          ),
          primaryColor: Theme.of(context).textTheme.bodyLarge!.color,
        ),
        iconColor: Theme.of(context).textTheme.bodyMedium!.color,
        dropdownStyle: DropdownStyle(
          elevation: 10,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        ),
        items: zoneList,
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text((restaurantRegController.selectedZoneIndex != -1 &&
                  restaurantRegController.zoneList != null &&
                  restaurantRegController.selectedZoneIndex! <
                      restaurantRegController.zoneList!.length)
              ? restaurantRegController
                  .zoneList![restaurantRegController.selectedZoneIndex!]
                  .name!
                  .tr
              : 'select_zone'.tr),
        ),
      ),
    );
  }
}
