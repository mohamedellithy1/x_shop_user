import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get_connect.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/offline_method_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/repositories/checkout_repository_interface.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';

class CheckoutRepository implements CheckoutRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  CheckoutRepository(
      {required this.apiClient, required this.sharedPreferences});

  @override
  Future<int?> getDmTipMostTapped() async {
    int mostDmTipAmount = 0;
    Response response = await apiClient.getData(AppConstants.mostTipsUri);
    if (response.statusCode == 200) {
      mostDmTipAmount = response.body['most_tips_amount'];
    }
    return mostDmTipAmount;
  }

  @override
  Future<List<OfflineMethodModel>> getOfflineMethodList() async {
    List<OfflineMethodModel> offlineMethodList = [];
    Response response =
        await apiClient.getData(AppConstants.offlineMethodListUri);
    if (response.statusCode == 200 && response.body != null) {
      dynamic body = response.body;
      List<dynamic>? methodsList;

      // Handle different response structures
      if (body is List) {
        methodsList = body;
      } else if (body is Map) {
        // Try common keys for list data
        if (body['data'] != null && body['data'] is List) {
          methodsList = body['data'] as List<dynamic>;
        } else if (body['offline_methods'] != null &&
            body['offline_methods'] is List) {
          methodsList = body['offline_methods'] as List<dynamic>;
        } else if (body['methods'] != null && body['methods'] is List) {
          methodsList = body['methods'] as List<dynamic>;
        }
      }

      if (methodsList != null) {
        for (var method in methodsList) {
          if (method is Map<String, dynamic>) {
            offlineMethodList.add(OfflineMethodModel.fromJson(method));
          } else if (method is Map) {
            offlineMethodList.add(
                OfflineMethodModel.fromJson(Map<String, dynamic>.from(method)));
          }
        }
      }
    }
    return offlineMethodList;
  }

  @override
  Future<double> getExtraCharge(double? distance) async {
    double? extraCharge;
    Response response = await apiClient
        .getData('${AppConstants.vehicleChargeUri}?distance=$distance');
    if (response.statusCode == 200) {
      extraCharge = double.parse(response.body.toString());
    } else {
      extraCharge = 0;
    }
    return extraCharge;
  }

  @override
  Future<bool> saveOfflineInfo(String data, String? guestId) async {
    Response response = await apiClient.postData(
        '${AppConstants.offlinePaymentSaveInfoUri}/${guestId != null ? '?guest_id=$guestId' : ''}',
        jsonDecode(data));
    return (response.statusCode == 200);
  }

  @override
  Future<Response> placeOrder(PlaceOrderBodyModel orderBody) async {
    return await apiClient.postData(
        AppConstants.placeOrderUri, orderBody.toJson());
  }

  @override
  Future<Response> sendNotificationRequest(
      String orderId, String? guestId) async {
    return await apiClient.getData(
        '${AppConstants.sendCheckoutNotificationUri}/$orderId${guestId != null ? '?guest_id=$guestId' : ''}');
  }

  @override
  Future<Response> getDistanceInMeter(
      LatLng originLatLng, LatLng destinationLatLng) async {
    final response = await apiClient.getData(
      '${AppConstants.distanceMatrixUri}?origin_lat=${originLatLng.latitude}&origin_lng=${originLatLng.longitude}'
      '&destination_lat=${destinationLatLng.latitude}&destination_lng=${destinationLatLng.longitude}&mode=WALK',
    );

    return response;
  }

  @override
  Future<bool> updateOfflineInfo(String data, String? guestId) async {
    Response response = await apiClient.postData(
        '${AppConstants.offlinePaymentUpdateInfoUri}${guestId != null ? '?guest_id=$guestId' : ''}',
        jsonDecode(data));
    return (response.statusCode == 200);
  }

  @override
  Future<bool> checkRestaurantValidation(
      {required Map<String, dynamic> data, String? guestId}) async {
    Response response = await apiClient.postData(
        '${AppConstants.checkRestaurantValidation}${guestId != null ? '?guest_id=$guestId' : ''}',
        data,
        handleError: false);
    return (response.statusCode == 200);
  }

  @override
  Future<Response> getOrderTax(PlaceOrderBodyModel orderBody) async {
    Response response = await apiClient.postData(
        AppConstants.getOrderTaxUri, orderBody.toJson());
    return response;
  }

  @override
  Future<bool> saveDmTipIndex(String index) async {
    return await sharedPreferences.setString(AppConstants.dmTipIndex, index);
  }

  @override
  String getDmTipIndex() {
    return sharedPreferences.getString(AppConstants.dmTipIndex) ?? "";
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
