/// Granular platform permissions granted to [UserRole.admin] accounts.
enum AdminCapability {
  manageDoctors('manage_doctors'),
  manageBusinesses('manage_businesses'),
  manageSecretaries('manage_secretaries'),
  managePatients('manage_patients'),
  manageSubscriptions('manage_subscriptions'),
  viewReports('view_reports'),
  sendNotifications('send_notifications'),
  resetPasswords('reset_passwords'),
  suspendAccounts('suspend_accounts'),
  deleteAccounts('delete_accounts'),
  manageCategories('manage_categories'),
  viewAnalytics('view_analytics'),
  /// System Owner only — create additional Admin accounts.
  createAdmins('create_admins'),
  /// System Owner only — edit Admin permissions and accounts.
  manageAdmins('manage_admins');

  const AdminCapability(this.storageKey);
  final String storageKey;

  bool get isOwnerOnly =>
      this == AdminCapability.createAdmins ||
      this == AdminCapability.manageAdmins;

  static AdminCapability? fromStorage(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final cap in AdminCapability.values) {
      if (cap.storageKey == value) return cap;
    }
    return null;
  }
}

/// Permission bundle stored on Admin user accounts.
class AdminPermissionSet {
  const AdminPermissionSet([Set<AdminCapability> capabilities = const {}])
      : _capabilities = capabilities;

  static const empty = AdminPermissionSet();

  static final allForAdmin = AdminPermissionSet({
    for (final cap in AdminCapability.values)
      if (!cap.isOwnerOnly) cap,
  });

  static final allForOwner = AdminPermissionSet({
    for (final cap in AdminCapability.values) cap,
  });

  final Set<AdminCapability> _capabilities;

  Set<AdminCapability> get capabilities => Set.unmodifiable(_capabilities);

  bool get isEmpty => _capabilities.isEmpty;

  bool has(AdminCapability capability) => _capabilities.contains(capability);

  bool hasAny(Iterable<AdminCapability> capabilities) =>
      capabilities.any(has);

  AdminPermissionSet withoutOwnerOnly() => AdminPermissionSet({
        for (final cap in _capabilities)
          if (!cap.isOwnerOnly) cap,
      });

  AdminPermissionSet withCapability(AdminCapability capability, bool enabled) {
    final next = Set<AdminCapability>.from(_capabilities);
    if (enabled) {
      next.add(capability);
    } else {
      next.remove(capability);
    }
    return AdminPermissionSet(next);
  }

  List<String> toStorageList() =>
      _capabilities.map((c) => c.storageKey).toList()..sort();

  factory AdminPermissionSet.fromStorage(dynamic raw) {
    if (raw is! List) return AdminPermissionSet.empty;
    final caps = <AdminCapability>{};
    for (final item in raw) {
      final cap = AdminCapability.fromStorage(item?.toString());
      if (cap != null) caps.add(cap);
    }
    return AdminPermissionSet(caps);
  }

  @override
  bool operator ==(Object other) =>
      other is AdminPermissionSet &&
      SetEquality<AdminCapability>().equals(_capabilities, other._capabilities);

  @override
  int get hashCode => Object.hashAll(_capabilities.toList()..sort());
}

/// Minimal set equality without importing collection package.
class SetEquality<T> {
  const SetEquality();
  bool equals(Set<T> a, Set<T> b) =>
      a.length == b.length && a.containsAll(b);
}
