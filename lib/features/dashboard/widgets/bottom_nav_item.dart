import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BottomNavItem extends StatelessWidget {
  final IconData iconData;
  final Function? onTap;
  final bool isSelected;
  final String title;
  const BottomNavItem(
      {super.key,
      required this.iconData,
      this.onTap,
      this.isSelected = false,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        onTap: onTap as void Function()?,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData,
                color: isSelected ? Colors.white : Colors.white70, size: 25),
            Text(title,
                style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
