/// Functional area for an audit record.
enum AuditModule {
  authentication('authentication'),
  owner('owner'),
  secretary('secretary'),
  doctor('doctor'),
  patient('patient'),
  system('system');

  const AuditModule(this.storageKey);
  final String storageKey;

  static AuditModule? fromStorage(String? raw) {
    if (raw == null) return null;
    for (final m in AuditModule.values) {
      if (m.storageKey == raw) return m;
    }
    return null;
  }
}

/// Immutable action type — used for filtering and statistics.
enum AuditActionType {
  login('login'),
  logout('logout'),
  failedLogin('failed_login'),
  passwordChanged('password_changed'),
  userCreated('user_created'),
  userDeleted('user_deleted'),
  userActivated('user_activated'),
  userDeactivated('user_deactivated'),
  roleChanged('role_changed'),
  settingsChanged('settings_changed'),
  medicineChanged('medicine_changed'),
  investigationChanged('investigation_changed'),
  patientRegistered('patient_registered'),
  patientEdited('patient_edited'),
  queueCreated('queue_created'),
  queueModified('queue_modified'),
  patientSentToDoctor('patient_sent_to_doctor'),
  patientCompleted('patient_completed'),
  patientCancelled('patient_cancelled'),
  diagnosisCreated('diagnosis_created'),
  diagnosisUpdated('diagnosis_updated'),
  prescriptionCreated('prescription_created'),
  prescriptionModified('prescription_modified'),
  investigationRequested('investigation_requested'),
  clinicalNoteAdded('clinical_note_added'),
  prescriptionPrinted('prescription_printed'),
  appointmentViewed('appointment_viewed'),
  prescriptionViewed('prescription_viewed'),
  investigationViewed('investigation_viewed'),
  other('other');

  const AuditActionType(this.storageKey);
  final String storageKey;

  static AuditActionType fromStorage(String? raw) {
    if (raw == null) return AuditActionType.other;
    for (final a in AuditActionType.values) {
      if (a.storageKey == raw) return a;
    }
    return AuditActionType.other;
  }
}
