import 'package:lottie/lottie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/features/dashboard/screens/dashboard_screen.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/support/widgets/web_support_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarketThemeController>(
      init: Get.find<MarketThemeController>(tag: 'xmarket'),
      builder: (marketThemeController) {
        return Theme(
          data: marketThemeController.darkTheme ? darkTheme : lightTheme,
          child: Scaffold(
            backgroundColor: marketThemeController.darkTheme
                ? Colors.black
                : Color(0xFFfafef5),
            body: Column(children: [
              // Custom Gradient AppBar
              Container(
                height: 120,
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
                padding: const EdgeInsets.only(top: 40, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    Expanded(
                      child: Text(
                        'do_you_need_help'.tr,
                        textAlign: TextAlign.center,
                        style: robotoBold.copyWith(
                            fontSize: 20,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black
                                    : Colors.white),
                      ),
                    ),
                    const SizedBox(width: 48), // Placeholder for symmetry
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),

                        // Lottie Animation
                        Center(
                          child: Lottie.asset(
                            'assets/image/supportChat.json',
                            width: 300,
                            height: 200,
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Large Bold Message
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'typically_the_support_team_send_you_any_feedback_in_2_hours'
                                .tr,
                            textAlign: TextAlign.center,
                            style: robotoBold.copyWith(
                              fontSize: 30,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              height: 1.2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Contact Text
                        Text(
                          'contact_us_through_phone'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // WhatsApp and Call Icons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // WhatsApp
                            InkWell(
                              onTap: () async {
                                String phone = Get.find<MarketSplashController>(
                                            tag: 'xmarket')
                                        .configModel
                                        ?.phone ??
                                    '';
                                String whatsappUrl = "https://wa.me/$phone";
                                if (await canLaunchUrlString(whatsappUrl)) {
                                  launchUrlString(whatsappUrl,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  showCustomSnackBar(
                                      'can_not_launch_whatsapp'.tr);
                                }
                              },
                              child: Column(
                                children: [
                                  Icon(FontAwesomeIcons.whatsapp,
                                      color: Colors.green, size: 35),
                                  const SizedBox(height: 5),
                                  Text('whatsapp'.tr, style: robotoRegular),
                                ],
                              ),
                            ),

                            const SizedBox(width: 60),

                            // Call
                            InkWell(
                              onTap: () async {
                                String phone = Get.find<MarketSplashController>(
                                            tag: 'xmarket')
                                        .configModel
                                        ?.phone ??
                                    '';
                                if (await canLaunchUrlString('tel:$phone')) {
                                  launchUrlString('tel:$phone',
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  showCustomSnackBar(
                                      '${'can_not_launch'.tr} $phone');
                                }
                              },
                              child: Column(
                                children: [
                                  const Icon(Icons.call,
                                      color: Colors.blue, size: 35),
                                  const SizedBox(height: 5),
                                  Text('call'.tr, style: robotoRegular),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                      ]),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class SupportCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? contactInfo;
  final Function()? onTap;
  final bool isAddress;
  const SupportCard(
      {super.key,
      required this.title,
      required this.description,
      required this.icon,
      this.contactInfo,
      this.onTap,
      this.isAddress = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Left Solid Circle Icon (matching xride image)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Icon(icon,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
                  size: 24),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),

            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color:
                              (Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black)
                                  .withValues(alpha: 0.8),
                        )),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(
                      description,
                      style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    if (!isAddress)
                      Text(
                        contactInfo ?? '',
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black),
                      ),
                  ]),
            ),

            // Right Light Rounded Box Icon (matching xride image)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child:
                  Icon(icon, color: Theme.of(context).primaryColor, size: 24),
            ),
          ]),
        ),
      ),
    );
  }
}
