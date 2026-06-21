import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../widgets/language_picker.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDashboard),
        backgroundColor: AppTheme.primaryDark,
        actions: [
          const LanguagePicker(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryDark.withOpacity(0.1),
                child: const Icon(Icons.admin_panel_settings,
                    color: AppTheme.primaryDark),
              ),
              title: Text(auth.currentUser?.name.localized(context) ?? l10n.roleAdmin),
              subtitle: Text(l10n.adminAppSubtitle),
            ),
          ),
          const SizedBox(height: 8),
          _AdminTile(
            title: l10n.createDoctorAccount,
            subtitle: l10n.createDoctorAccountHint,
            icon: Icons.medical_services_outlined,
            onTap: () => context.push('/admin/create-doctor'),
          ),
          _AdminTile(
            title: l10n.createSecretaryAccount,
            subtitle: l10n.createSecretaryAccountHint,
            icon: Icons.support_agent_outlined,
            onTap: () => context.push('/admin/create-secretary'),
          ),
        ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({
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
