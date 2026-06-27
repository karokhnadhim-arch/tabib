import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
                subtitle: Text(l10n.systemOwner),
              ),
            ),
            const SizedBox(height: 8),
            _PlatformTile(
              title: l10n.systemStatistics,
              subtitle: l10n.systemStatisticsHint,
              icon: Icons.analytics_outlined,
              onTap: () => context.push('/doctor/platform/stats'),
            ),
            _SectionHeader(label: l10n.createAccounts),
            _PlatformTile(
              title: l10n.createDoctorAccount,
              subtitle: l10n.createDoctorAccountHint,
              icon: Icons.person_add_outlined,
              onTap: () => context.push('/doctor/platform/create-doctor'),
            ),
            _PlatformTile(
              title: l10n.createSecretaryAccount,
              subtitle: l10n.createSecretaryAccountHint,
              icon: Icons.support_agent_outlined,
              onTap: () => context.push('/doctor/platform/create-secretary'),
            ),
            _PlatformTile(
              title: l10n.addClinic,
              subtitle: l10n.manageClinics,
              icon: Icons.add_business_outlined,
              onTap: () => context.push('/doctor/platform/clinics'),
            ),
            _SectionHeader(label: l10n.viewAndManage),
            _PlatformTile(
              title: l10n.viewAllDoctors,
              subtitle: l10n.viewAllDoctorsHint,
              icon: Icons.medical_services_outlined,
              onTap: () => context.push('/doctor/platform/doctors'),
            ),
            _PlatformTile(
              title: l10n.viewAllSecretaries,
              subtitle: l10n.viewAllSecretariesHint,
              icon: Icons.people_outline,
              onTap: () => context.push('/doctor/platform/secretaries'),
            ),
            _PlatformTile(
              title: l10n.viewAllClinics,
              subtitle: l10n.viewAllClinicsHint,
              icon: Icons.local_hospital_outlined,
              onTap: () => context.push('/doctor/platform/clinics'),
            ),
            _PlatformTile(
              title: l10n.manageStaff,
              subtitle: l10n.activateDeactivateAccounts,
              icon: Icons.manage_accounts_outlined,
              onTap: () => context.push('/doctor/platform/users'),
            ),
            _PlatformTile(
              title: l10n.manageSubscriptions,
              subtitle: l10n.manageSubscriptionsHint,
              icon: Icons.card_membership_outlined,
              onTap: () => context.push('/doctor/platform/subscriptions'),
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
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
