import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/safe_image.dart';
import '../../models/post_model.dart';
import '../../providers/social_provider.dart';
import '../../providers/auth_provider.dart';

class PostComposer extends StatefulWidget {
  const PostComposer({super.key});

  @override
  State<PostComposer> createState() => _PostComposerState();
}

class _PostComposerState extends State<PostComposer> {
  final _contentController = TextEditingController();
  String _privacy = 'public';
  String? _feeling;
  String? _location;
  String? _mediaUrl;
  
  // Poll creation fields
  bool _isCreatingPoll = false;
  final _pollQuestionController = TextEditingController();
  final List<TextEditingController> _pollOptionControllers = [
    TextEditingController(text: 'Option 1'),
    TextEditingController(text: 'Option 2'),
  ];

  void _submitPost() {
    if (_contentController.text.isEmpty && !_isCreatingPoll) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write some content for your post.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentUser!;
    final social = context.read<SocialProvider>();

    PollData? poll;
    if (_isCreatingPoll && _pollQuestionController.text.isNotEmpty) {
      poll = PollData(
        question: _pollQuestionController.text,
        options: _pollOptionControllers
            .where((c) => c.text.isNotEmpty)
            .map((c) => PollOption(
                  id: 'opt_${DateTime.now().microsecondsSinceEpoch}',
                  text: c.text,
                ))
            .toList(),
      );
    }

    final newPost = Post(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      authorId: currentUser.id,
      authorName: currentUser.name,
      authorUsername: currentUser.username,
      authorAvatar: currentUser.avatarUrl,
      isAuthorVerified: currentUser.isVerified,
      content: _contentController.text,
      mediaUrls: _mediaUrl != null ? [_mediaUrl!] : [],
      timestamp: 'Just now',
      privacy: _privacy,
      feeling: _feeling,
      locationCheckIn: _location,
      poll: poll,
    );

    social.addPost(newPost);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post published to KC App! 🎉')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Create Post',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              ElevatedButton(
                onPressed: _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Post'),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),

          // User Header & Privacy Picker
          Row(
            children: [
              SafeAvatar(radius: 22, imageUrl: user.avatarUrl, name: user.name),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: _privacy,
                      isDense: true,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: 'public', child: Text('🌐 Public', style: TextStyle(fontSize: 12, color: Colors.black))),
                        DropdownMenuItem(value: 'friends', child: Text('👥 Friends', style: TextStyle(fontSize: 12, color: Colors.black))),
                        DropdownMenuItem(value: 'only_me', child: Text('🔒 Only Me', style: TextStyle(fontSize: 12, color: Colors.black))),
                      ],
                      onChanged: (val) => setState(() => _privacy = val ?? 'public'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Composer Input
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _contentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      border: InputBorder.none,
                    ),
                  ),

                  // Media Preview
                  if (_mediaUrl != null)
                    Stack(
                      children: [
                        SafeNetworkImage(
                          imageUrl: _mediaUrl!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => setState(() => _mediaUrl = null),
                            ),
                          ),
                        ),
                      ],
                    ),

                  // Poll Creator Container
                  if (_isCreatingPoll) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _pollQuestionController,
                            decoration: const InputDecoration(hintText: 'Ask a poll question...'),
                          ),
                          const SizedBox(height: 12),
                          ..._pollOptionControllers.map((ctrl) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TextField(
                                controller: ctrl,
                                decoration: InputDecoration(
                                  hintText: 'Option',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            );
                          }),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _pollOptionControllers.add(TextEditingController());
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Option'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Toolbar Buttons (Photo, Poll, Feeling, Location)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.photo_library, color: AppColors.success),
                onPressed: () {
                  setState(() {
                    _mediaUrl = 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=1200&auto=format&fit=crop&q=80';
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.poll, color: AppColors.primary),
                onPressed: () => setState(() => _isCreatingPoll = !_isCreatingPoll),
              ),
              IconButton(
                icon: const Icon(Icons.sentiment_satisfied_alt, color: Colors.amber),
                onPressed: () => setState(() => _feeling = 'happy 😄'),
              ),
              IconButton(
                icon: const Icon(Icons.location_on, color: AppColors.destructive),
                onPressed: () => setState(() => _location = 'San Francisco, CA'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
