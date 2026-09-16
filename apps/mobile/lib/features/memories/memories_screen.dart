import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/story_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/social_provider.dart';

class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memories ("On This Day")', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.history_toggle_off, size: 72, color: AppColors.secondary),
              const SizedBox(height: 16),
              const Text('On This Day Throwbacks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 8),
              const Text(
                'Relive your favorite memories, posts, and photos from past years.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  final auth = context.read<AuthProvider>();
                  final social = context.read<SocialProvider>();
                  final user = auth.currentUser;
                  if (user != null) {
                    final memoryStory = Story(
                      id: 'story_mem_${DateTime.now().millisecondsSinceEpoch}',
                      authorId: user.id,
                      authorName: user.name,
                      authorAvatar: user.avatarUrl,
                      textContent: '✨ Shared a memory from 1 year ago today on KC App!',
                      createdAt: 'Just now',
                      expiresAt: '24 hours',
                    );
                    social.addStory(memoryStory);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Memory shared to your 24h Story! 📸')),
                    );
                  }
                },
                icon: const Icon(Icons.share),
                label: const Text('Share Memory to Story'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
