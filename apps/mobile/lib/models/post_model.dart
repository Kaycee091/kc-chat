class PollOption {
  final String id;
  final String text;
  final int voteCount;
  final List<String> voterIds;

  PollOption({
    required this.id,
    required this.text,
    this.voteCount = 0,
    this.voterIds = const [],
  });

  PollOption copyWith({
    int? voteCount,
    List<String>? voterIds,
  }) {
    return PollOption(
      id: id,
      text: text,
      voteCount: voteCount ?? this.voteCount,
      voterIds: voterIds ?? this.voterIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'voteCount': voteCount,
        'voterIds': voterIds,
      };

  factory PollOption.fromJson(Map<String, dynamic> json) => PollOption(
        id: json['id'] ?? '',
        text: json['text'] ?? '',
        voteCount: json['voteCount'] ?? 0,
        voterIds: List<String>.from(json['voterIds'] ?? []),
      );
}

class PollData {
  final String question;
  final List<PollOption> options;
  final int totalVotes;

  PollData({
    required this.question,
    required this.options,
    this.totalVotes = 0,
  });

  PollData copyWith({
    List<PollOption>? options,
    int? totalVotes,
  }) {
    return PollData(
      question: question,
      options: options ?? this.options,
      totalVotes: totalVotes ?? this.totalVotes,
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options.map((o) => o.toJson()).toList(),
        'totalVotes': totalVotes,
      };

  factory PollData.fromJson(Map<String, dynamic> json) => PollData(
        question: json['question'] ?? '',
        options: (json['options'] as List? ?? []).map((o) => PollOption.fromJson(o)).toList(),
        totalVotes: json['totalVotes'] ?? 0,
      );
}

class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String content;
  final String? imageUrl;
  final String timestamp;
  final Map<String, int> reactions; // 'like', 'love', etc.
  final String? userReaction;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    this.reactions = const {},
    this.userReaction,
    this.replies = const [],
  });

  Comment copyWith({
    String? content,
    Map<String, int>? reactions,
    String? userReaction,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id,
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      content: content ?? this.content,
      imageUrl: imageUrl,
      timestamp: timestamp,
      reactions: reactions ?? this.reactions,
      userReaction: userReaction ?? this.userReaction,
      replies: replies ?? this.replies,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'authorId': authorId,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'content': content,
        'imageUrl': imageUrl,
        'timestamp': timestamp,
        'reactions': reactions,
        'userReaction': userReaction,
        'replies': replies.map((r) => r.toJson()).toList(),
      };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'] ?? '',
        postId: json['postId'] ?? '',
        authorId: json['authorId'] ?? '',
        authorName: json['authorName'] ?? '',
        authorAvatar: json['authorAvatar'] ?? '',
        content: json['content'] ?? '',
        imageUrl: json['imageUrl'],
        timestamp: json['timestamp'] ?? '',
        reactions: Map<String, int>.from(json['reactions'] ?? {}),
        userReaction: json['userReaction'],
        replies: (json['replies'] as List? ?? []).map((r) => Comment.fromJson(r)).toList(),
      );
}

