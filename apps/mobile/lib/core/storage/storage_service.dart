import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';

class StorageService {
  static const _kAccessTokenKey = 'connecta_access_token';
  static const _kRefreshTokenKey = 'connecta_refresh_token';
  static const _kUserKey = 'connecta_current_user';
  static const _kSavedPostsKey = 'connecta_saved_post_ids';

  final FlutterSecureStorage _secureStorage;
  SharedPreferences? _prefs;

  final Map<String, String> _memoryTokens = {};
  final Map<String, dynamic> _memoryCache = {};
  final Set<String> _memorySavedPosts = {};

  StorageService({FlutterSecureStorage? secureStorage, SharedPreferences? prefs})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _prefs = prefs;

  Future<void> init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
    } catch (_) {
      // Graceful fallback to memory storage
    }
  }

  // --- Auth & Token Secure Storage ---
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    _memoryTokens[_kAccessTokenKey] = accessToken;
    _memoryTokens[_kRefreshTokenKey] = refreshToken;
    try {
      await _secureStorage.write(key: _kAccessTokenKey, value: accessToken);
      await _secureStorage.write(key: _kRefreshTokenKey, value: refreshToken);
    } catch (_) {}
  }

  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: _kAccessTokenKey);
      if (token != null) return token;
    } catch (_) {}
    return _memoryTokens[_kAccessTokenKey];
  }

  Future<String?> getRefreshToken() async {
    try {
      final token = await _secureStorage.read(key: _kRefreshTokenKey);
      if (token != null) return token;
    } catch (_) {}
    return _memoryTokens[_kRefreshTokenKey];
  }

  Future<void> clearTokens() async {
    _memoryTokens.remove(_kAccessTokenKey);
    _memoryTokens.remove(_kRefreshTokenKey);
    try {
      await _secureStorage.delete(key: _kAccessTokenKey);
      await _secureStorage.delete(key: _kRefreshTokenKey);
    } catch (_) {}
  }

  // --- User Profile Persistence ---
  Future<void> saveUser(UserProfile user) async {
    _memoryCache[_kUserKey] = user;
    try {
      await init();
      final jsonStr = jsonEncode(user.toJson());
      await _prefs?.setString(_kUserKey, jsonStr);
    } catch (_) {}
  }

  Future<UserProfile?> getUser() async {
    try {
      await init();
      final jsonStr = _prefs?.getString(_kUserKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return UserProfile.fromJson(map);
      }
    } catch (_) {}
    return _memoryCache[_kUserKey] as UserProfile?;
  }

  Future<void> clearUser() async {
    _memoryCache.remove(_kUserKey);
    try {
      await init();
      await _prefs?.remove(_kUserKey);
    } catch (_) {}
  }

  Future<void> clearAll() async {
    await clearTokens();
    await clearUser();
  }

  // --- Saved Post IDs Persistence ---
  Future<void> savePostId(String postId) async {
    _memorySavedPosts.add(postId);
    try {
      await init();
      final ids = _prefs?.getStringList(_kSavedPostsKey) ?? [];
      if (!ids.contains(postId)) {
        ids.add(postId);
        await _prefs?.setStringList(_kSavedPostsKey, ids);
      }
    } catch (_) {}
  }

  Future<void> removeSavedPostId(String postId) async {
    _memorySavedPosts.remove(postId);
    try {
      await init();
      final ids = _prefs?.getStringList(_kSavedPostsKey) ?? [];
      ids.remove(postId);
      await _prefs?.setStringList(_kSavedPostsKey, ids);
    } catch (_) {}
  }

  Future<List<String>> getSavedPostIds() async {
    try {
      await init();
      final ids = _prefs?.getStringList(_kSavedPostsKey);
      if (ids != null) return ids;
    } catch (_) {}
    return _memorySavedPosts.toList();
  }
}
