enum StaffCommunicationType {
  call,
  whatsapp,
  sms,
}

class StaffCommunicationLogEntry {
  const StaffCommunicationLogEntry({
    required this.id,
    required this.type,
    required this.staffUserId,
    required this.staffName,
    required this.patientName,
    required this.doctorName,
    required this.timestamp,
    this.patientId,
    this.doctorId,
    this.phone,
  });

  final String id;
  final StaffCommunicationType type;
  final String staffUserId;
  final String staffName;
  final String patientName;
  final String doctorName;
  final DateTime timestamp;
  final String? patientId;
  final String? doctorId;
  final String? phone;
}
