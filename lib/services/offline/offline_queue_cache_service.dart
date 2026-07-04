import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/queue_entry.dart';
import '../queue_service.dart';

/// Mirrors queue snapshots locally — read-only fallback when offline.
class OfflineQueueCacheService extends ChangeNotifier {
  static const _patientPrefix = 'offline_queue_patient_v1_';
  static const _doctorPrefix = 'offline_queue_doctor_v1_';

  List<QueueEntry> _cachedPatientQueues = const [];
  final Map<String, List<QueueEntry>> _cachedDoctorQueues = {};
  String? _patientId;

  List<QueueEntry> cachedPatientQueues(String patientId) =>
      _patientId == patientId ? List.unmodifiable(_cachedPatientQueues) : const [];

  List<QueueEntry> cachedDoctorQueue(String doctorId) =>
      List.unmodifiable(_cachedDoctorQueues[doctorId] ?? const []);

  QueueEntry? cachedActiveEntryForPatient(String patientId) {
    final list = cachedPatientQueues(patientId);
    return list.isNotEmpty ? list.first : null;
  }

  Future<void> bindPatient(String? patientId) async {
    _patientId = patientId;
    if (patientId == null || patientId.isEmpty) {
      _cachedPatientQueues = const [];
      notifyListeners();
      return;
    }
    _cachedPatientQueues = await _loadPatientQueues(patientId);
    notifyListeners();
  }

  void attach(QueueService queue, String patientId) {
    void persist() {
      _persistPatientQueues(patientId, queue.activeQueuesForPatient(patientId));
      for (final doctorId in queue.watchedDoctorIds) {
        _persistDoctorQueue(doctorId, queue.queueForDoctor(doctorId));
      }
    }

    queue.addListener(persist);
    persist();
  }

  Future<void> _persistPatientQueues(
    String patientId,
    List<QueueEntry> entries,
  ) async {
    _cachedPatientQueues = List.unmodifiable(entries);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_patientPrefix$patientId',
      jsonEncode(entries.map(_entryToMap).toList()),
    );
  }

  Future<void> _persistDoctorQueue(
    String doctorId,
    List<QueueEntry> entries,
  ) async {
    _cachedDoctorQueues[doctorId] = List.unmodifiable(entries);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_doctorPrefix$doctorId',
      jsonEncode(entries.map(_entryToMap).toList()),
    );
  }

  Future<List<QueueEntry>> _loadPatientQueues(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_patientPrefix$patientId');
    return _decodeEntries(raw);
  }

  List<QueueEntry> _decodeEntries(String? raw) {
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => _entryFromMap(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Map<String, dynamic> _entryToMap(QueueEntry e) => {
        'id': e.id,
        ...e.toMap(),
      };

  QueueEntry _entryFromMap(Map<String, dynamic> data) {
    final id = data['id'] as String? ?? '';
    return QueueEntry.fromFirestore(id, data);
  }
}
