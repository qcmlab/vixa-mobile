import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

abstract class IStorageService {
  Future<void> saveToken(String token);
  String? getToken();
  Future<void> saveRefreshToken(String token);
  String? getRefreshToken();
  Future<void> saveUserData(String jsonStr);
  String? getUserData();
  Future<void> clearAuth();
  Future<void> setString(String key, String value);
  String? getString(String key);
  Future<void> remove(String key);
  Future<void> setInt(String key, int value);
  int? getInt(String key);
  Future<void> setBool(String key, bool value);
  bool? getBool(String key);
}

class StorageService implements IStorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  @override
  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  @override
  String? getToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(AppConstants.refreshTokenKey, token);
  }

  @override
  String? getRefreshToken() {
    return _prefs.getString(AppConstants.refreshTokenKey);
  }

  @override
  Future<void> saveUserData(String jsonStr) async {
    await _prefs.setString(AppConstants.userKey, jsonStr);
  }

  @override
  String? getUserData() {
    return _prefs.getString(AppConstants.userKey);
  }

  @override
  Future<void> clearAuth() async {
    await _prefs.remove(AppConstants.tokenKey);
    await _prefs.remove(AppConstants.refreshTokenKey);
    await _prefs.remove(AppConstants.userKey);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  String? getString(String key) {
    return _prefs.getString(key);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  @override
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }
}
