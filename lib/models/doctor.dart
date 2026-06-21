import 'package:flutter/widgets.dart';

import 'clinic.dart';
import 'doctor_profile_visibility.dart';
import 'localized_text.dart';
import 'specialty.dart';

import '../utils/localization_utils.dart';

class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialtyId,
    required this.specialty,
    required this.clinicId,
    required this.clinic,
    required this.rating,
    required this.experienceYears,
    required this.bio,
    required this.isAvailableToday,
    this.photoUrl,
    this.academicDegree,
    this.clinicName,
    this.clinicAddress,
    this.latitude,
    this.longitude,
    this.workingDays,
    this.contactPhone,
    this.whatsappNumber,
    this.contactEmail,
    this.workingHours,
    this.languagesSpoken,
    this.consultationFee,
    this.clinicPhotos,
    this.profileVisibility = const DoctorProfileVisibility(),
  });

  final String id;
  final LocalizedText name;
  final String specialtyId;
  final Specialty specialty;
  final String clinicId;
  final Clinic clinic;
  final double rating;
  final int experienceYears;
  final LocalizedText bio;
  final bool isAvailableToday;
  final String? photoUrl;
  final LocalizedText? academicDegree;
  final LocalizedText? clinicName;
  final LocalizedText? clinicAddress;
  final double? latitude;
  final double? longitude;
  /// Weekday numbers 1 (Mon) through 7 (Sun), matching [DateTime.weekday].
  final List<int>? workingDays;
  final String? contactPhone;
  final String? whatsappNumber;
  final String? contactEmail;
  final LocalizedText? workingHours;
  final List<String>? languagesSpoken;
  final double? consultationFee;
  final List<String>? clinicPhotos;
  final DoctorProfileVisibility profileVisibility;

  LocalizedText get effectiveClinicName => clinicName ?? clinic.name;
  LocalizedText get effectiveAddress => clinicAddress ?? clinic.address;
  double get effectiveLatitude => latitude ?? clinic.latitude;
  double get effectiveLongitude => longitude ?? clinic.longitude;
  String get effectiveContactPhone => contactPhone ?? clinic.phone;
  String? get effectiveWhatsappNumber =>
      whatsappNumber ?? contactPhone ?? clinic.phone;

  static bool localizedHasText(LocalizedText? text) {
    if (text == null) return false;
    return text.ku.trim().isNotEmpty ||
        text.ar.trim().isNotEmpty ||
        text.en.trim().isNotEmpty;
  }

  bool get hasOwnGpsCoordinates =>
      latitude != null &&
      longitude != null &&
      (latitude!.abs() > 0.0001 || longitude!.abs() > 0.0001);

  String? get patientVisiblePhotoUrl =>
      profileVisibility.showProfilePhoto &&
              photoUrl != null &&
              photoUrl!.trim().isNotEmpty
          ? photoUrl!.trim()
          : null;

  String? patientVisibleDegree(BuildContext context) {
    if (!profileVisibility.showDegrees) return null;
    final degree = academicDegree?.localized(context).trim();
    return (degree != null && degree.isNotEmpty) ? degree : null;
  }

  bool get patientShowsExperience =>
      profileVisibility.showExperience && experienceYears > 0;

  bool patientShowsBio(BuildContext context) =>
      profileVisibility.showBio && bio.localized(context).trim().isNotEmpty;

  bool get patientShowsConsultationFee =>
      profileVisibility.showConsultationFee &&
      consultationFee != null &&
      consultationFee! > 0;

  bool get patientShowsPhone =>
      profileVisibility.showPhoneNumber &&
      contactPhone != null &&
      contactPhone!.trim().isNotEmpty;

  bool get patientShowsWhatsapp =>
      profileVisibility.showWhatsapp &&
      whatsappNumber != null &&
      whatsappNumber!.trim().isNotEmpty;

  String? get patientVisibleWhatsapp =>
      patientShowsWhatsapp ? whatsappNumber!.trim() : null;

  bool get patientShowsGpsLocation =>
      profileVisibility.showGpsLocation && hasOwnGpsCoordinates;

  bool get patientShowsClinicPhotos =>
      profileVisibility.showClinicPhotos &&
      clinicPhotos != null &&
      clinicPhotos!.isNotEmpty;

  bool patientShowsWorkingHours(BuildContext context) =>
      workingHours != null && workingHours!.localized(context).trim().isNotEmpty;

  bool get patientShowsWorkingDays =>
      workingDays != null && workingDays!.isNotEmpty;

  bool patientShowsSchedule(BuildContext context) =>
      patientShowsWorkingHours(context) || patientShowsWorkingDays;

  factory Doctor.fromMap({
    required String id,
    required Map<String, dynamic> data,
    required Specialty specialty,
    required Clinic clinic,
  }) {
    final specId = data['specialtyId'] as String? ?? specialty.id;
    final clinId = data['clinicId'] as String? ?? clinic.id;
    return Doctor(
      id: id,
      name: LocalizedText.fromMap(data['name'] as Map<String, dynamic>?),
      specialtyId: specId,
      specialty: specialty,
      clinicId: clinId,
      clinic: clinic,
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      experienceYears: (data['experienceYears'] as num?)?.toInt() ?? 0,
      bio: LocalizedText.fromMap(data['bio'] as Map<String, dynamic>?),
      isAvailableToday: data['isAvailableToday'] as bool? ?? false,
      photoUrl: data['photoUrl'] as String?,
      academicDegree: data['academicDegree'] != null
          ? LocalizedText.fromMap(
              data['academicDegree'] as Map<String, dynamic>?,
            )
          : null,
      clinicName: data['clinicName'] != null
          ? LocalizedText.fromMap(data['clinicName'] as Map<String, dynamic>?)
          : null,
      clinicAddress: data['clinicAddress'] != null
          ? LocalizedText.fromMap(
              data['clinicAddress'] as Map<String, dynamic>?,
            )
          : null,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      workingDays: (data['workingDays'] as List<dynamic>?)
          ?.map((d) => (d as num).toInt())
          .toList(),
      contactPhone: data['contactPhone'] as String?,
      whatsappNumber: data['whatsappNumber'] as String?,
      contactEmail: data['contactEmail'] as String?,
      workingHours: data['workingHours'] != null
          ? LocalizedText.fromMap(data['workingHours'] as Map<String, dynamic>?)
          : null,
      languagesSpoken: (data['languagesSpoken'] as List<dynamic>?)
          ?.map((l) => l as String)
          .toList(),
      consultationFee: (data['consultationFee'] as num?)?.toDouble(),
      clinicPhotos: (data['clinicPhotos'] as List<dynamic>?)
          ?.map((p) => p as String)
          .where((p) => p.trim().isNotEmpty)
          .toList(),
      profileVisibility: DoctorProfileVisibility.fromMap(
        data['profileVisibility'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name.toMap(),
        'specialtyId': specialtyId,
        'clinicId': clinicId,
        'rating': rating,
        'experienceYears': experienceYears,
        'bio': bio.toMap(),
        'isAvailableToday': isAvailableToday,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (academicDegree != null) 'academicDegree': academicDegree!.toMap(),
        if (clinicName != null) 'clinicName': clinicName!.toMap(),
        if (clinicAddress != null) 'clinicAddress': clinicAddress!.toMap(),
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (workingDays != null && workingDays!.isNotEmpty)
          'workingDays': workingDays,
        if (contactPhone != null) 'contactPhone': contactPhone,
        if (whatsappNumber != null) 'whatsappNumber': whatsappNumber,
        if (contactEmail != null) 'contactEmail': contactEmail,
        if (workingHours != null) 'workingHours': workingHours!.toMap(),
        if (languagesSpoken != null && languagesSpoken!.isNotEmpty)
          'languagesSpoken': languagesSpoken,
        if (consultationFee != null) 'consultationFee': consultationFee,
        if (clinicPhotos != null && clinicPhotos!.isNotEmpty)
          'clinicPhotos': clinicPhotos,
        'profileVisibility': profileVisibility.toMap(),
      };

  Doctor copyWith({
    LocalizedText? name,
    String? specialtyId,
    Specialty? specialty,
    String? clinicId,
    Clinic? clinic,
    double? rating,
    int? experienceYears,
    LocalizedText? bio,
    bool? isAvailableToday,
    String? photoUrl,
    LocalizedText? academicDegree,
    LocalizedText? clinicName,
    LocalizedText? clinicAddress,
    double? latitude,
    double? longitude,
    List<int>? workingDays,
    String? contactPhone,
    String? whatsappNumber,
    String? contactEmail,
    LocalizedText? workingHours,
    List<String>? languagesSpoken,
    double? consultationFee,
    List<String>? clinicPhotos,
    DoctorProfileVisibility? profileVisibility,
  }) {
    return Doctor(
      id: id,
      name: name ?? this.name,
      specialtyId: specialtyId ?? this.specialtyId,
      specialty: specialty ?? this.specialty,
      clinicId: clinicId ?? this.clinicId,
      clinic: clinic ?? this.clinic,
      rating: rating ?? this.rating,
      experienceYears: experienceYears ?? this.experienceYears,
      bio: bio ?? this.bio,
      isAvailableToday: isAvailableToday ?? this.isAvailableToday,
      photoUrl: photoUrl ?? this.photoUrl,
      academicDegree: academicDegree ?? this.academicDegree,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      workingDays: workingDays ?? this.workingDays,
      contactPhone: contactPhone ?? this.contactPhone,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      contactEmail: contactEmail ?? this.contactEmail,
      workingHours: workingHours ?? this.workingHours,
      languagesSpoken: languagesSpoken ?? this.languagesSpoken,
      consultationFee: consultationFee ?? this.consultationFee,
      clinicPhotos: clinicPhotos ?? this.clinicPhotos,
      profileVisibility: profileVisibility ?? this.profileVisibility,
    );
  }
}
