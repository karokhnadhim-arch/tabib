/// Platform-wide queue and prescription defaults — owner configurable.
class PlatformClinicalSettings {
  const PlatformClinicalSettings({
    this.consultationMinutesDefault = 15,
    this.autoAssignQueueNumbers = true,
    this.queueStartNumber = 1,
    this.showCompletedInSecretaryQueue = true,
    this.prescriptionHeaderClinicName = '',
    this.prescriptionHeaderAddress = '',
    this.prescriptionHeaderPhone = '',
    this.prescriptionFooterNote = '',
    this.prescriptionShowDiagnosis = true,
  });

  final int consultationMinutesDefault;
  final bool autoAssignQueueNumbers;
  final int queueStartNumber;
  final bool showCompletedInSecretaryQueue;
  final String prescriptionHeaderClinicName;
  final String prescriptionHeaderAddress;
  final String prescriptionHeaderPhone;
  final String prescriptionFooterNote;
  final bool prescriptionShowDiagnosis;

  PlatformClinicalSettings copyWith({
    int? consultationMinutesDefault,
    bool? autoAssignQueueNumbers,
    int? queueStartNumber,
    bool? showCompletedInSecretaryQueue,
    String? prescriptionHeaderClinicName,
    String? prescriptionHeaderAddress,
    String? prescriptionHeaderPhone,
    String? prescriptionFooterNote,
    bool? prescriptionShowDiagnosis,
  }) {
    return PlatformClinicalSettings(
      consultationMinutesDefault:
          consultationMinutesDefault ?? this.consultationMinutesDefault,
      autoAssignQueueNumbers:
          autoAssignQueueNumbers ?? this.autoAssignQueueNumbers,
      queueStartNumber: queueStartNumber ?? this.queueStartNumber,
      showCompletedInSecretaryQueue:
          showCompletedInSecretaryQueue ?? this.showCompletedInSecretaryQueue,
      prescriptionHeaderClinicName:
          prescriptionHeaderClinicName ?? this.prescriptionHeaderClinicName,
      prescriptionHeaderAddress:
          prescriptionHeaderAddress ?? this.prescriptionHeaderAddress,
      prescriptionHeaderPhone:
          prescriptionHeaderPhone ?? this.prescriptionHeaderPhone,
      prescriptionFooterNote:
          prescriptionFooterNote ?? this.prescriptionFooterNote,
      prescriptionShowDiagnosis:
          prescriptionShowDiagnosis ?? this.prescriptionShowDiagnosis,
    );
  }

  Map<String, dynamic> toMap() => {
        'consultationMinutesDefault': consultationMinutesDefault,
        'autoAssignQueueNumbers': autoAssignQueueNumbers,
        'queueStartNumber': queueStartNumber,
        'showCompletedInSecretaryQueue': showCompletedInSecretaryQueue,
        'prescriptionHeaderClinicName': prescriptionHeaderClinicName,
        'prescriptionHeaderAddress': prescriptionHeaderAddress,
        'prescriptionHeaderPhone': prescriptionHeaderPhone,
        'prescriptionFooterNote': prescriptionFooterNote,
        'prescriptionShowDiagnosis': prescriptionShowDiagnosis,
      };

  factory PlatformClinicalSettings.fromMap(Map<String, dynamic> data) {
    return PlatformClinicalSettings(
      consultationMinutesDefault:
          (data['consultationMinutesDefault'] as num?)?.toInt() ?? 15,
      autoAssignQueueNumbers:
          data['autoAssignQueueNumbers'] as bool? ?? true,
      queueStartNumber: (data['queueStartNumber'] as num?)?.toInt() ?? 1,
      showCompletedInSecretaryQueue:
          data['showCompletedInSecretaryQueue'] as bool? ?? true,
      prescriptionHeaderClinicName:
          data['prescriptionHeaderClinicName'] as String? ?? '',
      prescriptionHeaderAddress:
          data['prescriptionHeaderAddress'] as String? ?? '',
      prescriptionHeaderPhone: data['prescriptionHeaderPhone'] as String? ?? '',
      prescriptionFooterNote: data['prescriptionFooterNote'] as String? ?? '',
      prescriptionShowDiagnosis:
          data['prescriptionShowDiagnosis'] as bool? ?? true,
    );
  }

  static const defaults = PlatformClinicalSettings();
}
