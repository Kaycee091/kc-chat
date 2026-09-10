class AdminAuditLog {
  final String id;
  final String adminId;
  final String adminName;
  final String action; // 'suspend_user', 'ban_user', 'change_role', 'delete_post', etc.
  final String targetUserId;
  final String targetUserName;
  final String timestamp;
  final String details;

  AdminAuditLog({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.action,
    required this.targetUserId,
    required this.targetUserName,
    required this.timestamp,
    required this.details,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'adminId': adminId,
        'adminName': adminName,
        'action': action,
        'targetUserId': targetUserId,
        'targetUserName': targetUserName,
        'timestamp': timestamp,
        'details': details,
      };

  factory AdminAuditLog.fromJson(Map<String, dynamic> json) => AdminAuditLog(
        id: json['id'] ?? '',
        adminId: json['adminId'] ?? '',
        adminName: json['adminName'] ?? '',
        action: json['action'] ?? '',
        targetUserId: json['targetUserId'] ?? '',
        targetUserName: json['targetUserName'] ?? '',
        timestamp: json['timestamp'] ?? '',
        details: json['details'] ?? '',
      );
}

class ReportItem {
  final String id;
  final String reporterName;
  final String targetType; // 'post', 'comment', 'user', 'marketplace'
  final String targetId;
  final String reason;
  final String status; // 'pending', 'resolved', 'dismissed'
  final String timestamp;

  ReportItem({
    required this.id,
    required this.reporterName,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.status = 'pending',
    required this.timestamp,
  });

  ReportItem copyWith({String? status}) {
    return ReportItem(
      id: id,
      reporterName: reporterName,
      targetType: targetType,
      targetId: targetId,
      reason: reason,
      status: status ?? this.status,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reporterName': reporterName,
        'targetType': targetType,
        'targetId': targetId,
        'reason': reason,
        'status': status,
        'timestamp': timestamp,
      };

  factory ReportItem.fromJson(Map<String, dynamic> json) => ReportItem(
        id: json['id'] ?? '',
        reporterName: json['reporterName'] ?? '',
        targetType: json['targetType'] ?? '',
        targetId: json['targetId'] ?? '',
        reason: json['reason'] ?? '',
        status: json['status'] ?? 'pending',
        timestamp: json['timestamp'] ?? '',
      );
}
