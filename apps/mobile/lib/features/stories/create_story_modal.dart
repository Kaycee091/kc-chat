import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/story_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/social_provider.dart';

class CreateStoryModal extends StatefulWidget {
  const CreateStoryModal({super.key});

  @override
  State<CreateStoryModal> createState() => _CreateStoryModalState();
}

class _CreateStoryModalState extends State<CreateStoryModal> {
  final _textController = TextEditingController();
  String? _imageUrl;
  bool _isTextStory = true;

  void _publishStory() {
    if (_isTextStory && _textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please type some text for your story.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final user = auth.currentUser!;
    final social = context.read<SocialProvider>();

    final story = Story(
      id: 'story_${DateTime.now().millisecondsSinceEpoch}',
      authorId: user.id,
      authorName: user.name,
      authorAvatar: user.avatarUrl,
      imageUrl: _imageUrl,
      textContent: _isTextStory ? _textController.text : null,
      createdAt: DateTime.now().toIso8601String(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    );

    social.addStory(story);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Story published! Expires in 24 hours. ✨')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Create 24h Story', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ElevatedButton(
                onPressed: _publishStory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Share to Story'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Text Story'),
                  selected: _isTextStory,
                  onSelected: (v) => setState(() => _isTextStory = true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Photo Story'),
                  selected: !_isTextStory,
                  onSelected: (v) {
                    setState(() {
                      _isTextStory = false;
                      _imageUrl = 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80';
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isTextStory
                ? Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _textController,
                      maxLines: 5,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: 'Type your story message...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(_imageUrl!, fit: BoxFit.cover, width: double.infinity),
                  ),
          ),
        ],
      ),
    );
  }
}
