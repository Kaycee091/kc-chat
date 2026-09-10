import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/social_provider.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final social = context.watch<SocialProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events & Summits', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: social.events.length,
        itemBuilder: (ctx, index) {
          final event = social.events[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(event.coverUrl, height: 160, width: double.infinity, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.date, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text('📍 ${event.location}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(event.description, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${event.attendeesCount} Going', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          Row(
                            children: [
                              ChoiceChip(
                                label: const Text('Going'),
                                selected: event.rsvpStatus == 'Going',
                                onSelected: (_) => social.updateEventRSVP(event.id, 'Going'),
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text('Interested'),
                                selected: event.rsvpStatus == 'Interested',
                                onSelected: (_) => social.updateEventRSVP(event.id, 'Interested'),
                              ),
                            ],
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
    );
  }
}
