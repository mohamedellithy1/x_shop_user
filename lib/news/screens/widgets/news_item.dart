import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stackfood_multivendor/news/controllers/news_controller.dart';
import 'package:stackfood_multivendor/news/domain/entities/comments.dart';
import 'package:stackfood_multivendor/news/domain/models/news_model.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:get/get.dart';
import 'comments_bottom_sheet.dart';

import '../../domain/entities/news.dart';

class NewsItemWidget extends StatefulWidget {
  final News news;
  final List<CommentEntity> comments;

  const NewsItemWidget({
    super.key,
    required this.news,
    required this.comments,
  });

  @override
  State<NewsItemWidget> createState() => _NewsItemWidgetState();
}

class _NewsItemWidgetState extends State<NewsItemWidget> {
  bool isliked = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // News Image
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: CachedNetworkImage(
                    imageUrl: widget.news.image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              // News Title
              Text(
                widget.news.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              // News Body
              if (widget.news.body.isNotEmpty)
                Text(
                  widget.news.body,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 200,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              // Zone Name
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: Dimensions.paddingSizeExtraSmall,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Text(
                  widget.news.zone?.name ?? 'غير محدد',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              // Bottom Row - Date, Likes, Comments
              Row(
                children: [
                  // Date
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(
                          widget.news.createdAt,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),

                  // Likes
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isliked) {
                          widget.news.likesCount = widget.news.likesCount - 1;
                          isliked = false;
                        } else {
                          widget.news.likesCount = widget.news.likesCount + 1;
                          isliked = true;
                        }
                      });
                      Get.find<NewsController>().likeNews(widget.news.id);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.thumb_up_outlined,
                          size: 25,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(
                          '${widget.news.likesCount}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  // Comments
                  InkWell(
                    onTap: () {
                      _showCommentsBottomSheet(context, widget.news);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 25,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(
                          '${widget.news.commentsCount}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context, News news) {
    Get.bottomSheet(
      CommentsBottomSheet(news: news),
      isScrollControlled: true,
    );
  }
}
