import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/organization.dart';
import '../../../presentation/widgets/owner_metric_card.dart';
import '../../../presentation/widgets/super_owner_guard.dart';
import '../../../services/auth_service.dart';
import '../../../services/organization_service.dart';
import '../../../services/system_monitoring_service.dart';
import '../../../utils/localization_utils.dart';

/// Super Owner console — global monitoring and organization lifecycle (future-ready).
class SuperOwnerDashboardScreen extends StatefulWidget {
  const SuperOwnerDashboardScreen({super.key});

  @override
  State<SuperOwnerDashboardScreen> createState() =>
      _SuperOwnerDashboardScreenState();
}

class _SuperOwnerDashboardScreenState extends State<SuperOwnerDashboardScreen> {
  PlatformGlobalStats? _stats;
  bool _loading = true;
  String? _actionError;

  SystemMonitoringService? _monitoring;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    _monitoring = context.read<SystemMonitoringService>();
    await _monitoring!.activate();
    _syncFromMonitoring(_monitoring!);
    _monitoring!.addListener(_onMonitoringChanged);
    await _refreshStats();
  }

  @override
  void dispose() {
    _monitoring?.removeListener(_onMonitoringChanged);
    super.dispose();
  }

  void _onMonitoringChanged() {
    if (!mounted || _monitoring == null) return;
    _syncFromMonitoring(_monitoring!);
  }

  void _syncFromMonitoring(SystemMonitoringService monitoring) {
    final snap = monitoring.snapshot;
    if (snap == null) return;
    context.read<OrganizationService>().updateGlobalStats(
          totalDoctors: snap.totalDoctors,
          totalPatients: snap.totalPatients,
          totalRevenueLabel: snap.monthlyRevenue,
          firebaseUsageLabel: '${snap.firestoreReads} reads',
        );
  }

  Future<void> _refreshStats() async {
    setState(() {
      _loading = true;
      _actionError = null;
    });
    try {
      final stats = await context.read<OrganizationService>().fetchGlobalStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _actionError = e.toString();
        });
      }
    }
  }

  Future<void> _createOrganization() async {
    final l10n = AppLocalizations.of(context);
    final name = await _promptText(l10n.organizationName);
    if (name == null || name.trim().isEmpty) return;
    try {
      await context.read<OrganizationService>().createOrganization(name: name);
      await _refreshStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.organizationCreated)),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _actionError = e.toString());
    }
  }

  Future<void> _suspendOrganization(Organization org) async {
    final l10n = AppLocalizations.of(context);
    try {
      if (org.status == OrganizationStatus.suspended) {
        await context.read<OrganizationService>().activateOrganization(org.id);
      } else {
        await context.read<OrganizationService>().suspendOrganization(org.id);
      }
      await _refreshStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.organizationSuspended)),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _actionError = e.toString());
    }
  }

  Future<void> _deleteOrganization(Organization org) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteOrganization),
        content: Text('${org.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await context.read<OrganizationService>().deleteOrganization(org.id);
      await _refreshStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.organizationDeleted)),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _actionError = e.toString());
    }
  }

  Future<String?> _promptText(String label) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx).cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(AppLocalizations.of(ctx).save),
          ),
        ],
      ),
    );
  }

  String _planLabel(AppLocalizations l10n, OrganizationBillingPlan plan) =>
      switch (plan) {
        OrganizationBillingPlan.trial => l10n.planTrial,
        OrganizationBillingPlan.monthly => l10n.planMonthly,
        OrganizationBillingPlan.annual => l10n.planAnnual,
        OrganizationBillingPlan.enterprise => l10n.planEnterprise,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final orgs = context.watch<OrganizationService>().organizations;
    final stats = _stats;
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 1200 ? 4 : width >= 700 ? 2 : 1;

    return SuperOwnerGuard(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: AppBar(
          title: Text(l10n.superOwnerDashboard),
          backgroundColor: const Color(0xFF1A237E),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.refresh,
              onPressed: _refreshStats,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: l10n.logout,
              onPressed: () async {
                await auth.logout();
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _createOrganization,
          icon: const Icon(Icons.add_business_outlined),
          label: Text(l10n.createOrganization),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshStats,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.superOwnerDashboardHint,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                auth.currentUser?.name.localized(context) ?? l10n.superOwner,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (_actionError != null) ...[
                const SizedBox(height: 12),
                Text(_actionError!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              Text(
                l10n.globalStatistics,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                    ),
              ),
              const SizedBox(height: 12),
              if (_loading && stats == null)
                const Center(child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ))
              else
                GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.55,
                  children: [
                    OwnerMetricCard(
                      label: l10n.totalOrganizations,
                      value: '${stats?.totalOrganizations ?? 0}',
                      icon: Icons.apartment_outlined,
                      color: AppTheme.medicalBlue,
                    ),
                    OwnerMetricCard(
                      label: l10n.activeOrganizations,
                      value: '${stats?.activeOrganizations ?? 0}',
                      icon: Icons.check_circle_outline,
                      color: Colors.green.shade700,
                    ),
                    OwnerMetricCard(
                      label: l10n.suspendedOrganizations,
                      value: '${stats?.suspendedOrganizations ?? 0}',
                      icon: Icons.pause_circle_outline,
                      color: Colors.orange.shade800,
                    ),
                    OwnerMetricCard(
                      label: l10n.totalDoctors,
                      value: '${stats?.totalDoctors ?? 0}',
                      icon: Icons.medical_services_outlined,
                      color: AppTheme.primaryDark,
                    ),
                    OwnerMetricCard(
                      label: l10n.totalPatients,
                      value: '${stats?.totalPatients ?? 0}',
                      icon: Icons.people_alt_outlined,
                      color: Colors.teal.shade700,
                    ),
                    OwnerMetricCard(
                      label: l10n.platformRevenue,
                      value: stats?.totalRevenueLabel ?? '—',
                      icon: Icons.payments_outlined,
                      color: Colors.indigo,
                    ),
                    OwnerMetricCard(
                      label: l10n.firebaseUsage,
                      value: stats?.firebaseUsageLabel ?? '—',
                      icon: Icons.cloud_outlined,
                      color: Colors.blueGrey,
                    ),
                  ],
                ),
              const SizedBox(height: 28),
              Text(
                l10n.manageOrganizations,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                    ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    for (final org in orgs) ...[
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: org.primaryColor.withOpacity(0.15),
                          child: Icon(Icons.business, color: org.primaryColor),
                        ),
                        title: Text(org.name),
                        subtitle: Text(
                          '${_planLabel(l10n, org.billingPlan)} · ${org.status.name}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) async {
                            if (action == 'suspend') {
                              await _suspendOrganization(org);
                            } else if (action == 'delete') {
                              await _deleteOrganization(org);
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'suspend',
                              child: Text(
                                org.status == OrganizationStatus.suspended
                                    ? l10n.activate
                                    : l10n.suspendOrganization,
                              ),
                            ),
                            if (org.id != 'org_tabib_default')
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(l10n.deleteOrganization),
                              ),
                          ],
                        ),
                      ),
                      if (org != orgs.last) const Divider(height: 1),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.whiteLabelReady,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
