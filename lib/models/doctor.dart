import 'clinic.dart';
import 'localized_text.dart';
import 'specialty.dart';

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

  Map<String, dynamic> toMap() => {
        'name': name.toMap(),
        'specialtyId': specialtyId,
        'clinicId': clinicId,
        'rating': rating,
        'experienceYears': experienceYears,
        'bio': bio.toMap(),
        'isAvailableToday': isAvailableToday,
      };

  Doctor copyWith({
    Specialty? specialty,
    Clinic? clinic,
  }) {
    return Doctor(
      id: id,
      name: name,
      specialtyId: specialtyId,
      specialty: specialty ?? this.specialty,
      clinicId: clinicId,
      clinic: clinic ?? this.clinic,
      rating: rating,
      experienceYears: experienceYears,
      bio: bio,
      isAvailableToday: isAvailableToday,
    );
  }
}
