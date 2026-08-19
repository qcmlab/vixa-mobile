import 'dart:convert';
import '../storage/storage_service.dart';

class CacheEntry {
  final dynamic data;
  final DateTime cachedAt;
  final Duration ttl;

  CacheEntry({
    required this.data,
    required this.cachedAt,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().isAfter(cachedAt.add(ttl));

  Map<String, dynamic> toJson() => {
        'data': data,
        'cached_at': cachedAt.toIso8601String(),
        'ttl_seconds': ttl.inSeconds,
      };

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      data: json['data'],
      cachedAt: DateTime.parse(json['cached_at']),
      ttl: Duration(seconds: json['ttl_seconds'] ?? 86400),
    );
  }
}

class CacheManager {
  final IStorageService _storage;
  static const String _cachePrefix = 'hafedh_cache_';

  CacheManager(this._storage);

  Future<void> put(String key, dynamic data, {Duration ttl = const Duration(hours: 24)}) async {
    final entry = CacheEntry(
      data: data,
      cachedAt: DateTime.now(),
      ttl: ttl,
    );
    final rawJson = jsonEncode(entry.toJson());
    await _storage.setString('$_cachePrefix$key', rawJson);
  }

  dynamic get(String key, {bool ignoreExpiration = false}) {
    final rawJson = _storage.getString('$_cachePrefix$key');
    if (rawJson == null) return null;

    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      final entry = CacheEntry.fromJson(map);
      if (!ignoreExpiration && entry.isExpired) {
        return null;
      }
      return entry.data;
    } catch (_) {
      return null;
    }
  }

  Future<void> remove(String key) async {
    await _storage.remove('$_cachePrefix$key');
  }
}
