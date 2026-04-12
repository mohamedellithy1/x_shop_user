import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/vehicle_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/zone_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/reposotories/deliveryman_registration_repo_interface.dart';
import 'package:stackfood_multivendor/features/auth/domain/services/deliveryman_registration_service_interface.dart';
import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';

class DeliverymanRegistrationService
    implements DeliverymanRegistrationServiceInterface {
  final DeliverymanRegistrationRepoInterface
      deliverymanRegistrationRepoInterface;
  DeliverymanRegistrationService(
      {required this.deliverymanRegistrationRepoInterface});

  @override
  Future<List<ZoneModel>?> getZoneList(bool forDeliveryRegistration) async {
    return await deliverymanRegistrationRepoInterface.getList(
        forDeliveryRegistration: forDeliveryRegistration);
  }

  @override
  Future<XFile?> picImageFromGallery() async {
    return await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
        maxHeight: 1000);
  }

  @override
  Future<XFile?> picImageFromCamera() async {
    return await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1000,
        maxHeight: 1000);
  }

  @override
  Future<List<VehicleModel>?> getVehicleList() async {
    return await deliverymanRegistrationRepoInterface.getVehicleList();
  }

  @override
  List<int?>? setVehicleIdList(List<VehicleModel>? vehicles) {
    List<int?>? vehicleIds;
    if (vehicles != null) {
      vehicleIds = [];
      for (var vehicle in vehicles) {
        vehicleIds.add(vehicle.id);
      }
    }
    return vehicleIds;
  }

  @override
  int setIdentityTypeIndex(
      List<String> identityTypeList, String? identityType) {
    int index = 0;
    for (int i = 0; i < identityTypeList.length; i++) {
      if (identityTypeList[i] == identityType) {
        index = i;
        break;
      }
    }
    return index;
  }

  @override
  Future<FilePickerResult?> picFile(MediaData mediaData) async {
    List<String> permission = [];
    if (mediaData.image == 1) {
      permission.add('jpg');
    }
    if (mediaData.pdf == 1) {
      permission.add('pdf');
    }
    if (mediaData.docs == 1) {
      permission.add('doc');
    }

    FilePickerResult? result;

    if (GetPlatform.isWeb) {
      result = await FilePicker.platform.pickFiles(
        withReadStream: true,
      );
    } else {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: permission,
        allowMultiple: false,
      );
    }
    if (result != null && result.files.isNotEmpty) {
      return result;
    }
    return result;
  }

  @override
  List<MultipartBody> prepareIdentityImage(
      XFile? pickedImage, List<XFile> pickedIdentities) {
    List<MultipartBody> multiParts = [];
    multiParts.add(MultipartBody('image', pickedImage));
    for (XFile file in pickedIdentities) {
      multiParts.add(MultipartBody('identity_image[]', file));
    }
    return multiParts;
  }

  @override
  List<MultipartDocument> prepareMultipartDocuments(
      List<String> inputTypeList, List<FilePickerResult> additionalDocuments) {
    List<MultipartDocument> multiPartsDocuments = [];
    List<String> dataName = [];
    for (String data in inputTypeList) {
      dataName.add('additional_documents[$data]');
    }
    for (FilePickerResult file in additionalDocuments) {
      int index = additionalDocuments.indexOf(file);
      multiPartsDocuments.add(MultipartDocument('${dataName[index]}[]', file));
    }
    return multiPartsDocuments;
  }

  @override
  Future<void> registerDeliveryMan(
      Map<String, String> data,
      List<MultipartBody> multiParts,
      List<MultipartDocument> additionalDocument) async {
    debugPrint('==== Registration Request Data: ${data.toString()}');
    Response response = await deliverymanRegistrationRepoInterface
        .registerDeliveryMan(data, multiParts, additionalDocument);
    debugPrint('==== Registration Response Status: ${response.statusCode}');
    debugPrint('==== Registration Response Body: ${response.body.toString()}');

    if (response.statusCode == 200) {
      Get.find<DashboardController>()
          .saveRegistrationSuccessfulSharedPref(true);
      Get.offAllNamed(RouteHelper.getInitialRoute());
      // showCustomSnackBar('delivery_man_registration_successful'.tr, isError: false);
    }
  }
}
