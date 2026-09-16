import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/safe_image.dart';
import '../../models/post_model.dart';
import '../../providers/social_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import 'comment_sheet.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _showReactionPicker = false;

  final Map<String, String> _reactionEmojis = {
    'like': '👍',
    'love': '❤️',
    'care': '🥰',
    'haha': '😂',
    'wow': '😮',
    'sad': '😢',
    'angry': '😡',
  };

  void _showCommentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CommentSheet(post: widget.post),
    );
  }

  void _showPostMenu() {
    final social = context.read<SocialProvider>();
    final auth = context.read<AuthProvider>();
    final isOwner = widget.post.authorId == auth.currentUser?.id;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(widget.post.isPinned ? Icons.push_pin_outlined : Icons.push_pin, color: AppColors.primary),
              title: Text(widget.post.isPinned ? 'Unpin from Profile' : 'Pin to Profile'),
              onTap: () {
                Navigator.pop(ctx);
                social.togglePinPost(widget.post.id);
              },
            ),
            ListTile(
              leading: Icon(widget.post.isSaved ? Icons.bookmark_remove : Icons.bookmark_add_outlined, color: AppColors.secondary),
              title: Text(widget.post.isSaved ? 'Remove from Saved' : 'Save Post'),
              onTap: () {
                Navigator.pop(ctx);
                social.toggleSavePost(widget.post.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(widget.post.isSaved ? 'Removed from saved items' : 'Post saved successfully!')),
                );
              },
            ),
            ListTile(
              leading: Icon(widget.post.isCommentsDisabled ? Icons.comment : Icons.comments_disabled_outlined, color: Colors.amber),
              title: Text(widget.post.isCommentsDisabled ? 'Turn Comments On' : 'Turn Comments Off'),
              onTap: () {
                Navigator.pop(ctx);
                social.toggleComments(widget.post.id);
              },
            ),
            if (isOwner)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.destructive),
                title: const Text('Delete Post', style: TextStyle(color: AppColors.destructive)),
                onTap: () {
                  Navigator.pop(ctx);
                  social.deletePost(widget.post.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post deleted.')),
                  );
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: AppColors.destructive),
                title: const Text('Report Post'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<AdminProvider>().reportPost(
                    postId: widget.post.id,
                    reason: 'Inappropriate content',
                    reporterName: auth.currentUser?.name ?? 'User',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report submitted to KC App moderation team.')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _build7EmojiReactionPicker() {
    final social = context.read<SocialProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _reactionEmojis.entries.map((entry) {
          return GestureDetector(
            onTap: () {
              social.toggleReaction(widget.post.id, entry.key);
              setState(() => _showReactionPicker = false);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(entry.value, style: const TextStyle(fontSize: 26)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPollWidget(PollData poll) {
    final auth = context.read<AuthProvider>();
    final social = context.read<SocialProvider>();
    final currentUserId = auth.currentUser?.id ?? '';

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBackground : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.poll_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  poll.question,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...poll.options.map((opt) {
            final percentage = poll.totalVotes > 0 ? (opt.voteCount / poll.totalVotes) : 0.0;
            final isVoted = opt.voterIds.contains(currentUserId);

            return GestureDetector(
              onTap: () => social.votePoll(widget.post.id, opt.id, currentUserId),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Stack(
                  children: [
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isVoted ? AppColors.primary : Colors.grey.shade300,
                          width: isVoted ? 2 : 1,
                        ),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage > 0 ? percentage : 0.001,
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: isVoted ? AppColors.primary.withValues(alpha: 0.25) : AppColors.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              opt.text,
                              style: TextStyle(
                                fontWeight: isVoted ? FontWeight.bold : FontWeight.normal,
                                color: isVoted ? AppColors.primary : null,
                              ),
                            ),
                            Text(
                              '${(percentage * 100).toStringAsFixed(0)}% (${opt.voteCount})',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          Text(
            '${poll.totalVotes} votes in total',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final post = widget.post;
    final social = context.read<SocialProvider>();

    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pinned Header
                if (post.isPinned) ...[
                  Row(
                    children: [
                      const Icon(Icons.push_pin, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Pinned Post',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Post Header: Avatar, Name, Time, Menu
                Row(
                  children: [
                    SafeAvatar(
                      radius: 22,
                      imageUrl: post.authorAvatar,
                      name: post.authorName,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                post.authorName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              if (post.isAuthorVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, size: 16, color: AppColors.primary),
                              ],
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                post.timestamp,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              if (post.feeling != null) ...[
                                Text(' • feeling ${post.feeling}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                              const SizedBox(width: 4),
                              Icon(
                                post.privacy == 'public' ? Icons.public : Icons.people_outline,
                                size: 12,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: _showPostMenu,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Post Content
                Text(
                  post.content,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),

                // Media Gallery / Grid
                if (post.mediaUrls.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SafeNetworkImage(
                    imageUrl: post.mediaUrls.first,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ],

                // Poll Card
                if (post.poll != null) _buildPollWidget(post.poll!),

                // Shared Post Attachment Card
                if (post.originalPost != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark ? AppColors.darkBackground : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SafeAvatar(radius: 14, imageUrl: post.originalPost!.authorAvatar, name: post.originalPost!.authorName),
                            const SizedBox(width: 8),
                            Text(post.originalPost!.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(post.originalPost!.content, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(),

                // Reaction Counts & Comments Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (post.totalReactions > 0)
                      Row(
                        children: [
                          Text(_reactionEmojis[post.userReaction ?? 'like'] ?? '👍', style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text('${post.totalReactions}', style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                    Row(
                      children: [
                        Text('${post.comments.length} comments', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                        const SizedBox(width: 8),
                        Text('${post.sharesCount} shares', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Action Bar (Like, Comment, Share)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onLongPress: () => setState(() => _showReactionPicker = !_showReactionPicker),
                        onTap: () => social.toggleReaction(post.id, 'like'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _reactionEmojis[post.userReaction] ?? '👍',
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                post.userReaction != null ? post.userReaction!.toUpperCase() : 'Like',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: post.userReaction != null ? AppColors.primary : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: post.isCommentsDisabled ? null : _showCommentSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 20),
                              SizedBox(width: 6),
                              Text('Comment', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          final auth = context.read<AuthProvider>();
                          social.sharePost(post, auth.currentUser?.name ?? 'User', auth.currentUser?.avatarUrl ?? '');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Post shared to your profile timeline!')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.share_outlined, size: 20),
                              SizedBox(width: 6),
                              Text('Share', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Reaction Picker Hover Overlay
        if (_showReactionPicker)
          Positioned(
            left: 20,
            bottom: 60,
            child: _build7EmojiReactionPicker(),
          ),
      ],
    );
  }
}
