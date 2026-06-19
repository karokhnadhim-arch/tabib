import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/language_picker.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primary,
        actions: const [LanguagePicker()],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.local_hospital_rounded, size: 80, color: AppTheme.primary),
              const SizedBox(height: 16),
              Text(
                l10n.appTitle,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.appSubtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              _PortalCard(
                title: l10n.patientApp,
                subtitle: l10n.patientAppSubtitle,
                icon: Icons.person_outline,
                color: AppTheme.patientColor,
                onTap: () => context.push('/patient/login'),
              ),
              const SizedBox(height: 16),
              _PortalCard(
                title: l10n.staffApp,
                subtitle: l10n.staffAppSubtitle,
                icon: Icons.medical_information_outlined,
                color: AppTheme.staffColor,
                onTap: () => context.push('/staff/login'),
              ),
              const SizedBox(height: 16),
              _PortalCard(
                title: l10n.adminApp,
                subtitle: l10n.adminAppSubtitle,
                icon: Icons.admin_panel_settings_outlined,
                color: AppTheme.primaryDark,
                onTap: () => context.push('/admin/login'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _PortalCard extends StatelessWidget {
  const _PortalCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
