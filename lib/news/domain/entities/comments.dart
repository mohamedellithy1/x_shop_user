class CommentEntity {
  final int id;
  final String userId;
  final String? userEmail;
  final String body;
  final int? parentId;
  final String? user_name;
  final String createdAt;
  final List<CommentEntity> replies;

  CommentEntity({
    required this.id,
    required this.userId,
    this.userEmail,
    this.user_name,
    required this.body,
    this.parentId,
    required this.createdAt,
    required this.replies,
  });
}
