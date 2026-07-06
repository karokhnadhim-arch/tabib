import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/admin_permissions.dart';
import '../../../core/auth/admin_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../services/auth_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../widgets/language_picker.dart';

/// Hidden admin control panel — accessible only to the system owner.
class OwnerPlatformScreen extends StatelessWidget {
  const OwnerPlatformScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();

    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.adminControlPanel),
          backgroundColor: AppTheme.primaryDark,
          leading: auth.isSystemOwner
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go(AdminRoutes.ownerHome),
                )
              : null,
          actions: const [LanguagePicker()],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: AppTheme.primaryDark.withOpacity(0.06),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryDark.withOpacity(0.12),
                  child: const Icon(Icons.admin_panel_settings_outlined,
                      color: AppTheme.primaryDark),
                ),
                title: Text(auth.currentUser?.name.localized(context) ?? ''),
                subtitle: Text(l10n.adminControlPanelHint),
              ),
            ),
            const SizedBox(height: 8),
            if (AdminPermissions.canManageAdmins(auth))
              _PlatformTile(
                title: l10n.manageAdmins,
                subtitle: l10n.manageAdminsHint,
                icon: Icons.security_outlined,
                onTap: () => context.push('${AdminRoutes.platformPrefix}/admins'),
              ),
            if (AdminPermissions.canViewStatistics(auth))
              _PlatformTile(
                title: l10n.systemStatistics,
                subtitle: l10n.systemStatisticsHint,
                icon: Icons.analytics_outlined,
                onTap: () => context.push('${AdminRoutes.platformPrefix}/stats'),
              ),
            if (AdminPermissions.canCreateDoctors(auth) ||
                AdminPermissions.canCreateBusinesses(auth) ||
                AdminPermissions.canCreateSecretaries(auth) ||
                AdminPermissions.canCreateClinics(auth))
              _SectionHeader(label: l10n.createAccounts),
            if (AdminPermissions.canCreateBusinesses(auth))
              _PlatformTile(
                title: l10n.createBusinessAccount,
                subtitle: l10n.createBusinessAccountHint,
                icon: Icons.storefront_outlined,
                onTap: () => context.push('${AdminRoutes.platformPrefix}/create-doctor'),
              ),
            if (AdminPermissions.canCreateDoctors(auth))
              _PlatformTile(
                title: l10n.createDoctorAccount,
                subtitle: l10n.createDoctorAccountHint,
                icon: Icons.person_add_outlined,
                onTap: () => context.push('${AdminRoutes.platformPrefix}/create-doctor'),
              ),
            if (AdminPermissions.canCreateSecretaries(auth))
              _PlatformTile(
                title: l10n.createSecretaryAccount,
                subtitle: l10n.createSecretaryAccountHint,
                icon: Icons.support_agent_outlined,
                onTap: () => context.push('${AdminRoutes.platformPrefix}/create-secretary'),
              ),
            if (AdminPermissions.canCreateClinics(auth))
              _PlatformTile(
                title: l10n.addClinic,
                subtitle: l10n.manageClinics,
                icon: Icons.add_business_outlined,
                onTap: () => context.push('${AdminRoutes.platformPrefix}/clinics'),
              ),
            if (AdminPermissions.canViewAllStaff(auth) ||
                AdminPermissions.canManageSubscriptions(auth))
              _SectionHeader(label: l10n.viewAndManage),
            if (AdminPermissions.canViewAllStaff(auth))
              _PlatformTile(
                title: l10n.doctorManagement,
                subtitle: l10n.doctorManagementHint,
                icon: Icons.medical_services_outlined,
                onTap: () => context.push('${AdminRoutes.platformPrefix}/doctors'),
              ),
            if (AdminPermissions.canViewAllStaff(auth))
              _PlatformTile(
                title: l10n.viewAllSecretaries,
                subtitle: l10n.viewAllSecretariesHint,
                icon: Icons.people_outline,
                onTap: () => context.push('${AdminRoutes.platformPrefix}/secretaries'),
              ),
            if (AdminPermissions.canCreateClinics(auth))
              _PlatformTile(
                title: l10n.viewAllClinics,
                subtitle: l10n.viewAllClinicsHint,
                icon: Icons.local_hospital_outlined,
                onTap: () => context.push('${AdminRoutes.platformPrefix}/clinics'),
              ),
            if (AdminPermissions.canViewAllStaff(auth))
              _PlatformTile(
                title: l10n.manageStaff,
                subtitle: l10n.activateDeactivateAccounts,
                icon: Icons.manage_accounts_outlined,
                onTap: () => context.push('${AdminRoutes.platformPrefix}/users'),
              ),
            if (AdminPermissions.canManagePatients(auth))
              _PlatformTile(
                title: l10n.patientManagement,
                subtitle: l10n.managePatientsHint,
                icon: Icons.people_alt_outlined,
                onTap: () => context.push('${AdminRoutes.platformPrefix}/patients'),
              ),
            if (AdminPermissions.canManageClinics(auth))
              _PlatformTile(
                title: l10n.clinicalAdministration,
                subtitle: l10n.clinicalAdministrationHint,
                icon: Icons.medical_information_outlined,
                onTap: () => context.push('${AdminRoutes.platformPrefix}/clinical-admin'),
              ),
            if (AdminPermissions.canManageSubscriptions(auth))
              _PlatformTile(
                title: l10n.manageSubscriptions,
                subtitle: l10n.manageSubscriptionsHint,
                icon: Icons.card_membership_outlined,
                onTap: () => context.push('${AdminRoutes.platformPrefix}/subscriptions'),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _PlatformTile extends StatelessWidget {
  const _PlatformTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryDark),
        title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle, maxLines: 3, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
