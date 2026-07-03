import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../firebase_options.dart';
import '../../../l10n/app_localizations.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/firebase_bootstrap.dart';
import '../../../services/staff_data_service.dart';
import 'owner_module_hub_screen.dart';

/// Platform infrastructure status for the System Owner.
class OwnerSystemHealthScreen extends StatelessWidget {
  const OwnerSystemHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clinics = context.watch<ClinicDataService>().clinics.length;
    final staff = context.watch<StaffDataService>().staffIncludingHidden.length;
    final firebaseOk = FirebaseBootstrap.initialized;
    final configured = DefaultFirebaseOptions.isConfigured;

    return AdminGuard(
      child: OwnerModuleHubScreen(
        title: l10n.systemHealth,
        header: l10n.systemHealthHint,
        items: [
          OwnerHubItem(
            icon: Icons.cloud_outlined,
            title: l10n.firebaseStatus,
            subtitle: firebaseOk && configured
                ? l10n.statusConnected
                : l10n.statusDemoOrOffline,
          ),
          OwnerHubItem(
            icon: Icons.storage_outlined,
            title: l10n.storageUsage,
            subtitle: '$clinics ${l10n.clinicsLabel}, $staff ${l10n.accountsLabel}',
          ),
          OwnerHubItem(
            icon: Icons.dataset_outlined,
            title: l10n.databaseUsage,
            subtitle: '$clinics ${l10n.clinicsLabel}, $staff ${l10n.accountsLabel}',
          ),
          OwnerHubItem(
            icon: Icons.bug_report_outlined,
            title: l10n.errorLogs,
            subtitle: l10n.errorLogsHint,
            comingSoon: true,
          ),
          OwnerHubItem(
            icon: Icons.report_outlined,
            title: l10n.crashReports,
            subtitle: l10n.crashReportsHint,
            comingSoon: true,
          ),
          OwnerHubItem(
            icon: Icons.speed_outlined,
            title: l10n.performanceMonitoring,
            subtitle: l10n.performanceMonitoringHint,
            comingSoon: true,
          ),
        ],
      ),
    );
  }
}
