import 'account_status.dart';
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
    this.accountStatus = AccountStatus.active,
  });

  final String id;
  final LocalizedText name;
  final UserRole role;
  final String? email;
  final String? phone;
  final String? doctorId;
  final String? clinicId;
  final String? linkedDoctorId;
  final bool isSystemOwner;
  /// Legacy flag — kept in sync with [accountStatus] for older clients.
  final bool isActive;
  final AccountStatus accountStatus;

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
    AccountStatus? accountStatus,
  }) {
    final nextStatus = accountStatus ??
        (isActive != null
            ? (isActive ? AccountStatus.active : AccountStatus.disabled)
            : this.accountStatus);
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
      accountStatus: nextStatus,
      isActive: nextStatus.isActive,
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
        'isActive': accountStatus.isActive,
        'accountStatus': accountStatus.storageKey,
      };

  factory UserAccount.fromFirestore(String id, Map<String, dynamic> data) {
    final role = UserRole.values.firstWhere(
      (r) => r.name == data['role'],
      orElse: () => UserRole.patient,
    );
    final legacyActive = data['isActive'] != false;
    final status = AccountStatus.fromStorage(
      data['accountStatus'] as String?,
      legacyIsActive: legacyActive,
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
      accountStatus: status,
      isActive: status.isActive,
    );
  }
}
