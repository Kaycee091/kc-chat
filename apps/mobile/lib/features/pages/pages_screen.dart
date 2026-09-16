import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/safe_image.dart';

class PagesScreen extends StatefulWidget {
  const PagesScreen({super.key});

  @override
  State<PagesScreen> createState() => _PagesScreenState();
}

class _PagesScreenState extends State<PagesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';

  final List<_PageItem> _pages = [
    const _PageItem(
      id: 'p1',
      name: 'Flutter Dev Community',
      category: 'Technology',
      likes: 128400,
      avatarUrl: 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=400&auto=format&fit=crop&q=80',
      coverUrl: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&auto=format&fit=crop&q=80',
      isLiked: true,
    ),
    const _PageItem(
      id: 'p2',
      name: 'Global Foodies Network',
      category: 'Food & Beverage',
      likes: 342000,
      avatarUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&auto=format&fit=crop&q=80',
      coverUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&auto=format&fit=crop&q=80',
      isLiked: false,
    ),
    const _PageItem(
      id: 'p3',
      name: 'Travel & Adventure Club',
      category: 'Travel',
      likes: 890000,
      avatarUrl: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=400&auto=format&fit=crop&q=80',
      coverUrl: 'https://images.unsplash.com/photo-1500835556837-99ac94a94552?w=800&auto=format&fit=crop&q=80',
      isLiked: true,
    ),
    const _PageItem(
      id: 'p4',
      name: 'Fitness Warriors',
      category: 'Health & Fitness',
      likes: 215000,
      avatarUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400&auto=format&fit=crop&q=80',
      coverUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      isLiked: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatLikes(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(0)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pages', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Create Page',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create Page feature coming soon!')),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Discover'),
            Tab(text: 'Liked'),
            Tab(text: 'Your Pages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiscover(),
          _buildLiked(),
          _buildYourPages(),
        ],
      ),
    );
  }

  Widget _buildDiscover() {
    final filteredPages = _selectedCategory == 'All'
        ? _pages
        : _pages.where((p) => p.category.toLowerCase().contains(_selectedCategory.toLowerCase())).toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Categories Row
        const Text('Browse Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              'All', 'Technology', 'Travel', 'Food & Beverage', 'Health & Fitness', 'Music', 'Sports', 'Art',
            ].map((c) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(c),
                selected: c == _selectedCategory,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: c == _selectedCategory ? Colors.white : null,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedCategory = c);
                  }
                },
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Suggested Pages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        if (filteredPages.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No pages found in this category.', style: TextStyle(color: Colors.grey))),
          )
        else
          ...filteredPages.map((page) => _buildPageCard(page)),
      ],
    );
  }

  Widget _buildLiked() {
    final liked = _pages.where((p) => p.isLiked).toList();
    if (liked.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.thumb_up_alt_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No liked pages yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: liked.map((page) => _buildPageCard(page)).toList(),
    );
  }

  Widget _buildYourPages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.flag_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          const Text("You haven't created any pages yet", style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create Page feature coming soon!')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create a Page'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageCard(_PageItem page) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image
          SafeNetworkImage(
            imageUrl: page.coverUrl,
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
                  ),
                  child: SafeAvatar(
                    radius: 24,
                    imageUrl: page.avatarUrl,
                    name: page.name,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(page.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(page.category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      Text('${_formatLikes(page.likes)} likes', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      final idx = _pages.indexWhere((p) => p.id == page.id);
                      if (idx != -1) {
                        _pages[idx] = _pages[idx].copyWith(isLiked: !_pages[idx].isLiked);
                      }
                    });
                  },
                  icon: Icon(page.isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined, size: 16),
                  label: Text(page.isLiked ? 'Liked' : 'Like'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: page.isLiked ? AppColors.primary : Colors.grey.shade200,
                    foregroundColor: page.isLiked ? Colors.white : Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageItem {
  final String id;
  final String name;
  final String category;
  final int likes;
  final String avatarUrl;
  final String coverUrl;
  final bool isLiked;

  const _PageItem({
    required this.id,
    required this.name,
    required this.category,
    required this.likes,
    required this.avatarUrl,
    required this.coverUrl,
    required this.isLiked,
  });

  _PageItem copyWith({bool? isLiked}) => _PageItem(
        id: id,
        name: name,
        category: category,
        likes: likes,
        avatarUrl: avatarUrl,
        coverUrl: coverUrl,
        isLiked: isLiked ?? this.isLiked,
      );
}
