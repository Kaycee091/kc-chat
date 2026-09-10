import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/social_provider.dart';
import 'providers/messenger_provider.dart';
import 'providers/admin_provider.dart';
import 'features/auth/auth_screen.dart';
import 'features/layout/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SocialProvider()),
        ChangeNotifierProvider(create: (_) => MessengerProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const KCApp(),
    ),
  );
}

class KCApp extends StatelessWidget {
  const KCApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();

    return MaterialApp(
      title: 'KC APP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.currentThemeMode,
      home: authProvider.isAuthenticated ? const AppShell() : const AuthScreen(),
    );
  }
}
