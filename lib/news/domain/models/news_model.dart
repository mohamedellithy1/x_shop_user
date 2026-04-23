import 'package:stackfood_multivendor/news/domain/entities/news.dart';
import 'package:stackfood_multivendor/news/domain/models/comments_model.dart';
import 'package:stackfood_multivendor/news/domain/models/zone_model.dart';

class NewsModel extends News {
  NewsModel({
    required super.id,
    required super.title,
    required super.image,
    required super.body,
    required super.commentsCount,
    required super.likesCount,
    required super.isLiked,
    required super.createdAt,
    required super.zone,
    required super.comments,
    super.canComment,
    super.canReplyComment,
    super.canReplyReply,
    super.canEditComment,
    super.canEditReply,
    super.canEditReplyReply,
    super.canDeleteComment,
    super.canDeleteReply,
    super.canDeleteReplyReply,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      commentsCount: json['comments_count'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
      isLiked: (json['is_liked'] == 1 || json['is_liked'] == true),
      createdAt: json['created_at']?.toString() ?? '',
      comments: json['comments'] != null
          ? (json['comments'] as List<dynamic>)
              .map((e) => CommentModel.fromMap(e))
              .toList()
          : [],
      zone: json['zone'] != null
          ? ZoneModel.fromJson(json['zone'])
          : ZoneModel(id: '', name: 'غير محدد', readableId: 0),
      canComment: json['can_comment'] == null
          ? true
          : (json['can_comment'] == 1 || json['can_comment'] == true),
      canReplyComment: json['can_reply_comment'] == null
          ? true
          : (json['can_reply_comment'] == 1 ||
              json['can_reply_comment'] == true),
      canReplyReply: json['can_reply_reply'] == null
          ? true
          : (json['can_reply_reply'] == 1 || json['can_reply_reply'] == true),
      canEditComment: json['can_edit_comment'] == null
          ? true
          : (json['can_edit_comment'] == 1 || json['can_edit_comment'] == true),
      canEditReply: json['can_edit_reply'] == null
          ? true
          : (json['can_edit_reply'] == 1 || json['can_edit_reply'] == true),
      canEditReplyReply: json['can_edit_reply_reply'] == null
          ? true
          : (json['can_edit_reply_reply'] == 1 ||
              json['can_edit_reply_reply'] == true),
      canDeleteComment: json['can_delete_comment'] == null
          ? true
          : (json['can_delete_comment'] == 1 ||
              json['can_delete_comment'] == true),
      canDeleteReply: json['can_delete_reply'] == null
          ? true
          : (json['can_delete_reply'] == 1 || json['can_delete_reply'] == true),
      canDeleteReplyReply: json['can_delete_reply_reply'] == null
          ? true
          : (json['can_delete_reply_reply'] == 1 ||
              json['can_delete_reply_reply'] == true),
    );
  }

  static List<NewsModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) {
          try {
            return NewsModel.fromJson(json);
          } catch (e) {
            print('Error parsing news item: $e');
            print('News data: $json');
            return null;
          }
        })
        .where((news) => news != null)
        .cast<NewsModel>()
        .toList();
  }
}
