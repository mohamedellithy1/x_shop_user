import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:stackfood_multivendor/news/controllers/news_controller.dart';
import 'package:stackfood_multivendor/news/domain/entities/comments.dart';
import 'package:stackfood_multivendor/news/domain/entities/news.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';

class CommentsBottomSheet extends StatefulWidget {
  final News news;

  const CommentsBottomSheet({
    super.key,
    required this.news,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  String? _replyingTo;
  int? _replyingToCommentId;

  @override
  void initState() {
    super.initState();
    Get.find<NewsController>().getComments(widget.news.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _startReply(String userName, int commentId) {
    setState(() {
      _replyingTo = userName;
      _replyingToCommentId = commentId;
      _commentController.text = '@$userName ';
      _commentFocusNode.requestFocus();
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
      _replyingToCommentId = null;
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewsController>(
      builder: (newsController) {
        final comments = newsController.getCommentsForPost(widget.news.id);

        // إضافة debug prints
        print("Building CommentsBottomSheet for news ID: ${widget.news.id}");
        print("Comments count: ${comments.length}");
        print("Comments: $comments");

        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF9ebc67),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.black),
                    ),
                    Expanded(
                      child: Text(
                        'التعليقات (${comments.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: _buildCommentsList(comments),
              ),
              const SizedBox(height: 16),

              // Add Comment Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black),
                ),
                child: Column(
                  children: [
                    // Reply Indicator
                    if (_replyingTo != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.reply,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'الرد على @$_replyingTo',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: _cancelReply,
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),

                    TextField(
                      controller: _commentController,
                      focusNode: _commentFocusNode,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintStyle: TextStyle(color: Colors.black),
                        hintText: _replyingTo != null
                            ? 'اكتب ردك...'
                            : 'أضف تعليقك...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_replyingTo != null)
                          TextButton(
                            onPressed: _cancelReply,
                            child: Text(
                              'إلغاء',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_commentController.text.trim().isNotEmpty) {
                              final newsController = Get.find<NewsController>();

                              if (_replyingTo != null &&
                                  _replyingToCommentId != null) {
                                newsController.addComment(
                                  postId: widget.news.id,
                                  body: _commentController.text.trim(),
                                  parentId: _replyingToCommentId,
                                );
                                print(
                                    'إرسال رد على تعليق $_replyingToCommentId: ${_commentController.text}');
                              } else {
                                // إرسال تعليق جديد بدون parentId
                                newsController.addComment(
                                  postId: widget.news.id,
                                  body: _commentController.text.trim(),
                                  // لا نرسل parentId للتعليقات الجديدة
                                );
                                print(
                                    'إرسال تعليق جديد: ${_commentController.text}');
                              }

                              _commentController.clear();
                              _replyingTo = null;
                              _replyingToCommentId = null;
                              _commentFocusNode.unfocus();

                              Future.delayed(const Duration(milliseconds: 500),
                                  () {
                                newsController.getComments(widget.news.id);
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF9ebc67),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                              _replyingTo != null ? 'إرسال الرد' : 'إرسال'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Comments List
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentsList(List<CommentEntity> comments) {
    if (comments.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد تعليقات بعد',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    // Create flat list of all comments and replies with thread indicators
    List<Widget> flatItems = [];

    for (int commentIndex = 0; commentIndex < comments.length; commentIndex++) {
      var comment = comments[commentIndex];

      // Add main comment
      flatItems.add(_buildFlatCommentItem(
        comment,
        isMainComment: true,
        showTopLine: false,
        showBottomLine: comment.replies.isNotEmpty,
      ));

      // Add all replies with proper threading
      _addAllRepliesWithThreading(
          flatItems, comment.replies, comment.user_name ?? 'غير معروف', 1);

      // Add divider between different comment threads
      if (commentIndex < comments.length - 1) {
        flatItems.add(Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.grey.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  '• • •',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.grey.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ));
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: flatItems.length,
      itemBuilder: (context, index) {
        return flatItems[index];
      },
    );
  }

  void _addAllRepliesWithThreading(List<Widget> flatItems,
      List<CommentEntity> replies, String parentUser, int level,
      {Color? inheritedColor}) {
    for (int i = 0; i < replies.length; i++) {
      var reply = replies[i];
      bool hasMoreReplies = reply.replies.isNotEmpty;
      bool isLastInLevel = i == replies.length - 1;

      // Determine if we need connecting lines
      bool showTopLine = level > 0;
      bool showBottomLine = hasMoreReplies || (!isLastInLevel && level > 0);

      // Assign color: inherit from parent or get new color for level 1
      Color replyColor = inheritedColor ?? _getReplyColor(i);

      flatItems.add(_buildFlatCommentItem(
        reply,
        isMainComment: false,
        replyToUser: parentUser,
        showTopLine: showTopLine,
        showBottomLine: showBottomLine,
        threadLevel: level,
        isDirectReply: level == 1,
        replyColor: replyColor,
      ));

      // Recursively add nested replies with same color
      if (hasMoreReplies) {
        _addAllRepliesWithThreading(
            flatItems, reply.replies, reply.user_name ?? 'غير معروف', level + 1,
            inheritedColor: replyColor);
      }
    }
  }

  Color _getReplyColor(int index) {
    // Different colors for different reply chains
    List<Color> replyColors = [
      Colors.orange.withOpacity(0.8), // برتقالي
      Colors.purple.withOpacity(0.8), // بنفسجي
      // Colors.green.withOpacity(0.8), // أخضر
      Colors.red.withOpacity(0.8), // أحمر
      Colors.blue.withOpacity(0.8), // أزرق
      Colors.pink.withOpacity(0.8), // وردي
      // Colors.teal.withOpacity(0.8), // تركوازي
      Colors.amber.withOpacity(0.8), // عنبري
    ];

    return replyColors[index % replyColors.length];
  }

  // Color _getThreadLevelColor(int level) {
  //   // Keep this for backwards compatibility, but it won't be used much now
  //   switch (level) {
  //     case 1:
  //       return Colors.orange.withOpacity(0.8);
  //     case 2:
  //       return Colors.purple.withOpacity(0.8);
  //     case 3:
  //       return Colors.green.withOpacity(0.8);
  //     case 4:
  //       return Colors.red.withOpacity(0.8);
  //     default:
  //       return Colors.grey.withOpacity(0.8);
  //   }
  // }

  // IconData _getThreadLevelIcon(int level) {
  //   switch (level) {
  //     case 1:
  //       return Icons.reply;
  //     case 2:
  //       return Icons.subdirectory_arrow_right;
  //     case 3:
  //       return Icons.keyboard_return;
  //     case 4:
  //       return Icons.trending_flat;
  //     default:
  //       return Icons.more_horiz;
  //   }
  // }

  Widget _buildFlatCommentItem(CommentEntity item,
      {required bool isMainComment,
      String? replyToUser,
      bool showTopLine = false,
      bool showBottomLine = false,
      int threadLevel = 0,
      bool isDirectReply = false,
      Color? replyColor}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thread indicator column
          // Container(
          //   width: 40,
          //   child: Column(
          //     children: [
          //       // Top connecting line
          //       // if (showTopLine)
          //       //   Container(
          //       //     width: 2,
          //       //     height: 20,
          //       //     color: isMainComment
          //       //         ? Theme.of(context).primaryColor.withOpacity(0.4)
          //       //         : (replyColor ?? Theme.of(context).primaryColor)
          //       //             .withOpacity(0.4),
          //       //   ),

          //       // Center indicator with thread level styling
          //       // Container(
          //       //   width: isMainComment ? 16 : (18 + threadLevel * 2).toDouble(),
          //       //   height:
          //       //       isMainComment ? 16 : (18 + threadLevel * 2).toDouble(),
          //       //   margin: const EdgeInsets.symmetric(vertical: 4),
          //       //   decoration: BoxDecoration(
          //       //     color: isMainComment
          //       //         ? Theme.of(context).primaryColor
          //       //         : (replyColor ?? Colors.black),
          //       //     shape: isMainComment ? BoxShape.circle : BoxShape.rectangle,
          //       //     borderRadius: isMainComment
          //       //         ? null
          //       //         : BorderRadius.circular((4 + threadLevel).toDouble()),
          //       //     border: Border.all(
          //       //       color: Colors.white,
          //       //       width: 2,
          //       //     ),
          //       //     boxShadow: [
          //       //       BoxShadow(
          //       //         color: Colors.grey.withOpacity(0.3),
          //       //         spreadRadius: 1,
          //       //         blurRadius: 2,
          //       //       ),
          //       //     ],
          //       //   ),
          //       //   child: isMainComment
          //       //       ? Icon(
          //       //           Icons.chat,
          //       //           size: 8,
          //       //           color: Colors.black,
          //       //         )
          //       //       : null

          //       // ),

          //       // Bottom connecting line
          //       if (showBottomLine)
          //         Container(
          //           width: 2,
          //           height: 20,
          //           color: isMainComment
          //               ? Theme.of(context).primaryColor.withOpacity(0.4)
          //               : (replyColor ?? Theme.of(context).primaryColor)
          //                   .withOpacity(0.4),
          //         ),
          //     ],
          //   ),
          // ),

          // Content container
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 120, // Fixed minimum height for all items
              ),
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isMainComment
                      ? Colors.blue[300]!
                      : Colors.orange.withAlpha(40),
                  width: isMainComment ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      // User Avatar
                      _buildUserAvatar(
                        item.user_name ?? '',
                        isMainComment,
                        context,
                      ),
                      const SizedBox(width: 12),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.user_name ?? 'غير معروف',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMainComment ? 16 : 14,
                                  ),
                                ),
                                // Reply indicator for replies
                                if (!isMainComment && replyToUser != null) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_back,
                                    size: 12,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      replyToUser,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              DateConverter.dateTimeStringToDateTime(
                                  item.createdAt),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isMainComment ? 14 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Content
                  Text(
                    item.body,
                    style: TextStyle(
                      fontSize: isMainComment ? 16 : 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Reply Button
                  InkWell(
                    onTap: () {
                      _startReply(item.user_name ?? 'غير معروف', item.id);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.reply,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'رد',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // دالة لبناء Avatar المستخدم
  Widget _buildUserAvatar(
      String userName, bool isMainComment, BuildContext context) {
    // فحص إذا كان الاسم "xride" (case insensitive)
    bool isXride = userName.toLowerCase().trim() == 'xride' ||
        userName.toLowerCase().trim() == 'x ride';

    if (isXride) {
      // استخدام صورة لـ xride
      return ClipOval(
        child: Image.asset(
          'assets/image/splash_logo.JPG', // يمكن تغييرها لأي صورة
          width: (isMainComment ? 20 : 18) * 2,
          height: (isMainComment ? 20 : 18) * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // في حالة فشل تحميل الصورة، نستخدم الحرف X
            return CircleAvatar(
              radius: isMainComment ? 20 : 18,
              backgroundColor: Colors.white,
              child: Text(
                'X',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: isMainComment ? 16 : 14,
                ),
              ),
            );
          },
        ),
      );
    } else {
      // استخدام الحرف الأول للاسم
      return CircleAvatar(
        radius: isMainComment ? 20 : 18,
        backgroundColor: Colors.white,
        child: Text(
          userName.isNotEmpty ? userName.substring(0, 1) : 'م',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: isMainComment ? 16 : 14,
          ),
        ),
      );
    }
  }
}
