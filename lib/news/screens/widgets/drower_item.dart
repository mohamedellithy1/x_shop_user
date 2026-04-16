import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:stackfood_multivendor/news/controllers/news_controller.dart';

class DrowerItem extends StatefulWidget {
  const DrowerItem({super.key});

  @override
  State<DrowerItem> createState() => _DrowerItemState();
}

class _DrowerItemState extends State<DrowerItem> {
  List<Zone>? _zones;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchZones();
  }

  Future<void> _fetchZones() async {
    const String baseUrl = 'https://www.x-ride.support';
    const String endpoint = '/api/zone/list';

    debugPrint('🔄 Starting fetchZones()');

    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));

      debugPrint('✅ Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final parsedBody = jsonDecode(response.body);

        final zonesResponse = ZoneListResponse.fromJson(parsedBody);
        debugPrint('🗺️ Parsed zones count: ${zonesResponse.data.length}');

        setState(() {
          _zones = zonesResponse.data;
        });
      } else {
        debugPrint(
            '❌ Failed to fetch zones, status code: ${response.statusCode}');
      }
    } catch (e, st) {
      debugPrint('🔥 Exception in fetchZones: $e');
      debugPrint(st.toString());
    }
  }

  void _showZoneSelectionPopup() {
    final newsController = Get.find<NewsController>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                height: 500,
                width: double.maxFinite,
                constraints: const BoxConstraints(maxHeight: 500),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, color: Colors.black),
                          ),
                          Expanded(
                            child: Text(
                              'اختر المدينة',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 48), // Balance the close button
                        ],
                      ),
                    ),
                    // Zones List
                    Expanded(
                      child: _zones == null
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _zones!.length,
                              itemBuilder: (context, index) {
                                Zone zone = _zones![index];
                                bool isSelected =
                                    newsController.currentZoneId == zone.id;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        // تحديث NewsController بالمنطقة المحددة
                                        newsController.setSelectedZone(
                                            zone.id, zone.name);
                                        newsController.getNews(zone.id);

                                        Navigator.of(context).pop();
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.black.withOpacity(0.4)
                                              : Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // Zone icon
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Colors.grey[400],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.location_city,
                                                color: isSelected
                                                    ? Colors.black
                                                    : Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            // Zone name
                                            Expanded(
                                              child: Text(
                                                zone.name,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  color: isSelected
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ),
                                            // Check icon for selected
                                            if (isSelected)
                                              Icon(
                                                Icons.check_circle,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                size: 24,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewsController>(
      builder: (newsController) {
        return Container(
          color: Theme.of(context).primaryColor,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            children: [
              const SizedBox(height: 100),

              // Zone Selection Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Title
                    const Center(
                      child: Text(
                        "اختر المنطقه",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Selected Zone Display
                    if (newsController.selectedZoneName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.black.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_city,
                                color: Colors.black, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'المدينة المحددة: ${newsController.selectedZoneName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                newsController.clearZone();
                                newsController.getNews(""); // جلب جميع الأخبار
                              },
                              child: const Icon(Icons.close,
                                  color: Colors.black, size: 18),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.black.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.newspaper,
                                color: Colors.black, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'جميع الأخبار',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Zone Selection Button
                    InkWell(
                      onTap: _showZoneSelectionPopup,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.black.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.black, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              newsController.selectedZoneName != null
                                  ? 'تغيير المدينة'
                                  : 'تصفية حسب المدينة',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Zone Models
class ZoneListResponse {
  final String responseCode;
  final String message;
  final List<Zone> data;

  ZoneListResponse({
    required this.responseCode,
    required this.message,
    required this.data,
  });

  factory ZoneListResponse.fromJson(Map<String, dynamic> json) {
    return ZoneListResponse(
      responseCode: json['response_code'],
      message: json['message'],
      data: (json['data'] as List<dynamic>)
          .map((e) => Zone.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Zone {
  final String id;
  final String name;
  final int? readableId;
  final ZoneCoordinates zoneCoordinates;
  final bool isActive;
  final DateTime createdAt;

  Zone({
    required this.id,
    required this.name,
    this.readableId,
    required this.zoneCoordinates,
    required this.isActive,
    required this.createdAt,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'],
      name: json['name'],
      readableId: json['readable_id'],
      zoneCoordinates: ZoneCoordinates.fromJson(json['zone_coordinates']),
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ZoneCoordinates {
  final String type;
  final List<List<List<double>>> coordinates;

  ZoneCoordinates({
    required this.type,
    required this.coordinates,
  });

  factory ZoneCoordinates.fromJson(Map<String, dynamic> json) {
    return ZoneCoordinates(
      type: json['type'],
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => (e as List<dynamic>)
              .map((f) => (f as List<dynamic>)
                  .map((g) => (g as num).toDouble())
                  .toList())
              .toList())
          .toList(),
    );
  }
}
