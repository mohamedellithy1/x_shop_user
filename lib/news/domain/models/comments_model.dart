import 'package:stackfood_multivendor/news/domain/entities/comments.dart';

class CommentModel extends CommentEntity {
  CommentModel({
    required int id,
    required String userId,
    int? admin_id,
    String? comment_by,
    String? userEmail,
    String? user_name,
    String? user_image,
    required String body,
    int? parentId,
    required String createdAt,
    required bool isEdited,
    required List<CommentEntity> replies,
  }) : super(
          id: id,
          userId: userId,
          admin_id: admin_id,
          comment_by: comment_by,
          userEmail: userEmail,
          user_name: user_name,
          user_image: user_image,
          body: body,
          parentId: parentId,
          createdAt: createdAt,
          isEdited: isEdited,
          replies: replies,
        );

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] != null ? int.parse(map['id'].toString()) : 0,
      userId: map['user_id']?.toString() ?? '',
      admin_id: map['admin_id'] != null ? int.tryParse(map['admin_id'].toString()) : null,
      comment_by: map['comment_by']?.toString(),
      userEmail: map['user_email']?.toString(),
      user_name: map['user_name']?.toString(),
      user_image: map['user_image']?.toString(),
      body: map['body']?.toString() ?? '',
      parentId:
          map['parent_id'] != null ? int.tryParse(map['parent_id'].toString()) : null,
      createdAt: map['created_at']?.toString() ?? '',
      isEdited: map['is_edited'] == 1 || map['is_edited'] == true,
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
      'admin_id': admin_id,
      'comment_by': comment_by,
      'user_email': userEmail,
      'user_name': user_name,
      'user_image': user_image,
      'body': body,
      'parent_id': parentId,
      'created_at': createdAt,
      'is_edited': isEdited,
      'replies': replies.map((e) => (e as CommentModel).toMap()).toList(),
    };
  }
}
