import 'package:flutter/foundation.dart';

import '../core/architecture/tenant_constants.dart';
import '../core/architecture/tenant_scope.dart';
import '../models/user_account.dart';
/// Active organization context — defaults preserve single-tenant behavior.
class TenantContextService extends ChangeNotifier {
  String _activeOrganizationId = TenantConstants.defaultOrganizationId;
  UserAccount? _user;

  String get activeOrganizationId => _activeOrganizationId;

  bool get isDefaultOrganization =>
      _activeOrganizationId == TenantConstants.defaultOrganizationId;

  void bindUser(UserAccount? user) {
    _user = user;
    if (user == null) {
      _activeOrganizationId = TenantConstants.defaultOrganizationId;
    } else if (user.isSuperOwner) {
      // Super Owner keeps current selection until they pick an org in the console.
    } else {
      _activeOrganizationId = TenantScope.organizationIdFor(user);
    }
    notifyListeners();
  }

  void selectOrganization(String organizationId) {
    if (_activeOrganizationId == organizationId) return;
    _activeOrganizationId = organizationId;
    notifyListeners();
  }

  void resetToUserOrganization() {
    _activeOrganizationId = TenantScope.organizationIdFor(_user);
    notifyListeners();
  }

  bool canAccessOrganization(String organizationId, {required bool isSuperOwner}) {
    if (isSuperOwner) return true;
    return TenantScope.resolveOrganizationId(_user?.organizationId) ==
        organizationId;
  }

  bool entityInActiveOrganization({required String? entityOrganizationId}) =>
      TenantScope.belongsToOrganization(
        entityOrganizationId: entityOrganizationId,
        activeOrganizationId: _activeOrganizationId,
      );
}
