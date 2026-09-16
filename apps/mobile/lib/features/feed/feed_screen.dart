import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/mock_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/social_provider.dart';
import '../stories/story_tray.dart';
import '../friends/screens/friends_screen.dart';
import 'post_card.dart';
import 'post_composer.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  void _openComposer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PostComposer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final social = context.watch<SocialProvider>();
    final currentUser = auth.currentUser!;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Account Status Restriction Banner (Admin binding)
          if (currentUser.isSuspended || currentUser.isBanned)
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: AppColors.destructive,
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        currentUser.isBanned
                            ? 'ACCOUNT RESTRICTION NOTICE: Your account has been permanently banned by platform moderators.'
                            : 'ACCOUNT RESTRICTION NOTICE: Your account is currently suspended.',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Story Tray Component
          const SliverToBoxAdapter(
            child: StoryTray(),
          ),

          // Create Post Prompt Box (Facebook-style composer)
          SliverToBoxAdapter(
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _openComposer(context),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 20, backgroundImage: NetworkImage(currentUser.avatarUrl)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark ? AppColors.darkBackground : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                "What's on your mind, ${currentUser.name.split(' ').first}?",
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildComposerQuickBtn(
                          context,
                          icon: Icons.photo_library,
                          color: AppColors.success,
                          label: 'Photo',
                          onTap: () => _openComposer(context),
                        ),
                        _buildComposerQuickBtn(
                          context,
                          icon: Icons.videocam,
                          color: AppColors.destructive,
                          label: 'Video',
                          onTap: () => _openComposer(context),
                        ),
                        _buildComposerQuickBtn(
                          context,
                          icon: Icons.emoji_emotions,
                          color: AppColors.warning,
                          label: 'Feeling',
                          onTap: () => _openComposer(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Feed Category Filter Tabs (All Posts, Following, Latest, Friends)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabChip(context, 'All Feed', 'all', social.activeFeedTab),
                    _buildTabChip(context, 'Following', 'following', social.activeFeedTab),
                    _buildTabChip(context, 'Latest', 'latest', social.activeFeedTab),
                    _buildTabChip(context, 'Friends', 'friends', social.activeFeedTab),
                  ],
                ),
              ),
            ),
          ),

          // Posts List with Suggested People You May Know
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Insert "People You May Know" card after 2 posts
                if (index == 2) {
                  return Column(
                    children: [
                      _buildPeopleYouMayKnowSection(context),
                      if (index < social.posts.length) PostCard(post: social.posts[index]),
                    ],
                  );
                }
                return PostCard(post: social.posts[index]);
              },
              childCount: social.posts.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposerQuickBtn(BuildContext context, {required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(BuildContext context, String label, String tabKey, String activeTab) {
    final isActive = activeTab == tabKey;
    final social = context.read<SocialProvider>();

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isActive,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isActive ? Colors.white : null,
          fontWeight: FontWeight.bold,
        ),
        onSelected: (_) => social.setFeedTab(tabKey),
      ),
    );
  }

  Widget _buildPeopleYouMayKnowSection(BuildContext context) {
    final theme = Theme.of(context);
    final suggestions = MockData.users.where((u) => u.id != MockData.currentUser.id).toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('People You May Know', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FriendsScreen()));
                },
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              itemBuilder: (ctx, idx) {
                final user = suggestions[idx];
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? AppColors.darkBackground : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(radius: 28, backgroundImage: NetworkImage(user.avatarUrl)),
                      const SizedBox(height: 6),
                      Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('${user.mutualFriendsCount} mutuals', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 28,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Friend request sent to ${user.name}')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: const Text('Add Friend', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
