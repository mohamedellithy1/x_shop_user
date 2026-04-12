import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/cart_widget.dart';
import 'package:stackfood_multivendor/common/widgets/veg_filter_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_menu_bar.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CustomAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final bool isBackButtonExist;
  final Function? onBackPressed;
  final bool showCart;
  final Color? bgColor;
  final Function(String value)? onVegFilterTap;
  final String? type;
  final List<Widget>? actions;
  final IconData? backIcon;
  const CustomAppBarWidget(
      {super.key,
      required this.title,
      this.isBackButtonExist = true,
      this.onBackPressed,
      this.showCart = false,
      this.bgColor,
      this.onVegFilterTap,
      this.type,
      this.backIcon,
      this.actions});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context)
        ? const WebMenuBar()
        : PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.red],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: AppBar(
                title: Text(title,
                    style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Colors.white)),
                centerTitle: true,
                leading: isBackButtonExist
                    ? IconButton(
                        icon: Icon(backIcon ?? Icons.arrow_back_ios),
                        color: Colors.white,
                        onPressed: () => onBackPressed != null
                            ? onBackPressed!()
                            : Navigator.pop(context),
                      )
                    : const SizedBox(),
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                actions: showCart || onVegFilterTap != null
                    ? [
                        showCart
                            ? IconButton(
                                onPressed: () =>
                                    Get.offAllNamed(RouteHelper.getMainRoute('cart')),
                                icon: CartWidget(color: Colors.white, size: 25),
                              )
                            : const SizedBox(),
                        onVegFilterTap != null
                            ? VegFilterWidget(
                                type: type,
                                onSelected: onVegFilterTap,
                                fromAppBar: true,
                                iconColor: Colors.white,
                              )
                            : const SizedBox(),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                      ]
                    : actions ?? [const SizedBox()],
              ),
            ),
          );
  }

  @override
  Size get preferredSize =>
      Size(Dimensions.webMaxWidth, GetPlatform.isDesktop ? 100 : 50);
}
