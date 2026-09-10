import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('KC Admin & Moderation Console', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Metrics Grid
            Row(
              children: [
                _buildStatCard(context, 'Total Users', '${admin.allUsers.length}', Icons.people, AppColors.primary),
                const SizedBox(width: 12),
                _buildStatCard(context, 'Pending Reports', '${admin.pendingReports.length}', Icons.flag, AppColors.destructive),
              ],
            ),
            const SizedBox(height: 24),

            // User Moderation Section
            const Text('User Moderation & Access Control', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: admin.allUsers.map((u) {
                  return ListTile(
                    leading: CircleAvatar(backgroundImage: NetworkImage(u.avatarUrl)),
                    title: Row(
                      children: [
                        Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(u.role, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      u.isBanned
                          ? 'STATUS: BANNED 🚫'
                          : (u.isSuspended ? 'STATUS: SUSPENDED ⚠️' : 'STATUS: ACTIVE ✅'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: u.isBanned || u.isSuspended ? AppColors.destructive : AppColors.success,
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'suspend') admin.suspendUser(u.id, auth, reason: 'Violated Terms');
                        if (val == 'unsuspend') admin.unsuspendUser(u.id, auth);
                        if (val == 'ban') admin.banUser(u.id, auth, reason: 'Severe misconduct');
                        if (val == 'unban') admin.unbanUser(u.id, auth);
                        if (val == 'make_mod') admin.changeRole(u.id, 'moderator');
                      },
                      itemBuilder: (ctx) => [
                        if (!u.isSuspended)
                          const PopupMenuItem(value: 'suspend', child: Text('Suspend User ⚠️')),
                        if (u.isSuspended)
                          const PopupMenuItem(value: 'unsuspend', child: Text('Unsuspend User ✅')),
                        if (!u.isBanned)
                          const PopupMenuItem(value: 'ban', child: Text('Permanently Ban 🚫')),
                        if (u.isBanned)
                          const PopupMenuItem(value: 'unban', child: Text('Lift Ban ✅')),
                        const PopupMenuItem(value: 'make_mod', child: Text('Change Role to Moderator')),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Audit Logs Section
            const Text('Platform Audit Logs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: admin.auditLogs.map((log) {
                  return ListTile(
                    leading: const Icon(Icons.history, color: AppColors.primary),
                    title: Text('${log.action} on ${log.targetUserName}'),
                    subtitle: Text('${log.details}\nBy ${log.adminName} • ${log.timestamp}'),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
