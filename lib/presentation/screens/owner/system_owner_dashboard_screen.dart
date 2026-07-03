import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/admin_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../presentation/widgets/system_owner_guard.dart';
import '../../../services/auth_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../widgets/language_picker.dart';

class SystemOwnerDashboardScreen extends StatelessWidget {
  const SystemOwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;

    return SystemOwnerGuard(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(l10n.systemOwnerDashboard),
          backgroundColor: AppTheme.primaryDark,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: l10n.settings,
              onPressed: () => context.push('/settings'),
            ),
            const LanguagePicker(),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: l10n.logout,
              onPressed: () async {
                await auth.logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
        body: ResponsiveBody(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _WelcomeCard(name: auth.currentUser?.name.localized(context)),
              const SizedBox(height: 20),
              Text(
                l10n.systemOwnerModules,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                    ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: isWide ? 1.35 : 1.05,
                children: [
                  _ModuleCard(
                    icon: Icons.dashboard_outlined,
                    label: l10n.dashboardOverview,
                    route: AdminRoutes.ownerHome,
                    onTap: () {},
                    isActive: true,
                  ),
                  _ModuleCard(
                    icon: Icons.medical_services_outlined,
                    label: l10n.doctorManagement,
                    route: '${AdminRoutes.platformPrefix}/doctors',
                  ),
                  _ModuleCard(
                    icon: Icons.storefront_outlined,
                    label: l10n.businessManagement,
                    route: '${AdminRoutes.platformPrefix}/businesses',
                  ),
                  _ModuleCard(
                    icon: Icons.support_agent_outlined,
                    label: l10n.secretaryManagement,
                    route: '${AdminRoutes.platformPrefix}/secretaries',
                  ),
                  _ModuleCard(
                    icon: Icons.people_alt_outlined,
                    label: l10n.patientManagement,
                    route: '${AdminRoutes.platformPrefix}/patients',
                  ),
                  _ModuleCard(
                    icon: Icons.security_outlined,
                    label: l10n.manageAdmins,
                    route: '${AdminRoutes.platformPrefix}/admins',
                  ),
                  _ModuleCard(
                    icon: Icons.card_membership_outlined,
                    label: l10n.subscriptionManagement,
                    route: '${AdminRoutes.platformPrefix}/subscriptions',
                  ),
                  _ModuleCard(
                    icon: Icons.inventory_2_outlined,
                    label: l10n.packageManagement,
                    route: '${AdminRoutes.platformPrefix}/packages',
                  ),
                  _ModuleCard(
                    icon: Icons.payments_outlined,
                    label: l10n.payments,
                    route: '${AdminRoutes.platformPrefix}/payments',
                  ),
                  _ModuleCard(
                    icon: Icons.summarize_outlined,
                    label: l10n.reports,
                    route: '${AdminRoutes.platformPrefix}/reports',
                  ),
                  _ModuleCard(
                    icon: Icons.analytics_outlined,
                    label: l10n.analytics,
                    route: '${AdminRoutes.platformPrefix}/analytics',
                  ),
                  _ModuleCard(
                    icon: Icons.notifications_outlined,
                    label: l10n.notifications,
                    route: '${AdminRoutes.platformPrefix}/notifications-admin',
                  ),
                  _ModuleCard(
                    icon: Icons.tune_outlined,
                    label: l10n.systemSettings,
                    route: '${AdminRoutes.platformPrefix}/system-settings',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      color: AppTheme.primaryDark,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.admin_panel_settings_outlined,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.systemOwnerDashboard,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name ?? l10n.systemOwner,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.systemOwnerDashboardHint,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.icon,
    required this.label,
    required this.route,
    this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final String route;
  final VoidCallback? onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isActive ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isActive
              ? AppTheme.primaryDark.withOpacity(0.35)
              : Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap ?? () => context.push(route),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: AppTheme.primaryDark),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
