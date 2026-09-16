import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/safe_image.dart';
import '../../models/story_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/social_provider.dart';
import 'create_story_modal.dart';
import 'story_viewer_modal.dart';

class StoryTray extends StatelessWidget {
  const StoryTray({super.key});

  void _openCreateStory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CreateStoryModal(),
    );
  }

  void _openStoryViewer(BuildContext context, Story story) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (ctx) => StoryViewerModal(story: story),
    );
  }

  @override
  Widget build(BuildContext context) {
    final social = context.watch<SocialProvider>();
    final auth = context.watch<AuthProvider>();
    final currentUser = auth.currentUser!;

    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: social.activeStories.length + 1,
        itemBuilder: (ctx, index) {
          if (index == 0) {
            // Add Story Card
            return GestureDetector(
              onTap: () => _openCreateStory(context),
              child: Container(
                width: 110,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Stack(
                  children: [
                    SafeNetworkImage(
                      imageUrl: currentUser.avatarUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    const Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                          SizedBox(height: 4),
                          Text('Add Story', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final story = social.activeStories[index - 1];
          return GestureDetector(
            onTap: () => _openStoryViewer(context, story),
            child: Container(
              width: 110,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: AppColors.storyGradient,
              ),
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.black,
                ),
                child: Stack(
                  children: [
                    if (story.imageUrl != null)
                      SafeNetworkImage(
                        imageUrl: story.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: BorderRadius.circular(18),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: AppColors.primaryGradient,
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          story.textContent ?? '',
                          maxLines: 4,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: SafeAvatar(
                        radius: 16,
                        imageUrl: story.authorAvatar,
                        name: story.authorName,
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        story.authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
