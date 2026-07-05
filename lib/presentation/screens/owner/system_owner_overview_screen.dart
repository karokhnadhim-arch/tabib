import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/admin_routes.dart';
import '../../../core/owner/owner_dashboard_metrics.dart';
import '../../../core/owner/system_owner_nav.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/user_account.dart';
import '../../../presentation/widgets/owner_metric_card.dart';
import '../../../presentation/widgets/system_owner_guard.dart';
import '../../../presentation/screens/owner/system_health/owner_dashboard_ui.dart';
import '../../../services/backend/clinic_backend.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/staff_data_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../services/auth_service.dart';
import '../../../services/owner_dashboard_navigation_service.dart';

/// System Owner home — summary cards and live platform metrics.
class SystemOwnerOverviewScreen extends StatefulWidget {
  const SystemOwnerOverviewScreen({super.key});

  @override
  State<SystemOwnerOverviewScreen> createState() =>
      _SystemOwnerOverviewScreenState();
}

class _SystemOwnerOverviewScreenState extends State<SystemOwnerOverviewScreen> {
  List<UserAccount> _allAccounts = const [];
  bool _loadingAccounts = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final data = context.read<ClinicDataService>();
    final staff = context.read<StaffDataService>();
    await data.ensureCatalogLoaded();
    data.startRealtimeCatalog();
    staff.startRealtime();
    if (!data.doctors.isNotEmpty) {
      await data.loadDoctors(refresh: true);
    }
    try {
      final accounts = await context.read<ClinicBackend>().fetchAllAccounts();
      if (mounted) {
        setState(() {
          _allAccounts = accounts;
          _loadingAccounts = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingAccounts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final staffData = context.watch<StaffDataService>();
    final clinicData = context.watch<ClinicDataService>();
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;

    final metrics = OwnerDashboardMetrics.compute(
      staffData: staffData,
      clinicData: clinicData,
      allAccounts: _allAccounts,
    );

    return SystemOwnerGuard(
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: ListView(
          padding: EdgeInsets.fromLTRB(isWide ? 32 : 18, isWide ? 28 : 12, 18, 28),
          children: [
            if (isWide) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dashboardOverview,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryDark,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.systemOwnerDashboardHint,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Text(
                      auth.currentUser?.name.localized(context) ??
                          l10n.systemOwner,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            if (_loadingAccounts)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(),
              ),
            _MetricsGrid(
              width: width,
              isWide: isWide,
              children: [
                OwnerMetricCard(
                  label: l10n.totalDoctors,
                  value: '${metrics.totalDoctors}',
                  icon: Icons.medical_services_outlined,
                  color: AppTheme.doctorColor,
                  onTap: () => context.go(SystemOwnerNavSection.doctors.routePath),
                ),
                OwnerMetricCard(
                  label: l10n.totalBusinesses,
                  value: '${metrics.totalBusinesses}',
                  icon: Icons.storefront_outlined,
                  color: AppTheme.primaryDark,
                  onTap: () =>
                      context.go(SystemOwnerNavSection.businesses.routePath),
                ),
                OwnerMetricCard(
                  label: l10n.totalSecretaries,
                  value: '${metrics.totalSecretaries}',
                  icon: Icons.support_agent_outlined,
                  color: AppTheme.secretaryColor,
                  onTap: () =>
                      context.go(SystemOwnerNavSection.secretaries.routePath),
                ),
                OwnerMetricCard(
                  label: l10n.totalPatients,
                  value: '${metrics.totalPatients}',
                  icon: Icons.people_alt_outlined,
                  color: AppTheme.patientColor,
                  onTap: () =>
                      context.go(SystemOwnerNavSection.patients.routePath),
                ),
                OwnerMetricCard(
                  label: l10n.activeUsersToday,
                  value: '${metrics.activeUsersToday}',
                  icon: Icons.person_pin_outlined,
                  color: AppTheme.medicalBlue,
                ),
                OwnerMetricCard(
                  label: l10n.activeSubscriptions,
                  value: '${metrics.activeSubscriptions}',
                  icon: Icons.verified_outlined,
                  color: AppTheme.medicalGreen,
                  onTap: () =>
                      context.go(SystemOwnerNavSection.subscriptions.routePath),
                ),
                OwnerMetricCard(
                  label: l10n.expiredSubscriptions,
                  value: '${metrics.expiredSubscriptions}',
                  icon: Icons.event_busy_outlined,
                  color: Colors.orange.shade800,
                  onTap: () =>
                      context.go(SystemOwnerNavSection.subscriptions.routePath),
                ),
                OwnerMetricCard(
                  label: l10n.revenueOverview,
                  value: metrics.revenueEstimateLabel,
                  icon: Icons.payments_outlined,
                  color: Colors.teal.shade700,
                  onTap: () => context.go(
                    OwnerDashboardNavigationService.routeFor(
                      MonitoringDashboardSection.revenue,
                    ),
                  ),
                ),
                OwnerMetricCard(
                  label: l10n.newRegistrations,
                  value: '${metrics.newRegistrationsEstimate}',
                  icon: Icons.person_add_alt_1_outlined,
                  color: Colors.indigo,
                ),
                OwnerMetricCard(
                  label: l10n.liveQueueStatistics,
                  value:
                      '${metrics.queueWaiting + metrics.queueInProgress}',
                  subtitleContent: OwnerQueueMetricDetails(
                    waitingLabel: l10n.queueWaiting,
                    waitingCount: metrics.queueWaiting,
                    inProgressLabel: l10n.queueInProgress,
                    inProgressCount: metrics.queueInProgress,
                  ),
                  icon: Icons.queue_outlined,
                  color: AppTheme.medicalBlue,
                  onTap: () => context.go(
                    SystemOwnerNavSection.systemHealth.routePath,
                  ),
                ),
                OwnerMetricCard(
                  label: l10n.monitoringCenterTitle,
                  value: l10n.systemHealth,
                  icon: Icons.monitor_heart_outlined,
                  color: Colors.deepPurple,
                  onTap: () => context.go(
                    SystemOwnerNavSection.systemHealth.routePath,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              l10n.quickActions,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _QuickActionChip(
                  icon: Icons.person_add_outlined,
                  label: l10n.createDoctorAccount,
                  onTap: () =>
                      context.push('${AdminRoutes.platformPrefix}/create-doctor'),
                ),
                _QuickActionChip(
                  icon: Icons.security_outlined,
                  label: l10n.createAdminAccount,
                  onTap: () => context.go(SystemOwnerNavSection.admins.routePath),
                ),
                _QuickActionChip(
                  icon: Icons.card_membership_outlined,
                  label: l10n.manageSubscriptions,
                  onTap: () =>
                      context.go(SystemOwnerNavSection.subscriptions.routePath),
                ),
                _QuickActionChip(
                  icon: Icons.monitor_heart_outlined,
                  label: l10n.monitoringCenterTitle,
                  onTap: () =>
                      context.go(SystemOwnerNavSection.systemHealth.routePath),
                ),
                _QuickActionChip(
                  icon: Icons.history_outlined,
                  label: l10n.auditLog,
                  onTap: () => context.go(
                    OwnerDashboardNavigationService.routeFor(
                      MonitoringDashboardSection.auditLog,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({
    required this.width,
    required this.isWide,
    required this.children,
  });

  final double width;
  final bool isWide;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = isWide
        ? 5
        : width >= 560
            ? 2
            : 1;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: OwnerDashboardTokens.gridGap,
        mainAxisSpacing: OwnerDashboardTokens.gridGap,
        mainAxisExtent: OwnerDashboardTokens.metricTileHeight,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilterChip(
      avatar: Icon(icon, size: 18, color: scheme.primary),
      label: Text(
        label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      showCheckmark: false,
      onSelected: (_) => onTap(),
    );
  }
}
