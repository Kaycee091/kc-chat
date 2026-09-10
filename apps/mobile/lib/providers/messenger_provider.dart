import 'package:flutter/material.dart';
import '../models/messenger_model.dart';
import '../core/utils/mock_data.dart';

class MessengerProvider with ChangeNotifier {
  List<Conversation> _conversations = List.from(MockData.initialConversations);
  Map<String, List<Message>> _messagesMap = {
    'conv_1': List.from(MockData.sampleMessages),
  };

  // Floating Chat Head / Dock state (Max 3 open)
  List<String> _openChatHeadIds = ['conv_1'];
  String? _activeChatWindowId = 'conv_1';

  List<Conversation> get conversations => _conversations;
  List<String> get openChatHeadIds => _openChatHeadIds;
  String? get activeChatWindowId => _activeChatWindowId;

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
    notifyListeners();
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
  }

  void simulateIncomingMessage(String convId, String content) {
    final incoming = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: convId,
      senderId: 'user_2',
      senderName: 'Sophia Martinez',
      senderAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80',
      content: content,
      timestamp: 'Just now',
      status: 'read',
    );
    if (_messagesMap[convId] == null) {
      _messagesMap[convId] = [];
    }
    _messagesMap[convId]!.add(incoming);
    notifyListeners();
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
  }
}
