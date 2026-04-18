// import 'package:flutter/material.dart' hide Banner;
// import 'package:get/get.dart';
// import 'package:stackfood_multivendor/api/api_checker.dart';
// import 'package:stackfood_multivendor/features/home/domain/models/banner_modelXride.dart';
// import 'package:stackfood_multivendor/features/home/domain/repositories/banner_repo.dart';

// class BannerController extends GetxController implements GetxService {
//   final BannerRepo bannerRepo;
//   BannerController({required this.bannerRepo});

//   int? _currentIndex = 0;
//   int? get currentIndex => _currentIndex;
//   bool isLoading = false;
//   List<Banner>? bannerList;
//   bool isVideoPausedByForce = false;
//   bool shouldReset = false;

//   @override
//   void onInit() {
//     super.onInit();
//     getBannerList();
//   }

//   Future<void> getBannerList({bool notify = true}) async {
//     isLoading = true;
//     try {
//       Response? response = await bannerRepo.getBannerList();
//       if (response!.statusCode == 200) {
//         debugPrint("====> Banner Response Body: ${response.body}");
//         bannerList = [];
//         bannerList!.addAll(BannerModel.fromJson(response.body).data!);
//         isLoading = false;
//         debugPrint("====> Banners loaded: ${bannerList!.length}");
//       } else {
//         isLoading = false;
//         ApiChecker.checkApi(response);
//       }
//     } catch (e) {
//       isLoading = false;
//       debugPrint("====> Error loading banners: $e");
//     }

//     if (notify) {
//       update();
//     }
//   }

//   Future<void> updateBannerClickCount(String bannerId) async {
//     Response? response = await bannerRepo.updateBannerClickCount(bannerId);
//     if (response!.statusCode == 200) {
//     } else {
//       ApiChecker.checkApi(response);
//     }
//     update();
//   }

//   void setCurrentIndex(int index, bool notify) {
//     _currentIndex = index;
//     if (notify) {
//       update();
//     }
//   }

//   void forcePauseVideo(bool pause) {
//     isVideoPausedByForce = pause;
//     update();
//   }

//   void resetBanner() {
//     shouldReset = true;
//     _currentIndex = 0;
//     update();
//   }

//   void acknowledgeReset() {
//     shouldReset = false;
//   }
// }
