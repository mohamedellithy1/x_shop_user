import 'package:stackfood_multivendor/common/widgets/custom_loader_widget.dart';
import 'package:flutter/material.dart';

class RestaurantScreenShimmerWidget extends StatelessWidget {
  const RestaurantScreenShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CustomLoaderWidget());
  }
}
