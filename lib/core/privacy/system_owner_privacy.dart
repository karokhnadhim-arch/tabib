import '../../models/user_account.dart';

/// Visibility rules for platform-level accounts.
abstract final class SystemOwnerPrivacy {
  SystemOwnerPrivacy._();

  /// System Owner — never visible outside their own private session.
  static bool isSystemOwnerAccount(UserAccount account) => account.isSystemOwner;

  /// Platform Admin or System Owner — hidden from clinic-facing lists.
  static bool isInternalPlatformAccount(UserAccount account) =>
      account.isSystemOwner || account.role == UserRole.admin;

  @Deprecated('Use isInternalPlatformAccount for lists or isSystemOwnerAccount for owner-only hiding')
  static bool isHiddenAccount(UserAccount account) => isInternalPlatformAccount(account);

  static List<UserAccount> filterPublic(Iterable<UserAccount> accounts) =>
      accounts.where((a) => !isInternalPlatformAccount(a)).toList(growable: false);

  static List<UserAccount> filterAdminRoster(Iterable<UserAccount> accounts) =>
      accounts
          .where((a) => a.role == UserRole.admin && !a.isSystemOwner)
          .toList(growable: false);

  static UserAccount? visibleStaffForDoctor(
    String doctorId,
    List<UserAccount> staff,
  ) =>
      staff
          .where(
            (s) =>
                s.doctorId == doctorId &&
                s.role == UserRole.doctor &&
                !isInternalPlatformAccount(s),
          )
          .firstOrNull;

  static Set<String> hiddenAccountIds(Iterable<UserAccount> accounts) =>
      accounts.where(isSystemOwnerAccount).map((a) => a.id).toSet();
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
