class DoctorProfileVisibility {
  const DoctorProfileVisibility({
    this.showConsultationFee = true,
    this.showBio = true,
    this.showGpsLocation = true,
    this.showPhoneNumber = true,
    this.showWhatsapp = true,
    this.showEmail = true,
    this.showProfilePhoto = true,
    this.showExperience = true,
    this.showDegrees = true,
    this.showClinicPhotos = true,
  });

  final bool showConsultationFee;
  final bool showBio;
  final bool showGpsLocation;
  final bool showPhoneNumber;
  final bool showWhatsapp;
  final bool showEmail;
  final bool showProfilePhoto;
  final bool showExperience;
  final bool showDegrees;
  final bool showClinicPhotos;

  factory DoctorProfileVisibility.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const DoctorProfileVisibility();
    return DoctorProfileVisibility(
      showConsultationFee: _readBool(map['showConsultationFee'], true),
      showBio: _readBool(map['showBio'], true),
      showGpsLocation: _readBool(map['showGpsLocation'], true),
      showPhoneNumber: _readBool(map['showPhoneNumber'], true),
      showWhatsapp: _readBool(map['showWhatsapp'], true),
      showEmail: _readBool(map['showEmail'], true),
      showProfilePhoto: _readBool(map['showProfilePhoto'], true),
      showExperience: _readBool(map['showExperience'], true),
      showDegrees: _readBool(map['showDegrees'], true),
      showClinicPhotos: _readBool(map['showClinicPhotos'], true),
    );
  }

  static DoctorProfileVisibility fromFirestore(dynamic value) {
    if (value is Map<String, dynamic>) {
      return DoctorProfileVisibility.fromMap(value);
    }
    if (value is Map) {
      return DoctorProfileVisibility.fromMap(
        value.map((key, val) => MapEntry(key.toString(), val)),
      );
    }
    return const DoctorProfileVisibility();
  }

  static bool _readBool(dynamic value, bool defaultValue) {
    if (value is bool) return value;
    return defaultValue;
  }

  Map<String, dynamic> toMap() => {
        'showConsultationFee': showConsultationFee,
        'showBio': showBio,
        'showGpsLocation': showGpsLocation,
        'showPhoneNumber': showPhoneNumber,
        'showWhatsapp': showWhatsapp,
        'showEmail': showEmail,
        'showProfilePhoto': showProfilePhoto,
        'showExperience': showExperience,
        'showDegrees': showDegrees,
        'showClinicPhotos': showClinicPhotos,
      };

  DoctorProfileVisibility copyWith({
    bool? showConsultationFee,
    bool? showBio,
    bool? showGpsLocation,
    bool? showPhoneNumber,
    bool? showWhatsapp,
    bool? showEmail,
    bool? showProfilePhoto,
    bool? showExperience,
    bool? showDegrees,
    bool? showClinicPhotos,
  }) {
    return DoctorProfileVisibility(
      showConsultationFee: showConsultationFee ?? this.showConsultationFee,
      showBio: showBio ?? this.showBio,
      showGpsLocation: showGpsLocation ?? this.showGpsLocation,
      showPhoneNumber: showPhoneNumber ?? this.showPhoneNumber,
      showWhatsapp: showWhatsapp ?? this.showWhatsapp,
      showEmail: showEmail ?? this.showEmail,
      showProfilePhoto: showProfilePhoto ?? this.showProfilePhoto,
      showExperience: showExperience ?? this.showExperience,
      showDegrees: showDegrees ?? this.showDegrees,
      showClinicPhotos: showClinicPhotos ?? this.showClinicPhotos,
    );
  }
}
