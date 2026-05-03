import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/features/home/domain/models/banner_model.dart';
import 'package:stackfood_multivendor/features/home/domain/models/cashback_model.dart';
import 'package:stackfood_multivendor/features/home/domain/services/home_service_interface.dart';
import 'package:get/get.dart';

class HomeController extends GetxController implements GetxService {
  final HomeServiceInterface homeServiceInterface;

  HomeController({required this.homeServiceInterface});

  List<String?>? _bannerImageList;
  List<dynamic>? _bannerDataList;

  List<String?>? get bannerImageList => _bannerImageList;
  List<dynamic>? get bannerDataList => _bannerDataList;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  bool isVideoPausedByForce = false;
  bool shouldReset = false;

  void forcePauseVideo(bool pause) {
    isVideoPausedByForce = pause;
    update();
  }

  void resetBanner() {
    shouldReset = true;
    _currentIndex = 0;
    update();
  }

  void acknowledgeReset() {
    shouldReset = false;
  }

  List<CashBackModel>? _cashBackOfferList;
  List<CashBackModel>? get cashBackOfferList => _cashBackOfferList;

  CashBackModel? _cashBackData;
  CashBackModel? get cashBackData => _cashBackData;

  bool _showFavButton = true;
  bool get showFavButton => _showFavButton;

  Future<void> getBannerList(bool reload,
      {DataSourceEnum dataSource = DataSourceEnum.client,
      bool fromRecall = false}) async {
    print(
        '🚀 [HomeController] getBannerList called (dataSource: $dataSource, reload: $reload)');
    if (_bannerImageList == null || reload || fromRecall) {
      if (!fromRecall) {
        _bannerImageList = null;
      }
      BannerModel? bannerModel;
      
      print('🌐 [HomeController] Fetching Banners from Client (API)...');
      bannerModel = await homeServiceInterface.getBannerList(
          source: DataSourceEnum.client);
      if (bannerModel != null) {
        print('---👇---Banner API Response Content---👇---');
        print(bannerModel.toJson());
        print('-----------------------------------------');
      } else {
        print('❌ [HomeController] Banner API returned NULL');
      }
      _prepareBannerList(bannerModel);
    }
  }

  void _prepareBannerList(BannerModel? bannerModel) {
    if (bannerModel != null) {
      _bannerImageList = [];
      _bannerDataList = [];
      for (var campaign in bannerModel.campaigns!) {
        _bannerImageList!.add(campaign.imageFullUrl);
        _bannerDataList!.add(campaign);
        print('🖼️ [CAMPAIGN IMAGE]: ${campaign.imageFullUrl}');
      }
      for (var banner in bannerModel.banners!) {
        String? imageUrl = banner.imageFullUrl;
        print('🖼️ [BANNER IMAGE]: $imageUrl');
        
        if (_bannerImageList!.contains(imageUrl)) {
          _bannerImageList!.add(
              '${imageUrl}${bannerModel.banners!.indexOf(banner)}');
        } else {
          _bannerImageList!.add(imageUrl);
        }
        if (banner.food != null) {
          _bannerDataList!.add(banner.food);
        } else {
          _bannerDataList!.add(banner.restaurant);
        }
      }
    }
    print('---👇---Final Prepared Banner List---👇---');
    print(_bannerImageList);
    update();
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if (notify) {
      update();
    }
  }

  Future<void> getCashBackOfferList(
      {DataSourceEnum dataSource = DataSourceEnum.local}) async {
    _cashBackOfferList = null;
    List<CashBackModel>? cashBackOfferList;

    if (dataSource == DataSourceEnum.local) {
      cashBackOfferList = await homeServiceInterface.getCashBackOfferList(
          source: DataSourceEnum.local);
      _prepareCashBackOfferList(cashBackOfferList);
      getCashBackOfferList(dataSource: DataSourceEnum.client);
    } else {
      cashBackOfferList = await homeServiceInterface.getCashBackOfferList(
          source: DataSourceEnum.client);
      _prepareCashBackOfferList(cashBackOfferList);
    }
  }

  void _prepareCashBackOfferList(List<CashBackModel>? cashBackOfferList) {
    if (cashBackOfferList != null) {
      _cashBackOfferList = [];
      _cashBackOfferList!.addAll(cashBackOfferList);
    }
    update();
  }

  void forcefullyNullCashBackOffers() {
    _cashBackOfferList = null;
    update();
  }

  Future<void> getCashBackData(double amount) async {
    CashBackModel? cashBackModel =
        await homeServiceInterface.getCashBackData(amount);
    if (cashBackModel != null) {
      _cashBackData = cashBackModel;
    }
    update();
  }

  void changeFavVisibility() {
    _showFavButton = !_showFavButton;
    update();
  }
}