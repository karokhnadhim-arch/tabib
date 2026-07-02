/// Admin-managed lifecycle state for user accounts.
enum AccountStatus {
  active('active'),
  suspended('suspended'),
  disabled('disabled'),
  expiredSubscription('expired_subscription');

  const AccountStatus(this.storageKey);
  final String storageKey;

  static AccountStatus fromStorage(String? value, {bool legacyIsActive = true}) {
    if (value == null || value.isEmpty) {
      return legacyIsActive ? AccountStatus.active : AccountStatus.disabled;
    }
    for (final status in AccountStatus.values) {
      if (status.storageKey == value) return status;
    }
    return legacyIsActive ? AccountStatus.active : AccountStatus.disabled;
  }

  bool get canLogin => this == AccountStatus.active;

  bool get isActive => this == AccountStatus.active;
}
