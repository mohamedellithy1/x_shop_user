import 'package:stackfood_multivendor/news/domain/entities/zone.dart';

class ZoneModel extends ZoneNews {
  ZoneModel({
    required super.id,
    required super.name,
    required super.readableId,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'غير محدد',
      readableId: json['readable_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "readable_id": readableId,
      };
}
