import '../../models/user_account.dart';

/// Ordered platform roles — higher level implies broader scope in policy checks.
enum PlatformRoleLevel {
  systemOwner(0),
  admin(1),
  doctor(2),
  business(2),
  secretary(3),
  patient(4);

  const PlatformRoleLevel(this.rank);
  final int rank;
}

abstract final class RoleHierarchy {
  RoleHierarchy._();

  static PlatformRoleLevel levelFor(UserAccount account) {
    if (account.isSystemOwner) return PlatformRoleLevel.systemOwner;
    if (account.role == UserRole.admin) return PlatformRoleLevel.admin;
    if (account.role == UserRole.doctor) return PlatformRoleLevel.doctor;
    if (account.role == UserRole.secretary) return PlatformRoleLevel.secretary;
    return PlatformRoleLevel.patient;
  }

  static bool isHigherThan(UserAccount actor, UserAccount target) =>
      levelFor(actor).rank < levelFor(target).rank;

  static bool isPlatformAdmin(UserAccount? account) =>
      account != null &&
      (account.isSystemOwner || account.role == UserRole.admin);
}
