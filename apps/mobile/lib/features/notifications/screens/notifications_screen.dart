import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class NotificationModel {
  final String id;
  final String userAvatar;
  final String title;
  final String body;
  final String timestamp;
  final String iconType; // 'like', 'comment', 'friend', 'group', 'event'
  final bool isUnread;

  NotificationModel({
    required this.id,
    required this.userAvatar,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.iconType,
    this.isUnread = true,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: 'n1',
      userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80',
      title: 'Sophia Martinez',
      body: 'loved your post: "Excited to announce the official launch..."',
      timestamp: '5m ago',
      iconType: 'like',
      isUnread: true,
    ),
    NotificationModel(
      id: 'n2',
      userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
      title: 'Marcus Chen',
      body: 'commented on your photo: "The glassmorphic design looks incredible!"',
      timestamp: '32m ago',
      iconType: 'comment',
      isUnread: true,
    ),
    NotificationModel(
      id: 'n3',
      userAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&auto=format&fit=crop&q=80',
      title: 'David Miller',
      body: 'sent you a friend request.',
      timestamp: '2h ago',
      iconType: 'friend',
      isUnread: false,
    ),
    NotificationModel(
      id: 'n4',
      userAvatar: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=1200&auto=format&fit=crop&q=80',
      title: 'Flutter Developers Global',
      body: 'Marcus Chen posted a new update in the group.',
      timestamp: '5h ago',
      iconType: 'group',
      isUnread: false,
    ),
  ];

  IconData _getIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.chat_bubble;
      case 'friend':
        return Icons.person_add;
      case 'group':
        return Icons.groups;
      case 'event':
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'like':
        return AppColors.destructive;
      case 'comment':
        return AppColors.primary;
      case 'friend':
        return AppColors.secondary;
      case 'group':
        return AppColors.success;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unread = _notifications.where((n) => n.isUnread).toList();
    final earlier = _notifications.where((n) => !n.isUnread).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {
              setState(() {
                for (var i = 0; i < _notifications.length; i++) {
                  _notifications[i] = NotificationModel(
                    id: _notifications[i].id,
                    userAvatar: _notifications[i].userAvatar,
                    title: _notifications[i].title,
                    body: _notifications[i].body,
                    timestamp: _notifications[i].timestamp,
                    iconType: _notifications[i].iconType,
                    isUnread: false,
                  );
                }
              });
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          if (unread.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text('New', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ...unread.map((n) => _buildNotificationTile(n, theme)),
          ],
          if (earlier.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text('Earlier', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
            ),
            ...earlier.map((n) => _buildNotificationTile(n, theme)),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel n, ThemeData theme) {
    return Container(
      color: n.isUnread ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(n.userAvatar),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _getIconColor(n.iconType),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getIcon(n.iconType), color: Colors.white, size: 12),
              ),
            ),
          ],
        ),
        title: RichText(
          text: TextSpan(
            style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 14),
            children: [
              TextSpan(text: n.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' ${n.body}'),
            ],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(n.timestamp, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        trailing: n.isUnread
            ? Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : const Icon(Icons.more_horiz, color: Colors.grey),
        onTap: () {
          setState(() {
            final index = _notifications.indexWhere((item) => item.id == n.id);
            if (index != -1) {
              _notifications[index] = NotificationModel(
                id: n.id,
                userAvatar: n.userAvatar,
                title: n.title,
                body: n.body,
                timestamp: n.timestamp,
                iconType: n.iconType,
                isUnread: false,
              );
            }
          });
        },
      ),
    );
  }
}
