import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';
import '../models/marketplace_model.dart';
import '../models/social_models.dart';
import '../core/utils/mock_data.dart';
import '../core/network/api_client.dart';
import '../core/storage/storage_service.dart';
import 'auth_provider.dart';

class SocialProvider with ChangeNotifier {
  final ApiClient _apiClient;
  final StorageService _storageService;

  final List<Post> _posts = List.from(MockData.initialPosts);
  final List<Story> _stories = List.from(MockData.initialStories);
  final List<MarketplaceItem> _marketplaceItems = List.from(MockData.initialMarketplaceItems);
  final List<GroupModel> _groups = List.from(MockData.initialGroups);
  final List<EventModel> _events = List.from(MockData.initialEvents);
  final Set<String> _sentFriendRequestUserIds = {};
  
  String _activeFeedTab = 'all'; // 'all', 'following', 'latest', 'friends'
  String _searchQuery = '';
  String _selectedMarketplaceCategory = 'All';

  SocialProvider({ApiClient? apiClient, StorageService? storageService})
      : _apiClient = apiClient ?? ApiClient(),
        _storageService = storageService ?? StorageService();

  List<Post> get posts {
    List<Post> filtered = List.from(_posts);
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) =>
        p.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.authorName.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    if (_activeFeedTab == 'following') {
      filtered = filtered.where((p) => p.authorId == 'user_2' || p.authorId == 'user_3').toList();
    } else if (_activeFeedTab == 'friends') {
      filtered = filtered.where((p) => p.authorId != 'user_1').toList();
    }
    return filtered;
  }

  List<Story> get activeStories => _stories.where((s) => !s.isExpired).toList();
  List<MarketplaceItem> get marketplaceItems {
    if (_selectedMarketplaceCategory == 'All') return _marketplaceItems;
    return _marketplaceItems.where((item) => item.category == _selectedMarketplaceCategory).toList();
  }
  List<GroupModel> get groups => _groups;
  List<EventModel> get events => _events;
  String get activeFeedTab => _activeFeedTab;
  String get searchQuery => _searchQuery;
  Set<String> get sentFriendRequestUserIds => _sentFriendRequestUserIds;
  bool isFriendRequestSent(String userId) => _sentFriendRequestUserIds.contains(userId);
  List<Post> get savedPosts => _posts.where((p) => p.isSaved).toList();
  bool isPostSaved(String postId) => _posts.any((p) => p.id == postId && p.isSaved);

  void setFeedTab(String tab) {
    _activeFeedTab = tab;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setMarketplaceCategory(String category) {
    _selectedMarketplaceCategory = category;
    notifyListeners();
  }

  // --- Post Creation & Controls ---
  Future<void> addPost(Post newPost) async {
    _posts.insert(0, newPost);
    notifyListeners();

    // Async sync with Django API
    try {
      await _apiClient.post('posts/', body: {
        'content': newPost.content,
        'privacy': newPost.privacy,
        'feeling': newPost.feeling,
        'location': newPost.locationCheckIn,
        'media_urls': newPost.mediaUrls,
      });
    } catch (_) {}
  }

  void votePoll(String postId, String optionId, String userId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1 && _posts[index].poll != null) {
      final poll = _posts[index].poll!;
      final updatedOptions = poll.options.map((opt) {
        if (opt.id == optionId) {
          final newVoters = List<String>.from(opt.voterIds);
          if (!newVoters.contains(userId)) newVoters.add(userId);
          return opt.copyWith(voteCount: opt.voteCount + 1, voterIds: newVoters);
        }
        return opt;
      }).toList();
      final updatedPoll = poll.copyWith(options: updatedOptions, totalVotes: poll.totalVotes + 1);
      _posts[index] = _posts[index].copyWith(poll: updatedPoll);
      notifyListeners();

      try {
        _apiClient.post('posts/$postId/poll/vote/', body: {'option_id': optionId});
      } catch (_) {}
    }
  }

  void toggleReaction(String postId, String reactionType) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final currentReaction = post.userReaction;
      final newCounts = Map<String, int>.from(post.reactionCounts);

      if (currentReaction == reactionType) {
        // Remove reaction
        newCounts[reactionType] = (newCounts[reactionType] ?? 1) - 1;
        _posts[index] = post.copyWith(userReaction: null, reactionCounts: newCounts);
      } else {
        // Change or add reaction
        if (currentReaction != null) {
          newCounts[currentReaction] = (newCounts[currentReaction] ?? 1) - 1;
        }
        newCounts[reactionType] = (newCounts[reactionType] ?? 0) + 1;
        _posts[index] = post.copyWith(userReaction: reactionType, reactionCounts: newCounts);
      }
      notifyListeners();

      try {
        _apiClient.post('reactions/', body: {'post_id': postId, 'reaction_type': reactionType});
      } catch (_) {}
    }
  }

  void togglePinPost(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(isPinned: !post.isPinned);
      notifyListeners();
    }
  }

  Future<void> toggleSavePost(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final newSaved = !post.isSaved;
      _posts[index] = post.copyWith(isSaved: newSaved);
      if (newSaved) {
        await _storageService.savePostId(postId);
      } else {
        await _storageService.removeSavedPostId(postId);
      }
      notifyListeners();
    }
  }

  void toggleComments(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(isCommentsDisabled: !post.isCommentsDisabled);
      notifyListeners();
    }
  }

  void deletePost(String postId) {
    _posts.removeWhere((p) => p.id == postId);
    notifyListeners();
    try {
      _apiClient.delete('posts/$postId/');
    } catch (_) {}
  }

  void addComment(String postId, Comment comment) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final updatedComments = List<Comment>.from(_posts[index].comments)..add(comment);
      _posts[index] = _posts[index].copyWith(comments: updatedComments);
      notifyListeners();

      try {
        _apiClient.post('comments/', body: {
          'post_id': postId,
          'content': comment.content,
        });
      } catch (_) {}
    }
  }

  void sharePost(Post originalPost, String authorName, String authorAvatar) {
    final sharedPost = Post(
      id: 'shared_${DateTime.now().millisecondsSinceEpoch}',
      authorId: 'user_1',
      authorName: authorName,
      authorUsername: 'alexj',
      authorAvatar: authorAvatar,
      content: 'Shared this post:',
      timestamp: 'Just now',
      originalPost: originalPost,
    );
    _posts.insert(0, sharedPost);
    notifyListeners();
  }

  // --- Story Actions ---
  void addStory(Story story) {
    _stories.insert(0, story);
    notifyListeners();
    try {
      _apiClient.post('stories/', body: {
        'image_url': story.imageUrl,
        'text_content': story.textContent,
      });
    } catch (_) {}
  }

  void recordStoryView(String storyId, StoryViewer viewer) {
    final index = _stories.indexWhere((s) => s.id == storyId);
    if (index != -1) {
      final currentViewers = List<StoryViewer>.from(_stories[index].viewers);
      if (!currentViewers.any((v) => v.userId == viewer.userId)) {
        currentViewers.add(viewer);
        _stories[index] = Story(
          id: _stories[index].id,
          authorId: _stories[index].authorId,
          authorName: _stories[index].authorName,
          authorAvatar: _stories[index].authorAvatar,
          imageUrl: _stories[index].imageUrl,
          textContent: _stories[index].textContent,
          backgroundGradient: _stories[index].backgroundGradient,
          createdAt: _stories[index].createdAt,
          expiresAt: _stories[index].expiresAt,
          viewers: currentViewers,
          isSeen: true,
        );
        notifyListeners();
      }
    }
  }

  // --- Friend Actions ---
  void sendFriendRequest(String targetUserId, AuthProvider auth) {
    _sentFriendRequestUserIds.add(targetUserId);
    notifyListeners();

    try {
      _apiClient.post('friends/request/', body: {'target_user_id': targetUserId});
    } catch (_) {}
  }

  void acceptFriendRequest(String fromUserId, AuthProvider auth) {
    if (auth.currentUser != null) {
      final updatedFriendIds = List<String>.from(auth.currentUser!.friendIds);
      if (!updatedFriendIds.contains(fromUserId)) {
        updatedFriendIds.add(fromUserId);
        auth.updateProfile(auth.currentUser!.copyWith(friendIds: updatedFriendIds));
      }
    }
    notifyListeners();

    try {
      _apiClient.post('friends/accept/', body: {'user_id': fromUserId});
    } catch (_) {}
  }

  void removeFriend(String friendId, AuthProvider auth) {
    if (auth.currentUser != null) {
      final updatedFriendIds = List<String>.from(auth.currentUser!.friendIds)..remove(friendId);
      auth.updateProfile(auth.currentUser!.copyWith(friendIds: updatedFriendIds));
    }
    notifyListeners();

    try {
      _apiClient.post('friends/remove/', body: {'user_id': friendId});
    } catch (_) {}
  }

  // --- Marketplace & Social Actions ---
  void addMarketplaceItem(MarketplaceItem item) {
    _marketplaceItems.insert(0, item);
    notifyListeners();
    try {
      _apiClient.post('marketplace/', body: {
        'title': item.title,
        'price': item.price,
        'category': item.category,
        'description': item.description,
        'image_url': item.imageUrl,
      });
    } catch (_) {}
  }

  void toggleGroupMembership(String groupId) {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      final g = _groups[index];
      _groups[index] = g.copyWith(
        isJoined: !g.isJoined,
        memberCount: g.isJoined ? g.memberCount - 1 : g.memberCount + 1,
      );
      notifyListeners();
      try {
        _apiClient.post('groups/$groupId/membership/');
      } catch (_) {}
    }
  }

  void updateEventRSVP(String eventId, String status) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final e = _events[index];
      _events[index] = e.copyWith(rsvpStatus: status);
      notifyListeners();
      try {
        _apiClient.post('events/$eventId/rsvp/', body: {'status': status});
      } catch (_) {}
    }
  }
}
