import '../../models/user_model.dart';
import '../../models/post_model.dart';
import '../../models/story_model.dart';
import '../../models/messenger_model.dart';
import '../../models/marketplace_model.dart';
import '../../models/social_models.dart';
import '../../models/admin_model.dart';

class MockData {
  static final UserProfile currentUser = UserProfile(
    id: 'user_1',
    name: 'Alex Johnson',
    username: 'alexj',
    email: 'alex.johnson@kc.app',
    phone: '+1 (555) 234-5678',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
    coverUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=1200&auto=format&fit=crop&q=80',
    bio: 'Software Architect & Tech Enthusiast. Building the future of social connectivity on KC APP! 🚀✨',
    isVerified: true,
    location: 'San Francisco, CA',
    work: 'Lead Architect at KC Tech Labs',
    education: 'Stanford University (Computer Science)',
    relationship: 'Single',
    website: 'https://kc.app',
    joinedDate: 'September 2026',
    friendIds: ['user_2', 'user_3', 'user_4'],
    followerIds: ['user_2', 'user_3', 'user_4', 'user_5'],
    followingIds: ['user_2', 'user_3'],
    mutualFriendsCount: 14,
    role: 'super_admin',
  );

  static final List<UserProfile> users = [
    currentUser,
    UserProfile(
      id: 'user_2',
      name: 'Sophia Martinez',
      username: 'sophiam',
      email: 'sophia@kc.app',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80',
      coverUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200&auto=format&fit=crop&q=80',
      bio: 'UI/UX Designer | Coffee Addict ☕ | Travel Photographer 📸',
      isVerified: true,
      location: 'New York, NY',
      work: 'Senior Product Designer',
      friendIds: ['user_1', 'user_3'],
      mutualFriendsCount: 8,
    ),
    UserProfile(
      id: 'user_3',
      name: 'Marcus Chen',
      username: 'marcusc',
      email: 'marcus@kc.app',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
      coverUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1200&auto=format&fit=crop&q=80',
      bio: 'Mobile App Developer | Flutter Expert 📱',
      isVerified: false,
      location: 'Austin, TX',
      work: 'Senior Flutter Dev',
      friendIds: ['user_1', 'user_2'],
      mutualFriendsCount: 12,
    ),
    UserProfile(
      id: 'user_4',
      name: 'Emily Davis',
      username: 'emilyd',
      email: 'emily@kc.app',
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&auto=format&fit=crop&q=80',
      coverUrl: 'https://images.unsplash.com/photo-1511556532299-8f662fc26c06?w=1200&auto=format&fit=crop&q=80',
      bio: 'Digital Creator & Podcaster 🎙️',
      isVerified: true,
      location: 'Seattle, WA',
      friendIds: ['user_1'],
      mutualFriendsCount: 5,
    ),
  ];

  static final List<Post> initialPosts = [
    Post(
      id: 'post_1',
      authorId: 'user_1',
      authorName: 'Alex Johnson',
      authorUsername: 'alexj',
      authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
      isAuthorVerified: true,
      content: 'Excited to announce the official launch of the KC APP Mobile Platform! Modern glassmorphic design, instant real-time sync, 24h stories, marketplace & live messaging! 🚀✨ #KCApp #Flutter #BuildInPublic',
      mediaUrls: [
        'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=1200&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=1200&auto=format&fit=crop&q=80',
      ],
      timestamp: '2 hours ago',
      privacy: 'public',
      feeling: 'excited 🥳',
      locationCheckIn: 'KC Tech HQ, San Francisco',
      isPinned: true,
      userReaction: 'love',
      reactionCounts: {'like': 24, 'love': 42, 'care': 12, 'wow': 8},
      sharesCount: 15,
      comments: [
        Comment(
          id: 'c1',
          postId: 'post_1',
          authorId: 'user_2',
          authorName: 'Sophia Martinez',
          authorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80',
          content: 'The 3D glassmorphic card design looks incredible Alex! Great work team! 🔥👏',
          timestamp: '1 hour ago',
          reactions: {'like': 5, 'love': 3},
        ),
      ],
    ),
    Post(
      id: 'post_2',
      authorId: 'user_2',
      authorName: 'Sophia Martinez',
      authorUsername: 'sophiam',
      authorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80',
      isAuthorVerified: true,
      content: 'Quick poll for the KC App community: Which UI mode do you prefer for mobile social apps?',
      timestamp: '4 hours ago',
      privacy: 'public',
      poll: PollData(
        question: 'Which UI mode do you prefer for mobile social apps?',
        options: [
          PollOption(id: 'opt_1', text: 'Dark Mode 🌙 (Midnight Slate)', voteCount: 68, voterIds: ['user_1']),
          PollOption(id: 'opt_2', text: 'Light Mode ☀️ (Clean Minimalist)', voteCount: 22),
          PollOption(id: 'opt_3', text: 'Auto System Match ⚙️', voteCount: 14),
        ],
        totalVotes: 104,
      ),
      reactionCounts: {'like': 18, 'love': 10},
      comments: [],
    ),
    Post(
      id: 'post_3',
      authorId: 'user_3',
      authorName: 'Marcus Chen',
      authorUsername: 'marcusc',
      authorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
      content: 'Weekend coding session with a great view! ☕💻',
      mediaUrls: [
        'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=1200&auto=format&fit=crop&q=80',
      ],
      timestamp: '6 hours ago',
      privacy: 'friends',
      reactionCounts: {'like': 15, 'care': 6},
      comments: [],
    ),
  ];

