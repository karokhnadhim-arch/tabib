import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/staff_communication_log.dart';

/// Internal staff→patient communication audit trail (not shown to patients).
class StaffCommunicationLogService extends ChangeNotifier {
  StaffCommunicationLogService();

  static const _uuid = Uuid();
  final List<StaffCommunicationLogEntry> _entries = [];

  List<StaffCommunicationLogEntry> get entries => List.unmodifiable(
        _entries..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
      );

  void record({
    required StaffCommunicationType type,
    required String staffUserId,
    required String staffName,
    required String patientName,
    required String doctorName,
    String? patientId,
    String? doctorId,
    String? phone,
  }) {
    _entries.insert(
      0,
      StaffCommunicationLogEntry(
        id: _uuid.v4(),
        type: type,
        staffUserId: staffUserId,
        staffName: staffName,
        patientName: patientName,
        doctorName: doctorName,
        timestamp: DateTime.now(),
        patientId: patientId,
        doctorId: doctorId,
        phone: phone,
      ),
    );
    notifyListeners();
  }
}
