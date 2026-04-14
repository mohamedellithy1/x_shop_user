import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CustomButtonWidget extends StatelessWidget {
  final Function? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? fontSize;
  final double radius;
  final IconData? icon;
  final bool isBorder;
  final Color? color;
  final Color? textColor;
  final bool isLoading;
  final bool isBold;
  const CustomButtonWidget(
      {super.key,
      this.onPressed,
      required this.buttonText,
      this.transparent = false,
      this.margin,
      this.width,
      this.isBorder = true,
      this.height,
      this.fontSize,
      this.radius = 10,
      this.icon,
      this.color,
      this.textColor,
      this.isLoading = false,
      this.isBold = true});

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      backgroundColor:Color(0xFF9ebc67),
      minimumSize: Size(width != null ? width! : Dimensions.webMaxWidth,
          height != null ? height! : 50),
      padding: EdgeInsets.zero,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        //  border:isBorder? Border.all(color: color ?? Colors.black, width: 1) : null,
      ),
      child: Center(
          child: SizedBox(
              width: width ?? Dimensions.webMaxWidth,
              child: Padding(
                padding: margin == null ? const EdgeInsets.all(0) : margin!,
                child: TextButton(
                  onPressed: isLoading ? null : onPressed as void Function()?,
                  style: flatButtonStyle,
                  child: isLoading
                      ? Center(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 15,
                                  width: 15,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        textColor ?? Colors.white),
                                    strokeWidth: 2,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(
                                    width: Dimensions.paddingSizeSmall),
                                Text('loading'.tr,
                                    style: robotoMedium.copyWith(
                                        color: textColor ?? Colors.white)),
                              ]),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              icon != null
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          right:
                                              Dimensions.paddingSizeExtraSmall),
                                      child: Icon(icon,
                                          color: textColor ?? Colors.white),
                                    )
                                  : const SizedBox(),
                              Text(buttonText,
                                  textAlign: TextAlign.center,
                                  style: isBold
                                      ? robotoBold.copyWith(
                                          color: textColor ?? Colors.white,
                                          fontSize: fontSize ??
                                              Dimensions.fontSizeLarge,
                                        )
                                      : robotoRegular.copyWith(
                                          color: textColor ?? Colors.white,
                                          fontSize: fontSize ??
                                              Dimensions.fontSizeLarge,
                                        )),
                            ]),
                ),
              ))),
    );
  }
}