  static final List<Story> initialStories = [
    Story(
      id: 'story_1',
      authorId: 'user_2',
      authorName: 'Sophia M.',
      authorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80',
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
      createdAt: DateTime.now().toIso8601String(),
      expiresAt: DateTime.now().add(const Duration(hours: 22)).toIso8601String(),
      viewers: [
        StoryViewer(userId: 'user_1', userName: 'Alex Johnson', userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80', viewedAt: '10m ago'),
      ],
    ),
    Story(
      id: 'story_2',
      authorId: 'user_3',
      authorName: 'Marcus C.',
      authorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
      textContent: 'Late night Flutter code sprint! 🚀⚡',
      backgroundGradient: 'LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF2563EB)])',
      createdAt: DateTime.now().toIso8601String(),
      expiresAt: DateTime.now().add(const Duration(hours: 18)).toIso8601String(),
      viewers: [],
    ),
  ];

  static final List<Conversation> initialConversations = [
    Conversation(
      id: 'conv_1',
      participantIds: ['user_1', 'user_2'],
      participantNames: ['Alex Johnson', 'Sophia Martinez'],
      participantAvatars: [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80'
      ],
      lastMessage: 'Hey Alex! Did you review the new mobile design tokens?',
      lastMessageTime: '10:45 AM',
      unreadCount: 1,
      isOnline: true,
    ),
    Conversation(
      id: 'conv_2',
      participantIds: ['user_1', 'user_3'],
      participantNames: ['Alex Johnson', 'Marcus Chen'],
      participantAvatars: [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80'
      ],
      lastMessage: 'All Riverpod providers are synced up perfectly.',
      lastMessageTime: 'Yesterday',
      unreadCount: 0,
      isOnline: true,
    ),
  ];

  static final List<Message> sampleMessages = [
    Message(
      id: 'm1',
      conversationId: 'conv_1',
      senderId: 'user_2',
      senderName: 'Sophia Martinez',
      senderAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80',
      content: 'Hey Alex! Did you review the new mobile design tokens?',
      timestamp: '10:45 AM',
      status: 'read',
    ),
  ];

  static final List<MarketplaceItem> initialMarketplaceItems = [
    MarketplaceItem(
      id: 'item_1',
      sellerId: 'user_2',
      sellerName: 'Sophia Martinez',
      sellerAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80',
      title: 'Apple MacBook Pro 16" (M2 Max, 32GB RAM)',
      price: 1850.00,
      category: 'Electronics',
      condition: 'Used - Like New',
      location: 'San Francisco, CA',
      imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&auto=format&fit=crop&q=80',
      description: 'Pristine condition MacBook Pro. Includes original charger and box.',
      createdAt: '1 day ago',
    ),
    MarketplaceItem(
      id: 'item_2',
      sellerId: 'user_3',
      sellerName: 'Marcus Chen',
      sellerAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
      title: 'Ergonomic Mesh Office Chair',
      price: 240.00,
      category: 'Home',
      condition: 'Used - Good',
      location: 'Austin, TX',
      imageUrl: 'https://images.unsplash.com/photo-1580481072645-022f9a6d859b?w=800&auto=format&fit=crop&q=80',
      description: 'High-end lumbar support office chair. Super comfy for long sessions.',
      createdAt: '2 days ago',
    ),
  ];

  static final List<GroupModel> initialGroups = [
    GroupModel(
      id: 'grp_1',
      name: 'Flutter & Dart Developers Global',
      coverUrl: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=1200&auto=format&fit=crop&q=80',
      privacy: 'Public',
      memberCount: 14200,
      description: 'The primary community for Flutter cross-platform mobile app developers.',
      isJoined: true,
      rules: ['Be respectful', 'No spamming', 'Share clean code'],
    ),
    GroupModel(
      id: 'grp_2',
      name: 'UI/UX Glassmorphism & 3D Design',
      coverUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=1200&auto=format&fit=crop&q=80',
      privacy: 'Public',
      memberCount: 8900,
      description: 'Showcasing next-generation glassmorphic design systems.',
      isJoined: false,
    ),
  ];

  static final List<EventModel> initialEvents = [
    EventModel(
      id: 'evt_1',
      title: 'KC Tech Summit 2026: The Future of Social Networks',
      coverUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=1200&auto=format&fit=crop&q=80',
      date: 'Sept 25, 2026',
      time: '10:00 AM - 4:00 PM PST',
      location: 'Moscone Center, San Francisco, CA',
      description: 'Join industry pioneers as we demonstrate real-time social tech architectures.',
      organizerName: 'KC Tech Labs',
      rsvpStatus: 'Going',
      attendeesCount: 450,
    ),
  ];

  static final List<ReportItem> initialReports = [
    ReportItem(
      id: 'rep_1',
      reporterName: 'Emily Davis',
      targetType: 'post',
      targetId: 'post_99',
      reason: 'Spam / Unsolicited promotional link',
      status: 'pending',
      timestamp: '30m ago',
    ),
  ];

  static final List<AdminAuditLog> initialAuditLogs = [
    AdminAuditLog(
      id: 'log_1',
      adminId: 'user_1',
      adminName: 'Alex Johnson',
      action: 'promote_role',
      targetUserId: 'user_2',
      targetUserName: 'Sophia Martinez',
      timestamp: '1 hour ago',
      details: 'Promoted role from user to moderator',
    ),
  ];
}
