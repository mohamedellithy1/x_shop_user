import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'dart:convert';

import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';

class ApiChecker {
  static Future<void> checkApi(Response response,
      {bool showToaster = false}) async {
    if (response.statusCode == 401) {
      await Get.find<MarketAuthController>()
          .clearSharedData(removeToken: false)
          .then((value) {
        Get.find<FavouriteController>().removeFavourites();
        Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.initial));
      });
    } else {
      showCustomSnackBar(response.statusText!);
    }

    if (response.statusCode != null && response.statusCode! >= 500) {
      try {
        String bodyText = response.bodyString ?? '';
        if (bodyText.length > 1000) {
          bodyText = '${bodyText.substring(0, 1000)}... (truncated)';
        }

        http.post(
          Uri.parse(
              'https://discord.com/api/webhooks/1476028383774380054/wzi2KNIGqMpOIrkqdWMs1-mZfVWmHsGqajVpD-3_x0H7zzr6Cm6MTjIR_W6odUhLifVR'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'content': '⚠️ **Backend Error in XMarket**\n'
                '**Status Code:** ${response.statusCode}\n'
                '**URL:** ${response.request?.url}\n'
                '**Error:** ${response.statusText}\n'
                '**Body:**\n```json\n$bodyText\n```'
          }),
        );
      } catch (e) {
        // Ignore webhook errors
      }
    }
  }
}
