class CommentEntity {
  final int id;
  final String userId;
  final int? admin_id;
  final String? comment_by;
  final String? userEmail;
  final String body;
  final int? parentId;
  final String? user_name;
  final String? user_image;
  final String createdAt;
  final List<CommentEntity> replies;

  CommentEntity({
    required this.id,
    required this.userId,
    this.admin_id,
    this.comment_by,
    this.userEmail,
    this.user_name,
    this.user_image,
    required this.body,
    this.parentId,
    required this.createdAt,
    required this.replies,
  });
}
