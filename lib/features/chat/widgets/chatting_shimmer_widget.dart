import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/skeleton.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class ChattingShimmerWidget extends StatelessWidget {
  const ChattingShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * 0.80,
      child: SingleChildScrollView(
        child: Column(children: [
          _buildMessageShimmer(isLeft: true, width: 200, height: 40),
          _buildMessageShimmer(isLeft: false, width: 200, height: 40),
          _buildMessageShimmer(isLeft: true, width: 250, height: 80),
          _buildMessageShimmer(
              isLeft: true, width: 120, height: 120, isImage: true),
          _buildMessageShimmer(isLeft: false, width: 200, height: 40),
          _buildMessageShimmer(isLeft: false, width: 250, height: 80),
          _buildMessageShimmer(isLeft: true, width: 200, height: 40),
          _buildMessageShimmer(isLeft: true, width: 200, height: 40),
          _buildMessageShimmer(
              isLeft: false, width: 120, height: 120, isImage: true),
        ]),
      ),
    );
  }

  Widget _buildMessageShimmer({
    required bool isLeft,
    required double width,
    required double height,
    bool isImage = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        mainAxisAlignment:
            isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isLeft) ...[
            const Skeleton(height: 50, width: 50, isCircle: true),
            const SizedBox(width: Dimensions.paddingSizeDefault),
          ],
          Skeleton(
            height: height,
            width: width,
            radius:
                isImage ? Dimensions.radiusDefault : Dimensions.radiusDefault,
          ),
          if (!isLeft) ...[
            const SizedBox(width: Dimensions.paddingSizeDefault),
            const Skeleton(height: 50, width: 50, isCircle: true),
          ],
        ],
      ),
    );
  }
}
