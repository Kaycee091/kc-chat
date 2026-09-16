import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/safe_image.dart';

class WatchScreen extends StatefulWidget {
  const WatchScreen({super.key});

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  String _selectedCategory = 'Trending';
  final Set<int> _followedCreators = {};
  final Set<int> _playingVideos = {};

  final List<String> _categories = ['Trending', 'Gaming', 'Tech', 'Entertainment', 'Shorts/Reels'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KC Watch', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Categories Rail
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : null),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),

          // Video Feed
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: 2,
              itemBuilder: (ctx, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video Player Container
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_playingVideos.contains(index)) {
                              _playingVideos.remove(index);
                            } else {
                              _playingVideos.add(index);
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_playingVideos.contains(index) ? 'Streaming video #${index + 1}...' : 'Paused video')),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const SafeNetworkImage(
                              imageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=1200&auto=format&fit=crop&q=80',
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.black.withValues(alpha: 0.6),
                              child: Icon(
                                _playingVideos.contains(index) ? Icons.pause : Icons.play_arrow,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              index == 0 ? 'Building Flutter Apps with 3D Glassmorphism' : 'Top 10 Mobile UI Trends 2026',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            const Text('142K views • 2 days ago', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    SafeAvatar(
                                      radius: 14,
                                      imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
                                      name: 'KC Tech Media',
                                    ),
                                    SizedBox(width: 8),
                                    Text('KC Tech Media', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    final isFollowed = _followedCreators.contains(index);
                                    setState(() {
                                      if (isFollowed) {
                                        _followedCreators.remove(index);
                                      } else {
                                        _followedCreators.add(index);
                                      }
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(isFollowed ? 'Unfollowed KC Tech Media' : 'Following KC Tech Media!')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _followedCreators.contains(index) ? Colors.grey.shade400 : AppColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(_followedCreators.contains(index) ? 'Following' : 'Follow Creator'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
