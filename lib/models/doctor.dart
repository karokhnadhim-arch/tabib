import 'package:flutter/widgets.dart';

import 'clinic.dart';
import 'doctor_profile_visibility.dart';
import 'doctor_working_schedule.dart';
import 'localized_text.dart';
import 'service_provider_type.dart';
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
    this.photoThumbnailUrl,
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
    this.workingSchedule,
    this.languagesSpoken,
    this.consultationFee,
    this.clinicPhotos,
    this.clinicPhotoThumbnails,
    this.profileVisibility = const DoctorProfileVisibility(),
    this.accountType = ServiceProviderAccountType.doctor,
    this.businessCategory,
    this.accountCode,
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
  final String? photoThumbnailUrl;
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
  final List<DoctorDaySchedule>? workingSchedule;
  final List<String>? languagesSpoken;
  final double? consultationFee;
  final List<String>? clinicPhotos;
  final List<String>? clinicPhotoThumbnails;
  final DoctorProfileVisibility profileVisibility;
  final ServiceProviderAccountType accountType;
  final BusinessCategory? businessCategory;
  /// Permanent code (DR-xxxxx / BZ-xxxxx) — doctors and businesses only.
  final String? accountCode;

  bool get isBusiness => accountType.isBusiness;
  bool get isDoctorAccount => accountType.isDoctor;

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

  bool get patientShowsEmail =>
      profileVisibility.showEmail &&
      contactEmail != null &&
      contactEmail!.trim().isNotEmpty;

  String? get patientVisibleEmail =>
      patientShowsEmail ? contactEmail!.trim() : null;

  bool get patientShowsAnyContact =>
      patientShowsPhone || patientShowsWhatsapp || patientShowsEmail;

  bool get patientShowsGpsLocation =>
      profileVisibility.showGpsLocation && hasOwnGpsCoordinates;

  bool get patientShowsClinicPhotos =>
      profileVisibility.showClinicPhotos &&
      clinicPhotos != null &&
      clinicPhotos!.isNotEmpty;

  String? get patientVisiblePhotoThumbnailUrl =>
      profileVisibility.showProfilePhoto
          ? (photoThumbnailUrl ?? photoUrl)?.trim().isNotEmpty == true
              ? (photoThumbnailUrl ?? photoUrl)!.trim()
              : null
          : null;

  List<String>? get patientVisibleClinicPhotoThumbnails {
    if (!patientShowsClinicPhotos) return null;
    final photos = clinicPhotos!;
    final thumbs = clinicPhotoThumbnails;
    if (thumbs == null || thumbs.length != photos.length) {
      return photos;
    }
    return thumbs;
  }

  bool patientShowsWorkingHours(BuildContext context) =>
      workingHours != null && workingHours!.localized(context).trim().isNotEmpty;

  bool get patientShowsWorkingDays =>
      workingDays != null && workingDays!.isNotEmpty;

  bool get patientShowsStructuredSchedule =>
      effectiveWorkingSchedule.hasConfiguredSchedule;

  bool patientShowsSchedule(BuildContext context) =>
      patientShowsStructuredSchedule ||
      patientShowsWorkingHours(context) ||
      patientShowsWorkingDays;

  DoctorWorkingSchedule get effectiveWorkingSchedule {
    if (workingSchedule != null && workingSchedule!.isNotEmpty) {
      return DoctorWorkingSchedule(days: workingSchedule!);
    }
    return DoctorWorkingSchedule.fromLegacy(workingDays: workingDays);
  }

  bool isOpenOn(DateTime date) => effectiveWorkingSchedule.isOpenOn(date);

  bool isDateTimeWithinSchedule(DateTime dateTime) =>
      effectiveWorkingSchedule.isDateTimeWithinSchedule(dateTime);

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
      photoThumbnailUrl: data['photoThumbnailUrl'] as String?,
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
      workingSchedule: _parseWorkingSchedule(data),
      languagesSpoken: (data['languagesSpoken'] as List<dynamic>?)
          ?.map((l) => l as String)
          .toList(),
      consultationFee: (data['consultationFee'] as num?)?.toDouble(),
      clinicPhotos: (data['clinicPhotos'] as List<dynamic>?)
          ?.map((p) => p as String)
          .where((p) => p.trim().isNotEmpty)
          .toList(),
      clinicPhotoThumbnails: (data['clinicPhotoThumbnails'] as List<dynamic>?)
          ?.map((p) => p as String)
          .where((p) => p.trim().isNotEmpty)
          .toList(),
      profileVisibility: DoctorProfileVisibility.fromFirestore(
        data['profileVisibility'],
      ),
      accountType: ServiceProviderAccountType.fromStorage(
        data['accountType'] as String?,
      ),
      businessCategory: BusinessCategory.fromStorage(
        data['businessCategory'] as String?,
      ),
      accountCode: data['accountCode'] as String?,
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
        if (photoThumbnailUrl != null) 'photoThumbnailUrl': photoThumbnailUrl,
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
        if (workingSchedule != null && workingSchedule!.isNotEmpty)
          'workingSchedule':
              DoctorWorkingSchedule(days: workingSchedule!).toMapList(),
        if (languagesSpoken != null && languagesSpoken!.isNotEmpty)
          'languagesSpoken': languagesSpoken,
        if (consultationFee != null) 'consultationFee': consultationFee,
        if (clinicPhotos != null && clinicPhotos!.isNotEmpty)
          'clinicPhotos': clinicPhotos,
        if (clinicPhotoThumbnails != null && clinicPhotoThumbnails!.isNotEmpty)
          'clinicPhotoThumbnails': clinicPhotoThumbnails,
        'profileVisibility': profileVisibility.toMap(),
        'accountType': accountType.storageKey,
        if (businessCategory != null)
          'businessCategory': businessCategory!.storageKey,
        if (accountCode != null && accountCode!.isNotEmpty)
          'accountCode': accountCode,
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
    String? photoThumbnailUrl,
    bool clearPhotos = false,
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
    List<DoctorDaySchedule>? workingSchedule,
    List<String>? languagesSpoken,
    double? consultationFee,
    List<String>? clinicPhotos,
    List<String>? clinicPhotoThumbnails,
    DoctorProfileVisibility? profileVisibility,
    ServiceProviderAccountType? accountType,
    BusinessCategory? businessCategory,
    String? accountCode,
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
      photoUrl: clearPhotos ? null : (photoUrl ?? this.photoUrl),
      photoThumbnailUrl:
          clearPhotos ? null : (photoThumbnailUrl ?? this.photoThumbnailUrl),
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
      workingSchedule: workingSchedule ?? this.workingSchedule,
      languagesSpoken: languagesSpoken ?? this.languagesSpoken,
      consultationFee: consultationFee ?? this.consultationFee,
      clinicPhotos: clinicPhotos ?? this.clinicPhotos,
      clinicPhotoThumbnails:
          clinicPhotoThumbnails ?? this.clinicPhotoThumbnails,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      accountType: accountType ?? this.accountType,
      businessCategory: businessCategory ?? this.businessCategory,
      accountCode: accountCode ?? this.accountCode,
    );
  }

  static List<DoctorDaySchedule>? _parseWorkingSchedule(
    Map<String, dynamic> data,
  ) {
    final raw = data['workingSchedule'] as List<dynamic>?;
    if (raw == null || raw.isEmpty) return null;
    return DoctorWorkingSchedule.fromMapList(raw).days;
  }
}
