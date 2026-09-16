import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/safe_image.dart';
import '../../providers/messenger_provider.dart';
import 'floating_chat_window.dart';

class MessengerDock extends StatelessWidget {
  const MessengerDock({super.key});

  @override
  Widget build(BuildContext context) {
    final messenger = context.watch<MessengerProvider>();
    final openIds = messenger.openChatHeadIds;
    final activeId = messenger.activeChatWindowId;

    if (openIds.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: [
        // Floating Docked Chat Heads Column
        Positioned(
          right: 16,
          bottom: 90,
          child: Column(
            children: openIds.map((convId) {
              final conv = messenger.conversations.firstWhere(
                (c) => c.id == convId,
                orElse: () => messenger.conversations.first,
              );
              final isActive = activeId == convId;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => messenger.openChatHead(convId),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive ? AppColors.primary : Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SafeAvatar(
                          radius: 26,
                          imageUrl: conv.participantAvatars.isNotEmpty ? conv.participantAvatars.last : '',
                          name: conv.groupName ?? (conv.participantNames.isNotEmpty ? conv.participantNames.first : 'Chat'),
                        ),
                      ),
                      if (conv.isOnline)
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Active Floating Chat Window Modal Overlay
        if (activeId != null)
          Positioned(
            right: 16,
            bottom: 160,
            width: MediaQuery.of(context).size.width * 0.85,
            height: 420,
            child: FloatingChatWindow(convId: activeId),
          ),
      ],
    );
  }
}
