import 'package:stackfood_multivendor/common/widgets/custom_loader_widget.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:flutter/material.dart';

class OrderShimmerWidget extends StatelessWidget {
  final OrderController orderController;
  const OrderShimmerWidget({super.key, required this.orderController});

  @override
  Widget build(BuildContext context) {
    return const CustomLoaderWidget();
  }
}
