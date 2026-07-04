import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/admin_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../services/owner_dashboard_navigation_service.dart';
import 'owner_module_hub_screen.dart';

class OwnerPaymentsBillingScreen extends StatelessWidget {
  const OwnerPaymentsBillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AdminGuard(
      child: OwnerModuleHubScreen(
        title: l10n.paymentsBilling,
        header: l10n.paymentsBillingHint,
        items: [
          OwnerHubItem(
            icon: Icons.receipt_long_outlined,
            title: l10n.invoices,
            subtitle: l10n.invoicesHint,
            comingSoon: true,
          ),
          OwnerHubItem(
            icon: Icons.account_balance_wallet_outlined,
            title: l10n.billingOverview,
            subtitle: l10n.billingOverviewHint,
            comingSoon: true,
          ),
          OwnerHubItem(
            icon: Icons.credit_card_outlined,
            title: l10n.paymentMethods,
            subtitle: l10n.paymentMethodsHint,
            comingSoon: true,
          ),
        ],
      ),
    );
  }
}

class OwnerFeedbackSupportScreen extends StatelessWidget {
  const OwnerFeedbackSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AdminGuard(
      child: OwnerModuleHubScreen(
        title: l10n.feedbackSupport,
        header: l10n.feedbackSupportHint,
        items: [
          OwnerHubItem(
            icon: Icons.bug_report_outlined,
            title: l10n.bugReports,
            subtitle: l10n.bugReportsHint,
            comingSoon: true,
          ),
          OwnerHubItem(
            icon: Icons.lightbulb_outline,
            title: l10n.featureRequests,
            subtitle: l10n.featureRequestsHint,
            comingSoon: true,
          ),
          OwnerHubItem(
            icon: Icons.rate_review_outlined,
            title: l10n.userFeedback,
            subtitle: l10n.userFeedbackHint,
            comingSoon: true,
          ),
          OwnerHubItem(
            icon: Icons.forum_outlined,
            title: l10n.supportConversations,
            subtitle: l10n.supportConversationsHint,
            comingSoon: true,
          ),
        ],
      ),
    );
  }
}

class OwnerNotificationsCenterScreen extends StatelessWidget {
  const OwnerNotificationsCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AdminGuard(
      child: OwnerModuleHubScreen(
        title: l10n.notificationsCenter,
        header: l10n.notificationsCenterHint,
        items: [
          OwnerHubItem(
            icon: Icons.tune_outlined,
            title: l10n.notificationSystemSettings,
            subtitle: l10n.notificationSystemSettingsHint,
            route: '${AdminRoutes.adminConsole}/notifications-config',
          ),
          OwnerHubItem(
            icon: Icons.campaign_outlined,
            title: l10n.broadcastNotifications,
            subtitle: l10n.broadcastNotificationsHint,
            comingSoon: true,
          ),
          OwnerHubItem(
            icon: Icons.alarm_outlined,
            title: l10n.subscriptionReminders,
            subtitle: l10n.subscriptionRemindersHint,
            comingSoon: true,
          ),
          OwnerHubItem(
            icon: Icons.build_circle_outlined,
            title: l10n.maintenanceAnnouncements,
            subtitle: l10n.maintenanceAnnouncementsHint,
            route: OwnerDashboardNavigationService.routeFor(
              MonitoringDashboardSection.maintenance,
            ),
          ),
        ],
      ),
    );
  }
}

class OwnerReportsAnalyticsScreen extends StatelessWidget {
  const OwnerReportsAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final monitoring = OwnerDashboardNavigationService.routeFor;
    return AdminGuard(
      child: OwnerModuleHubScreen(
        title: l10n.reportsAnalytics,
        header: l10n.reportsAnalyticsHint,
        items: [
          OwnerHubItem(
            icon: Icons.insights_outlined,
            title: l10n.analyticsDashboard,
            subtitle: l10n.monitoringPhase3AnalyticsHint,
            route: monitoring(MonitoringDashboardSection.analyticsCharts),
          ),
          OwnerHubItem(
            icon: Icons.payments_outlined,
            title: l10n.revenueDashboard,
            subtitle: l10n.revenueStatisticsHint,
            route: monitoring(MonitoringDashboardSection.revenue),
          ),
          OwnerHubItem(
            icon: Icons.summarize_outlined,
            title: l10n.generateReports,
            subtitle: l10n.reportsFilterHint,
            route: monitoring(MonitoringDashboardSection.reports),
          ),
          OwnerHubItem(
            icon: Icons.today_outlined,
            title: l10n.reportDaily,
            subtitle: l10n.reportDailyHint,
            route: monitoring(MonitoringDashboardSection.analyticsCharts),
          ),
          OwnerHubItem(
            icon: Icons.date_range_outlined,
            title: l10n.reportWeekly,
            subtitle: l10n.reportWeeklyHint,
            route: monitoring(MonitoringDashboardSection.analyticsCharts),
          ),
          OwnerHubItem(
            icon: Icons.calendar_month_outlined,
            title: l10n.reportMonthly,
            subtitle: l10n.reportMonthlyHint,
            route: monitoring(MonitoringDashboardSection.analyticsCharts),
          ),
          OwnerHubItem(
            icon: Icons.queue_outlined,
            title: l10n.queueStatistics,
            subtitle: l10n.queueStatisticsHint,
            route: monitoring(MonitoringDashboardSection.queueAnalytics),
          ),
          OwnerHubItem(
            icon: Icons.event_note_outlined,
            title: l10n.appointmentStatistics,
            subtitle: l10n.appointmentStatisticsHint,
            route: monitoring(MonitoringDashboardSection.appointmentAnalytics),
          ),
          OwnerHubItem(
            icon: Icons.trending_up_outlined,
            title: l10n.userGrowth,
            subtitle: l10n.userGrowthHint,
            route: monitoring(MonitoringDashboardSection.analyticsCharts),
          ),
        ],
      ),
    );
  }
}

