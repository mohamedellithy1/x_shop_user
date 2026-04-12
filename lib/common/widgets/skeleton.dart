import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class Skeleton extends StatelessWidget {
  final double? height;
  final double? width;
  final double? radius;
  final bool isCircle;
  final EdgeInsetsGeometry? margin;

  const Skeleton({
    super.key,
    this.height,
    this.width,
    this.radius,
    this.isCircle = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Shimmer(
        duration: const Duration(seconds: 2),
        interval: const Duration(seconds: 1),
        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.15),
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle
                ? null
                : BorderRadius.circular(radius ?? Dimensions.radiusSmall),
          ),
        ),
      ),
    );
  }
}
