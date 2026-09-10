import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';
import '../models/marketplace_model.dart';
import '../models/social_models.dart';
import '../core/utils/mock_data.dart';

class SocialProvider with ChangeNotifier {
  List<Post> _posts = List.from(MockData.initialPosts);
  List<Story> _stories = List.from(MockData.initialStories);
  List<MarketplaceItem> _marketplaceItems = List.from(MockData.initialMarketplaceItems);
  List<GroupModel> _groups = List.from(MockData.initialGroups);
  List<EventModel> _events = List.from(MockData.initialEvents);
  
  String _activeFeedTab = 'all'; // 'all', 'following', 'latest', 'friends'
  String _searchQuery = '';
  String _selectedMarketplaceCategory = 'All';

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
  void addPost(Post newPost) {
    _posts.insert(0, newPost);
    notifyListeners();
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

  void toggleSavePost(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(isSaved: !post.isSaved);
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
  }

  void addComment(String postId, Comment comment) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final updatedComments = List<Comment>.from(_posts[index].comments)..add(comment);
      _posts[index] = _posts[index].copyWith(comments: updatedComments);
      notifyListeners();
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

  // --- Marketplace & Social Actions ---
  void addMarketplaceItem(MarketplaceItem item) {
    _marketplaceItems.insert(0, item);
    notifyListeners();
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
    }
  }

  void updateEventRSVP(String eventId, String status) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final e = _events[index];
      _events[index] = e.copyWith(rsvpStatus: status);
      notifyListeners();
    }
  }
}
