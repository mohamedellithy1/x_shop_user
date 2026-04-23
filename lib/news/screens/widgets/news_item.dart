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
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        // vertical: Dimensions.paddingSizeSmall,
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: Dimensions.paddingSizeDefault,
                left: Dimensions.paddingSizeDefault,
                right: Dimensions.paddingSizeDefault,
                bottom: Dimensions.paddingSizeSmall,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Time Badge at the top right of the card itself
              Padding(
                padding:
                    const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(
                      DateConverter.getRelativeTime(widget.news.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),

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
                        child: CircularProgressIndicator(
                          color: Color(0xFF9ebc67),
                        ),
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

              // // Zone Name
              // if (widget.news.zone != null && widget.news.zone?.name != null)
              //   Container(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: Dimensions.paddingSizeSmall,
              //       vertical: Dimensions.paddingSizeExtraSmall,
              //     ),
              //     decoration: BoxDecoration(
              //       color: Theme.of(context).primaryColor.withOpacity(0.1),
              //       borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              //     ),
              //     child: Text(
              //       widget.news.zone?.name ?? '',
              //       style: Theme.of(context).textTheme.bodySmall?.copyWith(
              //             color: Colors.black,
              //             fontWeight: FontWeight.w500,
              //           ),
              //     ),
              //   ),

              // const SizedBox(height: Dimensions.paddingSizeSmall),
                ],
              ),
            ),

              // Bottom Row - Date, Likes, Comments
              Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(Dimensions.radiusDefault),
                    bottomRight: Radius.circular(Dimensions.radiusDefault),
                  ),
                  border: Border.all(
                    color: Color(0xFF9ebc67),
                  ),
                  // gradient: const LinearGradient(
                  //   colors: [
                  //     Color(0xFFe3ebd5),
                  //     Color(0xFFfafff4),
                  //     Color(0xFFe3ebd5),
                  //   ],
                  //   begin: Alignment.centerLeft,
                  //   end: Alignment.centerRight,
                  // ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Date
                    // Expanded(
                    //   child: Row(
                    //     children: [
                    //       Icon(
                    //         Icons.access_time,
                    //         size: 16,
                    //         color: Colors.grey[600],
                    //       ),
                    //       const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    //       Text(
                    //         DateConverter.dateTimeStringToDateTime(
                    //             widget.news.createdAt),
                    //         style:
                    //             Theme.of(context).textTheme.bodySmall?.copyWith(
                    //                   color: Colors.grey[600],
                    //                 ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    // Likes with Reactions
                    GestureDetector(
                      onLongPressStart: (details) {
                        _showReactionsPopup(context, details.globalPosition);
                      },
                      onTap: () async {
                        bool? isLikedResponse = await Get.find<NewsController>()
                            .likeNews(widget.news.id);

                        if (isLikedResponse != null && mounted) {
                          setState(() {
                            widget.news.isLiked = isLikedResponse;
                            if (isLikedResponse) {
                              widget.news.likesCount =
                                  widget.news.likesCount + 1;
                            } else {
                              widget.news.likesCount =
                                  widget.news.likesCount - 1;
                            }
                          });
                        }
                      },
                      child: Row(
                        children: [
                          _buildReactionIcon(),
                          const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall),
                          Text(
                            '${widget.news.likesCount}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: widget.news.isLiked
                                          ? const Color(0xFF9ebc67)
                                          : Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: Dimensions.paddingSizeExtraOverLarge),

                    // Comments
                    if (widget.news.canComment)
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
                            const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall),
                            Text(
                              '${widget.news.commentsCount}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
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

  String? _selectedReaction; // Local state for the selected emoji/reaction

  Widget _buildReactionIcon() {
    if (!widget.news.isLiked) {
      return Icon(
        Icons.thumb_up_outlined,
        size: 25,
        color: Colors.grey[600],
      );
    }

    // Default to Like if liked but no reaction selected yet
    if (_selectedReaction == null) {
      return const Icon(
        Icons.thumb_up,
        size: 25,
        color: Color(0xFF9ebc67),
      );
    }

    return Text(
      _selectedReaction!,
      style: const TextStyle(fontSize: 22),
    );
  }

  void _showReactionsPopup(BuildContext context, Offset position) {
    final List<Map<String, String>> reactions = [
      {'emoji': '👍', 'name': 'Like'},
      {'emoji': '❤️', 'name': 'Love'},
      {'emoji': '😂', 'name': 'Haha'},
      {'emoji': '😮', 'name': 'Wow'},
      {'emoji': '😢', 'name': 'Sad'},
      {'emoji': '😡', 'name': 'Angry'},
    ];

    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Background listener to close on tap outside
          Positioned.fill(
            child: GestureDetector(
              onTap: () => overlayEntry?.remove(),
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: position.dx > 200 ? position.dx - 200 : 20,
            top: position.dy - 80,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: reactions.map((reaction) {
                    return GestureDetector(
                      onTap: () async {
                        overlayEntry?.remove();
                        setState(() {
                          _selectedReaction = reaction['emoji'];
                        });

                        // Call API if not already liked
                        if (!widget.news.isLiked) {
                          bool? success = await Get.find<NewsController>()
                              .likeNews(widget.news.id);
                          if (success != null && mounted) {
                            setState(() {
                              widget.news.isLiked = success;
                              if (success) {
                                widget.news.likesCount++;
                              }
                            });
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Transform.scale(
                          scale: 1.2,
                          child: Text(
                            reaction['emoji']!,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }
}
