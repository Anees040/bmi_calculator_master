/// In-memory cache with expiration
library cache;

/// Generic cache entry with expiration
class CacheEntry<T> {
  CacheEntry({
    required this.value,
    this.expiresIn = const Duration(hours: 1),
  }) :expressedAt = DateTime.now();

  final T value;
  final Duration expiresIn;
  final DateTime expressedAt;

  /// Check if entry is expired
  bool get isExpired {
    return DateTime.now().difference(expressedAt) > expiresIn;
  }
}

/// Simple in-memory cache implementation
class AppCache<K, V> {
  final Map<K, CacheEntry<V>> _cache = {};

  /// Get value from cache
  V? get(K key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.value;
  }

  /// Set value in cache
  void set(K key, V value, {Duration? expiresIn}) {
    _cache[key] = CacheEntry(
      value: value,
      expiresIn: expiresIn ?? const Duration(hours: 1),
    );
  }

  /// Remove specific key
  void remove(K key) {
    _cache.remove(key);
  }

  /// Clear entire cache
  void clear() {
    _cache.clear();
  }

  /// Get cache size
  int get size => _cache.length;

  /// Check if cache contains key
  bool contains(K key) {
    return get(key) != null;
  }

  /// Clean expired entries
  void cleanExpired() {
    _cache.removeWhere((_, entry) => entry.isExpired);
  }
}

/// Singleton cache instance for app
final appCache = AppCache<String, dynamic>();
