class DoctorProfileVisibility {
  const DoctorProfileVisibility({
    this.showConsultationFee = true,
    this.showBio = true,
    this.showGpsLocation = true,
    this.showPhoneNumber = true,
    this.showWhatsapp = true,
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
  final bool showProfilePhoto;
  final bool showExperience;
  final bool showDegrees;
  final bool showClinicPhotos;

  factory DoctorProfileVisibility.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const DoctorProfileVisibility();
    return DoctorProfileVisibility(
      showConsultationFee: map['showConsultationFee'] as bool? ?? true,
      showBio: map['showBio'] as bool? ?? true,
      showGpsLocation: map['showGpsLocation'] as bool? ?? true,
      showPhoneNumber: map['showPhoneNumber'] as bool? ?? true,
      showWhatsapp: map['showWhatsapp'] as bool? ?? true,
      showProfilePhoto: map['showProfilePhoto'] as bool? ?? true,
      showExperience: map['showExperience'] as bool? ?? true,
      showDegrees: map['showDegrees'] as bool? ?? true,
      showClinicPhotos: map['showClinicPhotos'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'showConsultationFee': showConsultationFee,
        'showBio': showBio,
        'showGpsLocation': showGpsLocation,
        'showPhoneNumber': showPhoneNumber,
        'showWhatsapp': showWhatsapp,
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
      showProfilePhoto: showProfilePhoto ?? this.showProfilePhoto,
      showExperience: showExperience ?? this.showExperience,
      showDegrees: showDegrees ?? this.showDegrees,
      showClinicPhotos: showClinicPhotos ?? this.showClinicPhotos,
    );
  }
}
