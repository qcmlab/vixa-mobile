import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/feed/data/flashcard_repository.dart';
import '../cache/cache_manager.dart';
import '../cache/offline_sync_service.dart';
import '../network/api_client.dart';
import '../storage/storage_service.dart';

// 1. SharedPreferences Raw Provider (overridden at bootstrap in main)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

// 2. Storage Service Provider
final storageServiceProvider = Provider<IStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

// 3. Cache Manager Provider
final cacheManagerProvider = Provider<CacheManager>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return CacheManager(storage);
});

// 4. Offline Sync Service Provider
final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return OfflineSyncService(storage);
});

// 5. ApiClient Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiClient(storage);
});

// 6. Flashcard Repository Provider
final flashcardRepositoryProvider = Provider<IFlashcardRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  final cache = ref.watch(cacheManagerProvider);
  final offlineSync = ref.watch(offlineSyncServiceProvider);

  return FlashcardRepository(
    api: api,
    cache: cache,
    offlineSync: offlineSync,
  );
});
