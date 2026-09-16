import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../storage/storage_service.dart';

class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? message;
  final String? errorCode;
  final Map<String, dynamic>? errorDetails;
  final int statusCode;

  ApiResponse({
    required this.isSuccess,
    this.data,
    this.message,
    this.errorCode,
    this.errorDetails,
    required this.statusCode,
  });

  factory ApiResponse.success(T data, {String? message, int statusCode = 200}) {
    return ApiResponse(
      isSuccess: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.failure({
    required String message,
    String? errorCode,
    Map<String, dynamic>? errorDetails,
    int statusCode = 500,
  }) {
    return ApiResponse(
      isSuccess: false,
      message: message,
      errorCode: errorCode ?? 'SERVER_ERROR',
      errorDetails: errorDetails,
      statusCode: statusCode,
    );
  }
}

class ApiClient {
  final http.Client _httpClient;
  final StorageService _storageService;
  bool _isRefreshingToken = false;

  ApiClient({http.Client? httpClient, StorageService? storageService})
      : _httpClient = httpClient ?? http.Client(),
        _storageService = storageService ?? StorageService();

  Future<Map<String, String>> _buildHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requiresAuth) {
      final token = await _storageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final urlStr = '${ApiConfig.baseUrl}/$cleanPath';
    final baseUri = Uri.parse(urlStr);
    if (queryParams != null && queryParams.isNotEmpty) {
      return baseUri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())));
    }
    return baseUri;
  }

  Future<ApiResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    return _sendWithRetry(
      () async {
        final uri = _buildUri(path, queryParams);
        final headers = await _buildHeaders(requiresAuth: requiresAuth);
        return await _httpClient.get(uri, headers: headers).timeout(ApiConfig.requestTimeout);
      },
      requiresAuth: requiresAuth,
    );
  }

  Future<ApiResponse<dynamic>> post(
    String path, {
    dynamic body,
    bool requiresAuth = true,
  }) async {
    return _sendWithRetry(
      () async {
        final uri = _buildUri(path);
        final headers = await _buildHeaders(requiresAuth: requiresAuth);
        final encodedBody = body != null ? jsonEncode(body) : null;
        return await _httpClient.post(uri, headers: headers, body: encodedBody).timeout(ApiConfig.requestTimeout);
      },
      requiresAuth: requiresAuth,
    );
  }

  Future<ApiResponse<dynamic>> put(
    String path, {
    dynamic body,
    bool requiresAuth = true,
  }) async {
    return _sendWithRetry(
      () async {
        final uri = _buildUri(path);
        final headers = await _buildHeaders(requiresAuth: requiresAuth);
        final encodedBody = body != null ? jsonEncode(body) : null;
        return await _httpClient.put(uri, headers: headers, body: encodedBody).timeout(ApiConfig.requestTimeout);
      },
      requiresAuth: requiresAuth,
    );
  }

  Future<ApiResponse<dynamic>> delete(
    String path, {
    dynamic body,
    bool requiresAuth = true,
  }) async {
    return _sendWithRetry(
      () async {
        final uri = _buildUri(path);
        final headers = await _buildHeaders(requiresAuth: requiresAuth);
        final encodedBody = body != null ? jsonEncode(body) : null;
        return await _httpClient.delete(uri, headers: headers, body: encodedBody).timeout(ApiConfig.requestTimeout);
      },
      requiresAuth: requiresAuth,
    );
  }

  Future<ApiResponse<dynamic>> _sendWithRetry(
    Future<http.Response> Function() requestFn, {
    required bool requiresAuth,
  }) async {
    try {
      final response = await requestFn();

      // Handle 401 Unauthorized token refresh
      if (response.statusCode == 401 && requiresAuth && !_isRefreshingToken) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          // Retry request once with new token
          final retryResponse = await requestFn();
          return _parseResponse(retryResponse);
        } else {
          await _storageService.clearTokens();
          return ApiResponse.failure(
            message: 'Session expired. Please sign in again.',
            errorCode: 'SESSION_EXPIRED',
            statusCode: 401,
          );
        }
      }

      return _parseResponse(response);
    } on SocketException {
      return ApiResponse.failure(
        message: 'Unable to connect to Connecta server. Please check your network.',
        errorCode: 'NETWORK_ERROR',
        statusCode: 0,
      );
    } on TimeoutException {
      return ApiResponse.failure(
        message: 'Request timed out. Please try again.',
        errorCode: 'TIMEOUT_ERROR',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse.failure(
        message: 'An unexpected error occurred: $e',
        errorCode: 'UNKNOWN_ERROR',
        statusCode: 500,
      );
    }
  }

  ApiResponse<dynamic> _parseResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = null;
    }

    // Connecta standard PRD envelope check:
    // { "success": true, "data": ..., "message": null }
    // { "success": false, "error": { "code": "...", "message": "...", "details": {} } }
    if (body is Map<String, dynamic>) {
      if (body.containsKey('success')) {
        final isSuccess = body['success'] == true;
        if (isSuccess) {
          return ApiResponse.success(
            body['data'] ?? body,
            message: body['message'],
            statusCode: response.statusCode,
          );
        } else {
          final errorObj = body['error'];
          String errorMessage = 'Request failed';
          String errorCode = 'API_ERROR';
          Map<String, dynamic>? errorDetails;

          if (errorObj is Map<String, dynamic>) {
            errorMessage = errorObj['message'] ?? errorMessage;
            errorCode = errorObj['code'] ?? errorCode;
            if (errorObj['details'] is Map<String, dynamic>) {
              errorDetails = errorObj['details'];
            }
          } else if (errorObj is String) {
            errorMessage = errorObj;
          }

          return ApiResponse.failure(
            message: errorMessage,
            errorCode: errorCode,
            errorDetails: errorDetails,
            statusCode: response.statusCode,
          );
        }
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.success(body, statusCode: response.statusCode);
    } else {
      return ApiResponse.failure(
        message: 'Server responded with status ${response.statusCode}',
        errorCode: 'HTTP_${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  Future<bool> _attemptTokenRefresh() async {
    _isRefreshingToken = true;
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }
      final refreshUri = _buildUri('auth/token/refresh/');
      final res = await _httpClient.post(
        refreshUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final newAccess = data['access'] ?? (data['data'] != null ? data['data']['access'] : null);
        final newRefresh = data['refresh'] ?? refreshToken;
        if (newAccess != null) {
          await _storageService.saveTokens(accessToken: newAccess, refreshToken: newRefresh);
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      _isRefreshingToken = false;
    }
  }
}
