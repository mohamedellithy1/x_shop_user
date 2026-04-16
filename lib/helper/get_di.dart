import 'dart:convert';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/dashboard/domain/repositories/dashboard_repo.dart';
import 'package:stackfood_multivendor/features/dashboard/domain/repositories/dashboard_repo_interface.dart';
import 'package:stackfood_multivendor/features/dine_in/controllers/dine_in_controller.dart';
import 'package:stackfood_multivendor/features/dine_in/domain/repositories/dine_in_repository.dart';
import 'package:stackfood_multivendor/features/dine_in/domain/repositories/dine_in_repository_interface.dart';
import 'package:stackfood_multivendor/features/dine_in/domain/services/dine_in_service.dart';
import 'package:stackfood_multivendor/features/dine_in/domain/services/dine_in_service_interface.dart';
import 'package:stackfood_multivendor/features/home/controllers/advertisement_controller.dart';
import 'package:stackfood_multivendor/features/home/domain/repositories/advertisement_repository.dart';
import 'package:stackfood_multivendor/features/home/domain/repositories/advertisement_repository_interface.dart';
import 'package:stackfood_multivendor/features/home/domain/services/advertisement_service.dart';
import 'package:stackfood_multivendor/features/home/domain/services/advertisement_service_interface.dart';
import 'package:stackfood_multivendor/features/product/controllers/campaign_controller.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/news/controllers/news_controller.dart';
import 'package:stackfood_multivendor/news/domain/repositories/news_repository.dart';
import 'package:stackfood_multivendor/features/cart/domain/repositories/cart_repository.dart';
import 'package:stackfood_multivendor/features/cart/domain/repositories/cart_repository_interface.dart';
import 'package:stackfood_multivendor/features/cart/domain/services/cart_service.dart';
import 'package:stackfood_multivendor/features/cart/domain/services/cart_service_interface.dart';
import 'package:stackfood_multivendor/features/chat/controllers/chat_controller.dart';
import 'package:stackfood_multivendor/features/chat/domain/repositories/chat_repository.dart';
import 'package:stackfood_multivendor/features/chat/domain/repositories/chat_repository_interface.dart';
import 'package:stackfood_multivendor/features/chat/domain/services/chat_service.dart';
import 'package:stackfood_multivendor/features/chat/domain/services/chat_service_interface.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:stackfood_multivendor/features/checkout/domain/repositories/checkout_repository_interface.dart';
import 'package:stackfood_multivendor/features/checkout/domain/services/checkout_service.dart';
import 'package:stackfood_multivendor/features/checkout/domain/services/checkout_service_interface.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/home/controllers/home_controller.dart';
import 'package:stackfood_multivendor/features/home/domain/repositories/home_repository.dart';
import 'package:stackfood_multivendor/features/home/domain/repositories/home_repository_interface.dart';
import 'package:stackfood_multivendor/features/home/domain/services/home_service.dart';
import 'package:stackfood_multivendor/features/home/domain/services/home_service_interface.dart';
import 'package:stackfood_multivendor/features/home/controllers/banner_controller.dart';
import 'package:stackfood_multivendor/features/home/domain/repositories/banner_repo.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/repositories/order_repository.dart';
import 'package:stackfood_multivendor/features/order/domain/repositories/order_repository_interface.dart';
import 'package:stackfood_multivendor/features/order/domain/services/order_service.dart';
import 'package:stackfood_multivendor/features/order/domain/services/order_service_interface.dart';
import 'package:stackfood_multivendor/features/product/domain/repositories/campaign_repository.dart';
import 'package:stackfood_multivendor/features/product/domain/repositories/campaign_repository_interface.dart';
import 'package:stackfood_multivendor/features/product/domain/services/campaign_service.dart';
import 'package:stackfood_multivendor/features/product/domain/services/campaign_service_interface.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/html/controllers/html_controller.dart';
import 'package:stackfood_multivendor/features/html/domain/repositories/html_repository.dart';
import 'package:stackfood_multivendor/features/html/domain/repositories/html_repository_interface.dart';
import 'package:stackfood_multivendor/features/html/domain/services/html_service.dart';
import 'package:stackfood_multivendor/features/html/domain/services/html_service_interface.dart';
import 'package:stackfood_multivendor/features/language/domain/models/language_model.dart';
import 'package:stackfood_multivendor/features/language/domain/repository/language_repository.dart';
import 'package:stackfood_multivendor/features/language/domain/repository/language_repository_interface.dart';
import 'package:stackfood_multivendor/features/language/domain/service/language_service.dart';
import 'package:stackfood_multivendor/features/language/domain/service/language_service_interface.dart';
import 'package:stackfood_multivendor/features/notification/controllers/notification_controller.dart';
import 'package:stackfood_multivendor/features/notification/domain/repository/notification_repository.dart';
import 'package:stackfood_multivendor/features/notification/domain/repository/notification_repository_interface.dart';
import 'package:stackfood_multivendor/features/notification/domain/service/notification_service.dart';
import 'package:stackfood_multivendor/features/notification/domain/service/notification_service_interface.dart';
import 'package:stackfood_multivendor/features/onboard/controllers/onboard_controller.dart';
import 'package:stackfood_multivendor/features/onboard/domain/repository/onboard_repository.dart';
import 'package:stackfood_multivendor/features/onboard/domain/repository/onboard_repository_interface.dart';
import 'package:stackfood_multivendor/features/onboard/domain/service/notification_service.dart';
import 'package:stackfood_multivendor/features/onboard/domain/service/onboard_service_interface.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/profile/domain/repositories/profile_repository.dart';
import 'package:stackfood_multivendor/features/profile/domain/repositories/profile_repository_interface.dart';
import 'package:stackfood_multivendor/features/profile/domain/services/profile_service.dart';
import 'package:stackfood_multivendor/features/profile/domain/services/profile_service_interface.dart';
import 'package:stackfood_multivendor/features/refer_and_earn/controllers/refer_and_earn_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/repositories/restaurant_repository.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/repositories/restaurant_repository_interface.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/services/restaurant_service.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/services/restaurant_service_interface.dart';
import 'package:stackfood_multivendor/features/search/controllers/search_controller.dart';
import 'package:stackfood_multivendor/features/search/domain/repositories/search_repository.dart';
import 'package:stackfood_multivendor/features/search/domain/repositories/search_repository_interface.dart';
import 'package:stackfood_multivendor/features/search/domain/services/search_service.dart';
import 'package:stackfood_multivendor/features/search/domain/services/search_service_interface.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/address/controllers/market_address_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/reposotories/address_repo.dart';
import 'package:stackfood_multivendor/features/address/domain/reposotories/address_repo_interface.dart';
import 'package:stackfood_multivendor/features/address/domain/services/address_service.dart';
import 'package:stackfood_multivendor/features/address/domain/services/address_service_interface.dart';
import 'package:stackfood_multivendor/features/auth/controllers/deliveryman_registration_controller.dart';
import 'package:stackfood_multivendor/features/auth/controllers/restaurant_registration_controller.dart';
import 'package:stackfood_multivendor/features/auth/domain/reposotories/auth_repo.dart';
import 'package:stackfood_multivendor/features/auth/domain/reposotories/auth_repo_interface.dart';
import 'package:stackfood_multivendor/features/auth/domain/reposotories/deliveryman_registration_repo.dart';
import 'package:stackfood_multivendor/features/auth/domain/reposotories/deliveryman_registration_repo_interface.dart';
import 'package:stackfood_multivendor/features/auth/domain/reposotories/restaurant_registration_repo.dart';
import 'package:stackfood_multivendor/features/auth/domain/reposotories/restaurant_registration_repo_interface.dart';
import 'package:stackfood_multivendor/features/auth/domain/services/auth_service.dart';
import 'package:stackfood_multivendor/features/auth/domain/services/auth_service_interface.dart';
import 'package:stackfood_multivendor/features/auth/domain/services/deliveryman_registration_service.dart';
import 'package:stackfood_multivendor/features/auth/domain/services/deliveryman_registration_service_interface.dart';
import 'package:stackfood_multivendor/features/auth/domain/services/restaurant_registration_service.dart';
import 'package:stackfood_multivendor/features/auth/domain/services/restaurant_registration_service_interface.dart';
import 'package:stackfood_multivendor/features/business/controllers/business_controller.dart';
import 'package:stackfood_multivendor/features/business/domain/reposotories/business_repo.dart';
import 'package:stackfood_multivendor/features/business/domain/reposotories/business_repo_interface.dart';
import 'package:stackfood_multivendor/features/business/domain/services/business_service.dart';
import 'package:stackfood_multivendor/features/business/domain/services/business_service_interface.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/features/category/domain/reposotories/category_repository.dart';
import 'package:stackfood_multivendor/features/category/domain/reposotories/category_repository_interface.dart';
import 'package:stackfood_multivendor/features/category/domain/services/category_service.dart';
import 'package:stackfood_multivendor/features/category/domain/services/category_service_interface.dart';
import 'package:stackfood_multivendor/features/coupon/domain/reposotories/coupon_repository.dart';
import 'package:stackfood_multivendor/features/coupon/domain/reposotories/coupon_repository_interface.dart';
import 'package:stackfood_multivendor/features/coupon/domain/services/coupon_service.dart';
import 'package:stackfood_multivendor/features/coupon/domain/services/coupon_service_interface.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/features/cuisine/domain/repositories/cuisine_repository.dart';
import 'package:stackfood_multivendor/features/cuisine/domain/repositories/cuisine_repository_interface.dart';
import 'package:stackfood_multivendor/features/cuisine/domain/services/cuisine_service.dart';
import 'package:stackfood_multivendor/features/cuisine/domain/services/cuisine_service_interface.dart';
import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stackfood_multivendor/features/dashboard/domain/services/dashboard_service.dart';
import 'package:stackfood_multivendor/features/dashboard/domain/services/dashboard_service_interface.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/favourite/domain/repositories/favourite_repository.dart';
import 'package:stackfood_multivendor/features/favourite/domain/repositories/favourite_repository_interface.dart';
import 'package:stackfood_multivendor/features/favourite/domain/services/favourite_service.dart';
import 'package:stackfood_multivendor/features/favourite/domain/services/favourite_service_interface.dart';
import 'package:stackfood_multivendor/features/interest/controllers/interest_controller.dart';
import 'package:stackfood_multivendor/features/interest/domain/repositories/interest_repository.dart';
import 'package:stackfood_multivendor/features/interest/domain/repositories/interest_repository_interface.dart';
import 'package:stackfood_multivendor/features/interest/domain/services/interest_service.dart';
import 'package:stackfood_multivendor/features/interest/domain/services/interest_service_interface.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/reposotories/location_repo.dart';
import 'package:stackfood_multivendor/features/location/domain/reposotories/location_repo_interface.dart';
import 'package:stackfood_multivendor/features/location/domain/services/location_service.dart';
import 'package:stackfood_multivendor/features/location/domain/services/location_service_interface.dart';
import 'package:stackfood_multivendor/features/loyalty/controllers/loyalty_controller.dart';
import 'package:stackfood_multivendor/features/loyalty/domain/repositories/loyalty_repository.dart';
import 'package:stackfood_multivendor/features/loyalty/domain/repositories/loyalty_repository_interface.dart';
import 'package:stackfood_multivendor/features/loyalty/domain/services/loyalty_service.dart';
import 'package:stackfood_multivendor/features/loyalty/domain/services/loyalty_service_interface.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/features/product/domain/repositories/product_repository.dart';
import 'package:stackfood_multivendor/features/product/domain/repositories/product_repository_interface.dart';
import 'package:stackfood_multivendor/features/product/domain/services/product_service.dart';
import 'package:stackfood_multivendor/features/product/domain/services/product_service_interface.dart';
import 'package:stackfood_multivendor/features/review/controllers/review_controller.dart';
import 'package:stackfood_multivendor/features/review/domain/repositories/review_repository.dart';
import 'package:stackfood_multivendor/features/review/domain/repositories/review_repository_interface.dart';
import 'package:stackfood_multivendor/features/review/domain/services/review_service.dart';
import 'package:stackfood_multivendor/features/review/domain/services/review_service_interface.dart';
import 'package:stackfood_multivendor/features/splash/domain/repositories/splash_repository.dart';
import 'package:stackfood_multivendor/features/splash/domain/repositories/splash_repository_interface.dart';
import 'package:stackfood_multivendor/features/splash/domain/services/splash_service.dart';
import 'package:stackfood_multivendor/features/splash/domain/services/splash_service_interface.dart';
import 'package:stackfood_multivendor/features/verification/controllers/verification_controller.dart';
import 'package:stackfood_multivendor/features/verification/domein/reposotories/verification_repo.dart';
import 'package:stackfood_multivendor/features/verification/domein/reposotories/verification_repo_interface.dart';
import 'package:stackfood_multivendor/features/verification/domein/services/verification_service.dart';
import 'package:stackfood_multivendor/features/verification/domein/services/verification_service_interface.dart';
import 'package:stackfood_multivendor/features/wallet/controllers/wallet_controller.dart';
import 'package:stackfood_multivendor/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:stackfood_multivendor/features/wallet/domain/repositories/wallet_repository_interface.dart';
import 'package:stackfood_multivendor/features/wallet/domain/services/wallet_service.dart';
import 'package:stackfood_multivendor/features/wallet/domain/services/wallet_service_interface.dart';
import 'package:stackfood_multivendor/localization/localization_controller.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/core/realtime/reverb_service.dart';
import 'package:stackfood_multivendor/core/realtime/delivery_realtime_service.dart';

