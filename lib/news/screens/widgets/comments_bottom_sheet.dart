import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/news/controllers/news_controller.dart';
import 'package:stackfood_multivendor/news/domain/entities/comments.dart';
import 'package:stackfood_multivendor/news/domain/entities/news.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';

class CommentsBottomSheet extends StatefulWidget {
  final News news;

  final int? highlightedCommentId;
  final int? highlightedParentId;

  const CommentsBottomSheet({
    super.key,
    required this.news,
    this.highlightedCommentId,
    this.highlightedParentId,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  String? _replyingTo;
  int? _replyingToCommentId;
  int? _editingCommentId;
  final Set<int> _expandedComments = {};
  final GlobalKey _highlightKey = GlobalKey();
  bool _hasScrolled = false;
  int _maxCommentsToShow = 10;

  @override
  void initState() {
    super.initState();
    Get.find<NewsController>().getComments(widget.news.id);

    // تلقائياً افتح التعليق الأب إذا كان هناك ريبلاي محدد
    if (widget.highlightedParentId != null) {
      _expandedComments.add(widget.highlightedParentId!);
    }

    // إذا كان هناك إشعار يحولني لتعليق معين، نعرض كل التعليقات للبحث عنه
    if (widget.highlightedCommentId != null) {
      _maxCommentsToShow = 10000;
    }
  }

  // إضافة متغير للتحكم في بريق التظليل
  double _highlightOpacity = 0.0;

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startReply(String userName, int commentId) {
    setState(() {
      _replyingTo = userName;
      _replyingToCommentId = commentId;
      _editingCommentId = null;
      _commentController.clear();
      _commentFocusNode.requestFocus();
    });
  }

  void _startEdit(CommentEntity comment) {
    setState(() {
      _editingCommentId = comment.id;
      _commentController.text = comment.body;
      _replyingTo = null;
      _replyingToCommentId = null;
      _commentFocusNode.requestFocus();
    });
  }

  bool _findAndExpand(CommentEntity parent, int targetId, int rootId) {
    if (parent.id == targetId) {
      print("Found target comment $targetId matching parent.id ${parent.id}");
      return true;
    }
    for (var reply in parent.replies) {
      if (_findAndExpand(reply, targetId, rootId)) {
        print(
            "Target comment found in replies of ${parent.id}. Expanding parent.");
        _expandedComments.add(rootId);
        _expandedComments.add(parent.id);
        return true;
      }
    }
    return false;
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
      _replyingToCommentId = null;
      _commentController.clear();
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingCommentId = null;
      _commentController.clear();
      _commentFocusNode.unfocus();
    });
  }

