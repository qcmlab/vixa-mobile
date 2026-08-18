import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class AppStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveToken(String token) async {
    await _prefs?.setString(AppConstants.tokenKey, token);
  }

  static String? getToken() {
    return _prefs?.getString(AppConstants.tokenKey);
  }

  static Future<void> saveRefreshToken(String token) async {
    await _prefs?.setString(AppConstants.refreshTokenKey, token);
  }

  static String? getRefreshToken() {
    return _prefs?.getString(AppConstants.refreshTokenKey);
  }

  static Future<void> clearAuth() async {
    await _prefs?.remove(AppConstants.tokenKey);
    await _prefs?.remove(AppConstants.refreshTokenKey);
    await _prefs?.remove(AppConstants.userKey);
  }

  static Future<void> saveUserData(String jsonStr) async {
    await _prefs?.setString(AppConstants.userKey, jsonStr);
  }

  static String? getUserData() {
    return _prefs?.getString(AppConstants.userKey);
  }

  static Future<void> saveCustomBaseUrl(String url) async {
    await _prefs?.setString('custom_base_url', url);
  }

  static String? getCustomBaseUrl() {
    return _prefs?.getString('custom_base_url');
  }
}
