import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kc_chat/main.dart';
import 'package:kc_chat/providers/theme_provider.dart';
import 'package:kc_chat/providers/auth_provider.dart';
import 'package:kc_chat/providers/social_provider.dart';
import 'package:kc_chat/providers/messenger_provider.dart';
import 'package:kc_chat/providers/admin_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Ignore network image load exceptions during offline widget tests
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final isNetworkImageError = details.exception.toString().contains('NetworkImage') ||
          details.exception.toString().contains('statusCode: 400');
      if (isNetworkImageError) {
        return;
      }
      originalOnError?.call(details);
    };

    await tester.pumpWidget(
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

    expect(find.byType(KCApp), findsOneWidget);
  });
}
