class GroupModel {
  final String id;
  final String name;
  final String coverUrl;
  final String privacy; // 'Public', 'Private'
  final int memberCount;
  final String description;
  final bool isJoined;
  final List<String> rules;

  GroupModel({
    required this.id,
    required this.name,
    required this.coverUrl,
    required this.privacy,
    required this.memberCount,
    required this.description,
    this.isJoined = false,
    this.rules = const [],
  });

  GroupModel copyWith({bool? isJoined, int? memberCount}) {
    return GroupModel(
      id: id,
      name: name,
      coverUrl: coverUrl,
      privacy: privacy,
      memberCount: memberCount ?? this.memberCount,
      description: description,
      isJoined: isJoined ?? this.isJoined,
      rules: rules,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'coverUrl': coverUrl,
        'privacy': privacy,
        'memberCount': memberCount,
        'description': description,
        'isJoined': isJoined,
        'rules': rules,
      };

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        coverUrl: json['coverUrl'] ?? '',
        privacy: json['privacy'] ?? 'Public',
        memberCount: json['memberCount'] ?? 0,
        description: json['description'] ?? '',
        isJoined: json['isJoined'] ?? false,
        rules: List<String>.from(json['rules'] ?? []),
      );
}

class EventModel {
  final String id;
  final String title;
  final String coverUrl;
  final String date;
  final String time;
  final String location;
  final String description;
  final String organizerName;
  final String rsvpStatus; // 'Going', 'Interested', 'Not Going', 'None'
  final int attendeesCount;

  EventModel({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    required this.organizerName,
    this.rsvpStatus = 'None',
    required this.attendeesCount,
  });

  EventModel copyWith({String? rsvpStatus, int? attendeesCount}) {
    return EventModel(
      id: id,
      title: title,
      coverUrl: coverUrl,
      date: date,
      time: time,
      location: location,
      description: description,
      organizerName: organizerName,
      rsvpStatus: rsvpStatus ?? this.rsvpStatus,
      attendeesCount: attendeesCount ?? this.attendeesCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'coverUrl': coverUrl,
        'date': date,
        'time': time,
        'location': location,
        'description': description,
        'organizerName': organizerName,
        'rsvpStatus': rsvpStatus,
        'attendeesCount': attendeesCount,
      };

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        coverUrl: json['coverUrl'] ?? '',
        date: json['date'] ?? '',
        time: json['time'] ?? '',
        location: json['location'] ?? '',
        description: json['description'] ?? '',
        organizerName: json['organizerName'] ?? '',
        rsvpStatus: json['rsvpStatus'] ?? 'None',
        attendeesCount: json['attendeesCount'] ?? 0,
      );
}

class PageModel {
  final String id;
  final String name;
  final String avatarUrl;
  final String coverUrl;
  final String category;
  final int followerCount;
  final bool isFollowing;

  PageModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.coverUrl,
    required this.category,
    required this.followerCount,
    this.isFollowing = false,
  });

  PageModel copyWith({bool? isFollowing, int? followerCount}) {
    return PageModel(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      coverUrl: coverUrl,
      category: category,
      followerCount: followerCount ?? this.followerCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'coverUrl': coverUrl,
        'category': category,
        'followerCount': followerCount,
        'isFollowing': isFollowing,
      };

  factory PageModel.fromJson(Map<String, dynamic> json) => PageModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        avatarUrl: json['avatarUrl'] ?? '',
        coverUrl: json['coverUrl'] ?? '',
        category: json['category'] ?? '',
        followerCount: json['followerCount'] ?? 0,
        isFollowing: json['isFollowing'] ?? false,
      );
}
