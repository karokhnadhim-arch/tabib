/// Coalesces duplicate in-flight async requests and optionally caches results.
class AsyncRequestCache<K, V> {
  AsyncRequestCache({this.ttl});

  final Duration? ttl;
  final Map<K, Future<V>> _inFlight = {};
  final Map<K, _CacheEntry<V>> _cache = {};

  Future<V> run(
    K key,
    Future<V> Function() loader, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _cache[key];
      if (cached != null && !cached.isExpired(ttl)) {
        return cached.value;
      }
      final pending = _inFlight[key];
      if (pending != null) return pending;
    }

    final future = loader();
    _inFlight[key] = future;
    try {
      final value = await future;
      _cache[key] = _CacheEntry(value, DateTime.now());
      return value;
    } finally {
      _inFlight.remove(key);
    }
  }

  void invalidate([K? key]) {
    if (key == null) {
      _cache.clear();
      return;
    }
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
    _inFlight.clear();
  }
}

class _CacheEntry<V> {
  _CacheEntry(this.value, this.storedAt);

  final V value;
  final DateTime storedAt;

  bool isExpired(Duration? ttl) {
    if (ttl == null) return false;
    return DateTime.now().difference(storedAt) > ttl;
  }
}
