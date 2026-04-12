import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/xmarket_images.dart';

void customPrint(String message) {
  if (kDebugMode) {
    print(message);
  }
}

void showCustomSnackBar(
  String message, {
  String? subtitle, // ده ال subtitle اختياري
  int seconds = 3,
}) {
  if (Get.context == null) return;

  Get.closeCurrentSnackbar();
  Get.showSnackbar(GetSnackBar(
    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
    duration: Duration(seconds: seconds),
    backgroundColor: Color(0xCC2C2C2E),
    dismissDirection: DismissDirection.horizontal,
    icon: Icon(
      Icons.info_outline,
      color: Colors.white,
      size: 24,
    ),
    messageText: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 30, // حجم الدايرة
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage(
            XmarketImages.splashLogo,
          ),
        )
      ],
    ),
  ));
}
