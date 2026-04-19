import 'package:carousel_slider/carousel_slider.dart';
import 'package:stackfood_multivendor/core/navigation/app_navigator_observer.dart';
import 'package:stackfood_multivendor/features/home/controllers/home_controller.dart';
import 'package:stackfood_multivendor/features/home/domain/models/banner_model.dart'
    as banner_mod;
import 'package:stackfood_multivendor/features/home/widgets/theme1/video_banner_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/product/domain/models/basic_campaign_model.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class BannerViewWidget1 extends StatefulWidget {
  const BannerViewWidget1({super.key});

  @override
  State<BannerViewWidget1> createState() => _BannerViewWidget1State();
}

class _BannerViewWidget1State extends State<BannerViewWidget1>
    with WidgetsBindingObserver, RouteAware {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    Get.find<HomeController>().forcePauseVideo(true);
  }

  @override
  void didPopNext() {
    Get.find<HomeController>().forcePauseVideo(false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      List<String?>? bannerList = homeController.bannerImageList;
      List<dynamic>? bannerDataList = homeController.bannerDataList;

      // تحديد لو العنصر الحالي فيديو عشان نوقف الـ autoPlay
      bool isCurrentVideo = false;
      if (bannerList != null &&
          bannerList.isNotEmpty &&
          homeController.currentIndex < bannerList.length) {
        isCurrentVideo =
            bannerList[homeController.currentIndex]?.contains('.mp4') ?? false;
      }

      if (homeController.shouldReset) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (bannerList != null && bannerList.isNotEmpty) {
            try {
              _carouselController.jumpToPage(0);
            } catch (e) {
              debugPrint("Carousel controller error: $e");
            }
          }
          homeController.acknowledgeReset();
        });
      }

      return (bannerList == null || bannerList.isEmpty)
          ? const SizedBox()
          : Padding(
              padding:
                  const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: GetPlatform.isDesktop ? 500 : 200,
                    width: MediaQuery.of(context).size.width,
                    child: CarouselSlider.builder(
                      carouselController: _carouselController,
                      options: CarouselOptions(
                        autoPlay: !isCurrentVideo && !homeController.isVideoPausedByForce,
                        enlargeCenterPage: false,
                        disableCenter: true,
                        viewportFraction: 1,
                        autoPlayInterval: const Duration(seconds: 7),
                        onPageChanged: (index, reason) {
                          homeController.setCurrentIndex(index, true);
                        },
                      ),
                      itemCount: bannerList.length,
                      itemBuilder: (context, index, _) {
                        String? imageUrl = bannerList[index];
                        bool isVideo = imageUrl?.contains('.mp4') ?? false;

                        if (!isVideo &&
                            bannerDataList != null &&
                            bannerDataList[index] is banner_mod.Banner) {
                          isVideo = (bannerDataList[index] as banner_mod.Banner)
                                  .mediaType ==
                               'video';
                        }

                        return InkWell(
                          onTap: () {
                            if (bannerDataList != null &&
                                bannerDataList[index] is Product) {
                              Product? product = bannerDataList[index];
                              ResponsiveHelper.isMobile(context)
                                  ? showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (con) =>
                                          ProductBottomSheetWidget(
                                              product: product),
                                    )
                                  : showDialog(
                                      context: context,
                                      builder: (con) => Dialog(
                                          child: ProductBottomSheetWidget(
                                              product: product)),
                                    );
                            } else if (bannerDataList![index] is Restaurant) {
                              Restaurant restaurant = bannerDataList[index];
                              Get.toNamed(
                                RouteHelper.getRestaurantRoute(restaurant.id,
                                    slug: restaurant.slug ?? ''),
                                arguments:
                                    RestaurantScreen(restaurant: restaurant),
                              );
                            } else if (bannerDataList[index]
                                is BasicCampaignModel) {
                              BasicCampaignModel campaign =
                                  bannerDataList[index];
                              Get.toNamed(
                                  RouteHelper.getBasicCampaignRoute(campaign));
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors
                                          .grey[Get.isDarkMode ? 800 : 200]!,
                                      spreadRadius: 1,
                                      blurRadius: 5)
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                                child: GetBuilder<MarketSplashController>(
                                    tag: 'xmarket',
                                    builder: (splashController) {
                                      return isVideo
                                          ? VideoBannerWidget(
                                              url: '${bannerList[index]}',
                                              isActive: index ==
                                                      homeController
                                                          .currentIndex &&
                                                  !homeController
                                                      .isVideoPausedByForce,
                                              onFinished: () {
                                                if (!homeController
                                                    .isVideoPausedByForce) {
                                                  _carouselController
                                                      .nextPage();
                                                }
                                              },
                                              onTap: () {
                                                // Handle tap for video if needed, currently onTap is handled by InkWell
                                              },
                                            )
                                          : CustomImageWidget(
                                              image: '${bannerList[index]}',
                                              fit: BoxFit.cover,
                                            );
                                    }),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: bannerList.map((bnr) {
                      int index = bannerList.indexOf(bnr);
                      return TabPageSelectorIndicator(
                        backgroundColor: index == homeController.currentIndex
                            ? Theme.of(context).primaryColor
                            : Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.5),
                        borderColor: Theme.of(context).colorScheme.surface,
                        size: index == homeController.currentIndex ? 10 : 7,
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
    });
  }
}
