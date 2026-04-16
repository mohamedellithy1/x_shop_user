import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/features/address/controllers/market_address_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';

import 'package:stackfood_multivendor/features/location/screens/pick_map_screen.dart';
import 'package:stackfood_multivendor/features/location/widgets/animated_map_icon_extended.dart';
import 'package:stackfood_multivendor/features/location/widgets/animated_map_icon_minimized.dart';
import 'package:stackfood_multivendor/features/location/widgets/custom_floating_action_button.dart';
import 'package:stackfood_multivendor/features/location/widgets/permission_dialog.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/custom_validator.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class AddAddressScreen extends StatefulWidget {
  final bool fromCheckout;
  final int? zoneId;
  final AddressModel? address;
  final bool forGuest;

  const AddAddressScreen(
      {super.key,
      required this.fromCheckout,
      this.zoneId,
      this.address,
      this.forGuest = false});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactPersonNameController =
      TextEditingController();
  final TextEditingController _contactPersonNumberController =
      TextEditingController();
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _nameNode = FocusNode();
  CameraPosition? _cameraPosition;
  late LatLng _initialPosition;
  bool _isFirstTimeMove = true;
  final double _currentZoomLevel = 18.0;

  bool _otherSelect = false;
  String? _countryDialCode =
      Get.find<MarketAuthController>().getUserCountryCode().isNotEmpty
          ? Get.find<MarketAuthController>().getUserCountryCode()
          : CountryCode.fromCountryCode(
                  Get.find<MarketSplashController>(tag: 'xmarket')
                      .configModel!
                      .country!)
              .dialCode;

  Regions? _regions;
  FamousRegionsResponse? _famousRegions;
  static final Map<int, Regions> _regionsCache = {};
  static final Map<int, FamousRegionsResponse> _famousRegionsCache = {};
  bool isSadatSelected = false;
  int? zoneId;
  bool _isAddressManuallySelected =
      false; // Flag to prevent reverse geocoding override
  bool _isAddressChosen = false;

  @override
  void initState() {
    super.initState();

    _initCall();
  }

  void _initCall() {
    Get.find<MarketLocationController>().setAddressTypeIndex(0, notify: false);
    if (Get.find<MarketAuthController>().isLoggedIn() &&
        Get.find<MarketProfileController>().userInfoModel == null) {
      Get.find<MarketProfileController>().getUserInfo();
    }
    if (widget.address == null) {
      _initialPosition = LatLng(
        double.parse(Get.find<MarketSplashController>(tag: 'xmarket')
                .configModel
                ?.defaultLocation
                ?.lat ??
            '0'),
        double.parse(Get.find<MarketSplashController>(tag: 'xmarket')
                .configModel
                ?.defaultLocation
                ?.lng ??
            '0'),
      );
    } else {
      Get.find<MarketLocationController>().updateAddress(widget.address!);
      _initialPosition = LatLng(
        double.parse(widget.address?.latitude ?? '0'),
        double.parse(widget.address?.longitude ?? '0'),
      );

      if (widget.address?.addressType == 'home') {
        Get.find<MarketLocationController>()
            .setAddressTypeIndex(0, notify: false);
      } else if (widget.address?.addressType == 'office') {
        Get.find<MarketLocationController>()
            .setAddressTypeIndex(1, notify: false);
      } else {
        Get.find<MarketLocationController>()
            .setAddressTypeIndex(2, notify: false);
        _levelController.text = widget.address?.addressType ?? '';
        _otherSelect = true;
      }

      _splitPhoneNumber(widget.address!.contactPersonNumber!);
      _contactPersonNameController.text =
          widget.address!.contactPersonName ?? '';
      _emailController.text = widget.address!.email ?? '';
      _streetNumberController.text = widget.address!.road ?? '';
      _houseController.text = widget.address!.house ?? '';
      _floorController.text = widget.address!.floor ?? '';
      _isAddressChosen = true;
    }

    _cameraPosition =
        CameraPosition(target: _initialPosition, zoom: _currentZoomLevel);

    // Initialize Sadat city data
    Future.microtask(() => _setSadatAsFixedCity());
  }

  void _splitPhoneNumber(String number) async {
    PhoneValid phoneNumber = await CustomValidator.isPhoneValid(number);
    _countryDialCode = '+${phoneNumber.countryCode}';
    _contactPersonNumberController.text =
        phoneNumber.phone.replaceFirst('+${phoneNumber.countryCode}', '');
  }

  // تعيين السادات كمدينة ثابتة
  void _setSadatAsFixedCity() async {
    zoneId = 3; // السادات
    isSadatSelected = true;

    // تحميل بيانات السادات مباشرة
    try {
      await Future.wait([
        _fetchRegions(readableId: 3),
        _fetchFamousRegions(readableId: 3),
      ]);
      if (kDebugMode) {
        print('✅ تم تحميل بيانات السادات بنجاح');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطأ في تحميل بيانات السادات: $e');
      }
    }
  }

  Future<void> _fetchRegions({int? readableId}) async {
    if (readableId == null) return;

    if (_regionsCache.containsKey(readableId)) {
      if (kDebugMode) {
        print('📦 Using cached regions for zone: $readableId');
      }
      if (mounted) {
        setState(() {
          _regions = _regionsCache[readableId];
        });
      }
      return;
    }

    if (kDebugMode) {
      print('🔄 Fetching regions for zone: $readableId');
    }

    try {
      final response = await http.get(
        Uri.parse('https://www.x-ride.support/api/regions/regions/$readableId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final parsedBody = jsonDecode(response.body);
        final regions = Regions.fromJson(parsedBody);

        _regionsCache[readableId] = regions;

        if (kDebugMode) {
          print('✅ Loaded ${regions.data.length} regions successfully');
        }

        if (mounted) {
          setState(() {
            _regions = regions;
          });
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to fetch regions');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching regions: $e');
      }
    }
  }

  Future<void> _fetchFamousRegions({int? readableId}) async {
    if (readableId == null) return;

    // تحقق من الـ cache أولاً
    if (_famousRegionsCache.containsKey(readableId)) {
      if (kDebugMode) {
        print('📦 Using cached famous regions for zone: $readableId');
      }
      if (mounted) {
        setState(() {
          _famousRegions = _famousRegionsCache[readableId];
        });
      }
      return;
    }

    if (kDebugMode) {
      print('🔄 Fetching famous regions for zone: $readableId');
    }

    try {
      final response = await http.get(
        Uri.parse(
            'https://www.x-ride.support/api/famous-regions/regions/$readableId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final parsedBody = jsonDecode(response.body);
        final famousRegions = FamousRegionsResponse.fromJson(parsedBody);

        // حفظ في الـ cache
        _famousRegionsCache[readableId] = famousRegions;

        if (kDebugMode) {
          print(
              '✅ Loaded ${famousRegions.data.famousRegions.length} famous regions successfully');
        }

        if (mounted) {
          setState(() {
            _famousRegions = famousRegions;
          });
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: Failed to fetch famous regions');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching famous regions: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFfafef5),
      appBar: CustomAppBarWidget(
        title:
            widget.address == null ? 'add_new_address'.tr : 'update_address'.tr,
      ),
      endDrawer: const MenuDrawerWidget(),
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child:
            GetBuilder<MarketProfileController>(builder: (profileController) {
          if (profileController.userInfoModel != null &&
              _contactPersonNameController.text.isEmpty) {
            // _contactPersonNameController.text =
            //     '${profileController.userInfoModel!.fName} ${profileController.userInfoModel!.lName}';
            _splitPhoneNumber(profileController.userInfoModel!.phone!);
          }

          return GetBuilder<MarketLocationController>(
              builder: (locationController) {
            if (_isAddressChosen) {
              _addressController.text = locationController.address ?? '';
            }

            return Column(children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(children: [
                    // Map Section
                    _buildMapSection(locationController),

                    // Form Section
                    Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: Column(children: [
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        // Name Field
                        _buildNameField(),

                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        // Address Field
                        _buildAddressField(locationController),
                      ]),
                    ),
                  ]),
                ),
              ),

              // Save Button
              _buildSaveButton(locationController),
            ]);
          });
        }),
      ),
    );
  }

  Widget _buildMapSection(MarketLocationController locationController) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      width: double.infinity,
      margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Stack(children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: _currentZoomLevel,
            ),
            minMaxZoomPreference: const MinMaxZoomPreference(0, 21),
            mapType: MapType.hybrid,
            onTap: (latLng) {
              locationController.mapController
                  ?.animateCamera(CameraUpdate.newLatLng(latLng));
            },
            zoomControlsEnabled: false,
            compassEnabled: false,
            indoorViewEnabled: false,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false, // ضيف السطر ده
            myLocationEnabled: false,
            onCameraMove: ((position) => _cameraPosition = position),
            onCameraMoveStarted: () {
              locationController.updateCameraMovingStatus(true);
            },
            onCameraIdle: () {
              locationController.updateCameraMovingStatus(false);
              // Only update position if address was not manually selected from bottom sheet
              if (!_isAddressManuallySelected) {
                if (widget.address != null || !_isFirstTimeMove) {
                  locationController.updatePosition(_cameraPosition, true);
                  if (_cameraPosition != null) {
                    setState(() {
                      _isAddressChosen = true;
                    });
                  }
                }
                _isFirstTimeMove = false;
              }
            },
            onMapCreated: (GoogleMapController controller) {
              locationController.setMapController(controller);
              if (widget.address == null) {
                locationController.getCurrentLocation(true,
                    mapController: controller);
              }
            },
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer()),
              Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
              Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
              Factory<VerticalDragGestureRecognizer>(
                  () => VerticalDragGestureRecognizer()),
            },
            style: Get.isDarkMode
                ? Get.find<MarketThemeController>(tag: 'xmarket').darkMap
                : Get.find<MarketThemeController>(tag: 'xmarket').lightMap,
          ),

          // Map Pin Icon
          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: Dimensions.pickMapIconSize * 0.65),
              child: locationController.isCameraMoving
                  ? const AnimatedMapIconExtended()
                  : const AnimatedMapIconMinimised(),
            ),
          ),

          // Floating Buttons
          Positioned(
            bottom: 10,
            right: 10,
            child: Column(children: [
              CustomFloatingActionButton(
                onTap: () {
                  Get.toNamed(
                    RouteHelper.getPickMapRoute('add-address', false),
                    arguments: PickMapScreen(
                      fromAddAddress: true,
                      fromSignUp: false,
                      fromSplash: false,
                      googleMapController:
                          Get.find<MarketLocationController>().mapController,
                      route: null,
                      canRoute: false,
                    ),
                  );
                },
                icon: Icons.fullscreen,
                heroTag: 'view_full_map_button',
                iconColor:
                    Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
                        ? Colors.white
                        : Colors.black,
                iconSize: 35,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              // CustomFloatingActionButton(
              //   onTap: () {
              //     _checkPermission(() {
              //       locationController.getCurrentLocation(true,
              //           mapController: locationController.mapController);
              //     });
              //   },
              //   icon: Icons.my_location,
              //   heroTag: 'my_location',
              //   iconColor: Theme.of(context).disabledColor,
              //   iconSize: 20,
              // ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: _contactPersonNameController,
        focusNode: _nameNode,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'اسم العنوان (مثال: عنوان المنزل)',
          hintStyle: robotoRegular.copyWith(
            color: Theme.of(context).hintColor,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeLarge,
            vertical: Dimensions.paddingSizeDefault,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
            child: Icon(
              Icons.label_outline,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressField(MarketLocationController locationController) {
    return Column(
      children: [
        InkWell(
          onTap: () => _openLocationPicker(locationController),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Theme.of(context).primaryColor,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
              vertical: Dimensions.paddingSizeDefault,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Theme.of(context).disabledColor,
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Expanded(
                  child: Text(
                    _isAddressChosen && _addressController.text.isNotEmpty
                        ? _addressController.text
                        : 'choose_address'.tr,
                    style: robotoRegular.copyWith(
                      color:
                          _isAddressChosen && _addressController.text.isNotEmpty
                              ? Theme.of(context).textTheme.bodyMedium?.color
                              : Theme.of(context).hintColor,
                    ),
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.location_on_outlined,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
        if (_isAddressChosen && _addressController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
            child: CustomButtonWidget(
              height: 40,
              width: 250,
              fontSize: Dimensions.fontSizeDefault,
              buttonText: 'إضغط للإختيار من المناطق',
              onPressed: () => _openLocationPicker(locationController),
            ),
          ),
      ],
    );
  }

  void _openLocationPicker(MarketLocationController locationController) async {
    if (_regions == null || _famousRegions == null) {
      showCustomSnackBar(
        'من فضلك انتظر ثوانى\nجاري تحميل المناطق',
      );
      return;
    }

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationPickerBottomSheet(
        isFrom: true,
        regions: _regions,
        famousRegions: _famousRegions,
        locationType: LocationType.from,
      ),
    );

    if (result == null) return;

    final type = result['type'] as String?;

    if (type == null) {
      final hasLatLng =
          result.containsKey('latitude') && result.containsKey('longitude');
      final hasLatLngShort =
          result.containsKey('lat') && result.containsKey('lng');

      if (hasLatLng || hasLatLngShort) {
        final latValue = result['latitude'] ?? result['lat'];
        final lngValue = result['longitude'] ?? result['lng'];
        final address = result['address'] as String?;

        final lat = latValue is double
            ? latValue
            : (latValue is num
                ? latValue.toDouble()
                : double.tryParse(latValue.toString()));
        final lng = lngValue is double
            ? lngValue
            : (lngValue is num
                ? lngValue.toDouble()
                : double.tryParse(lngValue.toString()));

        if (lat != null &&
            lng != null &&
            address != null &&
            address.isNotEmpty) {
          _isAddressManuallySelected = true;
          setState(() {
            _addressController.text = address;
            _isAddressChosen = true;
          });

          locationController.updateAddress(AddressModel(
            latitude: lat.toString(),
            longitude: lng.toString(),
            address: address,
            addressType: 'others',
          ));

          locationController.mapController
              ?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 18));
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _isAddressManuallySelected = false;
              });
            }
          });
        }
      }
      return;
    }

    LatLng toLatLng(String latDms, String lngDms) {
      double parseDms(String dms) {
        final parts = RegExp(r'(\d+\.?\d*)')
            .allMatches(dms)
            .map((m) => m.group(0)!)
            .toList();
        if (parts.length < 3) return 0;
        final deg = double.parse(parts[0]);
        final min = double.parse(parts[1]);
        final sec = double.parse(parts[2]);
        return deg + min / 60 + sec / 3600;
      }

      final lat = parseDms(latDms) * (latDms.trim().startsWith('S') ? -1 : 1);
      final lng = parseDms(lngDms) * (lngDms.trim().startsWith('W') ? -1 : 1);
      return LatLng(lat, lng);
    }

    String fullAddress = '';
    double? lat;
    double? lng;

    if (type == 'residential') {
      final region = result['region'] as Region;
      final street = result['street'] as Street?;
      final building = result['building'] as Building;
      final latLng = toLatLng(building.lat, building.lng);

      lat = latLng.latitude;
      lng = latLng.longitude;

      fullAddress = [
        building.name,
        if (street?.name != null && street!.name.isNotEmpty) street.name,
        region.name,
      ].join(' ');

      _houseController.text = building.name;
      _streetNumberController.text = street?.name ?? '';
    } else if (type == 'famous') {
      final favRegion = result['region'] as FamousRegion;
      final favBuilding = result['building'] as FamousBuilding;
      final latLng = toLatLng(favBuilding.lat, favBuilding.lng);

      lat = latLng.latitude;
      lng = latLng.longitude;

      fullAddress = '${favRegion.name}  ${favBuilding.name}';
      _streetNumberController.text = favRegion.name;
      _houseController.text = favBuilding.name;
    }

    if (lat != null && lng != null) {
      _isAddressManuallySelected = true;
      setState(() {
        _addressController.text = fullAddress;
        _isAddressChosen = true;
      });
      locationController.setPickData();
      locationController.updateAddress(AddressModel(
        latitude: lat.toString(),
        longitude: lng.toString(),
        address: fullAddress,
        addressType: 'others',
      ));
      locationController.mapController
          ?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 18));
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isAddressManuallySelected = false;
          });
        }
      });
    }
  }

  Widget _buildSaveButton(MarketLocationController locationController) {
    final MarketAddressController addressController =
        Get.find<MarketAddressController>(tag: 'xmarket');
    return GetBuilder<MarketAddressController>(
      id: 'xmarket',
      global: false,
      init: addressController,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: CustomButtonWidget(
            radius: Dimensions.radiusDefault,
            width: double.infinity,
            buttonText: 'save_location'.tr,
            isLoading: addressController.isLoading,
            onPressed: locationController.loading
                ? null
                : () => _onSaveButtonPressed(locationController),
          ),
        );
      },
    );
  }

  void _onSaveButtonPressed(MarketLocationController locationController) async {
    String numberWithCountryCode =
        _countryDialCode! + _contactPersonNumberController.text;
    PhoneValid phoneValid =
        await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    AddressModel? addressModel = _prepareAddressModel(
        locationController, phoneValid.isValid, numberWithCountryCode);
    if (addressModel == null) {
      return;
    }

    if (widget.forGuest) {
      addressModel.email = _emailController.text;
      Get.back(result: addressModel);
    } else {
      if (widget.address == null) {
        _addAddress(addressModel);
      } else {
        _updateAddress(addressModel);
      }
    }
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    } else if (permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialog());
    } else {
      onTap();
    }
  }

  AddressModel? _prepareAddressModel(
      MarketLocationController locationController,
      bool isValid,
      String numberWithCountryCode) {
    if (_contactPersonNameController.text.isEmpty) {
      showCustomSnackBar('من فضلك ادخل اسم العنوان');
    } else if (!isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    } else {
      AddressModel addressModel = AddressModel(
        id: widget.address?.id,
        addressType:
            _contactPersonNameController.text, // Send name to address_type
        contactPersonName: _contactPersonNameController.text,
        contactPersonNumber: numberWithCountryCode,
        address: _addressController.text,
        latitude: locationController.position.latitude.toString(),
        longitude: locationController.position.longitude.toString(),
        zoneId: locationController.zoneID,
        road: _streetNumberController.text.trim(),
        house: _houseController.text.trim(),
        floor: _floorController.text.trim(),
      );

      return addressModel;
    }
    return null;
  }

  void _addAddress(AddressModel addressModel) {
    Get.find<MarketAddressController>(tag: 'xmarket')
        .addAddress(addressModel, widget.fromCheckout, widget.zoneId)
        .then((response) {
      if (response.isSuccess) {
        Get.back(result: addressModel);
        //Get.offAllNamed(RouteHelper.getAddressRoute());
        showCustomSnackBar(
          response.message!,
        );
      } else {
        showCustomSnackBar(response.message!);
      }
    });
  }

  void _updateAddress(AddressModel addressModel) {
    Get.find<MarketAddressController>(tag: 'xmarket')
        .updateAddress(addressModel, widget.address!.id)
        .then((response) {
      if (response.isSuccess) {
        Get.back();
        showCustomSnackBar(
          response.message!,
        );
      } else {
        showCustomSnackBar(response.message!);
      }
    });
  }
}

