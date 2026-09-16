import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/social_provider.dart';
import '../../feed/post_card.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Posts', 'Videos', 'Marketplace'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final social = context.watch<SocialProvider>();
    final savedPosts = social.posts.where((p) => p.isSaved).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Items', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Saved
          _buildPostsList(savedPosts),
          // Posts
          _buildPostsList(savedPosts),
          // Videos
          _buildEmptyCategory('No saved videos yet.'),
          // Marketplace
          _buildEmptyCategory('No saved marketplace items yet.'),
        ],
      ),
    );
  }

  Widget _buildPostsList(List savedPosts) {
    if (savedPosts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmark_border_rounded, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No saved items yet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Tap the bookmark icon in the more options menu of any post to save it for later.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: savedPosts.length,
      itemBuilder: (context, index) {
        return PostCard(post: savedPosts[index]);
      },
    );
  }

  Widget _buildEmptyCategory(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bookmark_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
