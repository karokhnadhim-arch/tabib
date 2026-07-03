import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/system_monitoring.dart';

class SystemActivityFeedService extends ChangeNotifier {
  SystemActivityFeedService() {
    _seedDemo();
  }

  static const _uuid = Uuid();
  static const maxEntries = 100;
  final List<ActivityFeedEntry> _entries = [];

  List<ActivityFeedEntry> get entries => List.unmodifiable(_entries);

  void record({
    required ActivityEventType type,
    required String title,
    String? actorName,
  }) {
    _entries.insert(
      0,
      ActivityFeedEntry(
        id: _uuid.v4(),
        type: type,
        title: title,
        timestamp: DateTime.now(),
        actorName: actorName,
      ),
    );
    if (_entries.length > maxEntries) {
      _entries.removeRange(maxEntries, _entries.length);
    }
    notifyListeners();
  }

  void _seedDemo() {
    final now = DateTime.now();
    _entries.addAll([
      ActivityFeedEntry(
        id: 'act_1',
        type: ActivityEventType.patientRegistered,
        title: 'New patient registered',
        timestamp: now.subtract(const Duration(minutes: 4)),
        actorName: 'Demo Patient',
      ),
      ActivityFeedEntry(
        id: 'act_2',
        type: ActivityEventType.queueJoined,
        title: 'Patient joined queue',
        timestamp: now.subtract(const Duration(minutes: 11)),
      ),
      ActivityFeedEntry(
        id: 'act_3',
        type: ActivityEventType.appointmentBooked,
        title: 'Appointment booked',
        timestamp: now.subtract(const Duration(minutes: 25)),
      ),
      ActivityFeedEntry(
        id: 'act_4',
        type: ActivityEventType.login,
        title: 'Staff login',
        timestamp: now.subtract(const Duration(hours: 1)),
        actorName: 'System Owner',
      ),
    ]);
  }
}
