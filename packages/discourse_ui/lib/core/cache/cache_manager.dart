import 'dart:async';
import 'package:discourse_ui/core/cache/lru_cache.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';

/// Centralized cache management with memory monitoring
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  final Map<String, dynamic> _caches = {};
  final Map<String, Timer> _cleanupTimers = {};
  final Map<String, int> _maxSizes = {};

  /// Register a cache with size limits and cleanup
  void registerCache<T>(
    String cacheName,
    dynamic cache, {
    int maxSize = 100,
    Duration? cleanupInterval,
  }) {
    _caches[cacheName] = cache;
    _maxSizes[cacheName] = maxSize;

    // Cancel any previous cleanup timer for this name so re-registering
    // doesn't leak a periodic timer.
    _cleanupTimers.remove(cacheName)?.cancel();
    if (cleanupInterval != null) {
      _cleanupTimers[cacheName] = Timer.periodic(cleanupInterval, (_) {
        _cleanupCache(cacheName);
      });
    }

    AppLogger.debug('Registered cache: $cacheName (maxSize: $maxSize)');
  }

  /// Unregister a cache: cancels its cleanup timer and drops all references.
  /// Call from the owner's dispose (e.g. SiteManager.dispose).
  void unregisterCache(String cacheName) {
    _cleanupTimers.remove(cacheName)?.cancel();
    _caches.remove(cacheName);
    _maxSizes.remove(cacheName);
    AppLogger.debug('Unregistered cache: $cacheName');
  }

  /// Get cache by name
  T? getCache<T>(String cacheName) {
    return _caches[cacheName] as T?;
  }

  /// Cleanup specific cache
  void _cleanupCache(String cacheName) {
    final cache = _caches[cacheName];
    if (cache == null) return;

    try {
      if (cache is LRUCache) {
        // LRUCache evicts on insert by itself — nothing to do periodically.
        return;
      }
      if (cache is Map) {
        // For Map-based caches, remove oldest entries if over limit
        final maxSize = _maxSizes[cacheName] ?? 100;
        if (cache.length > maxSize) {
          final entriesToRemove = cache.length - maxSize;
          final keys = cache.keys.take(entriesToRemove).toList();
          for (final key in keys) {
            cache.remove(key);
          }
          AppLogger.debug('Cleaned up $entriesToRemove entries from $cacheName');
        }
      }
    } catch (e) {
      AppLogger.warning('Error cleaning cache $cacheName: $e');
    }
  }

  /// Clear specific cache
  void clearCache(String cacheName) {
    final cache = _caches[cacheName];
    if (cache != null) {
      _clearCacheInstance(cache);
      AppLogger.debug('Cleared cache: $cacheName');
    }
  }

  /// Clear all caches
  void clearAllCaches() {
    for (final cache in _caches.values) {
      _clearCacheInstance(cache);
    }
    AppLogger.info('Cleared all caches');
  }

  void _clearCacheInstance(dynamic cache) {
    if (cache is LRUCache) {
      cache.clear();
    } else if (cache is Map) {
      cache.clear();
    } else if (cache is List) {
      cache.clear();
    }
  }

  /// Get memory usage statistics
  Map<String, dynamic> getMemoryStats() {
    final stats = <String, dynamic>{};

    for (final entry in _caches.entries) {
      final cacheName = entry.key;
      final cache = entry.value;

      if (cache is LRUCache) {
        stats[cacheName] = {
          'type': 'LRUCache',
          'size': cache.size,
          'maxSize': _maxSizes[cacheName],
        };
      } else if (cache is Map) {
        stats[cacheName] = {
          'type': 'Map',
          'size': cache.length,
          'maxSize': _maxSizes[cacheName],
        };
      } else if (cache is List) {
        stats[cacheName] = {
          'type': 'List',
          'size': cache.length,
        };
      }
    }

    return stats;
  }

  /// Dispose all resources
  void dispose() {
    for (final timer in _cleanupTimers.values) {
      timer.cancel();
    }
    _cleanupTimers.clear();
    _caches.clear();
    _maxSizes.clear();
    AppLogger.info('CacheManager disposed');
  }
}
