import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/messenger_provider.dart';

class FullMessengerScreen extends StatefulWidget {
  const FullMessengerScreen({super.key});

  @override
  State<FullMessengerScreen> createState() => _FullMessengerScreenState();
}

class _FullMessengerScreenState extends State<FullMessengerScreen> {
  final _searchController = TextEditingController();
  final _groupNameController = TextEditingController();

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Group Chat'),
        content: TextField(
          controller: _groupNameController,
          decoration: const InputDecoration(hintText: 'Enter group name...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_groupNameController.text.isNotEmpty) {
                context.read<MessengerProvider>().createGroupConversation(_groupNameController.text, ['user_1', 'user_2', 'user_3']);
                _groupNameController.clear();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messenger = context.watch<MessengerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messenger Portal', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add, color: AppColors.primary),
            onPressed: _showCreateGroupDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),

          // Conversations List
          Expanded(
            child: ListView.builder(
              itemCount: messenger.conversations.length,
              itemBuilder: (ctx, index) {
                final conv = messenger.conversations[index];
                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(conv.participantAvatars.last),
                      ),
                      if (conv.isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    conv.isGroup ? (conv.groupName ?? 'Group') : conv.participantNames.last,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    conv.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    conv.lastMessageTime,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () => messenger.openChatHead(conv.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
