import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/post_model.dart';
import '../../providers/social_provider.dart';
import '../../providers/auth_provider.dart';

class CommentSheet extends StatefulWidget {
  final Post post;

  const CommentSheet({super.key, required this.post});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final _commentController = TextEditingController();

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;

    final auth = context.read<AuthProvider>();
    final user = auth.currentUser!;
    final social = context.read<SocialProvider>();

    final comment = Comment(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      postId: widget.post.id,
      authorId: user.id,
      authorName: user.name,
      authorAvatar: user.avatarUrl,
      content: _commentController.text,
      timestamp: 'Just now',
    );

    social.addComment(widget.post.id, comment);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Comments (${widget.post.comments.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(),

          // Comments List
          Expanded(
            child: widget.post.comments.isEmpty
                ? const Center(child: Text('No comments yet. Be the first to comment!'))
                : ListView.builder(
                    itemCount: widget.post.comments.length,
                    itemBuilder: (ctx, index) {
                      final comment = widget.post.comments[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(radius: 18, backgroundImage: NetworkImage(comment.authorAvatar)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.brightness == Brightness.dark ? AppColors.darkBackground : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(comment.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text(comment.content, style: const TextStyle(fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text(comment.timestamp, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Comment Input Box
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.primary),
                onPressed: _submitComment,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
