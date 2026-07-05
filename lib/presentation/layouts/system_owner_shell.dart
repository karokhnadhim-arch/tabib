import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/auth/admin_routes.dart';
import '../../core/owner/system_owner_nav.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../utils/localization_utils.dart';
import '../../widgets/language_picker.dart';

/// Persistent left navigation shell for the System Owner console.
class SystemOwnerShell extends StatelessWidget {
  const SystemOwnerShell({super.key, required this.child});

  final Widget child;

  static const _navWidth = 268.0;
  static const _breakpoint = 900.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _breakpoint;
          if (isWide) {
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              body: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: _navWidth,
                    child: _OwnerSideNav(extended: true),
                  ),
                  Expanded(child: child),
                ],
              ),
            );
          }
          final path = GoRouterState.of(context).matchedLocation;
          final isOverview = path == AdminRoutes.ownerHome;
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
            drawer: Drawer(
              width: _navWidth,
              child: _OwnerSideNav(extended: true),
            ),
            appBar: isOverview ? _mobileAppBar(context) : null,
            body: child,
          );
        },
    );
  }

  PreferredSizeWidget _mobileAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final path = GoRouterState.of(context).matchedLocation;
    final section = SystemOwnerNavSection.fromPath(path);

    return AppBar(
      title: Text(
        section == null
            ? l10n.systemOwnerDashboard
            : _sectionLabel(l10n, section),
      ),
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
    );
  }

  static String _sectionLabel(AppLocalizations l10n, SystemOwnerNavSection s) =>
      switch (s) {
        SystemOwnerNavSection.overview => l10n.dashboardOverview,
        SystemOwnerNavSection.doctors => l10n.doctorManagement,
        SystemOwnerNavSection.businesses => l10n.businessManagement,
        SystemOwnerNavSection.secretaries => l10n.secretaryManagement,
        SystemOwnerNavSection.patients => l10n.patientManagement,
        SystemOwnerNavSection.admins => l10n.manageAdmins,
        SystemOwnerNavSection.subscriptions => l10n.ownerNavSubscriptionsPackages,
        SystemOwnerNavSection.payments => l10n.paymentsBilling,
        SystemOwnerNavSection.feedback => l10n.feedbackSupport,
        SystemOwnerNavSection.notifications => l10n.notificationsCenter,
        SystemOwnerNavSection.reports => l10n.reportsAnalytics,
        SystemOwnerNavSection.systemHealth => l10n.systemHealth,
        SystemOwnerNavSection.auditLog => l10n.auditLog,
        SystemOwnerNavSection.security => l10n.securityCenter,
        SystemOwnerNavSection.backup => l10n.backupRestore,
        SystemOwnerNavSection.organizationSettings => l10n.organizationSettings,
        SystemOwnerNavSection.organizationBilling => l10n.organizationBilling,
        SystemOwnerNavSection.settings => l10n.systemSettings,
      };
}

class _OwnerSideNav extends StatelessWidget {
  const _OwnerSideNav({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final path = GoRouterState.of(context).matchedLocation;
    final active = SystemOwnerNavSection.fromPath(path);

    return Material(
      color: AppTheme.primaryDark,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      if (extended) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.systemOwnerDashboard,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (extended) ...[
                    const SizedBox(height: 8),
                    Text(
                      auth.currentUser?.name.localized(context) ??
                          l10n.systemOwner,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (final section in SystemOwnerNavSection.values)
                    _NavTile(
                      icon: section.icon,
                      label: SystemOwnerShell._sectionLabel(l10n, section),
                      selected: active == section,
                      onTap: () {
                        if (Scaffold.maybeOf(context)?.hasDrawer == true) {
                          Navigator.pop(context);
                        }
                        context.go(section.routePath);
                      },
                    ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            _NavTile(
              icon: Icons.settings_outlined,
              label: l10n.settings,
              selected: false,
              onTap: () => context.push('/settings'),
            ),
            _NavTile(
              icon: Icons.logout,
              label: l10n.logout,
              selected: false,
              onTap: () async {
                await auth.logout();
                if (context.mounted) context.go('/login');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: selected ? Colors.white.withOpacity(0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(selected ? 1 : 0.88),
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
