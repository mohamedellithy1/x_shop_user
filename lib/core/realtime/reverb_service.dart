import 'package:get/get.dart';
import 'package:stackfood_multivendor/helper/reverb_helper.dart';

/// Thin GetX service wrapper around [ReverbHelper] for easier DI / access.
class ReverbService extends GetxService {
  static ReverbService? _instance;

  ReverbService._internal();

  factory ReverbService() {
    _instance ??= ReverbService._internal();
    return _instance!;
  }

  bool get isConnected =>
      ReverbHelper.pusherClient != null &&
      (ReverbHelper.pusherClient?.socketId != null);

  dynamic get reverbClient => ReverbHelper.pusherClient;

  Future<void> init() async {
    await ReverbHelper.initializePusher();
  }

  Future<void> disconnect() async {
    await ReverbHelper.disconnectAll();
  }

  void printConnectionInfo() {
    ReverbHelper.runConnectionTest();
  }
}

