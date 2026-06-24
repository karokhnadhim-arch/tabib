import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../widgets/language_picker.dart';

/// Platform management for the hidden system owner only.
class OwnerPlatformScreen extends StatelessWidget {
  const OwnerPlatformScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();

    if (!auth.isSystemOwner) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDashboard),
        backgroundColor: AppTheme.primaryDark,
        actions: const [LanguagePicker()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryDark.withOpacity(0.1),
                child: const Icon(Icons.medical_services,
                    color: AppTheme.primaryDark),
              ),
              title: Text(auth.currentUser?.name.localized(context) ?? ''),
              subtitle: Text(l10n.roleDoctor),
            ),
          ),
          const SizedBox(height: 8),
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
            title: l10n.manageClinics,
            subtitle: l10n.manageClinics,
            icon: Icons.local_hospital_outlined,
            onTap: () => context.push('/doctor/platform/clinics'),
          ),
          _PlatformTile(
            title: l10n.manageStaff,
            subtitle: l10n.manageStaff,
            icon: Icons.people_outline,
            onTap: () => context.push('/doctor/platform/users'),
          ),
        ],
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
