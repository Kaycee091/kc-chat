import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/admin_model.dart';
import '../core/utils/mock_data.dart';
import 'auth_provider.dart';

class AdminProvider with ChangeNotifier {
  List<UserProfile> _allUsers = List.from(MockData.users);
  List<ReportItem> _reports = List.from(MockData.initialReports);
  List<AdminAuditLog> _auditLogs = List.from(MockData.initialAuditLogs);

  List<UserProfile> get allUsers => _allUsers;
  List<ReportItem> get pendingReports => _reports.where((r) => r.status == 'pending').toList();
  List<AdminAuditLog> get auditLogs => _auditLogs;

  void suspendUser(String userId, AuthProvider authProvider, {required String reason}) {
    final index = _allUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _allUsers[index] = _allUsers[index].copyWith(isSuspended: true);
      _logAction('suspend_user', userId, _allUsers[index].name, 'Suspended account. Reason: $reason');
      
      // If target user is the logged in user, propagate status
      if (authProvider.currentUser?.id == userId) {
        authProvider.updateRestrictionStatus(isSuspended: true);
      }
      notifyListeners();
    }
  }

  void unsuspendUser(String userId, AuthProvider authProvider) {
    final index = _allUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _allUsers[index] = _allUsers[index].copyWith(isSuspended: false);
      _logAction('unsuspend_user', userId, _allUsers[index].name, 'Restored active account status');
      if (authProvider.currentUser?.id == userId) {
        authProvider.updateRestrictionStatus(isSuspended: false);
      }
      notifyListeners();
    }
  }

  void banUser(String userId, AuthProvider authProvider, {required String reason}) {
    final index = _allUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _allUsers[index] = _allUsers[index].copyWith(isBanned: true);
      _logAction('ban_user', userId, _allUsers[index].name, 'Permanently banned account. Reason: $reason');
      if (authProvider.currentUser?.id == userId) {
        authProvider.updateRestrictionStatus(isBanned: true);
      }
      notifyListeners();
    }
  }

  void unbanUser(String userId, AuthProvider authProvider) {
    final index = _allUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _allUsers[index] = _allUsers[index].copyWith(isBanned: false);
      _logAction('unban_user', userId, _allUsers[index].name, 'Lifted permanent ban');
      if (authProvider.currentUser?.id == userId) {
        authProvider.updateRestrictionStatus(isBanned: false);
      }
      notifyListeners();
    }
  }

  void changeRole(String userId, String newRole) {
    final index = _allUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _allUsers[index] = _allUsers[index].copyWith(role: newRole);
      _logAction('change_role', userId, _allUsers[index].name, 'Changed role to $newRole');
      notifyListeners();
    }
  }

  void dismissReport(String reportId) {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      _reports[index] = _reports[index].copyWith(status: 'dismissed');
      notifyListeners();
    }
  }

  void resolveReport(String reportId) {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      _reports[index] = _reports[index].copyWith(status: 'resolved');
      notifyListeners();
    }
  }

  void _logAction(String action, String targetUserId, String targetUserName, String details) {
    _auditLogs.insert(
      0,
      AdminAuditLog(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        adminId: 'user_1',
        adminName: 'Alex Johnson',
        action: action,
        targetUserId: targetUserId,
        targetUserName: targetUserName,
        timestamp: 'Just now',
        details: details,
      ),
    );
  }
}
