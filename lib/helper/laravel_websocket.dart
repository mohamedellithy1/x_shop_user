import 'package:flutter/foundation.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

/// Generic Laravel Echo/Pusher style WebSocket client for xMarket.
///
/// - Handles connection / reconnection
/// - Maintains a heartbeat (ping/pong)
/// - Supports public & private channel subscription
/// - Exposes:
///   - [allMessages] stream for all raw messages
///   - [connectionStatus] stream (true/false)
///   - [errors] stream with error messages
///   - `listenToEvent` for custom event-specific callbacks.
class LaravelWebSocket {
  final String host;
  final int port;
  final String key;
  final String authToken;
  final String? wsPath;

  late WebSocketChannel _channel;
  String? _socketId;
  Timer? _pingTimer;

  final Map<String, Function(dynamic)> _eventCallbacks = {};

  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  LaravelWebSocket({
    required this.host,
    this.port = 443,
    required this.key,
    required this.authToken,
    this.wsPath,
  });

  Future<void> connect() async {
    try {
      final path = wsPath ?? '/app/$key';
      final wsUrl = Uri.parse('wss://$host${port == 443 ? "" : ":$port"}$path');

      debugPrint('🌐 [xMarket WS] Connecting to $wsUrl');

      _channel = WebSocketChannel.connect(wsUrl);

      _setupHeartbeat();

      _channel.stream.listen(
        (message) => _handleMessage(message),
        onError: (error) {
          debugPrint('❌ [xMarket WS] WebSocket error: $error');
          _errorController.add('WebSocket error: $error');
          _connectionStatusController.add(false);
          _reconnect();
        },
        onDone: () {
          debugPrint('🔌 [xMarket WS] WebSocket closed');
          _connectionStatusController.add(false);
          _reconnect();
        },
      );
    } catch (e) {
      debugPrint('💥 [xMarket WS] Connection exception: $e');
      _errorController.add('Connection exception: $e');
      _connectionStatusController.add(false);
      _reconnect();
    }
  }

