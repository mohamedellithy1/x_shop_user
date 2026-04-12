import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/profile/domain/models/userinfo_model.dart';
import 'package:get/get.dart';

class MarketReferAndEarnController extends GetxController implements GetxService {

  UserInfoModel? _userInfoModel;
  UserInfoModel? get userInfoModel => _userInfoModel;

  Future<void> getUserInfo() async {
    if(Get.find<MarketAuthController>().isLoggedIn() && Get.find<MarketProfileController>().userInfoModel == null) {
      await Get.find<MarketProfileController>().getUserInfo();
    }
    _userInfoModel = Get.find<MarketProfileController>().userInfoModel;
    update();
  }

}