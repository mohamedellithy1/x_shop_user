import 'package:stackfood_multivendor/common/widgets/custom_loader_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/address/controllers/market_address_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/address/widgets/address_card_widget.dart';
import 'package:stackfood_multivendor/features/home/controllers/home_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocationDropdown extends StatefulWidget {
  final Widget child;
  const LocationDropdown({super.key, required this.child});

  @override
  State<LocationDropdown> createState() => _LocationDropdownState();
}

class _LocationDropdownState extends State<LocationDropdown>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _expandAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    if (_isOpen) {
      _overlayEntry?.remove();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _animationController.forward();
  }

  void _close() async {
    if (_isOpen) {
      await _animationController.reverse();
      _overlayEntry?.remove();
      _overlayEntry = null;
      if (mounted) setState(() => _isOpen = false);
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(size.width * 0.05, size.height + 5),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.only(right: 20),
                width: size.width * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: CustomPaint(
                        size: const Size(15, 8),
                        painter:
                            TrianglePainter(color: Theme.of(context).cardColor),
                      ),
                    ),
                    Material(
                      elevation: 8,
                      shadowColor: Colors.black.withValues(alpha: 0.3),
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      clipBehavior: Clip.antiAlias,
                      color: Theme.of(context).cardColor,
                      child: SizeTransition(
                        sizeFactor: _expandAnimation,
                        axisAlignment: -1,
                        child: Container(
                          constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.4),
                          child: GetBuilder<MarketAddressController>(
                            id: 'xmarket',
                            init: Get.find<MarketAddressController>(
                                tag: 'xmarket'),
                            builder: (addressController) {
                              AddressModel? selectedAddress =
                                  AddressHelper.getAddressFromSharedPref();
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Scrollbar(
                                      thickness: 3,
                                      radius: const Radius.circular(10),
                                      child: SingleChildScrollView(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: Dimensions
                                                .paddingSizeExtraSmall),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _buildItem(
                                                    icon: Icons.my_location,
                                                    title:
                                                        'use_current_location'
                                                            .tr,
                                                    onTap: () {
                                                      _close();
                                                      _onCurrentLocationButtonPressed();
                                                    },
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    _close();
                                                    Get.find<HomeController>()
                                                        .forcePauseVideo(true);
                                                    Get.toNamed(RouteHelper
                                                        .getAddAddressRoute(
                                                            false, 0));
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .all(Dimensions
                                                            .paddingSizeExtraSmall),
                                                    margin: const EdgeInsets
                                                        .only(
                                                        right: Dimensions
                                                            .paddingSizeDefault),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withValues(
                                                              alpha: 0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(Icons.add,
                                                        color: Colors.orange,
                                                        size: 20),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Divider(
                                                height: 1, thickness: 0.5),
                                            if (addressController.addressList !=
                                                    null &&
                                                addressController
                                                    .addressList!.isNotEmpty)
                                              ...addressController.addressList!
                                                  .map((address) {
                                                bool selected =
                                                    selectedAddress?.id ==
                                                        address.id;
                                                return AddressCardWidget(
                                                  address: address,
                                                  fromAddress: false,
                                                  isSelected: selected,
                                                  fromDashBoard: true,
                                                  onTap: () {
                                                    _close();
                                                    Get.dialog(
                                                        const CustomLoaderWidget(),
                                                        barrierDismissible:
                                                            false);
                                                    Get.find<
                                                            MarketLocationController>()
                                                        .saveAddressAndNavigate(
                                                      address,
                                                      false,
                                                      null,
                                                      false,
                                                      ResponsiveHelper
                                                          .isDesktop(context),
                                                    );
                                                  },
                                                );
                                              }),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 4,
                                    width: 30,
                                    margin: const EdgeInsets.only(
                                        bottom: 5, top: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .disabledColor
                                          .withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall),
        child: Row(children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
              child: Text(title,
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Color(0xFF55745a)))),
        ]),
      ),
    );
  }

  void _onCurrentLocationButtonPressed() {
    Get.find<MarketLocationController>().checkPermission(() async {
      Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
      AddressModel address =
          await Get.find<MarketLocationController>().getCurrentLocation(true);
      ZoneResponseModel response = await Get.find<MarketLocationController>()
          .getZone(address.latitude, address.longitude, false);
      if (response.isSuccess) {
        Get.find<MarketLocationController>().saveAddressAndNavigate(
          address,
          false,
          '',
          false,
          ResponsiveHelper.isDesktop(Get.context),
        );
      } else {
        Get.back();
        Get.find<HomeController>().forcePauseVideo(true);
        Get.toNamed(
            RouteHelper.getPickMapRoute(RouteHelper.accessLocation, false));
        showCustomSnackBar('service_not_available_in_current_location'.tr);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: widget.child,
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = color;
    var path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
