import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_drop_down_button.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/deliveryman_registration_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class DeliveryManRegistrationScreen extends StatefulWidget {
  const DeliveryManRegistrationScreen({super.key});

  @override
  State<DeliveryManRegistrationScreen> createState() =>
      _DeliveryManRegistrationScreenState();
}

class _DeliveryManRegistrationScreenState
    extends State<DeliveryManRegistrationScreen> {
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _identityNumberController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.find<DeliverymanRegistrationController>().resetDmRegistrationData();
    Get.find<DeliverymanRegistrationController>()
        .getZoneList(forDeliveryRegistration: true);
    Get.find<DeliverymanRegistrationController>().getVehicleList();
    Get.find<DeliverymanRegistrationController>()
        .dmStatusChange(0.4, isUpdate: false);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeliverymanRegistrationController>(
        builder: (dmController) {
      return Scaffold(
        backgroundColor:
            Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
                ? const Color(0xFF141313)
                : const Color(0xFFfafef5),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 3),
          child: Container(
            decoration: const BoxDecoration(
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
            child: AppBar(
              title: Text('إنشاء حساب دليفري',
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge,
                    color: Colors.white,
                  )),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: Row(children: [
                  Expanded(
                      flex: (dmController.dmStatus * 100).toInt(),
                      child: Container(height: 3, color: Colors.white)),
                  Expanded(
                      flex: (100 - (dmController.dmStatus * 100)).toInt(),
                      child: Container(
                          height: 3, color: Colors.white.withOpacity(0.3))),
                ]),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (dmController.dmStatus == 0.4) ...[
              /// Step 1: Basic Information
              _buildSectionTitle('المعلومات الأساسية'),
              _buildCard([
                CustomTextFieldWidget(
                  labelText: 'الاسم *',
                  controller: _fNameController,
                  showBorder: true,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                CustomTextFieldWidget(
                  labelText: 'رقم الهاتف *',
                  controller: _phoneController,
                  inputType: TextInputType.phone,
                  showBorder: true,
                  prefixIcon: Icons.phone_android_outlined,
                ),
              ]),

              const SizedBox(height: Dimensions.paddingSizeLarge),
              _buildSectionTitle('معلومات الحساب'),
              _buildCard([
                CustomTextFieldWidget(
                  labelText: 'كلمة المرور *',
                  controller: _passwordController,
                  isPassword: true,
                  showBorder: true,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                CustomTextFieldWidget(
                  labelText: 'تأكيد كلمة المرور *',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  showBorder: true,
                ),
              ]),

              const SizedBox(height: Dimensions.paddingSizeLarge),
              _buildSectionTitle('صورة الملف الشخصي*'),
              _buildImagePicker(dmController.pickedImage, 'profile',
                  'صورة شخصية', dmController),
            ],
            if (dmController.dmStatus == 0.8) ...[
              /// Step 2: Setup & Identity
              _buildSectionTitle('إعداد'),
              _buildCard([
                CustomDropdownButton(
                  hintText: 'اختر نوع التسليم* ',
                  items: dmController.dmTypeList,
                  selectedValue: dmController.selectedDmType,
                  onChanged: (v) => dmController.setSelectedDmType(v),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                CustomDropdownButton(
                  hintText: 'المنطقه',
                  dropdownMenuItems: dmController.zoneList
                      ?.map((z) => DropdownMenuItem(
                          value: z.id.toString(), child: Text(z.name!)))
                      .toList(),
                  selectedValue: dmController.selectedDeliveryZoneId,
                  onChanged: (v) =>
                      dmController.setSelectedDeliveryZone(zoneId: v),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                CustomDropdownButton(
                  hintText: 'اختر مركبة* ',
                  dropdownMenuItems: dmController.vehicles
                      ?.map((v) => DropdownMenuItem(
                          value: v.id.toString(), child: Text(v.type!)))
                      .toList(),
                  selectedValue: dmController.selectedVehicleId,
                  onChanged: (v) =>
                      dmController.setSelectedVehicleType(vehicleId: v),
                ),
              ]),

              const SizedBox(height: Dimensions.paddingSizeLarge),
              _buildSectionTitle('معلومات الهوية'),
              _buildCard([
                CustomDropdownButton(
                  hintText: 'نوع الهوية',
                  items: dmController.identityTypeList,
                  selectedValue: dmController.selectedIdentityType,
                  onChanged: (v) => dmController.setSelectedIdentityType(v),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                CustomTextFieldWidget(
                  labelText: 'رقم البطاقة *',
                  controller: _identityNumberController,
                  showBorder: true,
                ),
              ]),

              const SizedBox(height: Dimensions.paddingSizeLarge),
              _buildSectionTitle('الوثائق والمستندات*'),

              /// National ID
              _buildDocumentUpload(
                  'صورة البطاقة',
                  dmController.nationalIdFront,
                  dmController.nationalIdBack,
                  'national_id_front',
                  'national_id_back',
                  dmController),

              /// Driving License
              if (dmController.nationalIdFront != null &&
                  dmController.nationalIdBack != null)
                _buildDocumentUpload(
                    'صورة الرخصة',
                    dmController.drivingLicenseFront,
                    dmController.drivingLicenseBack,
                    'driving_license_front',
                    'driving_license_back',
                    dmController),

              /// Vehicle License
              if (dmController.drivingLicenseFront != null &&
                  dmController.drivingLicenseBack != null)
                _buildDocumentUpload(
                    'رخصة المركبة',
                    dmController.vehicleLicenseFront,
                    dmController.vehicleLicenseBack,
                    'vehicle_license_front',
                    'vehicle_license_back',
                    dmController),

              /// Vehicle Image
              if (dmController.vehicleLicenseFront != null &&
                  dmController.vehicleLicenseBack != null) ...[
                _buildSectionTitle('صورة المركبة*'),
                _buildImagePicker(dmController.vehicleFront, 'vehicle_front',
                    'صورة المركبة من الأمام', dmController),
              ],
            ],
            const SizedBox(height: 40),
            CustomButtonWidget(
              color: Color(0xFF9ebc67),
              textColor: Colors.white,
              buttonText: dmController.dmStatus == 0.4 ? 'التالي' : 'إرسال',
              isLoading: dmController.isLoading,
              onPressed: () => _handleNext(dmController),
              // borderRadius: 15,
            ),
          ]),
        ),
      );
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: Dimensions.paddingSizeSmall,
          top: Dimensions.paddingSizeSmall,
          right: 5),
      child: Text(title,
          style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
                  ? Colors.white
                  : Colors.black)),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
            ? const Color(0xFF1b1b1b)
            : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              spreadRadius: 2)
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDocumentUpload(
      String title,
      XFile? front,
      XFile? back,
      String frontType,
      String backType,
      DeliverymanRegistrationController dmController) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(title,
              style: robotoMedium.copyWith(
                  color:
                      Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
                          ? Colors.white
                          : Colors.black87))),
      _buildImagePicker(front, frontType, 'الوجه الامامي', dmController),
      if (front != null) ...[
        const SizedBox(height: Dimensions.paddingSizeDefault),
        _buildImagePicker(back, backType, 'الوجه الخلفي', dmController),
      ],
      const SizedBox(height: Dimensions.paddingSizeDefault),
    ]);
  }

  Widget _buildImagePicker(XFile? file, String type, String label,
      DeliverymanRegistrationController dmController) {
    return InkWell(
      onTap: () {
        if (type == 'profile') {
          dmController.pickDmImage(true, false);
        } else {
          dmController.pickDmDocumentForRegistration(type);
        }
      },
      child: DottedBorder(
        dashPattern: const [6, 4],
        borderType: BorderType.RRect,
        radius: const Radius.circular(15),
        borderPadding: EdgeInsets.all(15),
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Get.find<MarketThemeController>(tag: 'xmarket').darkTheme
                  ? const Color(0xFF1b1b1b)
                  : Colors.white,
              borderRadius: BorderRadius.circular(15)),
          child: file != null
              ? Stack(children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(File(file.path),
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover)),
                  Positioned(
                      right: 5,
                      top: 5,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                            color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 15),
                      )),
                ])
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.camera_alt_outlined,
                      size: 30, color: Colors.grey.shade300),
                  const SizedBox(height: 5),
                  Text(label,
                      style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.grey)),
                ]),
        ),
      ),
    );
  }

  void _handleNext(DeliverymanRegistrationController dmController) {
    debugPrint(
        '==== _handleNext Clicked. Current dmStatus: ${dmController.dmStatus}');
    if (dmController.dmStatus == 0.4) {
      if (_fNameController.text.isEmpty) {
        showCustomSnackBar('يرجى إدخال الاسم');
        return;
      }
      if (_phoneController.text.isEmpty) {
        showCustomSnackBar('يرجى إدخال رقم الهاتف');
        return;
      }

      if (dmController.pickedImage == null) {
        showCustomSnackBar('يرجى إضافة صورة الملف الشخصي');
        return;
      }
      dmController.dmStatusChange(0.8);
    } else {
      debugPrint('==== Step 2 Submission Triggered');
      if (dmController.selectedDmType == null) {
        showCustomSnackBar('يرجى اختيار نوع التسليم');
        return;
      }
      if (dmController.selectedVehicleId == null) {
        showCustomSnackBar('يرجى اختيار نوع المركبة');
        return;
      }
      if (_identityNumberController.text.isEmpty) {
        showCustomSnackBar('يرجى إدخال رقم البطاقة');
        return;
      }

      // Check Documents
      if (dmController.nationalIdFront == null) {
        showCustomSnackBar('برجاء اضافة الوجه الامامي لصورة البطاقة');
        return;
      }
      if (dmController.nationalIdBack == null) {
        showCustomSnackBar('برجاء اضافة الوجه الخلفي لصورة البطاقة');
        return;
      }
      if (dmController.drivingLicenseFront == null) {
        showCustomSnackBar('برجاء اضافة الوجه الامامي لصورة الرخصة');
        return;
      }
      if (dmController.drivingLicenseBack == null) {
        showCustomSnackBar('برجاء اضافة الوجه الخلفي لصورة الرخصة');
        return;
      }
      if (dmController.vehicleLicenseFront == null) {
        showCustomSnackBar('برجاء اضافة الوجه الامامي لرخصة المركبة');
        return;
      }
      if (dmController.vehicleLicenseBack == null) {
        showCustomSnackBar('برجاء اضافة الوجه الخلفي لرخصة المركبة');
        return;
      }
      if (dmController.vehicleFront == null) {
        showCustomSnackBar('برجاء اضافة صورة المركبة من الأمام');
        return;
      }

      String phoneNumber = _phoneController.text.trim();
      if (phoneNumber.startsWith('+2')) {
        phoneNumber = phoneNumber.substring(2);
      } else if (phoneNumber.startsWith('2') && phoneNumber.length > 10) {
        phoneNumber = phoneNumber.substring(1);
      }

      Map<String, String> data = {
        'f_name': _fNameController.text.trim(),
        'l_name': '',
        'password': _passwordController.text.trim(),
        'phone': phoneNumber,
        'email': '',
        'identity_number': _identityNumberController.text.trim(),
        'identity_type': dmController.selectedIdentityType ?? 'nid',
        'earning': dmController.selectedDmTypeId.toString(),
        'zone_id': dmController.selectedDeliveryZoneId.toString(),
        'vehicle_id': dmController.selectedVehicleId.toString(),
      };

      debugPrint('==== Calling registerDeliveryMan API...');
      dmController.registerDeliveryMan(data, [], []);
    }
  }
}
