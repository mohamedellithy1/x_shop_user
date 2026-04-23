import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/api/api_checker.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/news/domain/entities/comments.dart';
import 'package:stackfood_multivendor/news/domain/entities/news.dart';
import 'package:stackfood_multivendor/news/domain/models/comments_model.dart';
import 'package:stackfood_multivendor/news/domain/models/news_model.dart';
import 'package:stackfood_multivendor/news/domain/repositories/news_repository.dart';

class NewsController extends GetxController {
  final NewsRepository newsRepo;
  NewsController({required this.newsRepo});

  bool isLoading = false;
  List<News>? newsList;
  String? currentZoneId;
  String? selectedZoneName; // إضافة اسم المنطقة المختارة

  // إضافة متغير لتخزين التعليقات
  Map<int, List<CommentEntity>> commentsMap = {};

  NotificationBodyModel? _pendingNotification;
  NotificationBodyModel? get pendingNotification => _pendingNotification;

  void setPendingNotification(NotificationBodyModel? notification) {
    _pendingNotification = notification;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    getNews("");
    // NewsBinding().dependencies();
    // Get.put(NewsController(newsRepo: Get.find<NewsRepository>()));
  }

  Future<void> getNews(String zoneId) async {
    currentZoneId = zoneId;
    isLoading = true;
    update();

    try {
      final response = await newsRepo.getNews(zoneId);
      print("Response status: ${response?.statusCode}");
      print("Response body: ${response?.body}");

      if (response != null && response.statusCode == 200) {
        if (response.body != null &&
            response.body is Map &&
            response.body['data'] != null) {
          final List<dynamic> data = response.body['data'];
          print("Data length: ${data.length}");
          newsList = NewsModel.fromJsonList(data);
          isLoading = false;
          print("newsList: ${newsList?.length}");
        } else {
          print("Response body or data is null");
          newsList = [];
          isLoading = false;
        }
      } else {
        isLoading = false;
        if (response != null) {
          ApiChecker.checkApi(response);
        }
      }
    } catch (e) {
      isLoading = false;
      print('Error getting news: $e');
      print('Error stack trace: ${StackTrace.current}');
    }

    update();
  }

  void setSelectedZone(String zoneId, String zoneName) {
    currentZoneId = zoneId;
    selectedZoneName = zoneName;
    update();
  }

  void refreshNews() {
    getNews(currentZoneId ?? "");
  }

  void clearZone() {
    currentZoneId = null;
    selectedZoneName = null;
    newsList = null;
    update();
  }

  Future<bool?> likeNews(int newsId) async {
    if (Get.find<MarketAuthController>().isLoggedIn()) {
      final response = await newsRepo.likeNews(newsId);
      if (response != null && response.statusCode == 200) {
        print("News liked successfully");
        if (response.body != null &&
            response.body is Map &&
            response.body.containsKey('is_liked')) {
          return (response.body['is_liked'] == 1 ||
              response.body['is_liked'] == true);
        }
        return true;
      } else {
        print("Failed to like news");
        return null;
      }
    } else {
      showCustomSnackBar("يجب تسجيل الدخول أولاً لتتمكن من الإعجاب بالخبر");
      return null;
    }
  }

  void addComment({
    required int postId,
    required String body,
    int? parentId,
  }) async {
    if (Get.find<MarketAuthController>().isLoggedIn()) {
      final response = await newsRepo.addComment(
          postId: postId, body: body, parentId: parentId);
      if (response != null && response.statusCode == 200) {
        getComments(postId);
      } else {
        print("Failed to add comment: ${response?.statusText}");
      }
    } else {
      showCustomSnackBar("يجب تسجيل الدخول أولاً لتتمكن من إضافة تعليق");
    }
  }

  void editComment({
    required int postId,
    required int commentId,
    required String body,
  }) async {
    if (Get.find<MarketAuthController>().isLoggedIn()) {
      final response = await newsRepo.editComment(
        commentId: commentId,
        body: body,
      );
      if (response != null && response.statusCode == 200) {
        getComments(postId);
        showCustomSnackBar("تم تعديل التعليق بنجاح");
      } else {
        print("Failed to edit comment: ${response?.statusText}");
        showCustomSnackBar("فشل تعديل التعليق");
      }
    } else {
      showCustomSnackBar("يجب تسجيل الدخول أولاً");
    }
  }

