import 'package:stackfood_multivendor/news/domain/entities/comments.dart';
import 'package:stackfood_multivendor/news/domain/entities/zone.dart';

class News {
  final int id;
  final String title;
  final String image;
  final String body;
  final int commentsCount;
  int likesCount;
  final String createdAt;
  final List<CommentEntity> comments;
  final ZoneNews? zone;

  News({
    required this.id,
    required this.title,
    required this.image,
    required this.comments,
    required this.body,
    required this.commentsCount,
    required this.likesCount,
    required this.createdAt,
    required this.zone,
  });
}
