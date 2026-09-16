class UserProfile {
  final String id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String avatarUrl;
  final String coverUrl;
  final String bio;
  final bool isVerified;
  final String location;
  final String work;
  final String education;
  final String relationship;
  final String website;
  final String joinedDate;
  final List<String> friendIds;
  final List<String> followerIds;
  final List<String> followingIds;
  final int mutualFriendsCount;
  final bool isSuspended;
  final bool isBanned;
  final String role; // 'user', 'moderator', 'admin', 'super_admin'
  final bool is2FAEnabled;
  final String defaultPostAudience; // 'public', 'friends', 'only_me'
  final bool onlineStatusEnabled;
  final bool readReceiptsEnabled;
  final List<String> blockedUserIds;

  UserProfile({
    required this.id,
    required this.name,
    required this.username,
    this.email = '',
    this.phone = '',
    required this.avatarUrl,
    this.coverUrl = '',
    this.bio = '',
    this.isVerified = false,
    this.location = '',
    this.work = '',
    this.education = '',
    this.relationship = '',
    this.website = '',
    this.joinedDate = 'September 2026',
    this.friendIds = const [],
    this.followerIds = const [],
    this.followingIds = const [],
    this.mutualFriendsCount = 0,
    this.isSuspended = false,
    this.isBanned = false,
    this.role = 'user',
    this.is2FAEnabled = false,
    this.defaultPostAudience = 'public',
    this.onlineStatusEnabled = true,
    this.readReceiptsEnabled = true,
    this.blockedUserIds = const [],
  });

  UserProfile copyWith({
    String? name,
    String? username,
    String? email,
    String? phone,
    String? avatarUrl,
    String? coverUrl,
    String? bio,
    bool? isVerified,
    String? location,
    String? work,
    String? education,
    String? relationship,
    String? website,
    List<String>? friendIds,
    List<String>? followerIds,
    List<String>? followingIds,
    int? mutualFriendsCount,
    bool? isSuspended,
    bool? isBanned,
    String? role,
    bool? is2FAEnabled,
    String? defaultPostAudience,
    bool? onlineStatusEnabled,
    bool? readReceiptsEnabled,
    List<String>? blockedUserIds,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      location: location ?? this.location,
      work: work ?? this.work,
      education: education ?? this.education,
      relationship: relationship ?? this.relationship,
      website: website ?? this.website,
      joinedDate: joinedDate,
      friendIds: friendIds ?? this.friendIds,
      followerIds: followerIds ?? this.followerIds,
      followingIds: followingIds ?? this.followingIds,
      mutualFriendsCount: mutualFriendsCount ?? this.mutualFriendsCount,
      isSuspended: isSuspended ?? this.isSuspended,
      isBanned: isBanned ?? this.isBanned,
      role: role ?? this.role,
      is2FAEnabled: is2FAEnabled ?? this.is2FAEnabled,
      defaultPostAudience: defaultPostAudience ?? this.defaultPostAudience,
      onlineStatusEnabled: onlineStatusEnabled ?? this.onlineStatusEnabled,
      readReceiptsEnabled: readReceiptsEnabled ?? this.readReceiptsEnabled,
      blockedUserIds: blockedUserIds ?? this.blockedUserIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'coverUrl': coverUrl,
        'bio': bio,
        'isVerified': isVerified,
        'location': location,
        'work': work,
        'education': education,
        'relationship': relationship,
        'website': website,
        'joinedDate': joinedDate,
        'friendIds': friendIds,
        'followerIds': followerIds,
        'followingIds': followingIds,
        'mutualFriendsCount': mutualFriendsCount,
        'isSuspended': isSuspended,
        'isBanned': isBanned,
        'role': role,
        'is2FAEnabled': is2FAEnabled,
        'defaultPostAudience': defaultPostAudience,
        'onlineStatusEnabled': onlineStatusEnabled,
        'readReceiptsEnabled': readReceiptsEnabled,
        'blockedUserIds': blockedUserIds,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        username: json['username'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        avatarUrl: json['avatarUrl'] ?? '',
        coverUrl: json['coverUrl'] ?? '',
        bio: json['bio'] ?? '',
        isVerified: json['isVerified'] ?? false,
        location: json['location'] ?? '',
        work: json['work'] ?? '',
        education: json['education'] ?? '',
        relationship: json['relationship'] ?? '',
        website: json['website'] ?? '',
        joinedDate: json['joinedDate'] ?? 'September 2026',
        friendIds: List<String>.from(json['friendIds'] ?? []),
        followerIds: List<String>.from(json['followerIds'] ?? []),
        followingIds: List<String>.from(json['followingIds'] ?? []),
        mutualFriendsCount: json['mutualFriendsCount'] ?? 0,
        isSuspended: json['isSuspended'] ?? false,
        isBanned: json['isBanned'] ?? false,
        role: json['role'] ?? 'user',
        is2FAEnabled: json['is2FAEnabled'] ?? false,
        defaultPostAudience: json['defaultPostAudience'] ?? 'public',
        onlineStatusEnabled: json['onlineStatusEnabled'] ?? true,
        readReceiptsEnabled: json['readReceiptsEnabled'] ?? true,
        blockedUserIds: List<String>.from(json['blockedUserIds'] ?? []),
      );
}

class LoginHistoryRecord {
  final String id;
  final String timestamp;
  final String ipAddress;
  final String deviceName;
  final String location;
  final bool isSuccessful;

  LoginHistoryRecord({
    required this.id,
    required this.timestamp,
    required this.ipAddress,
    required this.deviceName,
    required this.location,
    required this.isSuccessful,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp,
        'ipAddress': ipAddress,
        'deviceName': deviceName,
        'location': location,
        'isSuccessful': isSuccessful,
      };

  factory LoginHistoryRecord.fromJson(Map<String, dynamic> json) => LoginHistoryRecord(
        id: json['id'] ?? '',
        timestamp: json['timestamp'] ?? '',
        ipAddress: json['ipAddress'] ?? '',
        deviceName: json['deviceName'] ?? '',
        location: json['location'] ?? '',
        isSuccessful: json['isSuccessful'] ?? true,
      );
}

class ActiveSession {
  final String id;
  final String deviceName;
  final String browser;
  final String ipAddress;
  final String location;
  final String lastActive;

  ActiveSession({
    required this.id,
    required this.deviceName,
    required this.browser,
    required this.ipAddress,
    required this.location,
    required this.lastActive,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'deviceName': deviceName,
        'browser': browser,
        'ipAddress': ipAddress,
        'location': location,
        'lastActive': lastActive,
      };

  factory ActiveSession.fromJson(Map<String, dynamic> json) => ActiveSession(
        id: json['id'] ?? '',
        deviceName: json['deviceName'] ?? '',
        browser: json['browser'] ?? '',
        ipAddress: json['ipAddress'] ?? '',
        location: json['location'] ?? '',
        lastActive: json['lastActive'] ?? '',
      );
}
