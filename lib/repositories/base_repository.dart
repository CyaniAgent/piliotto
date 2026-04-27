import 'dart:collection';

class CacheConfig {
  final bool enabled;
  final Duration duration;
  const CacheConfig({
    this.enabled = true,
    this.duration = const Duration(minutes: 5),
  });
}

class _CacheEntry {
  final dynamic data;
  final DateTime expireAt;
  _CacheEntry(this.data, this.expireAt);
  bool get isExpired => DateTime.now().isAfter(expireAt);
}

abstract class BaseRepository {
  final HashMap<String, _CacheEntry> _cache = HashMap<String, _CacheEntry>();

  Future<T> withCache<T>(
    String key,
    Future<T> Function() fetch, {
    CacheConfig? cacheConfig,
  }) async {
    if (cacheConfig != null && cacheConfig.enabled) {
      final entry = _cache[key];
      if (entry != null && !entry.isExpired) {
        return entry.data as T;
      }
    }
    final result = await fetch();
    if (cacheConfig != null && cacheConfig.enabled) {
      _cache[key] = _CacheEntry(
        result,
        DateTime.now().add(cacheConfig.duration),
      );
    }
    return result;
  }

  void invalidateCache(String key) {
    _cache.remove(key);
  }

  void invalidateAllCache() {
    _cache.clear();
  }
}
