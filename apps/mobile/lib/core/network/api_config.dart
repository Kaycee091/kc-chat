import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Base URL for the Django REST API v1.
  /// Android emulator maps host machine to 10.0.2.2, while iOS simulator / desktop / web use 127.0.0.1.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000/api/v1';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        return 'http://127.0.0.1:8000/api/v1';
    }
  }

  /// Base WebSocket URL for Django Channels.
  static String get wsUrl {
    if (kIsWeb) {
      return 'ws://127.0.0.1:8000/ws';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ws://10.0.2.2:8000/ws';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        return 'ws://127.0.0.1:8000/ws';
    }
  }

  static const Duration requestTimeout = Duration(seconds: 12);
}
