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
  Offset? _tapPosition;

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
            InkWell(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radiusDefault),
                topRight: Radius.circular(Dimensions.radiusDefault),
              ),
              onTap: () => _showCommentsBottomSheet(context, widget.news),
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
                          padding: const EdgeInsets.only(
                              bottom: Dimensions.paddingSizeSmall),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall),
                              Text(
                                DateConverter.getRelativeTime(
                                    widget.news.createdAt),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
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
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusSmall),
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
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
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
                      ],
                    ),
                  ),
                  _buildReactionSummary(),
                ],
              ),
            ),

            // Bottom Row - Action Buttons
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
                    onTapDown: (details) {
                      _tapPosition = details.globalPosition;
                    },
                    onLongPressStart: (details) {
                      _showReactionsPopup(context, details.globalPosition);
                    },
                    onTap: () async {
                      if (widget.news.myReaction == null) {
                        if (_tapPosition != null) {
                          _showReactionsPopup(context, _tapPosition!);
                        }
                        return;
                      }

                      // If already reacted, send the same reaction to remove it.
                      String reactionToSend = widget.news.myReaction!;

                      final response = await Get.find<NewsController>()
                          .reactToItem('post', widget.news.id, reactionToSend);

                      if (response != null && mounted) {
                        setState(() {
                          // Update values dynamically based on API response
                          if (response.containsKey('my_reaction')) {
                            widget.news.myReaction =
                                response['my_reaction']?.toString();
                            // Sync isLiked with whether user has any reaction
                            widget.news.isLiked =
                                widget.news.myReaction != null;
                          }
                          if (response.containsKey('reactions_count') &&
                              response['reactions_count'] != null) {
                            widget.news.reactionsCount = Map<String, int>.from(
                                response['reactions_count'] as Map);
                            // Sync total likesCount by summing all reaction counts
                            widget.news.likesCount = widget
                                .news.reactionsCount.values
                                .fold(0, (sum, val) => sum + val);
                          }
                          // Fallbacks if backend actually provides them directly
                          if (response.containsKey('is_liked')) {
                            widget.news.isLiked = response['is_liked'] == 1 ||
                                response['is_liked'] == true;
                          }
                          if (response.containsKey('likes_count')) {
                            widget.news.likesCount = int.tryParse(
                                    response['likes_count'].toString()) ??
                                widget.news.likesCount;
                          }
                        });
                      }
                    },
                    child: Row(
                      children: [
                        _buildReactionIcon(),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(
                          _getReactionText(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _getReactionColor(),
                                    fontWeight: widget.news.myReaction != null
                                        ? FontWeight.bold
                                        : FontWeight.normal,
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
                            'تعليق',
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

  final Map<String, String> _reactionToEmoji = {
    'like': '👍',
    'love': '❤️',
    'haha': '😂',
    'wow': '😮',
    'sad': '😢',
    'angry': '😡',
  };

  Widget _buildReactionSummary() {
    if (widget.news.likesCount == 0 && widget.news.commentsCount == 0)
      return const SizedBox.shrink();

    var sortedReactions = widget.news.reactionsCount.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    var topReactions = sortedReactions.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (topReactions.isNotEmpty)
                SizedBox(
                  width: topReactions.length * 18.0 + 4,
                  height: 20,
                  child: Stack(
                    children: List.generate(topReactions.length, (index) {
                      return Positioned(
                        right: index * 14.0, // RTL layout
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Text(
                            _reactionToEmoji[topReactions[index].key] ?? '👍',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              // if (widget.news.likesCount > 0)
              //   Text(
              //     '${widget.news.likesCount}',
              //     style: TextStyle(color: Colors.grey[600], fontSize: 13),
              //   ),
            ],
          ),
          if (widget.news.commentsCount > 0)
            Text(
              '${widget.news.commentsCount} تعليق',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
        ],
      ),
    );
  }

  String _getReactionText() {
    if (widget.news.myReaction == null) return 'إعجاب';
    switch (widget.news.myReaction) {
      case 'like':
        return 'إعجاب';
      case 'love':
        return 'أحببته';
      case 'haha':
        return 'هاها';
      case 'wow':
        return 'واو';
      case 'sad':
        return 'أحزنني';
      case 'angry':
        return 'أغضبني';
      default:
        return 'إعجاب';
    }
  }

  Color _getReactionColor() {
    if (widget.news.myReaction == null) return Colors.grey[600]!;
    switch (widget.news.myReaction) {
      case 'like':
        return const Color(0xFF9ebc67);
      case 'love':
        return Colors.red;
      case 'haha':
        return Colors.orange;
      case 'wow':
        return Colors.orange;
      case 'sad':
        return Colors.orange;
      case 'angry':
        return Colors.red;
      default:
        return const Color(0xFF9ebc67);
    }
  }

  Widget _buildReactionIcon() {
    if (widget.news.myReaction == null ||
        !_reactionToEmoji.containsKey(widget.news.myReaction)) {
      if (widget.news.isLiked) {
        // fallback
        return const Icon(
          Icons.thumb_up,
          size: 25,
          color: Color(0xFF9ebc67),
        );
      }
      return Icon(
        Icons.thumb_up_outlined,
        size: 25,
        color: Colors.grey[600],
      );
    }

    return Text(
      _reactionToEmoji[widget.news.myReaction!]!,
      style: const TextStyle(fontSize: 22),
    );
  }

  void _showReactionsPopup(BuildContext context, Offset position) {
    final List<Map<String, String>> reactions = [
      {'emoji': '👍', 'name': 'like'},
      {'emoji': '❤️', 'name': 'love'},
      {'emoji': '😂', 'name': 'haha'},
      {'emoji': '😮', 'name': 'wow'},
      {'emoji': '😢', 'name': 'sad'},
      {'emoji': '😡', 'name': 'angry'},
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        // Update optimistically for instant feedback
                        setState(() {
                          widget.news.myReaction = reaction['name'];
                          widget.news.isLiked = true;
                        });

                        final response = await Get.find<NewsController>()
                            .reactToItem(
                                'post', widget.news.id, reaction['name']!);

                        if (response != null && mounted) {
                          setState(() {
                            // Update values dynamically based on API response
                            if (response.containsKey('my_reaction')) {
                              widget.news.myReaction =
                                  response['my_reaction']?.toString();
                              widget.news.isLiked =
                                  widget.news.myReaction != null;
                            }
                            if (response.containsKey('reactions_count') &&
                                response['reactions_count'] != null) {
                              widget.news.reactionsCount =
                                  Map<String, int>.from(
                                      response['reactions_count'] as Map);
                              widget.news.likesCount = widget
                                  .news.reactionsCount.values
                                  .fold(0, (sum, val) => sum + val);
                            }

                            // Fallbacks
                            if (response.containsKey('is_liked')) {
                              widget.news.isLiked = response['is_liked'] == 1 ||
                                  response['is_liked'] == true;
                            }
                            if (response.containsKey('likes_count')) {
                              widget.news.likesCount = int.tryParse(
                                      response['likes_count'].toString()) ??
                                  widget.news.likesCount;
                            }
                          });
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
