import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/image_widget.dart';
import 'package:stackfood_multivendor/core/navigation/app_navigator_observer.dart';
import 'package:stackfood_multivendor/features/home/controllers/banner_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/banner_shimmer.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/video_banner_widget.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerView extends StatefulWidget {
  const BannerView({super.key});

  @override
  State<BannerView> createState() => _BannerViewState();
}

class _BannerViewState extends State<BannerView>
    with WidgetsBindingObserver, RouteAware {
  int activeIndex = 0;
  bool isVideoActive = false;
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
    // الاشتراك في الـ RouteObserver عشان نعرف لما صفحة جديدة تتفتح فوقنا
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

  /// لما صفحة جديدة بتتفتح فوق الـ Home - وقف الفيديو فورًا
  @override
  void didPushNext() {
    final bannerController = Get.find<BannerController>();
    bannerController.forcePauseVideo(true);
  }

  /// لما المستخدم بيرجع للـ Home - شغل الفيديو تاني
  @override
  void didPopNext() {
    final bannerController = Get.find<BannerController>();
    bannerController.forcePauseVideo(false);
  }

  /// يراقب حالة التطبيق - لو راح Background يوقف الفيديو
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bannerController = Get.find<BannerController>();
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // التطبيق راح Background - إيقاف الفيديو وإعادة الضبط
      bannerController.forcePauseVideo(true);
      bannerController.resetBanner();
    } else if (state == AppLifecycleState.resumed) {
      // التطبيق رجع للـ Foreground - تشغيل الفيديو تاني
      bannerController.forcePauseVideo(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String baseurl =
        "${AppConstants.newsBaseUrl}/storage/app/public/promotion/banner";
    return GetBuilder<BannerController>(
      builder: (bannerController) {
        if (bannerController.shouldReset) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _carouselController.jumpToPage(0);
            bannerController.acknowledgeReset();
            setState(() {
              activeIndex = 0;
            });
          });
        }

        if (bannerController.bannerList != null &&
            bannerController.bannerList!.isNotEmpty) {
          var currentBanner = bannerController.bannerList![activeIndex];
          isVideoActive = currentBanner.mediaType == 'video' ||
              (currentBanner.image?.endsWith('.mp4') ?? false);
        }

        return bannerController.bannerList != null
            ? bannerController.bannerList!.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        child: CarouselSlider.builder(
                          carouselController: _carouselController,
                          options: CarouselOptions(
                            autoPlay: !isVideoActive,
                            enlargeCenterPage: false,
                            viewportFraction: 1,
                            disableCenter: true,
                            autoPlayInterval: const Duration(seconds: 7),
                            onPageChanged: (index, reason) {
                              setState(() {
                                activeIndex = index;
                              });
                            },
                          ),
                          itemCount: bannerController.bannerList!.length,
                          itemBuilder: (context, index, _) {
                            var banner = bannerController.bannerList![index];
                            bool isVideo = banner.mediaType == 'video' ||
                                (banner.image?.endsWith('.mp4') ?? false);

                            // بناء الـ URL بشكل صحيح بغض النظر عن الشكل اللي جاي من السيرفر
                            final String imageUrl =
                                _buildImageUrl(baseurl, banner.image);
                            debugPrint(
                                "====> Banner[$index] image URL: $imageUrl");

                            return InkWell(
                              onTap: () {
                                bannerController
                                    .updateBannerClickCount(banner.id!);
                                debugPrint(
                                    "=click===> ${banner.redirectLink!}");
                                if (banner.redirectLink != null) {
                                  _launchUrl(banner.redirectLink!);
                                }
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault),
                                  child: isVideo
                                      ? VideoBannerWidget(
                                          url: imageUrl,
                                          isActive: index == activeIndex &&
                                              !bannerController
                                                  .isVideoPausedByForce,
                                          onFinished: () {
                                            _carouselController.nextPage();
                                          },
                                          onTap: () {
                                            bannerController
                                                .updateBannerClickCount(
                                                    banner.id!);
                                            debugPrint(
                                                "=click====> ${banner.redirectLink!}");
                                            if (banner.redirectLink != null) {
                                              _launchUrl(banner.redirectLink!);
                                            }
                                          })
                                      : ImageWidget(
                                          image: imageUrl,
                                          fit: BoxFit.cover),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: Dimensions.paddingSizeExtraSmall,
                      ),
                      SizedBox(
                        height: 5,
                        width: Get.width,
                        child: Center(
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            itemCount: bannerController.bannerList!.length,
                            itemBuilder: (context, index) {
                              return Center(
                                  child: Container(
                                height: 5,
                                width: index == activeIndex ? 10 : 5,
                                decoration: BoxDecoration(
                                    color: Color(0xFF9ebc67),
                                    borderRadius: BorderRadius.circular(100)),
                              ));
                            },
                            separatorBuilder: (context, index) {
                              return const Padding(
                                  padding: EdgeInsets.only(
                                      right: Dimensions.paddingSizeExtraSmall));
                            },
                          ),
                        ),
                      )
                    ],
                  )
                : const SizedBox()
            : const BannerShimmer();
      },
    );
  }
}

Future<void> _launchUrl(String urlString) async {
  String formattedUrl = urlString;
  if (!urlString.startsWith('http')) {
    formattedUrl = 'https://$urlString';
  }
  Uri url = Uri.parse(formattedUrl);
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}

/// بيبني الـ URL الصحيح بغض النظر عن الشكل اللي جايه منه الـ image field:
/// - لو URL كامل (https://...) → يستخدمه مباشرة
/// - لو path بيبدأ بـ / → يضيف الـ base domain بس
/// - لو اسم ملف بس → يضيف الـ baseurl الكامل
String _buildImageUrl(String baseurl, String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) return '';
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return imagePath; // URL كامل بالفعل
  }
  if (imagePath.startsWith('/')) {
    // path من السيرفر زي /storage/app/public/...
    return '${AppConstants.newsBaseUrl}$imagePath';
  }
  // اسم ملف فقط
  return '$baseurl/$imagePath';
}
