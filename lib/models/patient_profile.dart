/// Extended patient profile stored on the user document.
class PatientProfile {
  const PatientProfile({
    this.photoUrl,
    this.photoThumbnailUrl,
    this.city,
    this.gender,
    this.showProfilePhoto = true,
    this.showPhoneNumber = true,
    this.visibleToVisitedOnly = false,
  });

  final String? photoUrl;
  final String? photoThumbnailUrl;
  final String? city;
  final String? gender;
  final bool showProfilePhoto;
  final bool showPhoneNumber;
  final bool visibleToVisitedOnly;

  PatientProfile copyWith({
    String? photoUrl,
    String? photoThumbnailUrl,
    String? city,
    String? gender,
    bool? showProfilePhoto,
    bool? showPhoneNumber,
    bool? visibleToVisitedOnly,
  }) =>
      PatientProfile(
        photoUrl: photoUrl ?? this.photoUrl,
        photoThumbnailUrl: photoThumbnailUrl ?? this.photoThumbnailUrl,
        city: city ?? this.city,
        gender: gender ?? this.gender,
        showProfilePhoto: showProfilePhoto ?? this.showProfilePhoto,
        showPhoneNumber: showPhoneNumber ?? this.showPhoneNumber,
        visibleToVisitedOnly:
            visibleToVisitedOnly ?? this.visibleToVisitedOnly,
      );

  Map<String, dynamic> toMap() => {
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (photoThumbnailUrl != null) 'photoThumbnailUrl': photoThumbnailUrl,
        if (city != null && city!.isNotEmpty) 'city': city,
        if (gender != null && gender!.isNotEmpty) 'gender': gender,
        'showProfilePhoto': showProfilePhoto,
        'showPhoneNumber': showPhoneNumber,
        'visibleToVisitedOnly': visibleToVisitedOnly,
      };

  factory PatientProfile.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const PatientProfile();
    return PatientProfile(
      photoUrl: map['photoUrl'] as String?,
      photoThumbnailUrl: map['photoThumbnailUrl'] as String?,
      city: map['city'] as String?,
      gender: map['gender'] as String?,
      showProfilePhoto: map['showProfilePhoto'] != false,
      showPhoneNumber: map['showPhoneNumber'] != false,
      visibleToVisitedOnly: map['visibleToVisitedOnly'] == true,
    );
  }
}
