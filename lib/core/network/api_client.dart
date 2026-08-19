import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../storage/storage_service.dart';

class ApiException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  ApiException({required this.message, this.code, this.details});

  @override
  String toString() => message;
}

class ApiClient {
  final IStorageService _storage;
  final http.Client _httpClient;

  ApiClient(this._storage, {http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  Map<String, String> _buildHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth) {
      final token = _storage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(String endpoint, {bool includeAuth = true}) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    try {
      final response = await _httpClient
          .get(url, headers: _buildHeaders(includeAuth: includeAuth))
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'فشل الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت.');
    }
  }

  Future<dynamic> post(String endpoint, {dynamic body, bool includeAuth = true}) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    try {
      final response = await _httpClient
          .post(
            url,
            headers: _buildHeaders(includeAuth: includeAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'فشل الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت.');
    }
  }

  Future<dynamic> put(String endpoint, {dynamic body, bool includeAuth = true}) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    try {
      final response = await _httpClient
          .put(
            url,
            headers: _buildHeaders(includeAuth: includeAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'فشل الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت.');
    }
  }

  dynamic _handleResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      body = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    if (response.statusCode == 401) {
      _storage.clearAuth();
      throw ApiException(
        message: body?['message'] ?? 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً.',
        code: 'UNAUTHORIZED',
      );
    }

    final message = body?['message'] ?? 'حدث خطأ غير متوقع (${response.statusCode})';
    final code = body?['code'];
    final details = body?['details'];

    throw ApiException(message: message, code: code, details: details);
  }
}
