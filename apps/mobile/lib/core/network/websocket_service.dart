import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'api_config.dart';
import '../storage/storage_service.dart';

enum WsConnectionState { disconnected, connecting, connected, error }

class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isDisposed = false;

  final StorageService _storageService;

  final _connectionStateController = StreamController<WsConnectionState>.broadcast();
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _presenceController = StreamController<Map<String, dynamic>>.broadcast();
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();

  WsConnectionState _currentState = WsConnectionState.disconnected;

  WebSocketService({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  Stream<WsConnectionState> get connectionStateStream => _connectionStateController.stream;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get presenceStream => _presenceController.stream;
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;

  WsConnectionState get currentState => _currentState;
  bool get isConnected => _currentState == WsConnectionState.connected;

  void _setState(WsConnectionState state) {
    _currentState = state;
    if (!_connectionStateController.isClosed) {
      _connectionStateController.add(state);
    }
  }

  Future<void> connect() async {
    if (_isDisposed || isConnected || _currentState == WsConnectionState.connecting) return;

    _setState(WsConnectionState.connecting);

    try {
      final token = await _storageService.getAccessToken();
      final uri = Uri.parse('${ApiConfig.wsUrl}/realtime/${token != null ? '?token=$token' : ''}');

      _channel = WebSocketChannel.connect(uri);
      await _channel?.ready;

      _setState(WsConnectionState.connected);
      _reconnectAttempts = 0;

      _subscription = _channel?.stream.listen(
        _handleIncomingEvent,
        onError: (err) {
          _handleDisconnect();
        },
        onDone: () {
          _handleDisconnect();
        },
      );
    } catch (_) {
      _handleDisconnect();
    }
  }

  void _handleIncomingEvent(dynamic rawData) {
    try {
      final Map<String, dynamic> event = jsonDecode(rawData as String);
      final type = event['type'] as String?;

      switch (type) {
        case 'message.created':
        case 'message.sent':
        case 'message.delivered':
        case 'message.read':
          if (!_messageController.isClosed) _messageController.add(event);
          break;
        case 'typing.started':
        case 'typing.stopped':
          if (!_typingController.isClosed) _typingController.add(event);
          break;
        case 'presence.online':
        case 'presence.offline':
          if (!_presenceController.isClosed) _presenceController.add(event);
          break;
        case 'notification.created':
          if (!_notificationController.isClosed) _notificationController.add(event);
          break;
        default:
          if (!_messageController.isClosed) _messageController.add(event);
      }
    } catch (_) {
      // Ignore malformed payloads
    }
  }

  void _handleDisconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    _setState(WsConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_isDisposed) return;
    _reconnectTimer?.cancel();

    // Exponential backoff: 2s, 4s, 8s, max 30s
    final delaySeconds = (2 << _reconnectAttempts).clamp(2, 30);
    _reconnectAttempts++;

    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_isDisposed && !isConnected) {
        connect();
      }
    });
  }

  void sendEvent(String type, Map<String, dynamic> data) {
    if (!isConnected || _channel == null) return;
    try {
      final payload = jsonEncode({'type': type, ...data});
      _channel?.sink.add(payload);
    } catch (_) {
      // Ignore write errors; reconnect will restore stream
    }
  }

  void sendChatMessage(String conversationId, String content, {String? attachmentUrl}) {
    sendEvent('chat.message', {
      'conversation_id': conversationId,
      'content': content,
      'attachment_url': attachmentUrl,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void sendTypingIndicator(String conversationId, bool isTyping) {
    sendEvent(isTyping ? 'typing.started' : 'typing.stopped', {
      'conversation_id': conversationId,
    });
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _setState(WsConnectionState.disconnected);
  }

  void dispose() {
    _isDisposed = true;
    disconnect();
    _connectionStateController.close();
    _messageController.close();
    _typingController.close();
    _presenceController.close();
    _notificationController.close();
  }
}
