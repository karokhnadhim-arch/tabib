import 'localized_text.dart';

enum UserRole { patient, doctor, secretary, admin }

class UserAccount {
  const UserAccount({
    required this.id,
    required this.name,
    required this.role,
    this.email,
    this.phone,
    this.doctorId,
    this.clinicId,
    this.linkedDoctorId,
    this.isSystemOwner = false,
    this.isActive = true,
  });

  final String id;
  final LocalizedText name;
  final UserRole role;
  final String? email;
  final String? phone;
  final String? doctorId;
  final String? clinicId;
  /// Required for secretary accounts — the doctor they assist.
  final String? linkedDoctorId;
  /// Hidden platform owner — full admin permissions, logs in via doctor UI.
  final bool isSystemOwner;
  final bool isActive;

  UserAccount copyWith({
    String? id,
    LocalizedText? name,
    UserRole? role,
    String? email,
    String? phone,
    String? doctorId,
    String? clinicId,
    String? linkedDoctorId,
    bool? isSystemOwner,
    bool? isActive,
  }) {
    return UserAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      doctorId: doctorId ?? this.doctorId,
      clinicId: clinicId ?? this.clinicId,
      linkedDoctorId: linkedDoctorId ?? this.linkedDoctorId,
      isSystemOwner: isSystemOwner ?? this.isSystemOwner,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name.toMap(),
        'role': role.name,
        'email': email,
        'phone': phone,
        'doctorId': doctorId,
        'clinicId': clinicId,
        'linkedDoctorId': linkedDoctorId,
        if (isSystemOwner) 'isSystemOwner': true,
        'isActive': isActive,
      };

  factory UserAccount.fromFirestore(String id, Map<String, dynamic> data) {
    final role = UserRole.values.firstWhere(
      (r) => r.name == data['role'],
      orElse: () => UserRole.patient,
    );
    return UserAccount(
      id: id,
      name: LocalizedText.fromMap(data['name'] as Map<String, dynamic>?),
      role: role,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      doctorId: data['doctorId'] as String?,
      clinicId: data['clinicId'] as String?,
      linkedDoctorId: data['linkedDoctorId'] as String?,
      isSystemOwner:
          data['isSystemOwner'] == true || role == UserRole.admin,
      isActive: data['isActive'] != false,
    );
  }
}
