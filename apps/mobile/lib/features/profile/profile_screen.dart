import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/social_provider.dart';
import '../../providers/messenger_provider.dart';
import '../feed/post_card.dart';
import 'edit_profile_modal.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile? targetUser;

  const ProfileScreen({super.key, this.targetUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  void _openEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const EditProfileModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = widget.targetUser ?? auth.currentUser!;
    final isMe = user.id == auth.currentUser?.id;
    final social = context.watch<SocialProvider>();
    final messenger = context.read<MessengerProvider>();

    final userPosts = social.posts.where((p) => p.authorId == user.id).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Cover & Avatar Header
          SliverToBoxAdapter(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomLeft,
                  children: [
                    // Cover Photo
                    Image.network(
                      user.coverUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),

                    // Profile Picture Avatar
                    Positioned(
                      bottom: -40,
                      left: 20,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 4),
                            ),
                            child: CircleAvatar(
                              radius: 46,
                              backgroundImage: NetworkImage(user.avatarUrl),
                            ),
                          ),
                          if (isMe)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.primary,
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                                  onPressed: _openEditProfile,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Name & Verified Badge
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                          if (user.isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: AppColors.primary, size: 20),
                          ],
                        ],
                      ),
                      Text('@${user.username}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(user.bio, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 12),

                      // Metadata Info
                      if (user.work.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.work_outline, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(user.work, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                            ],
                          ),
                        ),
                      if (user.location.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(user.location, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Social Counters (Friends, Followers, Following)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn('Friends', '${user.friendIds.length}'),
                          _buildStatColumn('Followers', '${user.followerIds.length}'),
                          _buildStatColumn('Following', '${user.followingIds.length}'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Action Buttons
                      if (isMe)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _openEditProfile,
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit Profile'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        )
                      else ...[
                        Builder(
                          builder: (context) {
                            final isFriend = auth.currentUser?.friendIds.contains(user.id) ?? false;
                            final isRequested = social.sentFriendRequestUserIds.contains(user.id);

                            return Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: isFriend || isRequested
                                        ? null
                                        : () {
                                            social.sendFriendRequest(user.id, auth);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Friend request sent to ${user.name}!')),
                                            );
                                          },
                                    icon: Icon(isFriend ? Icons.check : (isRequested ? Icons.hourglass_top : Icons.person_add)),
                                    label: Text(isFriend ? 'Friends' : (isRequested ? 'Request Sent' : 'Add Friend')),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isFriend || isRequested ? Colors.grey : AppColors.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => messenger.openConversationWithUser(user.id, user.name, user.avatarUrl),
                                    icon: const Icon(Icons.chat_bubble_outline),
                                    label: const Text('Message'),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Profile Tabs (Posts, Photos, Videos, Friends, Mutual, Tagged, About)
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppColors.primary,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Posts'),
                    Tab(text: 'Photos'),
                    Tab(text: 'Videos'),
                    Tab(text: 'Friends'),
                    Tab(text: 'Mutual Friends'),
                    Tab(text: 'Tagged'),
                    Tab(text: 'About'),
                  ],
                ),
              ],
            ),
          ),

          // User Posts Stream
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return PostCard(post: userPosts[index]);
              },
              childCount: userPosts.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
