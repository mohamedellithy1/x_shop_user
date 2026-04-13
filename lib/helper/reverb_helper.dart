import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/helper/laravel_websocket.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';

/// High level helper around [LaravelWebSocket] for xMarket.
///
/// This is responsible for:
/// - Initializing the WebSocket client with correct host / key / path
/// - Managing connection status & basic logging
/// - Subscribing the current customer to their private channel:
///     "private-user.customer.{id}"
/// - Exposing helper methods that higher level services can use.
class ReverbHelper {
  static LaravelWebSocket? pusherClient;

  static String? _lastToken;

  /// Initialize the WebSocket client using xMarket auth token.
  static Future<void> initializePusher() async {
    debugPrint('🚀 [xMarket WS] Initializing Reverb/Pusher client');

    final token = Get.find<MarketAuthController>().getUserToken();
    _lastToken = token;
    debugPrint(
        '🔑 [xMarket WS] Auth token: ${token.isNotEmpty ? "✅ Available" : "❌ Missing"}');

    final baseUri = Uri.parse(AppConstants.baseUrl);
    debugPrint('🌐 [xMarket WS] Connecting to: ${baseUri.host}:443');

    pusherClient = LaravelWebSocket(
      key: 'super-key-xshop',
      host: baseUri.host,
      port: 443,
      wsPath: '/ws/app/super-key-xshop',
      authToken: token,
    );

    // Listen to connection status & errors for basic diagnostics.
    pusherClient?.connectionStatus.listen((connected) {
      if (connected) {
        debugPrint(
            '✅ [xMarket WS] Connected. socketId=${pusherClient?.socketId}');
      } else {
        debugPrint('❌ [xMarket WS] Disconnected');
      }
    });

    pusherClient?.errors.listen((err) {
      debugPrint('💥 [xMarket WS] Error: $err');
    });

    await pusherClient?.connect();

    final ok = await pusherClient!
        .waitForConnected(timeout: const Duration(seconds: 5));
    if (!ok) {
      debugPrint('⛔ [xMarket WS] Failed to connect within timeout');
    } else {
      debugPrint('✅ [xMarket WS] Connection established successfully');
    }

    // Optionally listen to all raw messages (for debugging)
    pusherClient?.allMessages.listen((message) {
      debugPrint('[xMarket WS] Message: $message');
    });
  }

  static String? _currentCustomerId;

  /// Subscribe the current logged-in customer to their private channel.
  ///
  /// Channel pattern (without "private-"):
  ///   "user.customer.{customerId}"
  static Future<void> subscribeToCustomerEvents(String customerId) async {
    if (customerId.isEmpty) {
      debugPrint('⚠️ [xMarket WS] Empty customerId, cannot subscribe');
      return;
    }

    if (pusherClient == null) {
      debugPrint(
          '❌ [xMarket WS] pusherClient is null, call initializePusher first');
      return;
    }

    // If already subscribed for same id, do nothing.
    if (_currentCustomerId == customerId) {
      debugPrint(
          'ℹ️ [xMarket WS] Already subscribed for customerId=$customerId');
      return;
    }

    // Ensure connection is ready
    if (pusherClient?.socketId == null) {
      final connected = await pusherClient?.waitForConnected(
          timeout: const Duration(seconds: 5));
      if (connected != true) {
        debugPrint('❌ [xMarket WS] Cannot subscribe, socket not connected');
        return;
      }
    }

    // Forget previous listeners if any
    pusherClient?.removeAllEventListeners();

    final channelName = 'user.customer.$customerId';
    debugPrint('📡 [xMarket WS] Subscribing to channel: $channelName');

    try {
      await pusherClient?.subscribePrivateChannel(channelName);
      _currentCustomerId = customerId;
      debugPrint(
          '✅ [xMarket WS] Subscribed successfully for customerId=$customerId');
    } catch (e, stackTrace) {
      debugPrint(
          '❌ [xMarket WS] Failed to subscribe to customer channel: $e\n$stackTrace');
      _currentCustomerId = null;
      rethrow;
    }
  }

  /// Forward helper for adding event listeners on the underlying WebSocket.
  static void listenToEvent(String eventName, Function(dynamic) callback) {
    pusherClient?.listenToEvent(eventName, (data) {
      // Ensure we always work with Map<String, dynamic> if possible.
      if (data is Map<String, dynamic>) {
        callback(data);
      } else if (data is String) {
        try {
          final decoded = jsonDecode(data);
          callback(decoded);
        } catch (_) {
          callback({'data': data});
        }
      } else {
        callback({'data': data});
      }
    });
  }

  static Future<void> disconnectAll() async {
    if (pusherClient != null) {
      await pusherClient!.disconnect();
      pusherClient = null;
    }
    _currentCustomerId = null;
    _lastToken = null;
  }

  static Future<void> ensureConnected() async {
    debugPrint('🔍 [xMarket WS] Checking connection status...');
    final currentToken = Get.find<MarketAuthController>().getUserToken();

    if (pusherClient == null ||
        pusherClient?.socketId == null ||
        _lastToken != currentToken) {
      debugPrint('🔄 [xMarket WS] Not connected or token changed, initializing...');
      if (pusherClient != null) {
        await pusherClient!.disconnect();
      }
      await initializePusher();
    } else {
      debugPrint(
          '✅ [xMarket WS] Already connected. socketId=${pusherClient?.socketId}');
    }
  }

  static void runConnectionTest() {
    if (pusherClient != null && pusherClient!.socketId != null) {
      debugPrint(
          '🧪 [xMarket WS] Connection OK. socketId=${pusherClient!.socketId}');
    } else {
      debugPrint('🧪 [xMarket WS] Connection NOT established');
    }
  }
}
