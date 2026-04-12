import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/language/domain/models/language_model.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';

class LocalizationController extends GetxController implements GetxService {
  final SharedPreferences sharedPreferences;

  LocalizationController({required this.sharedPreferences}) {
    loadCurrentLanguage();
  }
  Locale _locale = Locale(AppConstants.languages[0].languageCode!,
      AppConstants.languages[0].countryCode!);
  bool _isLtr = true;
  int _selectIndex = 0;
  List<LanguageModel> _languages = [];

  Locale get locale => _locale;
  bool get isLtr => _isLtr;
  int get selectIndex => _selectIndex;
  List<LanguageModel> get languages => _languages;

  void setLanguage(Locale locale) {
    Get.updateLocale(locale);
    _locale = locale;
    _isLtr = !intl.Bidi.isRtlLanguage(_locale.languageCode);
    saveLanguage(_locale);
    update(['xride']);

    Address? address;
    try {
      address = Address.fromJson(
          jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!));
      // ignore: empty_catches
    } catch (e) {}
    Get.find<ApiClient>().updateHeader(
        sharedPreferences.getString(AppConstants.token) ?? '', null, null, null, [] as String?);
    backendLanguageUpdate();
  }

  void loadCurrentLanguage() async {
    // Always use Arabic as default language
    _locale = Locale(AppConstants.languages[0].languageCode!,
        AppConstants.languages[0].countryCode!);
    _isLtr = !intl.Bidi.isRtlLanguage(_locale.languageCode);
    // Save Arabic as default if no language is saved
    if (sharedPreferences.getString(AppConstants.languageCode) == null) {
      saveLanguage(_locale);
    }
    update(['xride']);
  }

  void saveLanguage(Locale locale) async {
    sharedPreferences.setString(AppConstants.languageCode, locale.languageCode);
    sharedPreferences.setString(AppConstants.countryCode, locale.countryCode!);
    update(['xride']);
  }

  void setSelectIndex(int index) {
    _selectIndex = index;
    update(['xride']);
  }

  void searchLanguage(String query, BuildContext context) {
    if (query.isEmpty) {
      _languages.clear();
      _languages = AppConstants.languages;
      update(['xride']);
    } else {
      _selectIndex = -1;
      _languages = [];
      for (LanguageModel language in AppConstants.languages) {
        if (language.languageName!.toLowerCase().contains(query.toLowerCase())) {
          _languages.add(language);
        }
      }
      update(['xride']);
    }
  }

  void initializeAllLanguages(BuildContext context) {
    if (_languages.isEmpty) {
      _languages.clear();
      _languages = AppConstants.languages;
    }
  }

  void setInitialIndex() {
    for (int i = 0; i < AppConstants.languages.length; i++) {
      if (locale.languageCode == AppConstants.languages[i].languageCode) {
        _selectIndex = i;
      }
    }
  }

  void backendLanguageUpdate() {
    Get.find<ApiClient>().postData(AppConstants.changeLanguage, {});
  }
}
class AddressModel {
  String? responseCode;
  String? message;
  int? totalSize;
  String? limit;
  String? offset;
  List<Address>? data;

  AddressModel({
    this.responseCode,
        this.message,
        this.totalSize,
        this.limit,
        this.offset,
        this.data,
        });

  AddressModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['data'] != null) {
      data = <Address>[];
      json['data'].forEach((v) {
        data!.add(Address.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response_code'] = responseCode;
    data['message'] = message;
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class Address {
  int? id;
  String? userId;
  double? latitude;
  double? longitude;
  String? street;
  String? house;
  String? contactPersonName;
  String? contactPersonPhone;
  String? address;
  String? addressLabel;
  String? createdAt;
  String? zoneId;

  Address({
    this.id,
        this.userId,
        this.latitude,
        this.longitude,
        this.street,
        this.house,
        this.contactPersonName,
        this.contactPersonPhone,
        this.address,
        this.addressLabel,
        this.createdAt,
        this.zoneId,
      });

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id']?.toString();
    latitude = json['latitude'] != null
        ? double.parse(json['latitude'].toString())
        : 0;
    longitude = json['longitude'] != null
        ? double.parse(json['longitude'].toString())
        : 0;
    street = json['street'];
    house = json['house'];
    contactPersonName = json['contact_person_name'];
    contactPersonPhone = json['contact_person_phone'];
    address = json['address'];
    addressLabel = json['address_label'];
    createdAt = json['created_at'];
    zoneId = json['zone_id']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['street'] = street;
    data['house'] = house;
    data['contact_person_name'] = contactPersonName;
    data['contact_person_phone'] = contactPersonPhone;
    data['address'] = address;
    data['address_label'] = addressLabel;
    data['created_at'] = createdAt;
    data['zone_id'] = zoneId;
    return data;
  }
}
