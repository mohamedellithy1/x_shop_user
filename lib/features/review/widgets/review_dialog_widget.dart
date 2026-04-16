import 'package:stackfood_multivendor/common/models/review_model.dart';
import 'package:stackfood_multivendor/common/widgets/rating_bar_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';

class ReviewDialogWidget extends StatelessWidget {
  final ReviewModel review;
  final bool fromOrderDetails;
  const ReviewDialogWidget(
      {super.key, required this.review, this.fromOrderDetails = false});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: !fromOrderDetails
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    ClipOval(
                      child: CustomImageWidget(
                        image: review.foodImageFullUrl ?? '',
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                            review.foodName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoBold.copyWith(
                                color: Color(0xFF55745a),
                                fontSize: Dimensions.fontSizeSmall),
                          ),
                          RatingBarWidget(
                              rating: review.rating!.toDouble(),
                              ratingCount: null,
                              size: 15),
                          Text(
                            review.customerName ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoMedium.copyWith(
                                color: Color(0xFF55745a),
                                fontSize: Dimensions.fontSizeExtraSmall),
                          ),
                          Text(
                            review.comment!,
                            style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Color(0xFF55745a)),
                          ),
                        ])),
                  ])
                : Text(
                    review.comment!,
                    style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color:Color(0xFF55745a)),
                  ),
          )),
    );
  }
}
