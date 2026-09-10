class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String content;
  final String? attachmentUrl;
  final bool isAudio;
  final String? audioDuration;
  final String timestamp;
  final String status; // 'sending', 'sent', 'delivered', 'read'

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.content,
    this.attachmentUrl,
    this.isAudio = false,
    this.audioDuration,
    required this.timestamp,
    this.status = 'read',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'senderId': senderId,
        'senderName': senderName,
        'senderAvatar': senderAvatar,
        'content': content,
        'attachmentUrl': attachmentUrl,
        'isAudio': isAudio,
        'audioDuration': audioDuration,
        'timestamp': timestamp,
        'status': status,
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] ?? '',
        conversationId: json['conversationId'] ?? '',
        senderId: json['senderId'] ?? '',
        senderName: json['senderName'] ?? '',
        senderAvatar: json['senderAvatar'] ?? '',
        content: json['content'] ?? '',
        attachmentUrl: json['attachmentUrl'],
        isAudio: json['isAudio'] ?? false,
        audioDuration: json['audioDuration'],
        timestamp: json['timestamp'] ?? '',
        status: json['status'] ?? 'read',
      );
}

class Conversation {
  final String id;
  final List<String> participantIds;
  final List<String> participantNames;
  final List<String> participantAvatars;
  final bool isGroup;
  final String? groupName;
  final String? groupAvatar;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final bool isTyping;
  final String? typingUserName;
  final bool isMuted;
  final bool isArchived;

  Conversation({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantAvatars,
    this.isGroup = false,
    this.groupName,
    this.groupAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isTyping = false,
    this.typingUserName,
    this.isMuted = false,
    this.isArchived = false,
  });

  Conversation copyWith({
    String? lastMessage,
    String? lastMessageTime,
    int? unreadCount,
    bool? isOnline,
    bool? isTyping,
    String? typingUserName,
    bool? isMuted,
    bool? isArchived,
  }) {
    return Conversation(
      id: id,
      participantIds: participantIds,
      participantNames: participantNames,
      participantAvatars: participantAvatars,
      isGroup: isGroup,
      groupName: groupName,
      groupAvatar: groupAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      isTyping: isTyping ?? this.isTyping,
      typingUserName: typingUserName ?? this.typingUserName,
      isMuted: isMuted ?? this.isMuted,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'participantIds': participantIds,
        'participantNames': participantNames,
        'participantAvatars': participantAvatars,
        'isGroup': isGroup,
        'groupName': groupName,
        'groupAvatar': groupAvatar,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime,
        'unreadCount': unreadCount,
        'isOnline': isOnline,
        'isTyping': isTyping,
        'typingUserName': typingUserName,
        'isMuted': isMuted,
        'isArchived': isArchived,
      };

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'] ?? '',
        participantIds: List<String>.from(json['participantIds'] ?? []),
        participantNames: List<String>.from(json['participantNames'] ?? []),
        participantAvatars: List<String>.from(json['participantAvatars'] ?? []),
        isGroup: json['isGroup'] ?? false,
        groupName: json['groupName'],
        groupAvatar: json['groupAvatar'],
        lastMessage: json['lastMessage'] ?? '',
        lastMessageTime: json['lastMessageTime'] ?? '',
        unreadCount: json['unreadCount'] ?? 0,
        isOnline: json['isOnline'] ?? false,
        isTyping: json['isTyping'] ?? false,
        typingUserName: json['typingUserName'],
        isMuted: json['isMuted'] ?? false,
        isArchived: json['isArchived'] ?? false,
      );
}
