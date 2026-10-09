class CacheEntry<T> {
  final T data;
  final DateTime expiry;

  CacheEntry(this.data, this.expiry);

  bool get isExpired => DateTime.now().isAfter(expiry);
}

class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  final Map<String, CacheEntry<dynamic>> _cache = {};

  /// Retrieves cached value if present and not expired
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.data as T?;
  }

  /// Stores value with a duration
  void set<T>(String key, T data, Duration duration) {
    _cache[key] = CacheEntry<T>(data, DateTime.now().add(duration));
  }

  /// Invalidate specific key
  void invalidate(String key) {
    _cache.remove(key);
  }

  /// Invalidate all keys starting with prefix
  void invalidatePrefix(String prefix) {
    _cache.removeWhere((key, value) => key.startsWith(prefix));
  }

  /// Invalidate entire cache
  void clear() {
    _cache.clear();
  }
}
