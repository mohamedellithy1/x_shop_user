import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ColorResources {
  static Color getRightBubbleColor() {
    return Theme.of(Get.context!).primaryColor;
  }

  static Color getLeftBubbleColor(bool isDark) {
    return isDark
        ? const Color(0xFF1b1b1b)
        : Theme.of(Get.context!).disabledColor.withValues(alpha: 0.2);
  }
}
