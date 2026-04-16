import 'package:stackfood_multivendor/news/domain/entities/comments.dart';

class CommentModel extends CommentEntity {
  CommentModel({
    required int id,
    required String userId,
    String? userEmail,
    String? user_name,
    required String body,
    int? parentId,
    required String createdAt,
    required List<CommentEntity> replies,
  }) : super(
          id: id,
          userId: userId,
          userEmail: userEmail,
          user_name: user_name,
          body: body,
          parentId: parentId,
          createdAt: createdAt,
          replies: replies,
        );

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? 0,
      userId: map['user_id'] ?? '',
      userEmail: map['user_email'],
      user_name: map['user_name'],
      body: map['body'] ?? '',
      parentId: map['parent_id'],
      createdAt: map['created_at'] ?? '',
      replies: map['replies'] != null
          ? (map['replies'] as List<dynamic>)
              .map((e) => CommentModel.fromMap(e))
              .toList()
          : [], // إذا لم تكن replies موجودة، استخدم قائمة فارغة
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'user_email': userEmail,
      'user_name': user_name,
      'body': body,
      'parent_id': parentId,
      'created_at': createdAt,
      'replies': replies.map((e) => (e as CommentModel).toMap()).toList(),
    };
  }
}
