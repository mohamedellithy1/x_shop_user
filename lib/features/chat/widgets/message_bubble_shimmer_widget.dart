import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/skeleton.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class MessageBubbleShimmerWidget extends StatelessWidget {
  final bool isMe;
  const MessageBubbleShimmerWidget({super.key, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isMe
          ? const EdgeInsets.fromLTRB(50, 5, 10, 5)
          : const EdgeInsets.fromLTRB(10, 5, 50, 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Skeleton(
              height: 30,
              width: MediaQuery.of(context).size.width,
              radius: Dimensions.radiusDefault,
            ),
          ),
        ],
      ),
    );
  }
}
