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
  });

  final String id;
  final LocalizedText name;
  final UserRole role;
  final String? email;
  final String? phone;
  final String? doctorId;
  final String? clinicId;

  Map<String, dynamic> toMap() => {
        'name': name.toMap(),
        'role': role.name,
        'email': email,
        'phone': phone,
        'doctorId': doctorId,
        'clinicId': clinicId,
      };

  factory UserAccount.fromFirestore(String id, Map<String, dynamic> data) {
    return UserAccount(
      id: id,
      name: LocalizedText.fromMap(data['name'] as Map<String, dynamic>?),
      role: UserRole.values.firstWhere(
        (r) => r.name == data['role'],
        orElse: () => UserRole.patient,
      ),
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      doctorId: data['doctorId'] as String?,
      clinicId: data['clinicId'] as String?,
    );
  }
}
