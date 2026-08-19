import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'storage.dart';

class ApiException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  ApiException({required this.message, this.code, this.details});

  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  Map<String, String> _buildHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth) {
      final token = AppStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(String endpoint, {bool includeAuth = true}) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    try {
      final response = await http
          .get(url, headers: _buildHeaders(includeAuth: includeAuth))
          .timeout(const Duration(seconds: 4));
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'تعذر الاتصال بالخادم. سيتم العمل بالوضع المحلي بدون إنترنت.');
    }
  }

  Future<dynamic> post(String endpoint, {dynamic body, bool includeAuth = true}) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    try {
      final response = await http
          .post(
            url,
            headers: _buildHeaders(includeAuth: includeAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 4));
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'تعذر الاتصال بالخادم. سيتم العمل بالوضع المحلي بدون إنترنت.');
    }
  }

  Future<dynamic> put(String endpoint, {dynamic body, bool includeAuth = true}) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    try {
      final response = await http
          .put(
            url,
            headers: _buildHeaders(includeAuth: includeAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 4));
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'تعذر الاتصال بالخادم. سيتم العمل بالوضع المحلي بدون إنترنت.');
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
      AppStorage.clearAuth();
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
