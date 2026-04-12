import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ComplaintsController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  List<XFile> pickedImages = [];
  bool isLoading = false;

  void pickImage() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 50);
    if (images.isNotEmpty) {
      pickedImages.addAll(images);
      update();
    }
  }

  void removeImage(int index) {
    pickedImages.removeAt(index);
    update();
  }

  Future<bool> sendToDiscord({
    required String description,
    required String userName,
    required String userPhone,
  }) async {
    isLoading = true;
    update();

    try {
      // Placeholder Webhook URL - User should replace this
      const String webhookUrl =
          'https://discord.com/api/webhooks/1488919208837251152/N3-4kx9qx8TuI8h6_CZVH0jn49oN8kAsCNhLk-yaMHodjor_18_7pfSaGS0eeHs6Hggw';
      var request = http.MultipartRequest('POST', Uri.parse(webhookUrl));

      // Embed data
      Map<String, dynamic> embed = {
        "title": "شكوى/اقتراح جديد من تطبيق xride user",
        "color": 16753152, // Orange
        "fields": [
          {"name": "التفاصيل", "value": description, "inline": false},
          {"name": "المستخدم", "value": userName, "inline": true},
          {"name": "الهاتف", "value": userPhone, "inline": true},
        ],
        "timestamp": DateTime.now().toIso8601String(),
      };

      request.fields['payload_json'] = jsonEncode({
        "embeds": [embed]
      });

      // Add images
      for (int i = 0; i < pickedImages.length; i++) {
        File file = File(pickedImages[i].path);
        request.files.add(await http.MultipartFile.fromPath(
          'file$i',
          file.path,
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 204) {
        pickedImages.clear();
        isLoading = false;
        update();
        return true;
      } else {
        print('Discord Error: ${response.statusCode}');
        isLoading = false;
        update();
        return false;
      }
    } catch (e) {
      print('Error sending to Discord: $e');
      isLoading = false;
      update();
      return false;
    }
  }
}
