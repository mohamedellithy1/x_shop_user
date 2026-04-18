// import 'package:get/get_connect/http/src/response/response.dart';
// import 'package:stackfood_multivendor/api/api_client.dart';
// import 'package:stackfood_multivendor/util/app_constants.dart';

// class BannerRepo {
//   final ApiClient apiClient;

//   BannerRepo({required this.apiClient});

//   Future<Response?> getBannerList() async {
//     return await apiClient.getData('${AppConstants.newsBaseUrl}${AppConstants.bannerUei}');
//   }

//   Future<Response?> updateBannerClickCount(String bannerId) async {
//     return await apiClient
//         .postData('${AppConstants.newsBaseUrl}${AppConstants.bannerCountUpdate}', {'banner_id': bannerId});
//   }
// }