class OwnerSecurityCenterScreen extends StatelessWidget {
  const OwnerSecurityCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final route = OwnerDashboardNavigationService.routeFor;
    return AdminGuard(
      child: OwnerModuleHubScreen(
        title: l10n.securityCenter,
        header: l10n.securityCenterHint,
        items: [
          OwnerHubItem(
            icon: Icons.shield_outlined,
            title: l10n.securityCenter,
            subtitle: l10n.viewFullMonitoringCenter,
            route: route(MonitoringDashboardSection.security),
          ),
          OwnerHubItem(
            icon: Icons.login_outlined,
            title: l10n.loginHistory,
            subtitle: l10n.loginHistoryHint,
            route: route(MonitoringDashboardSection.auditLog),
          ),
          OwnerHubItem(
            icon: Icons.devices_outlined,
            title: l10n.activeSessions,
            subtitle: l10n.activeSessionsHint,
            route: route(MonitoringDashboardSection.sessionManager),
          ),
          OwnerHubItem(
            icon: Icons.bug_report_outlined,
            title: l10n.errorMonitoring,
            subtitle: l10n.viewFullMonitoringCenter,
            route: route(MonitoringDashboardSection.errorMonitoring),
          ),
          OwnerHubItem(
            icon: Icons.block_outlined,
            title: l10n.failedLoginAttempts,
            subtitle: l10n.failedLoginAttemptsHint,
            route: route(MonitoringDashboardSection.security),
          ),
          OwnerHubItem(
            icon: Icons.no_accounts_outlined,
            title: l10n.blockedAccounts,
            subtitle: l10n.blockedAccountsHint,
            route: '${AdminRoutes.platformPrefix}/users',
          ),
          OwnerHubItem(
            icon: Icons.password_outlined,
            title: l10n.passwordResetLogs,
            subtitle: l10n.passwordResetLogsHint,
            route: route(MonitoringDashboardSection.auditLog),
          ),
        ],
      ),
    );
  }
}

class OwnerBackupRestoreScreen extends StatelessWidget {
  const OwnerBackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final route = OwnerDashboardNavigationService.routeFor(
      MonitoringDashboardSection.backup,
    );
    return AdminGuard(
      child: OwnerModuleHubScreen(
        title: l10n.backupRestore,
        header: l10n.backupRestoreHint,
        items: [
          OwnerHubItem(
            icon: Icons.backup_outlined,
            title: l10n.backupRestore,
            subtitle: l10n.viewFullMonitoringCenter,
            route: route,
          ),
          OwnerHubItem(
            icon: Icons.save_alt_outlined,
            title: l10n.manualBackup,
            subtitle: l10n.manualBackupHint,
            route: route,
          ),
          OwnerHubItem(
            icon: Icons.schedule_outlined,
            title: l10n.automaticBackup,
            subtitle: l10n.automaticBackupHint,
            route: route,
          ),
          OwnerHubItem(
            icon: Icons.restore_outlined,
            title: l10n.restoreData,
            subtitle: l10n.restoreDataHint,
            route: route,
          ),
        ],
      ),
    );
  }
}

class OwnerSystemSettingsScreen extends StatelessWidget {
  const OwnerSystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AdminGuard(
      child: OwnerModuleHubScreen(
        title: l10n.systemSettings,
        header: l10n.systemSettingsHint,
        items: [
          OwnerHubItem(
            icon: Icons.language_outlined,
            title: l10n.language,
            subtitle: l10n.languageSettingsHint,
            onTap: () => context.push('/settings'),
          ),
          OwnerHubItem(
            icon: Icons.palette_outlined,
            title: l10n.theme,
            subtitle: l10n.themeSettingsHint,
            onTap: () => context.push('/settings'),
          ),
          OwnerHubItem(
            icon: Icons.notifications_outlined,
            title: l10n.notifications,
            subtitle: l10n.notificationSettingsHint,
            onTap: () => context.push('/settings'),
          ),
          OwnerHubItem(
            icon: Icons.flag_outlined,
            title: l10n.featureFlags,
            subtitle: l10n.featureFlagsHint,
            comingSoon: true,
          ),
          OwnerHubItem(
            icon: Icons.build_outlined,
            title: l10n.maintenanceMode,
            subtitle: l10n.maintenanceModeHint,
            route: OwnerDashboardNavigationService.routeFor(
              MonitoringDashboardSection.maintenance,
            ),
          ),
          OwnerHubItem(
            icon: Icons.local_hospital_outlined,
            title: l10n.manageClinics,
            subtitle: l10n.manageClinics,
            route: '${AdminRoutes.platformPrefix}/clinics',
          ),
        ],
      ),
    );
  }
}
