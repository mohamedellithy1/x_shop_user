import 'package:get/get.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/news/controllers/news_controller.dart';
import 'package:stackfood_multivendor/news/domain/repositories/news_repository.dart';

class NewsBinding extends Bindings {
  @override
  void dependencies() {
    // تسجيل NewsRepository
    Get.lazyPut<NewsRepository>(() => NewsRepository(Get.find<ApiClient>()));

    // تسجيل NewsController
    Get.lazyPut<NewsController>(
        () => NewsController(newsRepo: Get.find<NewsRepository>()));
  }
}