  void _triggerScrollAndHighlight() {
    _hasScrolled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Step 1: Force a rebuild to expand parents and render the target comment
      setState(() {});

      // Step 2: Try to scroll multiple times with increasing delays to handle complex layouts
      void attemptScroll(int retryCount) {
        if (!mounted || retryCount <= 0) {
          print("Scroll attempts exhausted or unmounted.");
          return;
        }

        final delay = 600 + (5 - retryCount) * 300;
        print("Attempting scroll ($retryCount) after ${delay}ms delay...");

        Future.delayed(Duration(milliseconds: delay), () {
          if (!mounted) return;
          if (_highlightKey.currentContext != null) {
            print(
                "Context found for highlight key. Executing ensureVisible...");
            Scrollable.ensureVisible(
              _highlightKey.currentContext!,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutQuart,
              alignment: 0.3,
            );

            // Animation for visual highlighting
            setState(() => _highlightOpacity = 1.0);
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) setState(() => _highlightOpacity = 0.0);
            });
          } else {
            print("Context NOT found for highlight key. Retrying...");
            attemptScroll(retryCount - 1);
          }
        });
      }

      attemptScroll(5); // Increase retries
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewsController>(
      builder: (newsController) {
        final comments =
            newsController.getCommentsForPost(widget.news.id).reversed.toList();

        if (widget.highlightedCommentId != null &&
            comments.isNotEmpty &&
            !_hasScrolled) {
          bool found = false;
          for (var comment in comments) {
            if (_findAndExpand(
                comment, widget.highlightedCommentId!, comment.id)) {
              found = true;
              break;
            }
          }
          if (found) {
            print(
                "Target comment ${widget.highlightedCommentId} found in list. Triggering scroll...");
            _triggerScrollAndHighlight();
          } else {
            print(
                "Target comment ${widget.highlightedCommentId} NOT found in current comments list of size ${comments.length}");
          }
        }
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
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
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Color(0xFF9ebc67)),
                      ),
                      Expanded(
                        child: Text(
                          'التعليقات (${comments.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9ebc67),
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
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Indicator
                      if (_editingCommentId != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            // color: Color(0xFF55745a),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Color(0xFF55745a)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                size: 16,
                                color: Color(0xFF55745a),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'تعديل التعليق...',
                                  style: TextStyle(
                                    color: Color(0xFF55745a),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: _cancelEdit,
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Reply Indicator
                      if (_replyingTo != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.reply,
                                size: 16,
                                color: Colors.grey[700],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'الرد على @$_replyingTo',
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: _cancelReply,
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _commentController,
                            builder: (context, value, child) {
                              if (value.text.trim().isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  child!,
                                  const SizedBox(width: 8),
                                ],
                              );
                            },
                            child: InkWell(
                              onTap: () {
                                if (_commentController.text.trim().isNotEmpty) {
                                  final newsController =
                                      Get.find<NewsController>();

                                  if (_editingCommentId != null) {
                                    newsController.editComment(
                                      postId: widget.news.id,
                                      commentId: _editingCommentId!,
                                      body: _commentController.text.trim(),
                                    );
                                    _editingCommentId = null;
                                  } else if (_replyingTo != null &&
                                      _replyingToCommentId != null) {
                                    newsController.addComment(
                                      postId: widget.news.id,
                                      body: _commentController.text.trim(),
                                      parentId: _replyingToCommentId,
                                    );
                                  } else {
                                    // إرسال تعليق جديد بدون parentId
                                    newsController.addComment(
                                      postId: widget.news.id,
                                      body: _commentController.text.trim(),
                                    );
                                  }

                                  _commentController.clear();
                                  _replyingTo = null;
                                  _replyingToCommentId = null;
                                  _commentFocusNode.unfocus();

                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    newsController.getComments(widget.news.id);
                                  });
                                }
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 6, right: 4),
                                child: Directionality(
                                  textDirection: TextDirection
                                      .ltr, // To make the send icon point right like Facebook
                                  child: const Icon(
                                    Icons.send,
                                    color: Color(
                                        0xFF9ebc67), // Facebook messenger blue color
                                    size: 43,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // TextField
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFF9ebc67)),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: TextField(
                                cursorColor: Colors.black,
                                controller: _commentController,
                                focusNode: _commentFocusNode,
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: Colors.grey[600], fontSize: 14),
                                  hintText: _editingCommentId != null
                                      ? 'تعديل التعليق...'
                                      : _replyingTo != null
                                          ? 'اكتب ردك...'
                                          : 'أضف تعليقك...',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                maxLines: 5,
                                minLines: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Send Button
                        ],
                      ),
                    ],
                  ),
                ),

                // Comments List
              ],
            ),
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
    int displayLimit = comments.length < _maxCommentsToShow
        ? comments.length
        : _maxCommentsToShow;

    for (int commentIndex = 0; commentIndex < displayLimit; commentIndex++) {
      var comment = comments[commentIndex];

      // Add main comment
      flatItems.add(_buildFlatCommentItem(
        comment,
        isMainComment: true,
      ));

      // Add all replies with proper threading
      _addAllRepliesWithThreading(flatItems, comment.replies,
          comment.user_name ?? 'غير معروف', 1, comment.id,
          isParentLast: commentIndex == displayLimit - 1);

      // Add divider between different comment threads
      if (commentIndex < displayLimit - 1) {
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

    if (comments.length > _maxCommentsToShow) {
      flatItems.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: InkWell(
            onTap: () {
              setState(() {
                _maxCommentsToShow += 10;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF9ebc67)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'عرض مزيد من التعليقات',
                style: TextStyle(
                  color: Color(0xFF9ebc67),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ));
    }

    // Removed old scrolling logic from here as it's now in _triggerScrollAndHighlight
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: flatItems,
      ),
    );
  }

  void _addAllRepliesWithThreading(List<Widget> flatItems,
      List<CommentEntity> replies, String parentUser, int level, int parentId,
      {Color? inheritedColor, bool isParentLast = false}) {
    bool isExpanded = _expandedComments.contains(parentId);
    int displayCount = (replies.length > 2 && !isExpanded) ? 2 : replies.length;

    for (int i = 0; i < displayCount; i++) {
      var reply = replies[i];
      bool hasMoreReplies = reply.replies.isNotEmpty;
      bool isLastInLevel = i == displayCount - 1;

      // Assign color: inherit from parent or get new color for level 1
      Color replyColor = inheritedColor ?? _getReplyColor(i);

      flatItems.add(_buildFlatCommentItem(
        reply,
        isMainComment: false,
        replyToUser: parentUser,
        threadLevel: level,
        isLastChild: isLastInLevel,
        hasMoreReplies: hasMoreReplies,
        replyColor: replyColor,
      ));

      // Recursively add nested replies with same color
      if (hasMoreReplies) {
        _addAllRepliesWithThreading(flatItems, reply.replies,
            reply.user_name ?? 'غير معروف', level + 1, reply.id,
            inheritedColor: replyColor, isParentLast: isLastInLevel);
      }
    }

    if (!isExpanded && replies.length > 2) {
      flatItems
          .add(_buildSeeMoreRepliesButton(parentId, replies.length - 2, level));
    }
  }

  Widget _buildSeeMoreRepliesButton(
      int parentId, int remainingCount, int level) {
    return InkWell(
      onTap: () {
        setState(() {
          _expandedComments.add(parentId);
        });
      },
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: 48.0 + (level * 16.0),
          top: 4,
          bottom: 12,
          end: 16,
        ),
        child: Row(
          children: [
            Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF9ebc67)),
            const SizedBox(width: 4),
            Text(
              'عرض $remainingCount ردود إضافية',
              style: TextStyle(
                color: Color(0xFF9ebc67),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildFlatCommentItem(CommentEntity item,
      {required bool isMainComment,
      String? replyToUser,
      int threadLevel = 0,
      bool isLastChild = false,
      bool hasMoreReplies = false,
      Color? replyColor}) {
    return Container(
      key: widget.highlightedCommentId == item.id ? _highlightKey : null,
      margin: EdgeInsetsDirectional.only(
        start: isMainComment ? 0 : 8,
        top: 4,
        bottom: 4,
        end: 0,
      ),
      child: Builder(builder: (context) {
        if (widget.highlightedCommentId == item.id) {
          print("BUILDING flagged comment ${item.id} with highlight KEY");
        }
        return IntrinsicHeight(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thread lines for replies
            if (!isMainComment)
              Container(
                width: 40,
                child: Stack(
                  children: [
                    // Vertical line from top
                    Positioned(
                      top: 0,
                      bottom: isLastChild ? 20 : 0,
                      right: 18,
                      child: Container(
                        width: 2,
                        color: Colors.grey[300],
                      ),
                    ),
                    // Horizontal curve to avatar
                    Positioned(
                      top: 20,
                      right: 18,
                      left: 0,
                      child: Container(
                        height: 2,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),

            // Content container
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Avatar
                      _buildUserAvatar(
                        item.user_name ?? '',
                        item.user_image,
                        isMainComment,
                        context,
                      ),
                      const SizedBox(width: 8),

                      // Text Bubble
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: widget.highlightedCommentId == item.id
                                ? Border.all(
                                    color: Color(0xFF9ebc67).withOpacity(
                                        0.5 + _highlightOpacity * 0.5),
                                    width: 1.5)
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name and Time
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.user_name ?? 'غير معروف',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '•',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateConverter.getRelativeTime(
                                        item.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              // Content with mentions
                              Builder(
                                builder: (context) {
                                  String displayBody = item.body;
                                  if (!isMainComment && replyToUser != null) {
                                    String prefixToRemove = '@$replyToUser';
                                    if (displayBody
                                        .trimLeft()
                                        .startsWith(prefixToRemove)) {
                                      displayBody = displayBody
                                          .trimLeft()
                                          .substring(prefixToRemove.length)
                                          .trimLeft();
                                    }
                                  }

                                  return RichText(
                                    textDirection: TextDirection.rtl,
                                    text: TextSpan(
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 14),
                                      children: [
                                        if (!isMainComment &&
                                            replyToUser != null)
                                          TextSpan(
                                            text:
                                                '\u200F$replyToUser\u200F ', // RLM around name
                                            style: const TextStyle(
                                              color: Color(0xFF9ebc67),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        TextSpan(
                                            text:
                                                '\u200F$displayBody'), // RLM before body
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Actions (Reply and Likes)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        start: 48, top: 2, bottom: 4),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => _startReply(
                              item.user_name ?? 'غير معروف', item.id),
                          child: Text(
                            'رد',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (Get.find<MarketProfileController>().userInfoModel !=
                                null &&
                            item.userId ==
                                Get.find<MarketProfileController>()
                                    .userInfoModel!
                                    .id
                                    .toString())
                          Padding(
                            padding:
                                const EdgeInsetsDirectional.only(start: 16),
                            child: InkWell(
                              onTap: () => _startEdit(item),
                              child: Text(
                                'تعديل',
                                style: TextStyle(
                                  color: const Color(0xFF9ebc67),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 16),
                        // Simulated Likes for UI matching
                        // Icon(Icons.thumb_up, size: 12, color: Colors.blue[700]),
                        // const SizedBox(width: 4),
                        // Text(
                        //   '${(item.id % 20) + 1}', // Dynamic-looking dummy likes
                        //   style:
                        //       TextStyle(color: Colors.grey[600], fontSize: 12),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
      }),
    );
  }
}

// دالة لبناء Avatar المستخدم
Widget _buildUserAvatar(String userName, String? userImage, bool isMainComment,
    BuildContext context) {
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
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF9ebc67)),
            ),
            child: CircleAvatar(
              radius: isMainComment ? 20 : 18,
              backgroundColor: Colors.white,
              child: Text(
                'X',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isMainComment ? 16 : 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  } else if (userImage != null && userImage.isNotEmpty) {
    // استخدام الصورة القادمة من الـ API
    return ClipOval(
      child: Image.network(
        userImage,
        width: (isMainComment ? 20 : 18) * 2,
        height: (isMainComment ? 20 : 18) * 2,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to initial if image fails
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF9ebc67)),
            ),
            child: CircleAvatar(
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
            ),
          );
        },
      ),
    );
  } else {
    // استخدام الحرف الأول للاسم
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Color(0xFF9ebc67)),
      ),
      child: CircleAvatar(
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
      ),
    );
  }
}
