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
    required super.createdAt,
    required super.zone,
    required super.comments,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      commentsCount: json['comments_count'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      comments: json['comments'] != null
          ? (json['comments'] as List<dynamic>)
              .map((e) => CommentModel.fromMap(e))
              .toList()
          : [],
      zone: json['zone'] != null
          ? ZoneModel.fromJson(json['zone'])
          : ZoneModel(id: '', name: 'غير محدد', readableId: 0),
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
