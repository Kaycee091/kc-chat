import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/mock_data.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/social_provider.dart';
import '../../../providers/messenger_provider.dart';
import '../../profile/profile_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<UserProfile> _friendRequests = [
    UserProfile(
      id: 'req_1',
      name: 'David Miller',
      username: 'davidm',
      email: '',
      coverUrl: '',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&auto=format&fit=crop&q=80',
      mutualFriendsCount: 14,
    ),
    UserProfile(
      id: 'req_2',
      name: 'Jessica Taylor',
      username: 'jessicat',
      email: '',
      coverUrl: '',
      avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&auto=format&fit=crop&q=80',
      mutualFriendsCount: 6,
    ),
  ];

  final List<UserProfile> _suggestions = [
    UserProfile(
      id: 'sug_1',
      name: 'Michael Brown',
      username: 'michaelb',
      email: '',
      coverUrl: '',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&auto=format&fit=crop&q=80',
      mutualFriendsCount: 12,
    ),
    UserProfile(
      id: 'sug_2',
      name: 'Emma Watson',
      username: 'emmaw',
      email: '',
      coverUrl: '',
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&auto=format&fit=crop&q=80',
      mutualFriendsCount: 9,
    ),
    UserProfile(
      id: 'sug_3',
      name: 'Daniel Craig',
      username: 'danielc',
      email: '',
      coverUrl: '',
      avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&auto=format&fit=crop&q=80',
      mutualFriendsCount: 3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _confirmRequest(UserProfile user) {
    setState(() {
      _friendRequests.removeWhere((r) => r.id == user.id);
    });
    context.read<SocialProvider>().acceptFriendRequest(user.id, context.read<AuthProvider>());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Accepted friend request from ${user.name}')),
    );
  }

  void _deleteRequest(UserProfile user) {
    setState(() {
      _friendRequests.removeWhere((r) => r.id == user.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed friend request from ${user.name}')),
    );
  }

  void _addFriendSuggestion(UserProfile user) {
    setState(() {
      _suggestions.removeWhere((s) => s.id == user.id);
    });
    context.read<SocialProvider>().sendFriendRequest(user.id, context.read<AuthProvider>());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Friend request sent to ${user.name}')),
    );
  }

  void _removeSuggestion(UserProfile user) {
    setState(() {
      _suggestions.removeWhere((s) => s.id == user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allFriends = MockData.users.where((u) => u.id != MockData.currentUser.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Requests'),
            Tab(text: 'Suggestions'),
            Tab(text: 'All Friends'),
            Tab(text: 'Birthdays'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Friend Requests Tab
          _buildRequestsTab(theme),

          // 2. Suggestions Tab
          _buildSuggestionsTab(theme),

          // 3. All Friends Tab
          _buildAllFriendsTab(theme, allFriends),

          // 4. Birthdays Tab
          _buildBirthdaysTab(theme),
        ],
      ),
    );
  }

  Widget _buildRequestsTab(ThemeData theme) {
    if (_friendRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No pending friend requests', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _friendRequests.length,
      itemBuilder: (context, index) {
        final req = _friendRequests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(req.avatarUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(req.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${req.mutualFriendsCount} mutual friends', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _confirmRequest(req),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _deleteRequest(req),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Delete'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestionsTab(ThemeData theme) {
    if (_suggestions.isEmpty) {
      return const Center(
        child: Text('No suggestions available', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final sug = _suggestions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(sug.avatarUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sug.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${sug.mutualFriendsCount} mutual friends', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _addFriendSuggestion(sug),
                              icon: const Icon(Icons.person_add, size: 16),
                              label: const Text('Add Friend'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => _removeSuggestion(sug),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllFriendsTab(ThemeData theme, List<UserProfile> friends) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(friend.avatarUrl),
            ),
            title: Text(friend.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('@${friend.username} • ${friend.mutualFriendsCount} mutuals'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(targetUser: friend)));
            },
            trailing: IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (ctx) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                          title: const Text('Send Message'),
                          onTap: () {
                            Navigator.pop(ctx);
                            context.read<MessengerProvider>().openConversationWithUser(
                              friend.id,
                              friend.name,
                              friend.avatarUrl,
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: const Text('View Profile'),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(targetUser: friend)));
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.person_remove_outlined, color: AppColors.destructive),
                          title: const Text('Remove Friend', style: TextStyle(color: AppColors.destructive)),
                          onTap: () {
                            Navigator.pop(ctx);
                            context.read<SocialProvider>().removeFriend(friend.id, context.read<AuthProvider>());
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Removed ${friend.name} from friends.')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBirthdaysTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: AppColors.secondary.withValues(alpha: 0.1),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.cake, color: AppColors.secondary, size: 36),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Today\'s Birthdays 🎉', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Sophia Martinez turns 24 today! Wish her a happy birthday.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
