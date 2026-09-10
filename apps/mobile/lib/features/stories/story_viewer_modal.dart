import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/story_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/social_provider.dart';
import '../../providers/messenger_provider.dart';

class StoryViewerModal extends StatefulWidget {
  final Story story;

  const StoryViewerModal({super.key, required this.story});

  @override
  State<StoryViewerModal> createState() => _StoryViewerModalState();
}

class _StoryViewerModalState extends State<StoryViewerModal> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  final _replyController = TextEditingController();
  bool _showViewersDrawer = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward().then((_) {
        if (mounted && !_showViewersDrawer) {
          Navigator.pop(context);
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final social = context.read<SocialProvider>();
      final user = auth.currentUser!;
      social.recordStoryView(
        widget.story.id,
        StoryViewer(
          userId: user.id,
          userName: user.name,
          userAvatar: user.avatarUrl,
          viewedAt: 'Just now',
        ),
      );
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _sendStoryReaction(String emoji) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reacted $emoji to ${widget.story.authorName}\'s story!')),
    );
  }

  void _sendStoryReply() {
    if (_replyController.text.isEmpty) return;
    final messenger = context.read<MessengerProvider>();
    messenger.sendMessage('conv_1', 'Replied to story: ${_replyController.text}');
    _replyController.clear();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Story reply sent to Messenger!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final auth = context.watch<AuthProvider>();
    final isOwner = story.authorId == auth.currentUser?.id;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Story Content
            Center(
              child: story.imageUrl != null
                  ? Image.network(story.imageUrl!, fit: BoxFit.contain, width: double.infinity, height: double.infinity)
                  : Container(
                      padding: const EdgeInsets.all(32),
                      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                      alignment: Alignment.center,
                      child: Text(
                        story.textContent ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),

            // Top Overlay: Progress bar + Author info
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (ctx, child) {
                      return LinearProgressIndicator(
                        value: _progressController.value,
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                        minHeight: 3,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(radius: 20, backgroundImage: NetworkImage(story.authorAvatar)),
                      const SizedBox(width: 10),
                      Text(
                        story.authorName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Overlay: Quick Emoji Reactions & Reply Bar OR Viewers Drawer Button
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  if (isOwner) ...[
                    GestureDetector(
                      onTap: () {
                        setState(() => _showViewersDrawer = true);
                        _progressController.stop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.remove_red_eye, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Seen by ${story.viewers.length} people',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Quick Emoji Reactions Rail
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['❤️', '🔥', '😂', '😮', '👏'].map((emoji) {
                        return GestureDetector(
                          onTap: () => _sendStoryReaction(emoji),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                            child: Text(emoji, style: const TextStyle(fontSize: 24)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Reply Text Bar
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _replyController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Reply to ${story.authorName}...',
                              hintStyle: const TextStyle(color: Colors.white70),
                              fillColor: Colors.black54,
                              filled: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: AppColors.primary),
                          onPressed: _sendStoryReply,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Viewers List Drawer Sheet
            if (_showViewersDrawer)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.9),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Story Viewers (${story.viewers.length})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() => _showViewersDrawer = false);
                              _progressController.forward();
                            },
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24),
                      Expanded(
                        child: ListView.builder(
                          itemCount: story.viewers.length,
                          itemBuilder: (ctx, idx) {
                            final v = story.viewers[idx];
                            return ListTile(
                              leading: CircleAvatar(backgroundImage: NetworkImage(v.userAvatar)),
                              title: Text(v.userName, style: const TextStyle(color: Colors.white)),
                              subtitle: Text(v.viewedAt, style: const TextStyle(color: Colors.white54)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
