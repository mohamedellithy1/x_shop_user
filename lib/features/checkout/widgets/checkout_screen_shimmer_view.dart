import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_loader_widget.dart';

class CheckoutScreenShimmerView extends StatelessWidget {
  const CheckoutScreenShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CustomLoaderWidget());
  }
}

class CheckoutShimmerView extends StatelessWidget {
  const CheckoutShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CustomLoaderWidget());
  }
}
