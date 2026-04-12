import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/chat/controllers/chat_controller.dart';
import 'package:stackfood_multivendor/features/chat/domain/models/message_model.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/helper/reverb_helper.dart';
// import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';

/// Simple realtime service that can be used to manage the
/// subscription of the current customer to their private WS channel.
///
/// Naming kept similar to the driver app's pattern for consistency.
class UserRealtimeService extends GetxService {
  static UserRealtimeService? _instance;

  final RxBool isListening = false.obs;

  UserRealtimeService._internal();

  factory UserRealtimeService() {
    _instance ??= UserRealtimeService._internal();
    return _instance!;
  }

  /// Initialize WS and subscribe this customer to their private channel.
  Future<void> initializeListeners(String customerId) async {
    debugPrint(
        '🎯 [DeliveryRealtimeService] Starting initialization for customer: $customerId');
    await ReverbHelper.ensureConnected();
    debugPrint(
        '📡 [DeliveryRealtimeService] Subscribing to customer events...');
    await ReverbHelper.subscribeToCustomerEvents(customerId);

    // Setup global listeners once subscribed
    _setupGlobalListeners();

    isListening.value = true;
    debugPrint(
        '✅ [DeliveryRealtimeService] Initialization complete, listening: ${isListening.value}');
  }

  void _setupGlobalListeners() {
    // 1. General Order Status Updates
    ReverbHelper.listenToEvent('OrderStatusChanged', (data) {
      debugPrint('📦 [RealtimeService] OrderStatusChanged: $data');
      Get.find<OrderController>()
          .getRunningOrders(1, notify: true, reload: false);
    });

    ReverbHelper.listenToEvent('NewOrder', (data) {
      debugPrint('🆕 [RealtimeService] NewOrder: $data');
      Get.find<OrderController>()
          .getRunningOrders(1, notify: true, reload: false);
    });

    ReverbHelper.listenToEvent('DeliveryUpdate', (data) {
      debugPrint('🚚 [RealtimeService] DeliveryUpdate: $data');
      Get.find<OrderController>()
          .getRunningOrders(1, notify: true, reload: false);
    });

    // 2. Real-time Order Status Updates — actual event name from server is 'order.status.updated'
    // data['event_type'] = order_accepted | order_accepted_by_delivery | order_picked_up | order_delivered | order_canceled
    // data['order']['id'] = the order ID
    ReverbHelper.listenToEvent('order.status.updated', (data) {
      debugPrint('📡 [RealtimeService] order.status.updated: $data');
      _refreshOrderUI(data);
    });

    // 3. Real-time Chat
    ReverbHelper.listenToEvent('message.created', (data) {
      debugPrint('🔔 [SOCKET] message.created EVENT RECEIVED: $data');

      if (Get.isRegistered<ChatController>()) {
        final chatController = Get.find<ChatController>();

        Map<String, dynamic>? messageData;

        // Recursive search for the actual message data
        Map<String, dynamic>? deepFind(dynamic input) {
          if (input is! Map) return null;
          final m = Map<String, dynamic>.from(input);

          if ((m.containsKey('message') || m.containsKey('body')) &&
              (m.containsKey('conversation_id') ||
                  m.containsKey('conversationId'))) {
            return m;
          }
          if (m['data'] is Map) return deepFind(m['data']);
          if (m['data'] is String) {
            try {
              return deepFind(jsonDecode(m['data']));
            } catch (_) {}
          }
          return null;
        }

        messageData = deepFind(data);

        // Fallback
        if (messageData == null && data is Map) {
          messageData = Map<String, dynamic>.from(data);
        }

        if (messageData != null) {
          messageData['id'] ??= (data is Map ? data['message_id'] : null) ??
              messageData['id'] ??
              DateTime.now().millisecondsSinceEpoch;
          messageData['message'] ??= messageData['body'];
          messageData['conversation_id'] ??=
              (data is Map ? data['conversation_id'] : null) ??
                  messageData['conversationId'];

          if (messageData['message'] != null &&
              messageData['conversation_id'] != null) {
            try {
              final newMessage = Message.fromJson(messageData);
              debugPrint(
                  '✅ [SOCKET] SUCCESS: Message ID=${newMessage.id} for Conv=${newMessage.conversationId}');

              chatController.addMessage(newMessage);
              chatController.update(); // FORCE RELOAD UI

              // showCustomSnackBar(
              //     '${'new_message_received'.tr}: ${newMessage.message}');
            } catch (e) {
              debugPrint('❌ [RealtimeService] Parsing Error: $e');
            }
          } else {
            debugPrint('⚠️ [SOCKET] Payload incomplete: $messageData');
          }
        }
      }
    });

    debugPrint('👂 [RealtimeService] Global listeners set up successfully');
  }

  /// Refresh order UI by fetching latest data from API then updating running list.
  /// Event payload from server:
  ///   data['order']['id']           → order ID
  ///   data['order']['order_status'] → new status (e.g. handover, picked_up...)
  ///   data['event_type']            → event_type string
  void _refreshOrderUI(dynamic data) {
    if (Get.isRegistered<OrderController>()) {
      final orderController = Get.find<OrderController>();

      // Extract order ID — comes from data['order']['id'] in real server payload
      final orderMap = data['order'];
      final orderId = (orderMap is Map ? orderMap['id'] : null) ??
          data['order_id'] ??
          data['id'];

      // Extract status — comes from data['order']['order_status'] or data['status']
      final status = (orderMap is Map ? orderMap['order_status'] : null) ??
          data['status'] ??
          '';

      final eventType = data['event_type'] ?? 'unknown';
      debugPrint(
          '� [RealtimeService] event_type=$eventType, orderId=$orderId, status=$status');

      if (orderId != null) {
        final orderIdStr = orderId.toString();

        // 1. Optimistically update status in memory for instant UI feedback
        if (status.isNotEmpty) {
          orderController.updateOrderStatus(int.tryParse(orderIdStr), status);
        }

        // 2. Fetch fresh data from API endpoint (track order) to sync all details
        orderController.timerTrackOrder(orderIdStr);
      }

      // 3. Refresh the running orders list
      orderController.getRunningOrders(1, notify: true, reload: false);
    }
  }

  Future<void> stopListening() async {
    await ReverbHelper.disconnectAll();
    isListening.value = false;
  }
}
