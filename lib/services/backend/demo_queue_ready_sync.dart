import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/queue_entry.dart';

/// Persists secretary "patient ready" flags in demo mode so doctor + secretary
/// tabs stay in sync (separate browser tabs do not share in-memory state).
abstract final class DemoQueueReadySync {
  static const _flagsKey = 'tabib_demo_patient_ready_flags';
  static const _revisionKey = 'tabib_demo_patient_ready_rev';

  static Timer? _pollTimer;
  static void Function()? _onRemoteChange;

  static void startPolling(void Function() onRemoteChange) {
    _onRemoteChange = onRemoteChange;
    _pollTimer ??= Timer.periodic(
      const Duration(milliseconds: 750),
      (_) => _pullInto(_queuesHolder?.call() ?? const []),
    );
  }

  static List<QueueEntry> Function()? _queuesHolder;

  static void bindQueues(List<QueueEntry> Function() queues) {
    _queuesHolder = queues;
  }

  static Future<void> persist(List<QueueEntry> queues) async {
    final prefs = await SharedPreferences.getInstance();
    final flags = <String, bool>{};
    for (final q in queues) {
      if (q.patientReady) flags[q.id] = true;
    }
    await prefs.setString(_flagsKey, jsonEncode(flags));
    await prefs.setInt(_revisionKey, DateTime.now().millisecondsSinceEpoch);
  }

  static int _lastRevision = 0;

  static Future<void> _pullInto(List<QueueEntry> queues) async {
    if (queues.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final revision = prefs.getInt(_revisionKey) ?? 0;
    if (revision == _lastRevision) return;
    _lastRevision = revision;

    final raw = prefs.getString(_flagsKey);
    if (raw == null) return;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return;
    final flags = decoded.map(
      (key, value) => MapEntry(key.toString(), value == true),
    );

    var changed = false;
    for (final entry in queues) {
      final remote = flags[entry.id] ?? false;
      if (entry.patientReady != remote) {
        entry.patientReady = remote;
        changed = true;
      }
    }
    if (changed) _onRemoteChange?.call();
  }

  static void dispose() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _onRemoteChange = null;
    _queuesHolder = null;
  }
}
