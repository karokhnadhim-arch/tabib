import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/auth/admin_permissions.dart';
import '../../core/auth/admin_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/account_code_resolver.dart';
import '../../core/widgets/responsive_scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../../models/account_status.dart';
import '../../models/doctor.dart';
import '../../models/user_account.dart';
import '../../presentation/widgets/account_code_badge.dart';
import '../../presentation/widgets/account_status_badge.dart';
import '../../presentation/widgets/owner_secretary_actions.dart';
import '../../services/auth_service.dart';
import '../../services/clinic_data_service.dart';
import '../../utils/localization_utils.dart';

/// Secretaries grouped under their linked doctor for the System Owner console.
class OwnerSecretariesGroupedView extends StatelessWidget {
  const OwnerSecretariesGroupedView({
    super.key,
    required this.secretaries,
    this.statusFilter,
  });

  final List<UserAccount> secretaries;
  final AccountStatus? statusFilter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clinicData = context.watch<ClinicDataService>();
    final filtered = statusFilter == null
        ? secretaries
        : secretaries
            .where((s) => s.accountStatus == statusFilter)
            .toList();

    if (filtered.isEmpty) {
      return Center(child: Text(l10n.noSecretariesYet));
    }

    final grouped = <String, List<UserAccount>>{};
    for (final secretary in filtered) {
      final doctorId = secretary.linkedDoctorId ?? '';
      grouped.putIfAbsent(doctorId, () => []).add(secretary);
    }

    final doctorIds = grouped.keys.toList()
      ..sort((a, b) {
        if (a.isEmpty) return 1;
        if (b.isEmpty) return -1;
        final nameA =
            clinicData.doctorById(a)?.name.localized(context) ?? '';
        final nameB =
            clinicData.doctorById(b)?.name.localized(context) ?? '';
        return nameA.compareTo(nameB);
      });

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: doctorIds.length,
      itemBuilder: (context, index) {
        final doctorId = doctorIds[index];
        final group = grouped[doctorId]!;
        final doctor = doctorId.isEmpty ? null : clinicData.doctorById(doctorId);

        return _DoctorSecretaryGroup(
          doctor: doctor,
          doctorId: doctorId,
          secretaries: group,
        );
      },
    );
  }
}

class _DoctorSecretaryGroup extends StatelessWidget {
  const _DoctorSecretaryGroup({
    required this.doctor,
    required this.doctorId,
    required this.secretaries,
  });

  final Doctor? doctor;
  final String doctorId;
  final List<UserAccount> secretaries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final doctorName =
        doctor?.name.localized(context) ?? l10n.unassignedSecretaries;
    final accountCode = AccountCodeResolver.forDoctor(doctor);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ResponsiveHeaderRow(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.secretariesCount(secretaries.length),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  if (accountCode != null) ...[
                    const SizedBox(height: 8),
                    AccountCodeBadge(code: accountCode, compact: true),
                  ],
                ],
              ),
              trailing: [
                if (doctorId.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => context.push(
                      '${AdminRoutes.platformPrefix}/doctors/$doctorId?section=secretaries',
                    ),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text(l10n.doctorProfile),
                  ),
              ],
            ),
            const Divider(height: 24),
            ...secretaries.map(
              (secretary) => _SecretaryRow(
                secretary: secretary,
                doctorId: doctorId,
                linkedAccountCode: accountCode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecretaryRow extends StatelessWidget {
  const _SecretaryRow({
    required this.secretary,
    required this.doctorId,
    this.linkedAccountCode,
  });

  final UserAccount secretary;
  final String doctorId;
  final String? linkedAccountCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final canManage = AdminPermissions.canCreateSecretaries(auth) ||
        AdminPermissions.canDeleteAccounts(auth) ||
        AdminPermissions.canResetPasswords(auth);

    final contact = [
      if (secretary.phone != null && secretary.phone!.isNotEmpty)
        secretary.phone!,
      if (secretary.email != null && secretary.email!.isNotEmpty)
        secretary.email!,
    ].join(' · ');

    final resolvedDoctorId = doctorId.isNotEmpty
        ? doctorId
        : (secretary.linkedDoctorId ?? '');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey.shade50,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Icon(
          Icons.badge_outlined,
          color: secretary.accountStatus == AccountStatus.active
              ? AppTheme.primaryDark
              : Colors.grey,
        ),
        title: Text(
          secretary.name.localized(context),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contact.isNotEmpty)
              Text(contact, style: const TextStyle(fontSize: 13)),
            if (linkedAccountCode != null)
              Text(
                l10n.linkedToAccountCode(linkedAccountCode!),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            const SizedBox(height: 6),
            AccountStatusBadge(status: secretary.accountStatus, compact: true),
          ],
        ),
        isThreeLine: true,
        trailing: canManage
            ? PopupMenuButton<String>(
                onSelected: (value) => OwnerSecretaryActions.handleMenuSelection(
                  context,
                  value,
                  secretary,
                  resolvedDoctorId,
                ),
                itemBuilder: (context) => OwnerSecretaryActions.menuItems(
                  context,
                  secretary,
                  resolvedDoctorId,
                ),
              )
            : null,
      ),
    );
  }
}
