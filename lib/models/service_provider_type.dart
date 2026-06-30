/// Whether a catalog profile is an individual doctor or a healthcare business.
enum ServiceProviderAccountType {
  doctor('doctor'),
  business('business');

  const ServiceProviderAccountType(this.storageKey);
  final String storageKey;

  static ServiceProviderAccountType fromStorage(String? value) {
    if (value == ServiceProviderAccountType.business.storageKey) {
      return ServiceProviderAccountType.business;
    }
    return ServiceProviderAccountType.doctor;
  }

  bool get isBusiness => this == ServiceProviderAccountType.business;
  bool get isDoctor => this == ServiceProviderAccountType.doctor;
}

/// Business category for healthcare service locations (not individual doctors).
enum BusinessCategory {
  clinic('clinic'),
  beautyCenter('beauty_center'),
  medicalLaboratory('medical_laboratory'),
  radiologyCenter('radiology_center'),
  physiotherapyCenter('physiotherapy_center'),
  dentalCenter('dental_center'),
  eyeCenter('eye_center'),
  hearingCenter('hearing_center'),
  vaccinationCenter('vaccination_center'),
  bloodTestCenter('blood_test_center'),
  pharmacy('pharmacy'),
  otherHealthcare('other_healthcare');

  const BusinessCategory(this.storageKey);
  final String storageKey;

  static BusinessCategory? fromStorage(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final category in BusinessCategory.values) {
      if (category.storageKey == value) return category;
    }
    return null;
  }

  /// Default specialty catalog id used for filtering and legacy joins.
  String get defaultSpecialtyId => switch (this) {
        BusinessCategory.dentalCenter => 'dental',
        BusinessCategory.clinic => 'general',
        BusinessCategory.eyeCenter => 'eye',
        _ => 'healthcare_services',
      };
}
