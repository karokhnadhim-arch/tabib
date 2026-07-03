import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/admin_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../presentation/widgets/admin_guard.dart';
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
            comingSoon: true,
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
    return AdminGuard(
      child: OwnerModuleHubScreen(
        title: l10n.reportsAnalytics,
        header: l10n.reportsAnalyticsHint,
        items: [
          OwnerHubItem(
            icon: Icons.today_outlined,
            title: l10n.reportDaily,
            subtitle: l10n.reportDailyHint,
            route: '${AdminRoutes.platformPrefix}/analytics?period=daily',
          ),
          OwnerHubItem(
            icon: Icons.date_range_outlined,
            title: l10n.reportWeekly,
            subtitle: l10n.reportWeeklyHint,
            route: '${AdminRoutes.platformPrefix}/analytics?period=weekly',
          ),
          OwnerHubItem(
            icon: Icons.calendar_month_outlined,
            title: l10n.reportMonthly,
            subtitle: l10n.reportMonthlyHint,
            route: '${AdminRoutes.platformPrefix}/analytics?period=monthly',
          ),
          OwnerHubItem(
            icon: Icons.calendar_today_outlined,
            title: l10n.reportYearly,
            subtitle: l10n.reportYearlyHint,
            route: '${AdminRoutes.platformPrefix}/analytics?period=yearly',
          ),
          OwnerHubItem(
            icon: Icons.queue_outlined,
            title: l10n.queueStatistics,
            subtitle: l10n.queueStatisticsHint,
            route: '${AdminRoutes.platformPrefix}/stats',
          ),
          OwnerHubItem(
            icon: Icons.event_note_outlined,
            title: l10n.appointmentStatistics,
            subtitle: l10n.appointmentStatisticsHint,
            route: '${AdminRoutes.platformPrefix}/stats',
          ),
          OwnerHubItem(
            icon: Icons.payments_outlined,
            title: l10n.revenueStatistics,
            subtitle: l10n.revenueStatisticsHint,
            comingSoon: true,
          ),
          OwnerHubItem(
            icon: Icons.trending_up_outlined,
            title: l10n.userGrowth,
            subtitle: l10n.userGrowthHint,
            route: '${AdminRoutes.platformPrefix}/stats',
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
    return AdminGuard(
      child: OwnerModuleHubScreen(
        title: l10n.securityCenter,
        header: l10n.securityCenterHint,
        items: [
          OwnerHubItem(
            icon: Icons.login_outlined,
            title: l10n.loginHistory,
            subtitle: l10n.loginHistoryHint,
            route: AdminRoutes.platformPrefix + '/audit-log',
          ),
          OwnerHubItem(
            icon: Icons.devices_outlined,
            title: l10n.activeSessions,
            subtitle: l10n.activeSessionsHint,
            comingSoon: true,
          ),
          OwnerHubItem(
            icon: Icons.block_outlined,
            title: l10n.failedLoginAttempts,
            subtitle: l10n.failedLoginAttemptsHint,
            comingSoon: true,
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
            comingSoon: true,
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
    return AdminGuard(
      child: OwnerModuleHubScreen(
        title: l10n.backupRestore,
        header: l10n.backupRestoreHint,
        items: [
          OwnerHubItem(
            icon: Icons.save_alt_outlined,
            title: l10n.manualBackup,
            subtitle: l10n.manualBackupHint,
            comingSoon: true,
          ),
          OwnerHubItem(
            icon: Icons.schedule_outlined,
            title: l10n.automaticBackup,
            subtitle: l10n.automaticBackupHint,
            comingSoon: true,
          ),
          OwnerHubItem(
            icon: Icons.restore_outlined,
            title: l10n.restoreData,
            subtitle: l10n.restoreDataHint,
            comingSoon: true,
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
            comingSoon: true,
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