Future<Map<String, Map<String, String>>> init() async {
  /// Core
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);
  // Use tag to differentiate xmarket ApiClient from xride ApiClient
  Get.lazyPut(
      () => ApiClient(
          appBaseUrl: AppConstants.baseUrl, sharedPreferences: Get.find()),
      tag: 'xmarket');

  ///Interfaces
  LocationRepoInterface locationRepoInterface =
      LocationRepo(apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => locationRepoInterface, tag: 'xmarket');
  LocationServiceInterface locationServiceInterface =
      LocationService(locationRepoInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => locationServiceInterface, tag: 'xmarket');
  AddressRepoInterface addressRepoInterface =
      AddressRepo(apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => addressRepoInterface, tag: 'xmarket');
  AddressServiceInterface addressServiceInterface =
      AddressService(addressRepoInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => addressServiceInterface, tag: 'xmarket');
  DashboardRepoInterface dashboardRepoInterface =
      DashboardRepo(sharedPreferences: Get.find());
  Get.lazyPut(() => dashboardRepoInterface, tag: 'xmarket');
  DashboardServiceInterface dashboardServiceInterface =
      DashboardService(dashboardRepoInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => dashboardServiceInterface, tag: 'xmarket');
  BusinessRepoInterface businessRepoInterface =
      BusinessRepo(apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => businessRepoInterface, tag: 'xmarket');
  BusinessServiceInterface businessServiceInterface =
      BusinessService(businessRepoInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => businessServiceInterface, tag: 'xmarket');
  AuthRepoInterface authRepoInterface = AuthRepo(
      apiClient: Get.find(tag: 'xmarket'), sharedPreferences: Get.find());
  Get.lazyPut(() => authRepoInterface, tag: 'xmarket');
  AuthServiceInterface authServiceInterface =
      AuthService(authRepoInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => authServiceInterface, tag: 'xmarket');
  DeliverymanRegistrationRepoInterface deliverymanRegistrationRepoInterface =
      DeliverymanRegistrationRepo(apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => deliverymanRegistrationRepoInterface, tag: 'xmarket');
  DeliverymanRegistrationServiceInterface
      deliverymanRegistrationServiceInterface = DeliverymanRegistrationService(
          deliverymanRegistrationRepoInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => deliverymanRegistrationServiceInterface, tag: 'xmarket');
  RestaurantRegistrationRepoInterface restaurantRegistrationRepoInterface =
      RestaurantRegistrationRepo(apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => restaurantRegistrationRepoInterface, tag: 'xmarket');
  RestaurantRegistrationServiceInterface
      restaurantRegistrationServiceInterface = RestaurantRegistrationService(
          restaurantRegistrationRepoInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => restaurantRegistrationServiceInterface, tag: 'xmarket');
  VerificationRepoInterface verificationRepoInterface = VerificationRepo(
      sharedPreferences: Get.find(), apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => verificationRepoInterface, tag: 'xmarket');
  VerificationServiceInterface verificationServiceInterface =
      VerificationService(
          verificationRepoInterface: Get.find(tag: 'xmarket'),
          authRepoInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => verificationServiceInterface, tag: 'xmarket');
  CategoryRepositoryInterface categoryRepositoryInterface =
      CategoryRepository(apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => categoryRepositoryInterface, tag: 'xmarket');
  CategoryServiceInterface categoryServiceInterface =
      CategoryService(categoryRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => categoryServiceInterface, tag: 'xmarket');
  CouponRepositoryInterface couponRepositoryInterface =
      CouponRepository(apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => couponRepositoryInterface, tag: 'xmarket');
  CouponServiceInterface couponServiceInterface =
      CouponService(couponRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => couponServiceInterface, tag: 'xmarket');
  ChatRepositoryInterface chatRepositoryInterface =
      ChatRepository(apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => chatRepositoryInterface, tag: 'xmarket');
  ChatServiceInterface chatServiceInterface =
      ChatService(chatRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => chatServiceInterface, tag: 'xmarket');
  CuisineRepositoryInterface cuisineRepositoryInterface =
      CuisineRepository(apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => cuisineRepositoryInterface, tag: 'xmarket');
  CuisineServiceInterface cuisineServiceInterface =
      CuisineService(cuisineRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => cuisineServiceInterface, tag: 'xmarket');
  FavouriteRepositoryInterface favouriteRepositoryInterface =
      FavouriteRepository(apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => favouriteRepositoryInterface, tag: 'xmarket');
  FavouriteServiceInterface favouriteServiceInterface =
      FavouriteService(favouriteRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => favouriteServiceInterface, tag: 'xmarket');
  ProductRepositoryInterface productRepositoryInterface =
      ProductRepository(apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => productRepositoryInterface, tag: 'xmarket');
  ProductServiceInterface productServiceInterface =
      ProductService(productRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => productServiceInterface, tag: 'xmarket');
  ReviewRepositoryInterface reviewRepositoryInterface =
      ReviewRepository(apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => reviewRepositoryInterface, tag: 'xmarket');
  ReviewServiceInterface reviewServiceInterface =
      ReviewService(reviewRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => reviewServiceInterface, tag: 'xmarket');
  InterestRepositoryInterface interestRepositoryInterface =
      InterestRepository(apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => interestRepositoryInterface, tag: 'xmarket');
  InterestServiceInterface interestServiceInterface =
      InterestService(interestRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => interestServiceInterface, tag: 'xmarket');
  WalletRepositoryInterface walletRepositoryInterface = WalletRepository(
      apiClient: Get.find(tag: 'xmarket'), sharedPreferences: Get.find());
  Get.lazyPut(() => walletRepositoryInterface, tag: 'xmarket');
  WalletServiceInterface walletServiceInterface =
      WalletService(walletRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => walletServiceInterface, tag: 'xmarket');
  LoyaltyRepositoryInterface loyaltyRepositoryInterface = LoyaltyRepository(
      apiClient: Get.find(tag: 'xmarket'), sharedPreferences: Get.find());
  Get.lazyPut(() => loyaltyRepositoryInterface, tag: 'xmarket');
  LoyaltyServiceInterface loyaltyServiceInterface =
      LoyaltyService(loyaltyRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => loyaltyServiceInterface, tag: 'xmarket');
  // Register SplashRepositoryInterface first
  final splashRepositoryInterface = SplashRepository(
      apiClient: Get.find<ApiClient>(tag: 'xmarket'),
      sharedPreferences: Get.find<SharedPreferences>());
  Get.put<SplashRepositoryInterface>(splashRepositoryInterface, tag: 'xmarket');

  // Register SplashServiceInterface after repository
  final splashServiceInterface = SplashService(
      splashRepositoryInterface:
          Get.find<SplashRepositoryInterface>(tag: 'xmarket'));
  Get.put<SplashServiceInterface>(splashServiceInterface, tag: 'xmarket');
  HtmlRepositoryInterface htmlRepositoryInterface =
      HtmlRepository(apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => htmlRepositoryInterface, tag: 'xmarket');
  HtmlServiceInterface htmlServiceInterface =
      HtmlService(htmlRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => htmlServiceInterface, tag: 'xmarket');
  LanguageRepositoryInterface languageRepositoryInterface = LanguageRepository(
      apiClient: Get.find(tag: 'xmarket'), sharedPreferences: Get.find());
  Get.lazyPut(() => languageRepositoryInterface, tag: 'xmarket');
  LanguageServiceInterface languageServiceInterface =
      LanguageService(languageRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => languageServiceInterface, tag: 'xmarket');
  NotificationRepositoryInterface notificationRepositoryInterface =
      NotificationRepository(
          apiClient: Get.find(tag: 'xmarket'), sharedPreferences: Get.find());
  Get.lazyPut(() => notificationRepositoryInterface, tag: 'xmarket');
  NotificationServiceInterface notificationServiceInterface =
      NotificationService(
          notificationRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => notificationServiceInterface, tag: 'xmarket');
  OnboardRepositoryInterface onboardRepositoryInterface = OnboardRepository();
  Get.lazyPut(() => onboardRepositoryInterface, tag: 'xmarket');
  OnboardServiceInterface onboardServiceInterface =
      OnboardService(onboardRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => onboardServiceInterface, tag: 'xmarket');
  SearchRepositoryInterface searchRepositoryInterface = SearchRepository(
      apiClient: Get.find(tag: 'xmarket'), sharedPreferences: Get.find());
  Get.lazyPut(() => searchRepositoryInterface, tag: 'xmarket');
  SearchServiceInterface searchServiceInterface =
      SearchService(searchRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => searchServiceInterface, tag: 'xmarket');
  ProfileRepositoryInterface profileRepositoryInterface =
      ProfileRepository(apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => profileRepositoryInterface, tag: 'xmarket');
  ProfileServiceInterface profileServiceInterface =
      ProfileService(profileRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => profileServiceInterface, tag: 'xmarket');
  RestaurantRepositoryInterface restaurantRepositoryInterface =
      RestaurantRepository(
          apiClient: Get.find(tag: 'xmarket'), sharedPreferences: Get.find());
  Get.lazyPut(() => restaurantRepositoryInterface, tag: 'xmarket');
  RestaurantServiceInterface restaurantServiceInterface = RestaurantService(
      restaurantRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => restaurantServiceInterface, tag: 'xmarket');
  CheckoutRepositoryInterface checkoutRepositoryInterface = CheckoutRepository(
      apiClient: Get.find(tag: 'xmarket'), sharedPreferences: Get.find());
  Get.lazyPut(() => checkoutRepositoryInterface, tag: 'xmarket');
  CheckoutServiceInterface checkoutServiceInterface =
      CheckoutService(checkoutRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => checkoutServiceInterface, tag: 'xmarket');
  CartRepositoryInterface cartRepositoryInterface = CartRepository(
      apiClient: Get.find(tag: 'xmarket'), sharedPreferences: Get.find());
  Get.lazyPut(() => cartRepositoryInterface, tag: 'xmarket');
  CartServiceInterface cartServiceInterface =
      CartService(cartRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => cartServiceInterface, tag: 'xmarket');
  OrderRepositoryInterface orderRepositoryInterface =
      OrderRepository(apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => orderRepositoryInterface, tag: 'xmarket');
  OrderServiceInterface orderServiceInterface =
      OrderService(orderRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => orderServiceInterface, tag: 'xmarket');
  HomeRepositoryInterface homeRepositoryInterface =
      HomeRepository(apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => homeRepositoryInterface, tag: 'xmarket');
  HomeServiceInterface homeServiceInterface =
      HomeService(homeRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => homeServiceInterface, tag: 'xmarket');
  CampaignRepositoryInterface campaignRepositoryInterface =
      CampaignRepository(apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => campaignRepositoryInterface, tag: 'xmarket');
  CampaignServiceInterface campaignServiceInterface =
      CampaignService(campaignRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => campaignServiceInterface, tag: 'xmarket');
  AdvertisementRepositoryInterface advertisementRepositoryInterface =
      AdvertisementRepository(apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => advertisementRepositoryInterface, tag: 'xmarket');
  AdvertisementServiceInterface advertisementServiceInterface =
      AdvertisementService(
          advertisementRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => advertisementServiceInterface, tag: 'xmarket');
  DineInRepositoryInterface dineInRepositoryInterface =
      DineInRepository(apiClient: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => dineInRepositoryInterface, tag: 'xmarket');
  DineInServiceInterface dineInServiceInterface =
      DineInService(dineInRepositoryInterface: Get.find(tag: 'xmarket'));
  Get.lazyPut(() => dineInServiceInterface, tag: 'xmarket');

  Get.lazyPut(() => NewsRepository(Get.find(tag: 'xmarket')));
  Get.lazyPut(() => BannerRepo(apiClient: Get.find(tag: 'xmarket')));

  /// Controller
  Get.lazyPut(
      () => MarketThemeController(
          splashServiceInterface:
              Get.find<SplashServiceInterface>(tag: 'xmarket')),
      tag: 'xmarket');
  Get.lazyPut(
      () => MarketSplashController(
          splashServiceInterface:
              Get.find<SplashServiceInterface>(tag: 'xmarket')),
      tag: 'xmarket');
  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find()),
      tag: 'xmarket');
  Get.lazyPut(() =>
      OnBoardingController(onboardServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() =>
      MarketAuthController(authServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(
      () => MarketAddressController(
          addressServiceInterface: Get.find(tag: 'xmarket')),
      tag: 'xmarket');
  Get.lazyPut(() => MarketLocationController(
      locationServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() =>
      DashboardController(dashboardServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() =>
      BusinessController(businessServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() => DeliverymanRegistrationController(
      deliverymanRegistrationServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() => RestaurantRegistrationController(
      restaurantRegistrationServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() => VerificationController(
      verificationServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() => MarketCategoryController(
      categoryServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(
      () => ChatController(chatServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() =>
      CuisineController(cuisineServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() =>
      FavouriteController(favouriteServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() =>
      ProductController(productServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(
      () => ReviewController(reviewServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() =>
      InterestController(interestServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() =>
      MarketWalletController(walletServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() =>
      LoyaltyController(loyaltyServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(
      () => HtmlController(htmlServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() => MarketNotificationController(
      notificationServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() => MarketProfileController(
      profileServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(
      () => HomeController(homeServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() =>
      MarketCartController(cartServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() => RestaurantController(
      restaurantServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() => MarketReferAndEarnController());
  Get.lazyPut(
      () => SearchController(searchServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() =>
      MarketCouponController(couponServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(
      () => OrderController(orderServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() =>
      CampaignController(campaignServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() =>
      CheckoutController(checkoutServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() => AdvertisementController(
      advertisementServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(
      () => DineInController(dineInServiceInterface: Get.find(tag: 'xmarket')));
  Get.lazyPut(() => ReverbService());
  Get.lazyPut(() => UserRealtimeService());
  Get.lazyPut(() => BannerController(bannerRepo: Get.find()));
  Get.lazyPut(() => NewsController(newsRepo: Get.find()));

  /// Retrieving localized data
  /// Note: Language files are already loaded by xride DI, so we return empty map
  /// to avoid conflicts and missing file errors
  Map<String, Map<String, String>> languages = {};
  // Try to load language files safely, skip if file doesn't exist
  for (LanguageModel languageModel in AppConstants.languages) {
    try {
      String jsonStringValues = await rootBundle
          .loadString('assets/language/${languageModel.languageCode}.json');
      Map<String, dynamic> mappedJson = jsonDecode(jsonStringValues);
      Map<String, String> json = {};
      mappedJson.forEach((key, value) {
        json[key] = value.toString();
      });
      languages['${languageModel.languageCode}_${languageModel.countryCode}'] =
          json;
    } catch (e) {
      // Skip languages that don't have files
      // Languages are already loaded by xride DI
      continue;
    }
  }
  return languages;
}
