import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/admin_permissions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/account_status.dart';
import '../../../models/user_account.dart';
import '../../../presentation/widgets/account_status_badge.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../services/auth_service.dart';
import '../../../services/backend/clinic_backend.dart';
import '../../../utils/localization_utils.dart';

enum OwnerStaffFilter { doctors, secretaries, patients, all }

class OwnerStaffListScreen extends StatefulWidget {
  const OwnerStaffListScreen({super.key, required this.filter});

  final OwnerStaffFilter filter;

  @override
  State<OwnerStaffListScreen> createState() => _OwnerStaffListScreenState();
}

class _OwnerStaffListScreenState extends State<OwnerStaffListScreen> {
  AccountStatus? _statusFilter;

  String _title(AppLocalizations l10n) {
    switch (widget.filter) {
      case OwnerStaffFilter.doctors:
        return l10n.viewAllDoctors;
      case OwnerStaffFilter.secretaries:
        return l10n.viewAllSecretaries;
      case OwnerStaffFilter.patients:
        return l10n.managePatients;
      case OwnerStaffFilter.all:
        return l10n.manageStaff;
    }
  }

  String _roleLabel(AppLocalizations l10n, UserRole role) {
    switch (role) {
      case UserRole.doctor:
        return l10n.roleDoctor;
      case UserRole.secretary:
        return l10n.roleSecretary;
      case UserRole.patient:
        return l10n.patientApp;
      case UserRole.admin:
        return l10n.roleAdmin;
    }
  }

  List<UserAccount> _filterAccounts(List<UserAccount> accounts) {
    var list = accounts;
    switch (widget.filter) {
      case OwnerStaffFilter.doctors:
        list = list
            .where((s) => s.role == UserRole.doctor || s.role == UserRole.admin)
            .toList();
      case OwnerStaffFilter.secretaries:
        list = list.where((s) => s.role == UserRole.secretary).toList();
      case OwnerStaffFilter.patients:
        list = list.where((s) => s.role == UserRole.patient).toList();
      case OwnerStaffFilter.all:
        break;
    }
    if (_statusFilter != null) {
      list = list.where((s) => s.accountStatus == _statusFilter).toList();
    }
    return list;
  }

  Future<void> _changeStatus(
    BuildContext context,
    UserAccount user,
    AccountStatus status,
  ) async {
    final l10n = AppLocalizations.of(context);
    final err = await context.read<AuthService>().setAccountStatus(
          user.id,
          status,
        );
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    }
  }

  Future<void> _pickStatus(BuildContext context, UserAccount user) async {
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<AccountStatus>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: AccountStatus.values.map((status) {
            return ListTile(
              leading: AccountStatusBadge(status: status, compact: true),
              title: Text(_statusLabel(l10n, status)),
              selected: user.accountStatus == status,
              onTap: () => Navigator.pop(context, status),
            );
          }).toList(),
        ),
      ),
    );
    if (selected == null || selected == user.accountStatus) return;
    await _changeStatus(context, user, selected);
  }

  String _statusLabel(AppLocalizations l10n, AccountStatus status) =>
      switch (status) {
        AccountStatus.active => l10n.accountStatusActive,
        AccountStatus.suspended => l10n.accountStatusSuspended,
        AccountStatus.disabled => l10n.accountStatusDisabled,
        AccountStatus.expiredSubscription =>
          l10n.accountStatusExpiredSubscription,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    if (!AdminPermissions.canViewAllStaff(auth)) {
      return const SizedBox.shrink();
    }

    final backend = context.read<ClinicBackend>();

    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_title(l10n)),
          backgroundColor: AppTheme.primaryDark,
        ),
        body: Column(
          children: [
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(l10n.allStatuses),
                      selected: _statusFilter == null,
                      onSelected: (_) => setState(() => _statusFilter = null),
                    ),
                  ),
                  ...AccountStatus.values.map(
                    (status) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_statusLabel(l10n, status)),
                        selected: _statusFilter == status,
                        onSelected: (_) =>
                            setState(() => _statusFilter = status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<UserAccount>>(
                stream: backend.watchAllAccounts(),
                builder: (context, snapshot) {
                  final accounts = _filterAccounts(snapshot.data ?? []);
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      accounts.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (accounts.isEmpty) {
                    return Center(child: Text(l10n.noStaffAccounts));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: accounts.length,
                    itemBuilder: (context, i) {
                      final user = accounts[i];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Icon(
                            _iconForRole(user.role),
                            color: user.accountStatus == AccountStatus.active
                                ? AppTheme.primaryDark
                                : Colors.grey,
                          ),
                          title: Text(user.name.localized(context)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                [
                                  _roleLabel(l10n, user.role),
                                  if (user.email != null) user.email!,
                                  if (user.phone != null) user.phone!,
                                ].join(' · '),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 8),
                              AccountStatusBadge(
                                status: user.accountStatus,
                                compact: true,
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: user.isSystemOwner
                              ? Chip(
                                  label: Text(l10n.systemOwner),
                                  backgroundColor:
                                      AppTheme.medicalGreen.withOpacity(0.15),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.manage_accounts_outlined),
                                  tooltip: l10n.changeAccountStatus,
                                  onPressed: () => _pickStatus(context, user),
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForRole(UserRole role) => switch (role) {
        UserRole.secretary => Icons.badge_outlined,
        UserRole.patient => Icons.person_outline,
        _ => Icons.medical_services_outlined,
      };
}
