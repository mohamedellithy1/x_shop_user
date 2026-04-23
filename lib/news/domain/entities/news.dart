import 'package:stackfood_multivendor/news/domain/entities/comments.dart';
import 'package:stackfood_multivendor/news/domain/entities/zone.dart';

class News {
  final int id;
  final String title;
  final String image;
  final String body;
  final int commentsCount;
  int likesCount;
  bool isLiked;
  final String createdAt;
  final List<CommentEntity> comments;
  final ZoneNews? zone;
  final bool canComment;
  final bool canReplyComment;
  final bool canReplyReply;
  final bool canEditComment;
  final bool canEditReply;
  final bool canEditReplyReply;
  final bool canDeleteComment;
  final bool canDeleteReply;
  final bool canDeleteReplyReply;

  News({
    required this.id,
    required this.title,
    required this.image,
    required this.comments,
    required this.body,
    required this.commentsCount,
    required this.likesCount,
    required this.isLiked,
    required this.createdAt,
    required this.zone,
    this.canComment = true,
    this.canReplyComment = true,
    this.canReplyReply = true,
    this.canEditComment = true,
    this.canEditReply = true,
    this.canEditReplyReply = true,
    this.canDeleteComment = true,
    this.canDeleteReply = true,
    this.canDeleteReplyReply = true,
  });
}
