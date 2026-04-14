import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                  colors: [
                    Color(0xFFe3ebd5),
                    Color(0xFFfafff4),
                    Color(0xFFe3ebd5),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),

                // gradient: LinearGradient(
                //   colors: [Color(0xFFd6e0c4), Color(0xFFe7feba)],
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                // ),
                // color: Color(0xFFd6e0c4),
              ),
              child: AppBar(
                systemOverlayStyle: SystemUiOverlayStyle.dark,
                title: Text(title,
                    style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Colors.black)),
                centerTitle: true,
                leading: isBackButtonExist
                    ? IconButton(
                        icon: Icon(backIcon ?? Icons.arrow_back_ios),
                        color: Colors.black,
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
                                onPressed: () => Get.offAllNamed(
                                    RouteHelper.getMainRoute('cart')),
                                icon: CartWidget(color: Colors.black, size: 25),
                              )
                            : const SizedBox(),
                        onVegFilterTap != null
                            ? VegFilterWidget(
                                type: type,
                                onSelected: onVegFilterTap,
                                fromAppBar: true,
                                iconColor: Colors.black,
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
