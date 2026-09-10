import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsModal extends StatefulWidget {
  const SettingsModal({super.key});

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  void _showDownloadDataDialog(String jsonData) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.download, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Download Data Archive'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your complete data archive (connecta_data_archive.json) is ready for download:'),
            const SizedBox(height: 12),
            Container(
              height: 140,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
              child: SingleChildScrollView(
                child: Text(jsonData, style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontFamily: 'monospace')),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('connecta_data_archive.json downloaded successfully! 📁')),
              );
            },
            child: const Text('Export JSON File'),
          ),
        ],
      ),
    );
  }

  void _confirmAccountWipe() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('PERMANENTLY DELETE ACCOUNT?'),
        content: const Text('This action CANNOT be undone. All your profile data, posts, messages, and photos will be permanently deleted from KC App servers.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              context.read<AuthProvider>().permanentlyDeleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.destructive, foregroundColor: Colors.white),
            child: const Text('WIPE ALL DATA'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser!;
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Settings & Privacy Controls', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Account'),
              Tab(text: 'Privacy'),
              Tab(text: 'Notifications'),
              Tab(text: 'Security & 2FA'),
              Tab(text: 'Blocking'),
              Tab(text: 'Appearance'),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Account Tab
                ListView(
                  children: [
                    ListTile(title: const Text('Logged in as'), subtitle: Text('${user.name} (${user.email})')),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.download, color: AppColors.primary),
                      title: const Text('Download User Data Archive JSON'),
                      subtitle: const Text('Export connecta_data_archive.json'),
                      onTap: () => _showDownloadDataDialog(auth.exportUserDataJson()),
                    ),
                    ListTile(
                      leading: const Icon(Icons.pause_circle_outline, color: Colors.amber),
                      title: const Text('Deactivate Account'),
                      onTap: () => auth.deactivateAccount(),
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: AppColors.destructive),
                      title: const Text('Permanently Delete Account', style: TextStyle(color: AppColors.destructive, fontWeight: FontWeight.bold)),
                      onTap: _confirmAccountWipe,
                    ),
                  ],
                ),

                // 2. Privacy Tab
                ListView(
                  children: [
                    SwitchListTile(
                      title: const Text('Show Online Presence'),
                      value: user.onlineStatusEnabled,
                      activeColor: AppColors.primary,
                      onChanged: (v) => auth.updateProfile(user.copyWith(onlineStatusEnabled: v)),
                    ),
                    SwitchListTile(
                      title: const Text('Read Receipts'),
                      value: user.readReceiptsEnabled,
                      activeColor: AppColors.primary,
                      onChanged: (v) => auth.updateProfile(user.copyWith(readReceiptsEnabled: v)),
                    ),
                  ],
                ),

                // 3. Notifications Tab
                ListView(
                  children: [
                    SwitchListTile(title: const Text('Push Notifications'), value: true, activeColor: AppColors.primary, onChanged: (_) {}),
                    SwitchListTile(title: const Text('Email Digest Notifications'), value: true, activeColor: AppColors.primary, onChanged: (_) {}),
                  ],
                ),

                // 4. Security & 2FA Tab
                ListView(
                  children: [
                    SwitchListTile(
                      title: const Text('Two-Factor Authentication (2FA)'),
                      subtitle: const Text('Require 6-digit OTP code on sign in'),
                      value: user.is2FAEnabled,
                      activeColor: AppColors.primary,
                      onChanged: (v) => auth.toggle2FA(v),
                    ),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Active Logged-In Sessions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    ...auth.activeSessions.map((sess) {
                      return ListTile(
                        leading: const Icon(Icons.devices, color: AppColors.primary),
                        title: Text(sess.deviceName),
                        subtitle: Text('${sess.browser} • ${sess.ipAddress}\n${sess.lastActive}'),
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton.icon(
                        onPressed: () => auth.logoutOtherDevices(),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout Other Devices'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.destructive, foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),

                // 5. Blocking Tab
                ListView(
                  children: const [
                    ListTile(
                      title: Text('No blocked users currently'),
                      subtitle: Text('Blocked users cannot see your profile or message you.'),
                    ),
                  ],
                ),

                // 6. Appearance Tab
                ListView(
                  children: [
                    RadioListTile<ThemeModeOption>(
                      title: const Text('Light Mode ☀️'),
                      value: ThemeModeOption.light,
                      groupValue: themeProvider.themeModeOption,
                      onChanged: (v) => themeProvider.setThemeMode(v!),
                    ),
                    RadioListTile<ThemeModeOption>(
                      title: const Text('Dark Mode 🌙 (Midnight Slate)'),
                      value: ThemeModeOption.dark,
                      groupValue: themeProvider.themeModeOption,
                      onChanged: (v) => themeProvider.setThemeMode(v!),
                    ),
                    RadioListTile<ThemeModeOption>(
                      title: const Text('System Auto Match ⚙️'),
                      value: ThemeModeOption.system,
                      groupValue: themeProvider.themeModeOption,
                      onChanged: (v) => themeProvider.setThemeMode(v!),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
