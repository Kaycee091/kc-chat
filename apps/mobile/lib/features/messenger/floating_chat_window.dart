import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/messenger_provider.dart';

class FloatingChatWindow extends StatefulWidget {
  final String convId;

  const FloatingChatWindow({super.key, required this.convId});

  @override
  State<FloatingChatWindow> createState() => _FloatingChatWindowState();
}

class _FloatingChatWindowState extends State<FloatingChatWindow> {
  final _messageController = TextEditingController();

  void _sendMessage({String? attachmentUrl, bool isAudio = false}) {
    final text = _messageController.text;
    if (text.isEmpty && attachmentUrl == null && !isAudio) return;

    final messenger = context.read<MessengerProvider>();
    messenger.sendMessage(widget.convId, isAudio ? 'Voice note' : text, attachmentUrl: attachmentUrl, isAudio: isAudio);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messenger = context.watch<MessengerProvider>();
    final conv = messenger.conversations.firstWhere(
      (c) => c.id == widget.convId,
      orElse: () => messenger.conversations.first,
    );
    final messages = messenger.getMessagesForConversation(widget.convId);
    final theme = Theme.of(context);

    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: theme.cardColor,
        child: Column(
          children: [
            // Window Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: AppColors.primary,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(conv.participantAvatars.last),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conv.isGroup ? (conv.groupName ?? 'Group') : conv.participantNames.last,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          conv.isTyping ? '... is typing' : (conv.isOnline ? 'Online' : 'Offline'),
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.white, size: 20),
                    onPressed: () => messenger.minimizeChatWindow(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => messenger.closeChatHead(widget.convId),
                  ),
                ],
              ),
            ),

            // Messages Stream
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (ctx, index) {
                  final msg = messages[index];
                  final isMe = msg.senderId == 'user_1';

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.primary : (theme.brightness == Brightness.dark ? AppColors.darkBackground : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (msg.isAudio)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.play_arrow, color: isMe ? Colors.white : AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'Voice note (${msg.audioDuration ?? "0:15"})',
                                  style: TextStyle(color: isMe ? Colors.white : null, fontSize: 13),
                                ),
                              ],
                            )
                          else
                            Text(
                              msg.content,
                              style: TextStyle(color: isMe ? Colors.white : null, fontSize: 13),
                            ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                msg.timestamp,
                                style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.grey),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.done_all, size: 12, color: Colors.white70),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Text Input & Attachments Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: theme.brightness == Brightness.dark ? AppColors.darkBackground : Colors.grey.shade100,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic, color: AppColors.primary, size: 20),
                    onPressed: () => _sendMessage(isAudio: true),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Type message...',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primary, size: 20),
                    onPressed: () => _sendMessage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
