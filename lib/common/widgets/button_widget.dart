import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ButtonWidget extends StatelessWidget {
  final Function()? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets margin;
  final double height;
  final double width;
  final double? fontSize;
  final double radius;
  final IconData? icon;
  final bool showBorder;
  final double borderWidth;
  final Color? borderColor;
  final Color? textColor;
  final bool isFind;
  final Color? backgroundColor;
  final bool boldText;
  const ButtonWidget(
      {super.key,
      this.onPressed,
      required this.buttonText,
      this.transparent = false,
      this.isFind = false,
      this.margin = EdgeInsets.zero,
      this.width = Dimensions.webMaxWidth,
      this.height = 45,
      this.fontSize,
      this.radius = 5,
      this.icon,
      this.showBorder = false,
      this.borderWidth = 1,
      this.borderColor,
      this.textColor,
      this.backgroundColor,
      this.boldText = true});

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      backgroundColor: backgroundColor == null ? Colors.white : backgroundColor,
      minimumSize: Size(width, height),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: showBorder
            ? BorderSide(color: Colors.black, width: borderWidth)
            : const BorderSide(color: Colors.transparent),
      ),
    );

    return Center(
        child: Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.black, width: borderWidth),
      ),
      child: Padding(
        padding: margin,
        child: TextButton(
          onPressed: onPressed,
          style: flatButtonStyle,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            icon != null
                ? Padding(
                    padding: const EdgeInsets.only(
                        right: Dimensions.paddingSizeExtraSmall),
                    child: Icon(icon, color: Colors.black),
                  )
                : const SizedBox(),
            Flexible(
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                style: boldText
                    ? robotoBold.copyWith(
                        color: textColor == null ? Colors.black : textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize ?? Dimensions.fontSizeDefault,
                        overflow: TextOverflow.ellipsis,
                      )
                    : robotoBold.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize ?? Dimensions.fontSizeLarge,
                      ),
              ),
            ),
          ]),
        ),
      ),
    ));
  }
}
