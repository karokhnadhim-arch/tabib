import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/admin_routes.dart';
import '../../../core/owner/owner_dashboard_metrics.dart';
import '../../../core/owner/system_owner_nav.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/user_account.dart';
import '../../../presentation/widgets/system_owner_guard.dart';
import '../../../services/backend/clinic_backend.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/staff_data_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../services/auth_service.dart';

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
        color: const Color(0xFFF4F6F9),
        child: ListView(
          padding: EdgeInsets.fromLTRB(isWide ? 28 : 16, isWide ? 24 : 8, 16, 24),
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
              isWide: isWide,
              children: [
                _MetricCard(
                  label: l10n.totalDoctors,
                  value: '${metrics.totalDoctors}',
                  icon: Icons.medical_services_outlined,
                  color: AppTheme.doctorColor,
                  onTap: () => context.go(SystemOwnerNavSection.doctors.routePath),
                ),
                _MetricCard(
                  label: l10n.totalBusinesses,
                  value: '${metrics.totalBusinesses}',
                  icon: Icons.storefront_outlined,
                  color: AppTheme.primaryDark,
                  onTap: () =>
                      context.go(SystemOwnerNavSection.businesses.routePath),
                ),
                _MetricCard(
                  label: l10n.totalSecretaries,
                  value: '${metrics.totalSecretaries}',
                  icon: Icons.support_agent_outlined,
                  color: AppTheme.secretaryColor,
                  onTap: () =>
                      context.go(SystemOwnerNavSection.secretaries.routePath),
                ),
                _MetricCard(
                  label: l10n.totalPatients,
                  value: '${metrics.totalPatients}',
                  icon: Icons.people_alt_outlined,
                  color: AppTheme.patientColor,
                  onTap: () =>
                      context.go(SystemOwnerNavSection.patients.routePath),
                ),
                _MetricCard(
                  label: l10n.activeUsersToday,
                  value: '${metrics.activeUsersToday}',
                  icon: Icons.person_pin_outlined,
                  color: AppTheme.medicalBlue,
                ),
                _MetricCard(
                  label: l10n.activeSubscriptions,
                  value: '${metrics.activeSubscriptions}',
                  icon: Icons.verified_outlined,
                  color: AppTheme.medicalGreen,
                  onTap: () =>
                      context.go(SystemOwnerNavSection.subscriptions.routePath),
                ),
                _MetricCard(
                  label: l10n.expiredSubscriptions,
                  value: '${metrics.expiredSubscriptions}',
                  icon: Icons.event_busy_outlined,
                  color: Colors.orange.shade800,
                  onTap: () =>
                      context.go(SystemOwnerNavSection.subscriptions.routePath),
                ),
                _MetricCard(
                  label: l10n.revenueOverview,
                  value: metrics.revenueEstimateLabel,
                  icon: Icons.payments_outlined,
                  color: Colors.teal.shade700,
                  onTap: () =>
                      context.go(SystemOwnerNavSection.payments.routePath),
                ),
                _MetricCard(
                  label: l10n.newRegistrations,
                  value: '${metrics.newRegistrationsEstimate}',
                  icon: Icons.person_add_alt_1_outlined,
                  color: Colors.indigo,
                ),
                _MetricCard(
                  label: l10n.liveQueueStatistics,
                  value:
                      '${metrics.queueWaiting + metrics.queueInProgress}',
                  subtitle:
                      '${l10n.queueWaiting}: ${metrics.queueWaiting} · ${l10n.queueInProgress}: ${metrics.queueInProgress}',
                  icon: Icons.queue_outlined,
                  color: AppTheme.medicalBlue,
                  onTap: () => context.go('${AdminRoutes.platformPrefix}/reports'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              l10n.quickActions,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
            ),
            const SizedBox(height: 12),
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
                  icon: Icons.history_outlined,
                  label: l10n.auditLog,
                  onTap: () =>
                      context.go(SystemOwnerNavSection.auditLog.routePath),
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
  const _MetricsGrid({required this.isWide, required this.children});

  final bool isWide;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = isWide ? 5 : 2;
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: isWide ? 1.45 : 1.05,
      children: children,
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ],
          ),
        ),
      ),
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
    return ActionChip(
      avatar: Icon(icon, size: 18, color: AppTheme.primaryDark),
      label: Text(
        label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: onTap,
    );
  }
}
