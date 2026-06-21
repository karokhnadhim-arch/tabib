import 'dart:async';

/// Ensures only one active listener per key; cancels the previous subscription.
class SubscriptionManager {
  final Map<String, StreamSubscription<dynamic>> _subs = {};

  void bind<T>(
    String key,
    Stream<T> stream,
    void Function(T data) onData, {
    void Function(Object error)? onError,
    void Function()? onDone,
  }) {
    if (_subs.containsKey(key)) return;
    _subs[key] = stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
    );
  }

  /// Replace listener when key parameters change (e.g. different doctorId).
  void replace<T>(
    String key,
    Stream<T> stream,
    void Function(T data) onData, {
    void Function(Object error)? onError,
  }) {
    final existing = _subs[key];
    if (existing != null) {
      unawaited(existing.cancel());
      _subs.remove(key);
    }
    _subs[key] = stream.listen(onData, onError: onError);
  }

  void cancel(String key) {
    final sub = _subs.remove(key);
    if (sub != null) unawaited(sub.cancel());
  }

  void cancelAll() {
    for (final sub in _subs.values) {
      unawaited(sub.cancel());
    }
    _subs.clear();
  }
}