class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String authorUsername;
  final String authorAvatar;
  final bool isAuthorVerified;
  final String content;
  final List<String> mediaUrls;
  final bool isVideo;
  final String? videoUrl;
  final String timestamp;
  final String privacy; // 'public', 'friends', 'only_me'
  final String? feeling;
  final String? locationCheckIn;
  final PollData? poll;
  final bool isPinned;
  final bool isSaved;
  final bool isCommentsDisabled;
  final Post? originalPost; // For shared posts
  final int sharesCount;
  final String? userReaction; // 'like', 'love', 'care', 'haha', 'wow', 'sad', 'angry'
  final Map<String, int> reactionCounts;
  final List<Comment> comments;
  final String? backgroundGradient;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorUsername,
    required this.authorAvatar,
    this.isAuthorVerified = false,
    required this.content,
    this.mediaUrls = const [],
    this.isVideo = false,
    this.videoUrl,
    required this.timestamp,
    this.privacy = 'public',
    this.feeling,
    this.locationCheckIn,
    this.poll,
    this.isPinned = false,
    this.isSaved = false,
    this.isCommentsDisabled = false,
    this.originalPost,
    this.sharesCount = 0,
    this.userReaction,
    this.reactionCounts = const {},
    this.comments = const [],
    this.backgroundGradient,
  });

  int get totalReactions => reactionCounts.values.fold(0, (a, b) => a + b);

  Post copyWith({
    String? content,
    List<String>? mediaUrls,
    PollData? poll,
    bool? isPinned,
    bool? isSaved,
    bool? isCommentsDisabled,
    int? sharesCount,
    String? userReaction,
    Map<String, int>? reactionCounts,
    List<Comment>? comments,
  }) {
    return Post(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorUsername: authorUsername,
      authorAvatar: authorAvatar,
      isAuthorVerified: isAuthorVerified,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      isVideo: isVideo,
      videoUrl: videoUrl,
      timestamp: timestamp,
      privacy: privacy,
      feeling: feeling,
      locationCheckIn: locationCheckIn,
      poll: poll ?? this.poll,
      isPinned: isPinned ?? this.isPinned,
      isSaved: isSaved ?? this.isSaved,
      isCommentsDisabled: isCommentsDisabled ?? this.isCommentsDisabled,
      originalPost: originalPost,
      sharesCount: sharesCount ?? this.sharesCount,
      userReaction: userReaction,
      reactionCounts: reactionCounts ?? this.reactionCounts,
      comments: comments ?? this.comments,
      backgroundGradient: backgroundGradient,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'authorName': authorName,
        'authorUsername': authorUsername,
        'authorAvatar': authorAvatar,
        'isAuthorVerified': isAuthorVerified,
        'content': content,
        'mediaUrls': mediaUrls,
        'isVideo': isVideo,
        'videoUrl': videoUrl,
        'timestamp': timestamp,
        'privacy': privacy,
        'feeling': feeling,
        'locationCheckIn': locationCheckIn,
        'poll': poll?.toJson(),
        'isPinned': isPinned,
        'isSaved': isSaved,
        'isCommentsDisabled': isCommentsDisabled,
        'originalPost': originalPost?.toJson(),
        'sharesCount': sharesCount,
        'userReaction': userReaction,
        'reactionCounts': reactionCounts,
        'comments': comments.map((c) => c.toJson()).toList(),
        'backgroundGradient': backgroundGradient,
      };

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] ?? '',
        authorId: json['authorId'] ?? '',
        authorName: json['authorName'] ?? '',
        authorUsername: json['authorUsername'] ?? '',
        authorAvatar: json['authorAvatar'] ?? '',
        isAuthorVerified: json['isAuthorVerified'] ?? false,
        content: json['content'] ?? '',
        mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
        isVideo: json['isVideo'] ?? false,
        videoUrl: json['videoUrl'],
        timestamp: json['timestamp'] ?? '',
        privacy: json['privacy'] ?? 'public',
        feeling: json['feeling'],
        locationCheckIn: json['locationCheckIn'],
        poll: json['poll'] != null ? PollData.fromJson(json['poll']) : null,
        isPinned: json['isPinned'] ?? false,
        isSaved: json['isSaved'] ?? false,
        isCommentsDisabled: json['isCommentsDisabled'] ?? false,
        originalPost: json['originalPost'] != null ? Post.fromJson(json['originalPost']) : null,
        sharesCount: json['sharesCount'] ?? 0,
        userReaction: json['userReaction'],
        reactionCounts: Map<String, int>.from(json['reactionCounts'] ?? {}),
        comments: (json['comments'] as List? ?? []).map((c) => Comment.fromJson(c)).toList(),
        backgroundGradient: json['backgroundGradient'],
      );
}
