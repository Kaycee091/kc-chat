import 'package:flutter/material.dart';
import '../models/messenger_model.dart';
import '../core/utils/mock_data.dart';
import '../core/network/websocket_service.dart';
import '../core/network/api_client.dart';

class MessengerProvider with ChangeNotifier {
  final WebSocketService _wsService;
  final ApiClient _apiClient;

  final List<Conversation> _conversations = List.from(MockData.initialConversations);
  final Map<String, List<Message>> _messagesMap = {
    'conv_1': List.from(MockData.sampleMessages),
  };

  // Floating Chat Head / Dock state (Max 3 open)
  final List<String> _openChatHeadIds = ['conv_1'];
  String? _activeChatWindowId = 'conv_1';

  MessengerProvider({WebSocketService? wsService, ApiClient? apiClient})
      : _wsService = wsService ?? WebSocketService(),
        _apiClient = apiClient ?? ApiClient() {
    _initWebSocketListener();
  }

  List<Conversation> get conversations => _conversations;
  List<String> get openChatHeadIds => _openChatHeadIds;
  String? get activeChatWindowId => _activeChatWindowId;
  WebSocketService get wsService => _wsService;

  int get totalUnreadCount => _conversations.fold(0, (sum, c) => sum + c.unreadCount);

  void _initWebSocketListener() {
    _wsService.messageStream.listen((event) {
      final convId = event['conversation_id'] as String?;
      final content = event['content'] as String?;
      final senderName = event['sender_name'] as String? ?? 'User';
      final senderAvatar = event['sender_avatar'] as String? ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400';
      final senderId = event['sender_id'] as String? ?? 'user_remote';

      if (convId != null && content != null) {
        final incoming = Message(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          conversationId: convId,
          senderId: senderId,
          senderName: senderName,
          senderAvatar: senderAvatar,
          content: content,
          timestamp: 'Just now',
          status: 'delivered',
        );

        if (_messagesMap[convId] == null) {
          _messagesMap[convId] = [];
        }
        _messagesMap[convId]!.add(incoming);

        final convIndex = _conversations.indexWhere((c) => c.id == convId);
        if (convIndex != -1) {
          _conversations[convIndex] = _conversations[convIndex].copyWith(
            lastMessage: content,
            lastMessageTime: 'Just now',
            unreadCount: _conversations[convIndex].unreadCount + 1,
          );
        }
        notifyListeners();
      }
    });

    _wsService.typingStream.listen((event) {
      final convId = event['conversation_id'] as String?;
      final isTyping = event['type'] == 'typing.started';
      if (convId != null) {
        final convIndex = _conversations.indexWhere((c) => c.id == convId);
        if (convIndex != -1) {
          _conversations[convIndex] = _conversations[convIndex].copyWith(isTyping: isTyping);
          notifyListeners();
        }
      }
    });
  }

  List<Message> getMessagesForConversation(String convId) {
    return _messagesMap[convId] ?? [];
  }

  void openChatHead(String convId) {
    if (!_openChatHeadIds.contains(convId)) {
      if (_openChatHeadIds.length >= 3) {
        _openChatHeadIds.removeAt(0);
      }
      _openChatHeadIds.add(convId);
    }
    _activeChatWindowId = convId;

    // Reset unread count on open
    final convIndex = _conversations.indexWhere((c) => c.id == convId);
    if (convIndex != -1 && _conversations[convIndex].unreadCount > 0) {
      _conversations[convIndex] = _conversations[convIndex].copyWith(unreadCount: 0);
    }

    notifyListeners();
  }

  /// Open or locate conversation for a specific user ID
  Conversation openConversationWithUser(String userId, String userName, String userAvatar) {
    final existingIndex = _conversations.indexWhere(
      (c) => !c.isGroup && c.participantIds.contains(userId),
    );

    if (existingIndex != -1) {
      openChatHead(_conversations[existingIndex].id);
      return _conversations[existingIndex];
    } else {
      // Create new direct conversation
      final newConv = Conversation(
        id: 'conv_user_$userId',
        participantIds: ['user_1', userId],
        participantNames: ['Alex Johnson', userName],
        participantAvatars: [
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
          userAvatar.isNotEmpty ? userAvatar : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
        ],
        lastMessage: 'Started conversation',
        lastMessageTime: 'Just now',
        unreadCount: 0,
        isOnline: true,
      );
      _conversations.insert(0, newConv);
      _messagesMap[newConv.id] = [];
      openChatHead(newConv.id);
      return newConv;
    }
  }

  void closeChatHead(String convId) {
    _openChatHeadIds.remove(convId);
    if (_activeChatWindowId == convId) {
      _activeChatWindowId = _openChatHeadIds.isNotEmpty ? _openChatHeadIds.last : null;
    }
    notifyListeners();
  }

  void minimizeChatWindow() {
    _activeChatWindowId = null;
    notifyListeners();
  }

  void sendMessage(String convId, String content, {String? attachmentUrl, bool isAudio = false}) {
    final newMessage = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: convId,
      senderId: 'user_1',
      senderName: 'Alex Johnson',
      senderAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
      content: content,
      attachmentUrl: attachmentUrl,
      isAudio: isAudio,
      audioDuration: isAudio ? '0:15' : null,
      timestamp: 'Just now',
      status: 'read',
    );

    if (_messagesMap[convId] == null) {
      _messagesMap[convId] = [];
    }
    _messagesMap[convId]!.add(newMessage);

    final convIndex = _conversations.indexWhere((c) => c.id == convId);
    if (convIndex != -1) {
      _conversations[convIndex] = _conversations[convIndex].copyWith(
        lastMessage: isAudio ? '🎤 Voice message (0:15)' : content,
        lastMessageTime: 'Just now',
      );
    }
    notifyListeners();

    // Broadcast through WebSocket channel and REST API
    _wsService.sendChatMessage(convId, content, attachmentUrl: attachmentUrl);
    try {
      _apiClient.post('messaging/conversations/$convId/messages/', body: {
        'content': content,
        'attachment_url': attachmentUrl,
        'is_audio': isAudio,
      });
    } catch (_) {}
  }

  void sendTyping(String convId, bool isTyping) {
    _wsService.sendTypingIndicator(convId, isTyping);
  }

  void createGroupConversation(String groupName, List<String> participantIds) {
    final newConv = Conversation(
      id: 'conv_${DateTime.now().millisecondsSinceEpoch}',
      participantIds: participantIds,
      participantNames: ['Alex Johnson', 'Sophia Martinez', 'Marcus Chen'],
      participantAvatars: [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80'
      ],
      isGroup: true,
      groupName: groupName,
      groupAvatar: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=400&auto=format&fit=crop&q=80',
      lastMessage: 'Group conversation created.',
      lastMessageTime: 'Just now',
    );
    _conversations.insert(0, newConv);
    openChatHead(newConv.id);
    notifyListeners();

    try {
      _apiClient.post('messaging/conversations/', body: {
        'group_name': groupName,
        'participant_ids': participantIds,
        'is_group': true,
      });
    } catch (_) {}
  }
}
