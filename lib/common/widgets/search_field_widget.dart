import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SearchFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? suffixIcon;
  final Function? iconPressed;
  final Function? onSubmit;
  final Function? onChanged;
  final Function()? onTap;
  const SearchFieldWidget(
      {super.key,
      required this.controller,
      required this.hint,
      this.suffixIcon,
      this.iconPressed,
      this.onSubmit,
      this.onChanged,
      this.onTap});

  @override
  State<SearchFieldWidget> createState() => _SearchFieldWidgetState();
}

class _SearchFieldWidgetState extends State<SearchFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      textInputAction: TextInputAction.search,
      onTap: widget.onTap,
      //autofocus: true,
      inputFormatters: [
        FilteringTextInputFormatter.deny(
            RegExp(r'[!@#$%^&*(),.?":{}|<>_+-/~`•√π÷×§∆£¢€¥°=©®™✓;]')),
      ],
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Color(0xFF55745a)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              ResponsiveHelper.isDesktop(context)
                  ? Dimensions.radiusSmall
                  : 60),
          borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              ResponsiveHelper.isDesktop(context)
                  ? Dimensions.radiusSmall
                  : 60),
          borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              ResponsiveHelper.isDesktop(context)
                  ? Dimensions.radiusSmall
                  : 60),
          borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              width: 1.5),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        hoverColor: Colors.transparent,
        suffixIcon: widget.suffixIcon != null
            ? IconButton(
                icon: Icon(widget.suffixIcon,
                    color: Get.find<MarketThemeController>(tag: 'xmarket')
                            .darkTheme
                        ? Colors.black
                        : Colors.white),
                onPressed: widget.iconPressed as void Function()?,
              )
            : null,
      ),
      onSubmitted: widget.onSubmit as void Function(String)?,
      onChanged: widget.onChanged as void Function(String)?,
    );
  }
}
