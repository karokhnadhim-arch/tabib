import '../../models/admin_capability.dart';
import '../../models/user_account.dart';

/// Evaluates configurable Admin permissions and System Owner overrides.
abstract final class PermissionPolicy {
  PermissionPolicy._();

  static bool isSystemOwner(UserAccount? user) => user?.isSystemOwner == true;

  static bool isDelegatedAdmin(UserAccount? user) =>
      user != null && user.role == UserRole.admin && !user.isSystemOwner;

  static bool canAccessAdminPanel(UserAccount? user) {
    if (user == null) return false;
    if (isSystemOwner(user)) return true;
    return isDelegatedAdmin(user) && !user.adminPermissions.isEmpty;
  }

  static bool hasCapability(UserAccount? user, AdminCapability capability) {
    if (user == null) return false;
    if (isSystemOwner(user)) return true;
    if (!isDelegatedAdmin(user)) return false;
    if (capability.isOwnerOnly) return false;
    return user.adminPermissions.has(capability);
  }

  static bool hasAnyCapability(
    UserAccount? user,
    Iterable<AdminCapability> capabilities,
  ) =>
      capabilities.any((cap) => hasCapability(user, cap));

  /// Whether [actor] may change [target] (status, delete, password, etc.).
  static bool canModifyAccount(UserAccount? actor, UserAccount target) {
    if (actor == null) return false;
    if (target.isSystemOwner) return false;
    if (target.role == UserRole.admin) return false;
    if (isSystemOwner(actor)) return actor.id != target.id;
    if (isDelegatedAdmin(actor)) return true;
    return false;
  }

  static bool canManageAdminAccounts(UserAccount? actor) =>
      isSystemOwner(actor);

  static AdminPermissionSet sanitizeGrantedPermissions(
    UserAccount? granter,
    AdminPermissionSet requested,
  ) {
    if (isSystemOwner(granter)) {
      return requested.withoutOwnerOnly();
    }
    if (!isDelegatedAdmin(granter)) return AdminPermissionSet.empty;

    final allowed = <AdminCapability>{};
    for (final cap in requested.capabilities) {
      if (cap.isOwnerOnly) continue;
      if (hasCapability(granter, cap)) allowed.add(cap);
    }
    return AdminPermissionSet(allowed);
  }
}
