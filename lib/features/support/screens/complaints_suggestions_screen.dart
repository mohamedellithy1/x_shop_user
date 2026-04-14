import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:stackfood_multivendor/common/widgets/app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/body_widget.dart';
import 'package:stackfood_multivendor/common/widgets/button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/support/controllers/complaints_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ComplaintsSuggestionsScreen extends StatefulWidget {
  const ComplaintsSuggestionsScreen({super.key});

  @override
  State<ComplaintsSuggestionsScreen> createState() =>
      _ComplaintsSuggestionsScreenState();
}

class _ComplaintsSuggestionsScreenState
    extends State<ComplaintsSuggestionsScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _descriptionFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ComplaintsController>()) {
      Get.put(ComplaintsController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BodyWidget(
        appBar: AppBarWidget(
          title: 'الشكاوي والاقتراحات',
          showBackButton: true,
          onBackPressed: () => Get.back(),
        ),
        body: GetBuilder<ComplaintsController>(builder: (controller) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                'يسعدنا معرفه ملاحظاتك لتحسين خدمتنا',
                style: robotoRegular.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        spreadRadius: 1)
                  ],
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(children: [
                  CustomTextFieldWidget(
                    hintText: 'اكتب تفاصيل الشكوى أو الاقتراح هنا...',
                    labelText: 'اكتب ملاحظتك',
                    controller: _descriptionController,
                    focusNode: _descriptionFocus,
                    inputType: TextInputType.multiline,
                    maxLines: 5,
                    required: true,
                  ),
                ]),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text('إرفاق صور (اختياري)', style: robotoRegular),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.pickedImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == controller.pickedImages.length) {
                      return InkWell(
                        onTap: () => controller.pickImage(),
                        child: DottedBorder(
                          color: Theme.of(context).primaryColor,
                          strokeWidth: 1,
                          dashPattern: const [5, 5],
                          borderType: BorderType.RRect,
                          radius:
                              const Radius.circular(Dimensions.radiusDefault),
                          child: Container(
                            width: 100,
                            height: 100,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined,
                                    color: Colors.black),
                                const SizedBox(height: 4),
                                Text('أضف صورة',
                                    style: robotoRegular.copyWith(
                                        fontSize: 10, color: Colors.black)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(
                          right: Dimensions.paddingSizeSmall),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusDefault),
                            child: Image.file(
                              File(controller.pickedImages[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: InkWell(
                              onTap: () => controller.removeImage(index),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge * 2),
              controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ButtonWidget(
                      textColor: Colors.white,
                      buttonText: 'إرسال',
                      showBorder: false,
                      backgroundColor: Colors.orange,
                      onPressed: () async {
                        if (_descriptionController.text.isEmpty) {
                          showCustomSnackBar(
                              'يرجى كتابة تفاصيل الشكوى أو الاقتراح');
                          return;
                        }

                        final profile =
                            Get.find<MarketProfileController>().userInfoModel;
                        bool success = await controller.sendToDiscord(
                          description: _descriptionController.text,
                          userName:
                              '${profile?.fName ?? "غير معروف"} ${profile?.lName ?? ""}',
                          userPhone: profile?.phone ?? "غير معروف",
                        );

                        if (success) {
                          _descriptionController.clear();
                          // Get.back();
                          showCustomSnackBar('شكرا لارسال ملاحظاتك');
                        } else {
                          showCustomSnackBar(
                              'حدث خطأ أثناء الإرسال، يرجى المحاولة لاحقاً');
                        }
                      },
                    ),
            ]),
          );
        }),
      ),
    );
  }
}