class FamousBuilding {
  final int id;
  final int famousRegionId;
  final String name;
  final String lat;
  final String lng;

  FamousBuilding({
    required this.id,
    required this.famousRegionId,
    required this.name,
    required this.lat,
    required this.lng,
  });

  factory FamousBuilding.fromJson(Map<String, dynamic> json) {
    return FamousBuilding(
      id: json['id'],
      famousRegionId: json['famous_region_id'],
      name: json['name'],
      lat: json['lat'],
      lng: json['lng'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'famous_region_id': famousRegionId,
      'name': name,
      'lat': lat,
      'lng': lng,
    };
  }
}

class FamousRegion {
  final int id;
  final String name;
  final List<FamousBuilding> famousBuilding;

  FamousRegion(
      {required this.id, required this.name, required this.famousBuilding});

  factory FamousRegion.fromJson(Map<String, dynamic> json) {
    return FamousRegion(
      id: json['id'],
      name: json['name'],
      famousBuilding: List<FamousBuilding>.from(
        json['famous_building'].map((b) => FamousBuilding.fromJson(b)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'famous_building': famousBuilding.map((b) => b.toJson()).toList(),
    };
  }
}

class Regions {
  final String status;
  final List<Region> data;

  Regions({required this.status, required this.data});

  factory Regions.fromJson(Map<String, dynamic> json) {
    var data = json['data'];
    List<Region> regionsList = [];

    if (data is List) {
      // Simple case: data is list of regions with 'region_no'
      regionsList = data
          .map((e) => Region.fromJsonSimple(e as Map<String, dynamic>))
          .toList();
    } else if (data is Map<String, dynamic> && data.containsKey('regions')) {
      // Complex case: data is a map with 'regions' key containing list
      regionsList = (data['regions'] as List<dynamic>)
          .map((e) => Region.fromJsonComplex(e as Map<String, dynamic>))
          .toList();
    }

    return Regions(
      status: json['status'] as String,
      data: regionsList,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'data': data.map((e) => e.toJson()).toList(),
      };
}

class Region {
  final int id;
  final String name;
  final List<Street> streets;
  final List<Building> buildings;

  Region({
    required this.id,
    required this.name,
    this.streets = const [],
    this.buildings = const [],
  });

  // Simple list (no nested streets/buildings)
  factory Region.fromJsonSimple(Map<String, dynamic> json) {
    return Region(
      id: json['region_no'] is int
          ? json['region_no']
          : int.tryParse(json['region_no'].toString()) ?? 0,
      name: json['name'].toString(),
      streets: const [],
      buildings: const [],
    );
  }

  // Nested list (streets *and* buildings)
  factory Region.fromJsonComplex(Map<String, dynamic> json) {
    // Handle streets - ensure it's never null
    List<Street> streetsList = [];
    if (json['streets'] != null) {
      streetsList = (json['streets'] as List<dynamic>)
          .map((e) => Street.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Handle buildings - ensure it's never null
    List<Building> buildingsList = [];
    if (json['buildings'] != null) {
      buildingsList = (json['buildings'] as List<dynamic>)
          .map((e) => Building.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return Region(
      id: json['id'] as int,
      name: json['name'].toString(),
      streets: streetsList,
      buildings: buildingsList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'streets': streets.map((s) => s.toJson()).toList(),
        'buildings': buildings.map((b) => b.toJson()).toList(),
      };
}

class Building {
  final int id;
  final String name;
  final String lat;
  final String lng;
  final int? streetId;
  final int? regionId;

  Building({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.streetId,
    this.regionId,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'] as int,
      name: json['name'] as String,
      lat: json['lat'] as String,
      lng: json['lng'] as String,
      streetId: json['street_id'] as int?,
      regionId: json['region_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lat': lat,
        'lng': lng,
        'street_id': streetId,
        'region_id': regionId,
      };
}

class Street {
  final int id;
  final String name;
  final int regionId;
  final List<Building> buildings;

  Street({
    required this.id,
    required this.name,
    required this.regionId,
    this.buildings = const [],
  });

  factory Street.fromJson(Map<String, dynamic> json) {
    return Street(
      id: json['id'] as int,
      name: json['name'] as String,
      regionId: json['region_id'] as int,
      buildings: (json['buildings'] as List<dynamic>?)
              ?.map((e) => Building.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'region_id': regionId,
        'buildings': buildings.map((b) => b.toJson()).toList(),
      };
}

enum LocationType {
  from,
  to,
  extraOne,
  extraTwo,
  location,
  accessLocation,
  senderLocation,
  receiverLocation
}

class LocationPickerBottomSheet extends StatelessWidget {
  final Regions? regions;
  final FamousRegionsResponse? famousRegions;
  final bool isFrom;
  final LocationType? locationType; // نوع الموقع (from, to, extraOne, extraTwo)
  const LocationPickerBottomSheet({
    super.key,
    this.regions,
    this.famousRegions,
    this.isFrom = false,
    this.locationType,
  });

  @override
  Widget build(BuildContext context) {
    final Color appColor =
        Get.isDarkMode ? Theme.of(context).primaryColorDark : Colors.black;

    return DraggableScrollableSheet(
      initialChildSize: 1,
      minChildSize: 1,
      maxChildSize: 1,
      expand: true,
      builder: (context, scrollController) {
        return Stack(
          children: [
            Container(color: Color(0xffe36f2c)),
            Column(
              children: [
                Container(
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

                    // gradient: LinearGradient(
                    //   colors: [Color(0xFFd6e0c4), Color(0xFFe7feba)],
                    //   begin: Alignment.topLeft,
                    //   end: Alignment.bottomRight,
                    // ),
                  ),
                  padding: const EdgeInsets.only(
                    top: 50,
                    left: Dimensions.paddingSizeDefault,
                    right: Dimensions.paddingSizeDefault - 13,
                    bottom: Dimensions.paddingSizeLarge - 10,
                  ),
                  width: double.infinity,
                  // color: Colors.orange,
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall - 5),
                        Text(
                          'select_location'.tr,
                          style: robotoRegular.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(40)),
                    ),
                    child: TabBarSection(
                      isFrom: isFrom,
                      regions: regions,
                      famousRegions: famousRegions,
                      locationType: locationType,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class TabBarSection extends StatefulWidget {
  final Regions? regions;
  final FamousRegionsResponse? famousRegions;
  final bool isFrom;
  final LocationType? locationType;

  const TabBarSection({
    super.key,
    this.regions,
    this.isFrom = false,
    this.famousRegions,
    this.locationType,
  });

  @override
  State<TabBarSection> createState() => _TabBarSectionState();
}

class _TabBarSectionState extends State<TabBarSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            dividerColor: Color(0xFF9ebc67),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black,
            indicatorColor: Color(0xFF9ebc67),
            indicatorWeight: 2,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 17,
            ),
            tabs: [
              const Tab(text: 'عمارات سكنية'),
              const Tab(text: 'أماكن مشهورة'),
              InkWell(
                  onTap: () async {
                    // إغلاق الـ bottom sheet أولاً  <--  حذفنا هذا السطر لكي لا نفقد الـ context
                    // Navigator.pop(context);

                    // تحديد نوع الموقع الصحيح
                    LocationType type;
                    if (widget.locationType != null) {
                      // إذا كان في نوع محدد (مثل extraOne أو extraTwo)
                      type = widget.locationType!;
                    } else {
                      // الطريقة القديمة (from أو to)
                      type =
                          widget.isFrom ? LocationType.from : LocationType.to;
                    }

                    // فتح الخريطة لاختيار الموقع
                    final result = await Get.to(() => PickMapScreen(
                          fromAddAddress: true,
                          fromSignUp: false,
                          fromSplash: false,
                          googleMapController:
                              Get.find<MarketLocationController>()
                                  .mapController,
                          route: null,
                          canRoute: false,
                        ));

                    // إذا تم اختيار موقع من الخريطة، إرجاع النتيجة
                    if (result != null) {
                      Navigator.pop(context, result);
                    }
                  },
                  child: const Tab(text: 'الخريطه')),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics:
                const BouncingScrollPhysics(), // ممكن تخليها NeverScrollable عشان تمنع السحب
            children: [
              _LocationGrid(
                title: 'عمارات سكنية',
                regions: widget.regions,
                famousRegions: null,
              ),
              _LocationGrid(
                title: 'أماكن مشهورة',
                regions: null,
                famousRegions: widget.famousRegions,
              ),
              // عرض رسالة للمستخدم
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'اضغط على "الخريطه" أعلاه لفتح الخريطة',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// دالة للتنقل بين الـ Tabs بسرعة مخصصة (150ms)
  void goToTab(int index) {
    _tabController.animateTo(
      index,
      duration: Duration.zero, // أسرع من الافتراضي
      curve: Curves.ease,
    );
  }
}

class _LocationGrid extends StatefulWidget {
  final String title;
  final Regions? regions;
  final FamousRegionsResponse? famousRegions;

  const _LocationGrid({
    required this.title,
    this.regions,
    this.famousRegions,
  });

  @override
  State<_LocationGrid> createState() => _LocationGridState();
}

class _LocationGridState extends State<_LocationGrid> {
  // For nested navigation
  List<dynamic> breadcrumbs = [];
  String currentLevel =
      'regions'; // For residential: regions -> streets -> buildings
  // For famous: regions -> buildings

  // Current selected items for navigation
  Region? selectedRegion;
  Street? selectedStreet;
  FamousRegion? selectedFamousRegion;

  // Search functionality
  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredData = [];
  List<dynamic> originalData = [];

  @override
  void initState() {
    super.initState();
    _updateCurrentData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _updateCurrentData() {
    originalData = getCurrentLevelData();
    filteredData = List.from(originalData);
  }

  void _filterData(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredData = List.from(originalData);
      } else {
        filteredData = originalData.where((item) {
          String name = getDisplayName(item).toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  List<dynamic> getCurrentLevelData() {
    if (widget.title == 'عمارات سكنية') {
      if (currentLevel == 'regions') {
        return widget.regions!.data;
      } else if (currentLevel == 'streets' && selectedRegion != null) {
        return selectedRegion!.streets;
      } else if (currentLevel == 'buildings') {
        if (selectedStreet != null) {
          return selectedStreet!.buildings;
        }
        return selectedRegion!.buildings;
      }
    } else if (widget.title == 'أماكن مشهورة') {
      if (widget.famousRegions == null) return [];

      if (currentLevel == 'regions') {
        return widget.famousRegions!.data.famousRegions;
      } else if (currentLevel == 'buildings' && selectedFamousRegion != null) {
        return selectedFamousRegion!.famousBuilding;
      }
    }
    return [];
  }

  void handleItemTap(dynamic item) {
    if (widget.title == 'عمارات سكنية') {
      setState(() {
        if (currentLevel == 'regions' && item is Region) {
          selectedRegion = item;
          breadcrumbs = [item];

          // ← if no streets but has buildings, go straight to buildings
          if (item.streets.isEmpty && item.buildings.isNotEmpty) {
            currentLevel = 'buildings';
          } else {
            currentLevel = 'streets';
          }

          selectedStreet = null;
          searchController.clear();
          _updateCurrentData();
        } else if (currentLevel == 'streets' && item is Street) {
          selectedStreet = item;
          breadcrumbs = [selectedRegion!, item];
          currentLevel = 'buildings';
          searchController.clear();
          _updateCurrentData();
        } else if (currentLevel == 'buildings' && item is Building) {
          Navigator.pop(context, {
            'type': 'residential',
            'region': selectedRegion,
            'street': selectedStreet,
            'building': item,
          });
        }
      });
    } else if (widget.title == 'أماكن مشهورة') {
      // Famous places navigation
      setState(() {
        if (currentLevel == 'regions' && item is FamousRegion) {
          breadcrumbs = [item]; // Replace breadcrumbs
          selectedFamousRegion = item;
          currentLevel = 'buildings';
          searchController.clear();
          _updateCurrentData();
        } else if (currentLevel == 'buildings' && item is FamousBuilding) {
          // Final selection - famous building selected
          Navigator.pop(context, {
            'type': 'famous',
            'region': selectedFamousRegion,
            'building': item,
          });
        }
      });
    }
  }

  void handleBreadcrumbTap(int index) {
    setState(() {
      // Navigate to specific breadcrumb level
      breadcrumbs = breadcrumbs.sublist(0, index + 1);

      if (widget.title == 'عمارات سكنية') {
        if (breadcrumbs.length == 1) {
          // Back to streets level
          currentLevel = 'streets';
          selectedRegion = breadcrumbs[0] as Region;
          selectedStreet = null;
        } else if (breadcrumbs.length == 2) {
          // Back to buildings level
          currentLevel = 'buildings';
          selectedRegion = breadcrumbs[0] as Region;
          selectedStreet = breadcrumbs[1] as Street;
        }
      } else if (widget.title == 'أماكن مشهورة') {
        if (breadcrumbs.length == 1) {
          // Back to buildings level
          currentLevel = 'buildings';
          selectedFamousRegion = breadcrumbs[0] as FamousRegion;
        }
      }

      searchController.clear();
      _updateCurrentData();
    });
  }

  void goBack() {
    if (breadcrumbs.isEmpty) return;

    setState(() {
      breadcrumbs.removeLast();

      if (widget.title == 'عمارات سكنية') {
        if (breadcrumbs.isEmpty) {
          currentLevel = 'regions';
          selectedRegion = null;
          selectedStreet = null;
        } else if (breadcrumbs.length == 1) {
          currentLevel = 'streets';
          selectedRegion = breadcrumbs[0] as Region;
          selectedStreet = null;
        }
      } else if (widget.title == 'أماكن مشهورة') {
        if (breadcrumbs.isEmpty) {
          currentLevel = 'regions';
          selectedFamousRegion = null;
        }
      }

      searchController.clear();
      _updateCurrentData();
    });
  }

  String getDisplayName(dynamic item) {
    if (item is Region ||
        item is Street ||
        item is Building ||
        item is FamousRegion ||
        item is FamousBuilding) {
      return item.name;
    }
    return item.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator if data is being loaded
    bool isLoading =
        (widget.title == 'عمارات سكنية' && widget.regions == null) ||
            (widget.title == 'أماكن مشهورة' && widget.famousRegions == null);

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        // Breadcrumbs
        if (breadcrumbs.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              children: [
                // Back button
                InkWell(
                  onTap: goBack,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          size: 16,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'رجوع',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ...breadcrumbs.asMap().entries.map((entry) {
                  int index = entry.key;
                  dynamic crumb = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: InkWell(
                      onTap: () => handleBreadcrumbTap(index),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          getDisplayName(crumb),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(12),
            child: TextField(
              controller: searchController,
              textAlign: TextAlign.right,
              onChanged: _filterData,
              decoration: InputDecoration(
                hintText: 'ابحث هنا',
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
                prefixIcon: const Icon(Icons.search),
                prefixIconColor: Theme.of(context).primaryColor,
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          _filterData('');
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ),
        ),

        // Grid of clickable cards
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: filteredData.isEmpty
                ? Center(
                    child: Text(
                      searchController.text.isNotEmpty
                          ? 'لا توجد نتائج للبحث'
                          : 'لا توجد بيانات متاحة',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  )
                : GridView.builder(
                    itemCount: filteredData.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      return Material(
                        color: Colors.white,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          splashColor: Colors.white,
                          highlightColor: Colors.white,
                          onTap: () => handleItemTap(filteredData[index]),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  width: 2, color: Color(0xFF9ebc67)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                getDisplayName(filteredData[index]),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class FamousRegionsResponse {
  final String status;
  final FamousRegionData data;

  FamousRegionsResponse({required this.status, required this.data});

  factory FamousRegionsResponse.fromJson(Map<String, dynamic> json) {
    return FamousRegionsResponse(
      status: json['status'],
      data: FamousRegionData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
    };
  }
}

class FamousRegionData {
  final List<FamousRegion> famousRegions;

  FamousRegionData({required this.famousRegions});

  factory FamousRegionData.fromJson(Map<String, dynamic> json) {
    return FamousRegionData(
      famousRegions: List<FamousRegion>.from(
        json['famous_regions'].map((region) => FamousRegion.fromJson(region)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'famous_regions': famousRegions.map((region) => region.toJson()).toList(),
    };
  }
}