  void _setupHeartbeat() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      try {
        _channel.sink.add(jsonEncode({'event': 'pusher:ping', 'data': {}}));
        debugPrint('💓 [xMarket WS] Sent ping');
      } catch (e) {
        debugPrint('💥 [xMarket WS] Error sending ping: $e');
        _reconnect();
      }
    });
  }

  Future<void> _reconnect() async {
    debugPrint('🔁 [xMarket WS] Attempting to reconnect...');
    await disconnect();
    await Future.delayed(const Duration(seconds: 2));
    await connect();
  }

  Future<void> subscribePublicChannel(String channelName) async {
    _channel.sink.add(jsonEncode({
      'event': 'pusher:subscribe',
      'data': {
        'channel': channelName,
      },
    }));
    debugPrint('[xMarket WS] Subscribed to public channel: $channelName');
  }

  /// Subscribe to a private channel using xMarket's customer auth endpoint.
  ///
  /// Backend contract:
  ///   POST /api/v1/ws/auth/customer
  ///   Headers:
  ///     Authorization: Bearer {customer_token}
  ///     Content-Type: application/json
  ///   Body:
  ///     {
  ///       "socket_id": "123.456",
  ///       "channel_name": "private-user.customer.{id}"
  ///     }
  ///   Response:
  ///     { "auth": "super-key-xshop:signature...", "channel_data": null }
  Future<void> subscribePrivateChannel(String channelName) async {
    try {
      if (_socketId == null) {
        await _waitForConnection();
      }

      final fullChannelName = 'private-$channelName';
      final authEndpoint = 'https://$host/api/v1/ws/auth/customer';

      debugPrint(
        '[xMarket WS] Authenticating private channel: $fullChannelName via $authEndpoint',
      );

      final authResponse = await http.post(
        Uri.parse(authEndpoint),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'socket_id': _socketId,
          'channel_name': fullChannelName,
        }),
      );

      debugPrint(
        '[xMarket WS] Auth response: '
        'status=${authResponse.statusCode}, body=${authResponse.body}',
      );

      if (authResponse.statusCode != 200) {
        final msg = 'Failed to authenticate: ${authResponse.body}';
        _errorController.add(msg);
        throw Exception(msg);
      }

      final authData = jsonDecode(authResponse.body);

      final subscribeMessage = {
        'event': 'pusher:subscribe',
        'data': {
          'auth': authData['auth'],
          'channel': fullChannelName,
        },
      };

      _channel.sink.add(jsonEncode(subscribeMessage));
      debugPrint(
          '✅ [xMarket WS] Subscribed to private channel: $fullChannelName');
    } catch (e, stackTrace) {
      debugPrint('❌ [xMarket WS] Subscription error: $e');
      debugPrint(stackTrace.toString());
      _errorController.add('Subscription error: $e');
      rethrow;
    }
  }

  Future<void> _waitForConnection() async {
    const maxAttempts = 10;
    var attempts = 0;

    while (_socketId == null && attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
      debugPrint(
        '[xMarket WS] Waiting for connection... '
        '(attempt $attempts/$maxAttempts)',
      );
    }

    if (_socketId == null) {
      throw Exception(
        '[xMarket WS] Failed to get socket ID after $maxAttempts attempts',
      );
    }
  }

  void _handleMessage(dynamic message) {
    debugPrint('📨 [xMarket WS] Raw message: $message');
    _sendToDiscord(message);

    try {
      final data = jsonDecode(message);
      final event = data['event']?.toString();

      if (event == 'pusher:connection_established') {
        final connectionData = jsonDecode(data['data']);
        _socketId = connectionData['socket_id'];
        debugPrint(
            '✅ [xMarket WS] Connection established. socketId=$_socketId');
        _connectionStatusController.add(true);
      } else if (event == 'pusher:pong') {
        debugPrint('🏓 [xMarket WS] Received pong');
        return;
      } else if (event == 'pusher:error') {
        debugPrint('❌ [xMarket WS] Pusher error: ${data['data']}');
        _errorController.add('Pusher error: ${data['data']}');
        _connectionStatusController.add(false);
      }

      _messageController.add(data);

      if (event != null && _eventCallbacks.containsKey(event)) {
        dynamic decodedPayload;

        if (data['data'] == null) {
          decodedPayload = {};
        } else if (data['data'] is String) {
          try {
            decodedPayload = jsonDecode(data['data']);
          } catch (_) {
            decodedPayload = data['data'];
          }
        } else {
          decodedPayload = data['data'];
        }

        _eventCallbacks[event]!(decodedPayload);
      }
    } catch (e, trace) {
      debugPrint('💥 [xMarket WS] Error parsing message: $e');
      debugPrint(trace.toString());
      _errorController.add('Parsing error: $e');
    }
  }

  void listenToEvent(String eventName, Function(dynamic) callback) {
    debugPrint('[xMarket WS] Adding listener for event: $eventName');
    _eventCallbacks[eventName] = callback;
  }

  void removeEventListener(String eventName) {
    _eventCallbacks.remove(eventName);
  }

  void removeAllEventListeners() {
    _eventCallbacks.clear();
  }

  bool hasEventListener(String eventName) {
    return _eventCallbacks.containsKey(eventName);
  }

  List<String> getRegisteredEvents() {
    return _eventCallbacks.keys.toList();
  }

  Stream<Map<String, dynamic>> get allMessages => _messageController.stream;
  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  Stream<String> get errors => _errorController.stream;

  String? get socketId => _socketId;

  /// Wait until we get a socketId (connection established) or timeout.
  Future<bool> waitForConnected(
      {Duration timeout = const Duration(seconds: 10)}) async {
    if (_socketId != null) return true;
    try {
      final result =
          await connectionStatus.firstWhere((c) => c == true).timeout(timeout);
      return result;
    } catch (_) {
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      _pingTimer?.cancel();
      await _channel.sink.close();
      debugPrint('🔌 [xMarket WS] Disconnected successfully');
    } catch (e) {
      debugPrint('💥 [xMarket WS] Error during disconnect: $e');
    }
  }

  void _sendToDiscord(dynamic message) async {
    try {
      final String webhookUrl = AppConstants.discordWebhookUri;
      String eventName = 'Unknown Event';
      String channelName = 'Unknown Channel';
      String bodyText = message.toString();

      try {
        final data = jsonDecode(message);
        eventName = data['event']?.toString() ?? 'N/A';
        channelName = data['channel']?.toString() ?? 'N/A';
      } catch (_) {}

      if (eventName == 'pusher:ping' || eventName == 'pusher:pong') return;

      String discordMessage = '📡 **X-Market WebSocket Event** 📡\n'
          '**Event:** `$eventName`\n'
          '**Channel:** `$channelName`';

      if (bodyText.length > 1000) {
        bodyText = '${bodyText.substring(0, 1000)}... (truncated)';
      }

      await http.post(
        Uri.parse(webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'embeds': [
            {
              'title': 'WS Event: $eventName',
              'color': 0x00A2FF,
              'description': discordMessage,
              'fields': [
                {
                  'name': 'Payload',
                  'value': '```json\n$bodyText\n```',
                }
              ],
              'timestamp': DateTime.now().toIso8601String(),
            }
          ]
        }),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to send WS event to Discord: $e');
      }
    }
  }
}
