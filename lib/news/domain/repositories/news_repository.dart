import 'package:get/get_connect/http/src/response/response.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';

class NewsRepository {
  final ApiClient apiClient;

  NewsRepository(this.apiClient);

  Future<Response?> getNews(String zoneId) async {
    String url = AppConstants.newsUei;
    if (zoneId.isNotEmpty) {
      url += '?${AppConstants.newsUeiWithZoneId}$zoneId';
    }
    print("News API URL: ${AppConstants.newsBaseUrl}$url");
    return await apiClient.getData('${AppConstants.newsBaseUrl}$url');
  }

  Future<Response?> reactToItem({
    required String targetType,
    required int targetId,
    required String reaction,
  }) async {
    return await apiClient
        .postData('${AppConstants.newsBaseUrl}${AppConstants.reactNewsUri}', {
      'target_type': targetType,
      'target_id': targetId,
      'reaction': reaction,
    });
  }

  Future<Response?> getComments(int postId) async {
    return await apiClient.getData(
        '${AppConstants.newsBaseUrl}${AppConstants.getCommentsById}$postId');
  }

  Future<Response?> addComment({
    required int postId,
    required String body,
    int? parentId,
  }) async {
    return await apiClient.postData(
      '${AppConstants.newsBaseUrl}${AppConstants.addCommentUei}',
      {
        'post_id': postId,
        'body': body,
        'parent_id': parentId,
      },
      handleError: false,
    );
  }

  Future<Response?> editComment({
    required int commentId,
    required String body,
  }) async {
    return await apiClient.postData(
      '${AppConstants.newsBaseUrl}${AppConstants.editCommentUei}$commentId',
      {
        'body': body,
      },
      handleError: false,
    );
  }

  Future<Response?> deleteComment(int commentId) async {
    return await apiClient.deleteData(
      '${AppConstants.newsBaseUrl}${AppConstants.editCommentUei}$commentId',
    );
  }
}
