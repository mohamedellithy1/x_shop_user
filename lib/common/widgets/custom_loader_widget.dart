import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLoaderWidget extends StatelessWidget {
  final double size;
  const CustomLoaderWidget({super.key, this.size = 150});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/image/loading_gray.json',
        width: size,
        height: size,
      ),
    );
  }
}
