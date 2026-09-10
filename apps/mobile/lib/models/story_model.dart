class StoryViewer {
  final String userId;
  final String userName;
  final String userAvatar;
  final String viewedAt;

  StoryViewer({
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.viewedAt,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'viewedAt': viewedAt,
      };

  factory StoryViewer.fromJson(Map<String, dynamic> json) => StoryViewer(
        userId: json['userId'] ?? '',
        userName: json['userName'] ?? '',
        userAvatar: json['userAvatar'] ?? '',
        viewedAt: json['viewedAt'] ?? '',
      );
}

class Story {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String? imageUrl;
  final String? textContent;
  final String? backgroundGradient;
  final String createdAt;
  final String expiresAt;
  final List<StoryViewer> viewers;
  final bool isSeen;

  Story({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    this.imageUrl,
    this.textContent,
    this.backgroundGradient,
    required this.createdAt,
    required this.expiresAt,
    this.viewers = const [],
    this.isSeen = false,
  });

  bool get isExpired => DateTime.now().isAfter(DateTime.parse(expiresAt));

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'imageUrl': imageUrl,
        'textContent': textContent,
        'backgroundGradient': backgroundGradient,
        'createdAt': createdAt,
        'expiresAt': expiresAt,
        'viewers': viewers.map((v) => v.toJson()).toList(),
        'isSeen': isSeen,
      };

  factory Story.fromJson(Map<String, dynamic> json) => Story(
        id: json['id'] ?? '',
        authorId: json['authorId'] ?? '',
        authorName: json['authorName'] ?? '',
        authorAvatar: json['authorAvatar'] ?? '',
        imageUrl: json['imageUrl'],
        textContent: json['textContent'],
        backgroundGradient: json['backgroundGradient'],
        createdAt: json['createdAt'] ?? '',
        expiresAt: json['expiresAt'] ?? '',
        viewers: (json['viewers'] as List? ?? []).map((v) => StoryViewer.fromJson(v)).toList(),
        isSeen: json['isSeen'] ?? false,
      );
}
