import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:kc_chat/core/widgets/safe_image.dart';
import 'package:kc_chat/core/network/api_client.dart';
import 'package:kc_chat/core/storage/storage_service.dart';
import 'package:kc_chat/models/post_model.dart';
import 'package:kc_chat/providers/auth_provider.dart';
import 'package:kc_chat/providers/social_provider.dart';
import 'package:kc_chat/providers/messenger_provider.dart';
import 'package:kc_chat/providers/admin_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = TestImageHttpOverrides();
  });

  group('Core Storage & Network Unit Tests', () {
    test('StorageService token operations', () async {
      final storage = StorageService();
      await storage.saveTokens(
        accessToken: 'access_abc_123',
        refreshToken: 'refresh_xyz_789',
      );

      final token = await storage.getAccessToken();
      expect(token, equals('access_abc_123'));

      final refresh = await storage.getRefreshToken();
      expect(refresh, equals('refresh_xyz_789'));

      await storage.clearTokens();
      final clearedToken = await storage.getAccessToken();
      expect(clearedToken, isNull);
    });

    test('ApiResponse envelope handles success and failure', () {
      final successResp = ApiResponse<Map<String, dynamic>>.success(
        {'id': 1, 'name': 'Connecta'},
        message: 'OK',
      );
      expect(successResp.isSuccess, isTrue);
      expect(successResp.data?['name'], equals('Connecta'));

      final errorResp = ApiResponse.failure(
        message: 'Wrong password',
        errorCode: 'INVALID_CREDENTIALS',
      );
      expect(errorResp.isSuccess, isFalse);
      expect(errorResp.message, equals('Wrong password'));
      expect(errorResp.errorCode, equals('INVALID_CREDENTIALS'));
    });
  });

  group('AuthProvider State & Session Tests', () {
    test('Sign in and sign out updates authentication state', () async {
      final auth = AuthProvider();
      expect(auth.isAuthenticated, isTrue); // Default session initialized

      auth.signOut();
      expect(auth.isAuthenticated, isFalse);
      expect(auth.currentUser, isNull);

      final success = await auth.signIn('alex@kc.app', 'password123', true);
      expect(success, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser?.email, equals('alex.johnson@kc.app'));
    });

    test('Two-Factor Authentication (2FA) verification', () async {
      final auth = AuthProvider();
      final valid = await auth.verify2FA('123456');
      expect(valid, isTrue);
      expect(auth.isAuthenticated, isTrue);

      final invalid = await auth.verify2FA('123');
      expect(invalid, isFalse);
    });
  });

  group('SocialProvider Features Tests', () {
    test('Add post, toggle save, and reaction updates', () async {
      final social = SocialProvider();
      final initialCount = social.posts.length;

      final testPost = Post(
        id: 'test_post_100',
        authorId: 'user_1',
        authorName: 'Alex Johnson',
        authorUsername: 'alexj',
        authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
        content: 'Automated test post for Connecta mobile application.',
        timestamp: 'Just now',
        privacy: 'public',
      );

      await social.addPost(testPost);
      expect(social.posts.length, equals(initialCount + 1));
      expect(social.posts.first.id, equals('test_post_100'));

      // Toggle Bookmark/Save
      expect(social.isPostSaved('test_post_100'), isFalse);
      await social.toggleSavePost('test_post_100');
      expect(social.isPostSaved('test_post_100'), isTrue);
      expect(social.savedPosts.any((p) => p.id == 'test_post_100'), isTrue);

      // Toggle Reaction
      social.toggleReaction('test_post_100', 'love');
      final updated = social.posts.firstWhere((p) => p.id == 'test_post_100');
      expect(updated.userReaction, equals('love'));
      expect(updated.totalReactions, equals(1));
    });

    test('Friend request tracking and dispatching', () {
      final social = SocialProvider();
      final auth = AuthProvider();

      expect(social.isFriendRequestSent('user_target_99'), isFalse);
      social.sendFriendRequest('user_target_99', auth);
      expect(social.isFriendRequestSent('user_target_99'), isTrue);
      expect(social.sentFriendRequestUserIds.contains('user_target_99'), isTrue);
    });
  });

  group('MessengerProvider & AdminProvider Tests', () {
    test('Dynamic conversation creation and messaging', () {
      final messenger = MessengerProvider();

      final conv = messenger.openConversationWithUser(
        'user_new_42',
        'Elena Rostova',
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
      );
      expect(conv.participantIds.contains('user_new_42'), isTrue);
      expect(messenger.openChatHeadIds.contains(conv.id), isTrue);

      messenger.sendMessage(conv.id, 'Hello from automated unit test!');
      final messages = messenger.getMessagesForConversation(conv.id);
      expect(messages.isNotEmpty, isTrue);
      expect(messages.last.content, equals('Hello from automated unit test!'));
    });

    test('AdminProvider report submission and pending reports', () {
      final admin = AdminProvider();
      final initialReportsCount = admin.pendingReports.length;

      admin.reportPost(
        postId: 'post_violating_1',
        reason: 'Harassment',
        reporterName: 'Alex Johnson',
      );
      expect(admin.pendingReports.length, equals(initialReportsCount + 1));
      expect(admin.pendingReports.any((r) => r.targetId == 'post_violating_1'), isTrue);
    });
  });
}
