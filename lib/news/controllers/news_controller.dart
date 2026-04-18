import 'package:get/get.dart';
import 'package:stackfood_multivendor/api/api_checker.dart';
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
        if (response.body != null && response.body is Map && response.body['data'] != null) {
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

  void likeNews(int newsId) async {
    final response = await newsRepo.likeNews(newsId);
    if (response != null && response.statusCode == 200) {
      print("News liked successfully");
    } else {
      print("Failed to like news");
    }
  }

  void addComment({
    required int postId,
    required String body,
    int? parentId,
  }) async {
    final response = await newsRepo.addComment(
        postId: postId, body: body, parentId: parentId);
    if (response != null && response.statusCode == 200) {
      print("Comment added successfully");
      getComments(postId);
    } else {
      print("Failed to add comment");
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

          // تنظيم التعليقات والردود
          List<CommentEntity> organizedComments =
              _organizeCommentsAndReplies(allComments);

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
            userEmail: comment.userEmail,
            body: comment.body,
            parentId: comment.parentId,
            createdAt: comment.createdAt,
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
