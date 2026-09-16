import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kc_chat/main.dart';
import 'package:kc_chat/providers/theme_provider.dart';
import 'package:kc_chat/providers/auth_provider.dart';
import 'package:kc_chat/providers/social_provider.dart';
import 'package:kc_chat/providers/messenger_provider.dart';
import 'package:kc_chat/providers/admin_provider.dart';
import 'package:kc_chat/core/widgets/safe_image.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestImageHttpOverrides();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
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
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
