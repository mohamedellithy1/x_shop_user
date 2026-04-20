import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/news/controllers/news_controller.dart';
import 'package:stackfood_multivendor/news/domain/repositories/news_repository.dart';
import 'package:stackfood_multivendor/news/screens/widgets/news_item.dart';
import 'package:stackfood_multivendor/news/screens/widgets/comments_bottom_sheet.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/xmarket_images.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  @override
  void initState() {
    super.initState();
    // NewsController مسجل بالفعل في di_container.dart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.045),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFe3ebd5),
                Color(0xFFfafff4),
                Color(0xFFe3ebd5),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            // leading: Builder(
            //   builder: (context) => IconButton(
            //     icon: const Icon(Icons.menu),
            //     onPressed: () => Scaffold.of(context).openDrawer(),
            //   ),
            // ),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: const Text(
                'الاخبار',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
      ),
      // drawer: const DrowerItem(),
      body: GetBuilder<NewsController>(
        init: Get.find<NewsController>(),
        builder: (controller) {
          if (controller.newsList != null && controller.pendingNotification != null) {
            final notification = controller.pendingNotification!;
            // ignore: avoid_print
            print("Notification Post ID: ${notification.postId}");
            final newsIndex = controller.newsList!.indexWhere((n) => n.id == notification.postId);
            // ignore: avoid_print
            print("News Index Found: $newsIndex");
            if (newsIndex != -1) {
              final news = controller.newsList![newsIndex];
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Get.isBottomSheetOpen == false) {
                  Get.bottomSheet(
                    CommentsBottomSheet(
                      news: news,
                      highlightedCommentId: notification.commentId,
                      highlightedParentId: notification.parentId,
                    ),
                    isScrollControlled: true,
                  );
                  controller.setPendingNotification(null);
                }
              });
            }
          }

          if (controller.isLoading || controller.newsList == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF9ebc67)),
            );
          }

          if (controller.newsList!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    XmarketImages.placeholder,
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Text(
                    controller.currentZoneId != null &&
                            controller.currentZoneId!.isNotEmpty
                        ? 'لا توجد أخبار متاحة في هذه المدينة'
                        : 'لا توجد أخبار متاحة حالياً',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: Colors.black,
            onRefresh: () async {
              controller.refreshNews();
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeSmall,
              ),
              itemCount: controller.newsList!.length,
              itemBuilder: (context, index) {
                final news = controller.newsList![index];
                print("newsImage: ${news.image}");
                return Column(
                  children: [
                    NewsItemWidget(
                      news: news,
                      comments: news.comments,
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
