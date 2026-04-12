import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/skeleton.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class ProductShimmer extends StatelessWidget {
  final bool isEnabled;
  final bool isRestaurant;
  final bool hasDivider;
  const ProductShimmer(
      {super.key,
      required this.isEnabled,
      required this.hasDivider,
      this.isRestaurant = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      child: Container(
        margin: EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Skeleton(
                  height: 90,
                  width: 90,
                  radius: Dimensions.radiusDefault,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Skeleton(height: 12, width: 100),
                  SizedBox(height: 4),
                  Skeleton(height: 12, width: 60),
                ],
              ),
              const SizedBox(height: 4),
              const Center(
                child: Skeleton(height: 12, width: 50),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              if (!isRestaurant)
                const Center(
                  child: Skeleton(
                    height: 30,
                    width: 30,
                    isCircle: true,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
