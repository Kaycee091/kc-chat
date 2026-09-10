import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/messenger_provider.dart';
import '../feed/feed_screen.dart';
import '../feed/post_composer.dart';
import '../friends/screens/friends_screen.dart';
import '../notifications/screens/notifications_screen.dart';
import '../search/screens/search_screen.dart';
import '../watch/watch_screen.dart';
import '../marketplace/marketplace_screen.dart';
import '../profile/profile_screen.dart';
import '../events/events_screen.dart';
import '../groups/groups_screen.dart';
import '../pages/pages_screen.dart';
import '../memories/memories_screen.dart';
import '../admin/admin_screen.dart';
import '../messenger/full_messenger_screen.dart';
import '../messenger/messenger_dock.dart';
import '../settings/settings_modal.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const SettingsModal(),
    );
  }

  void _openPostComposer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PostComposer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final messenger = context.watch<MessengerProvider>();
    final unreadMessagesCount = messenger.totalUnreadCount;

    final List<Widget> pages = [
      const FeedScreen(),
      const FriendsScreen(),
      const SizedBox.shrink(), // Index 2 triggers Create Post Modal
      const NotificationsScreen(),
      _buildMenuGrid(context),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hub_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'CONNECTA',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search Connecta',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                tooltip: 'Messenger',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FullMessengerScreen()));
                },
              ),
              if (unreadMessagesCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.destructive,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$unreadMessagesCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(
              themeProvider.themeModeOption == ThemeModeOption.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              final newMode = themeProvider.themeModeOption == ThemeModeOption.dark
                  ? ThemeModeOption.light
                  : ThemeModeOption.dark;
              themeProvider.setThemeMode(newMode);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex == 2 ? 0 : _currentIndex,
            children: pages,
          ),
          // Floating Docked Chat Heads Overlay
          const MessengerDock(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            _openPostComposer();
          } else {
            setState(() => _currentIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline_rounded, size: 28), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_rounded), label: 'Menu'),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser!;
    final isAdmin = user.role == 'admin' || user.role == 'super_admin';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Banner Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(radius: 26, backgroundImage: NetworkImage(user.avatarUrl)),
              title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: const Text('View your profile', style: TextStyle(color: Colors.grey)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
            ),
          ),
          const SizedBox(height: 20),

          const Text('Shortcuts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _buildMenuTile(context, 'Friends', Icons.people_rounded, AppColors.primary, () {
                setState(() => _currentIndex = 1);
              }),
              _buildMenuTile(context, 'Groups', Icons.groups_rounded, AppColors.secondary, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupsScreen()));
              }),
              _buildMenuTile(context, 'Pages', Icons.flag_rounded, Colors.orange, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PagesScreen()));
              }),
              _buildMenuTile(context, 'Events', Icons.event_rounded, Colors.pink, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EventsScreen()));
              }),
              _buildMenuTile(context, 'Marketplace', Icons.storefront_rounded, AppColors.success, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketplaceScreen()));
              }),
              _buildMenuTile(context, 'Watch Video', Icons.ondemand_video_rounded, Colors.red, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const WatchScreen()));
              }),
              _buildMenuTile(context, 'Memories', Icons.history_rounded, Colors.amber, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoriesScreen()));
              }),
              _buildMenuTile(context, 'Saved Items', Icons.bookmark_rounded, Colors.teal, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening Saved Items collection...')),
                );
              }),
              if (isAdmin)
                _buildMenuTile(context, 'Admin Console', Icons.admin_panel_settings_rounded, AppColors.destructive, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
                }),
              _buildMenuTile(context, 'Settings', Icons.settings_rounded, Colors.blueGrey, _openSettings),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => auth.signOut(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.destructive,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
