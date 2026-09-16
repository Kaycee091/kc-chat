import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/widgets/safe_image.dart';
import '../../profile/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeCategory = 'All';
  final List<String> _recentSearches = [
    'Flutter 3D Design',
    'Sophia Martinez',
    'MacBook Pro Marketplace',
    'KC Tech Summit',
  ];

  final List<String> _categories = [
    'All',
    'People',
    'Posts',
    'Groups',
    'Pages',
    'Videos',
    'Marketplace',
    'Events',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _searchController.text.trim().toLowerCase();

    final matchingUsers = MockData.users.where((u) => u.name.toLowerCase().contains(query)).toList();
    final matchingPosts = MockData.initialPosts.where((p) => p.content.toLowerCase().contains(query)).toList();
    final matchingGroups = MockData.initialGroups.where((g) => g.name.toLowerCase().contains(query)).toList();
    final matchingItems = MockData.initialMarketplaceItems.where((m) => m.title.toLowerCase().contains(query)).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: (val) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search Connecta...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = cat == _activeCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => setState(() => _activeCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // Search Body
          Expanded(
            child: query.isEmpty
                ? _buildRecentSearches(theme)
                : _buildSearchResults(
                    theme,
                    matchingUsers,
                    matchingPosts,
                    matchingGroups,
                    matchingItems,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Searches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton(
              onPressed: () {
                setState(() => _recentSearches.clear());
              },
              child: const Text('Clear All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._recentSearches.map(
          (s) => ListTile(
            leading: const Icon(Icons.history, color: Colors.grey),
            title: Text(s),
            trailing: const Icon(Icons.north_west, size: 16, color: Colors.grey),
            onTap: () {
              _searchController.text = s;
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(
    ThemeData theme,
    List matchingUsers,
    List matchingPosts,
    List matchingGroups,
    List matchingItems,
  ) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (_activeCategory == 'All' || _activeCategory == 'People') ...[
          if (matchingUsers.isNotEmpty) ...[
            const Text('People', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...matchingUsers.map((u) => ListTile(
                  leading: SafeAvatar(imageUrl: u.avatarUrl, name: u.name),
                  title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('@${u.username} • ${u.mutualFriendsCount} mutual friends'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProfileScreen(targetUser: u)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('View Profile'),
                  ),
                )),
            const SizedBox(height: 16),
          ],
        ],
        if (_activeCategory == 'All' || _activeCategory == 'Posts') ...[
          if (matchingPosts.isNotEmpty) ...[
            const Text('Posts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...matchingPosts.map((p) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: SafeAvatar(imageUrl: p.authorAvatar, name: p.authorName),
                    title: Text(p.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(p.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                )),
            const SizedBox(height: 16),
          ],
        ],
        if (_activeCategory == 'All' || _activeCategory == 'Groups') ...[
          if (matchingGroups.isNotEmpty) ...[
            const Text('Groups', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...matchingGroups.map((g) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: SafeAvatar(imageUrl: g.coverUrl, name: g.name),
                    title: Text(g.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${g.memberCount} members • ${g.privacy}'),
                  ),
                )),
            const SizedBox(height: 16),
          ],
        ],
        if (_activeCategory == 'All' || _activeCategory == 'Marketplace') ...[
          if (matchingItems.isNotEmpty) ...[
            const Text('Marketplace', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...matchingItems.map((m) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: SafeAvatar(imageUrl: m.imageUrl, name: m.title),
                    title: Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('\$${m.price.toStringAsFixed(0)} • ${m.location}'),
                  ),
                )),
          ],
        ],
      ],
    );
  }
}
