import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/utils/mock_data.dart';

class AuthProvider with ChangeNotifier {
  UserProfile? _currentUser = MockData.currentUser;
  bool _isAuthenticated = true;
  bool _isEmailVerified = true;
  bool _isOnboardingCompleted = true;
  bool _is2FAPending = false;

  List<ActiveSession> _activeSessions = [
    ActiveSession(
      id: 'sess_1',
      deviceName: 'Pixel 8 Pro (This Device)',
      browser: 'KC Mobile App v1.0',
      ipAddress: '192.168.1.104',
      location: 'San Francisco, CA',
      lastActive: 'Active Now',
    ),
    ActiveSession(
      id: 'sess_2',
      deviceName: 'MacBook Pro 16"',
      browser: 'Chrome 122.0',
      ipAddress: '192.168.1.102',
      location: 'San Francisco, CA',
      lastActive: '2 hours ago',
    ),
  ];

  List<LoginHistoryRecord> _loginHistory = [
    LoginHistoryRecord(
      id: 'log_1',
      timestamp: 'Today, 10:30 AM',
      ipAddress: '192.168.1.104',
      deviceName: 'Pixel 8 Pro',
      location: 'San Francisco, CA',
      isSuccessful: true,
    ),
    LoginHistoryRecord(
      id: 'log_2',
      timestamp: 'Yesterday, 8:15 PM',
      ipAddress: '192.168.1.102',
      deviceName: 'MacBook Pro',
      location: 'San Francisco, CA',
      isSuccessful: true,
    ),
  ];

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isEmailVerified => _isEmailVerified;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  bool get is2FAPending => _is2FAPending;
  List<ActiveSession> get activeSessions => _activeSessions;
  List<LoginHistoryRecord> get loginHistory => _loginHistory;

  int calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    return score; // 1 to 4
  }

  Future<bool> signIn(String identifier, String password, bool rememberMe) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = MockData.currentUser;
    if (_currentUser!.is2FAEnabled) {
      _is2FAPending = true;
      notifyListeners();
      return true;
    }
    _isAuthenticated = true;
    _loginHistory.insert(
      0,
      LoginHistoryRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: 'Just now',
        ipAddress: '127.0.0.1',
        deviceName: 'Mobile Client',
        location: 'Current Location',
        isSuccessful: true,
      ),
    );
    notifyListeners();
    return true;
  }

  Future<bool> verify2FA(String otpCode) async {
    if (otpCode == '123456' || otpCode.length == 6) {
      _is2FAPending = false;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String dob,
    required String gender,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _currentUser = UserProfile(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      username: username,
      email: email,
      phone: phone,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
      coverUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=1200&auto=format&fit=crop&q=80',
    );
    _isEmailVerified = false;
    _isOnboardingCompleted = false;
    notifyListeners();
    return true;
  }

  Future<bool> verifyEmailCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (code == '123456') {
      _isEmailVerified = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void completeOnboarding() {
    _isOnboardingCompleted = true;
    _isAuthenticated = true;
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  void updateProfile(UserProfile updated) {
    _currentUser = updated;
    notifyListeners();
  }

  void toggle2FA(bool enabled) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(is2FAEnabled: enabled);
      notifyListeners();
    }
  }

  void logoutOtherDevices() {
    _activeSessions = _activeSessions.where((s) => s.id == 'sess_1').toList();
    notifyListeners();
  }

  String exportUserDataJson() {
    final archive = {
      'export_date': DateTime.now().toIso8601String(),
      'profile': _currentUser?.toJson(),
      'active_sessions': _activeSessions.map((s) => s.toJson()).toList(),
      'login_history': _loginHistory.map((l) => l.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(archive);
  }

  void deactivateAccount() {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  void permanentlyDeleteAccount() {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  void updateRestrictionStatus({bool? isSuspended, bool? isBanned}) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        isSuspended: isSuspended ?? _currentUser!.isSuspended,
        isBanned: isBanned ?? _currentUser!.isBanned,
      );
      notifyListeners();
    }
  }
}