  void deleteComment(int postId, int commentId) async {
    if (Get.find<MarketAuthController>().isLoggedIn()) {
      final response = await newsRepo.deleteComment(commentId);
      if (response != null && response.statusCode == 200) {
        getComments(postId);
        showCustomSnackBar("تم حذف التعليق بنجاح");
      } else {
        print("Failed to delete comment: ${response?.statusText}");
        showCustomSnackBar("فشل حذف التعليق");
      }
    } else {
      showCustomSnackBar("يجب تسجيل الدخول أولاً");
    }
  }

  void getComments(int postId) async {
    try {
      final response = await newsRepo.getComments(postId);

      if (response != null && response.statusCode == 200) {
        if (response.body != null && response.body['data'] != null) {
          final data = response.body['data'];
          print("Raw comments data: $data");

          List<CommentEntity> allComments = [];

          if (data is List<dynamic>) {
            allComments = data
                .map((e) {
                  try {
                    return CommentModel.fromMap(e);
                  } catch (error) {
                    print("Error parsing comment: $error");
                    print("Comment data: $e");
                    return null;
                  }
                })
                .where((comment) => comment != null)
                .cast<CommentEntity>()
                .toList();
          } else if (data is Map<String, dynamic>) {
            var commentsList = data['comments'] ?? data['data'] ?? [];
            if (commentsList is List<dynamic>) {
              allComments = commentsList
                  .map((e) {
                    try {
                      return CommentModel.fromMap(e);
                    } catch (error) {
                      print("Error parsing comment: $error");
                      print("Comment data: $e");
                      return null;
                    }
                  })
                  .where((comment) => comment != null)
                  .cast<CommentEntity>()
                  .toList();
            }
          }

          // التحقق مما إذا كانت التعليقات متداخلة بالفعل من الـ API
          bool isAlreadyNested = allComments.any((c) => c.replies.isNotEmpty);

          List<CommentEntity> organizedComments;
          if (isAlreadyNested) {
            organizedComments = allComments;
            print("Comments are already nested, skipping reorganization");
          } else {
            organizedComments = _organizeCommentsAndReplies(allComments);
            print("Organizing flat comments list");
          }

          commentsMap[postId] = organizedComments;
          print(
              "Comments organized successfully for post $postId: ${organizedComments.length} main comments");
        } else {
          commentsMap[postId] = [];
          print("No comments data for post $postId");
          print("Response body: ${response.body}");
        }
      } else {
        commentsMap[postId] = [];
        print("Failed to fetch comments for post $postId");
        print("Response status: ${response?.statusCode}");
        print("Response body: ${response?.body}");
      }
    } catch (error) {
      print("Error in getComments: $error");
      commentsMap[postId] = [];
    }

    update();
  }

  List<CommentEntity> getCommentsForPost(int postId) {
    return commentsMap[postId] ?? [];
  }

  // دالة لتنظيم التعليقات والردود بشكل هرمي
  List<CommentEntity> _organizeCommentsAndReplies(
      List<CommentEntity> allComments) {
    // فصل التعليقات الأصلية عن الردود
    List<CommentEntity> mainComments = [];
    Map<int, List<CommentEntity>> repliesMap = {};

    // تصنيف التعليقات والردود
    for (var comment in allComments) {
      if (comment.parentId == null) {
        // تعليق أصلي
        mainComments.add(comment);
      } else {
        // رد على تعليق
        if (!repliesMap.containsKey(comment.parentId)) {
          repliesMap[comment.parentId!] = [];
        }
        repliesMap[comment.parentId!]!.add(comment);
      }
    }

    // دالة متداخلة لإضافة الردود إلى التعليقات
    List<CommentEntity> addRepliesToComment(List<CommentEntity> comments) {
      List<CommentEntity> result = [];

      for (var comment in comments) {
        // البحث عن ردود لهذا التعليق
        List<CommentEntity> replies = repliesMap[comment.id] ?? [];

        // إضافة الردود إلى الردود بشكل متداخل
        if (replies.isNotEmpty) {
          // إنشاء نسخة جديدة من التعليق مع إضافة الردود
          result.add(CommentModel(
            id: comment.id,
            userId: comment.userId,
            admin_id: comment.admin_id,
            comment_by: comment.comment_by,
            userEmail: comment.userEmail,
            user_name: comment.user_name,
            user_image: comment.user_image,
            body: comment.body,
            parentId: comment.parentId,
            createdAt: comment.createdAt,
            isEdited: comment.isEdited,
            replies: addRepliesToComment(replies), // إضافة الردود بشكل متداخل
          ));
        } else {
          // إذا لم يكن هناك ردود، إضافة التعليق كما هو
          result.add(comment);
        }
      }

      return result;
    }

    // إضافة الردود إلى التعليقات الأصلية
    return addRepliesToComment(mainComments);
  }
}
