import 'package:flutter/material.dart';

import '../../../core/auth/admin_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../presentation/widgets/admin_guard.dart';
import 'owner_module_hub_screen.dart';

/// Hub for medicine, investigation, queue, and prescription administration.
class OwnerClinicalAdminScreen extends StatelessWidget {
  const OwnerClinicalAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefix = AdminRoutes.platformPrefix;

    return AdminGuard(
      child: OwnerModuleHubScreen(
        title: l10n.clinicalAdministration,
        header: l10n.clinicalAdministrationHint,
        items: [
          OwnerHubItem(
            icon: Icons.medication_outlined,
            title: l10n.medicineDatabase,
            subtitle: l10n.medicineDatabaseHint,
            route: '$prefix/medicine-database',
          ),
          OwnerHubItem(
            icon: Icons.biotech_outlined,
            title: l10n.investigationDatabase,
            subtitle: l10n.investigationDatabaseHint,
            route: '$prefix/investigation-database',
          ),
          OwnerHubItem(
            icon: Icons.queue_outlined,
            title: l10n.queueSettings,
            subtitle: l10n.queueSettingsHint,
            route: '$prefix/queue-settings',
          ),
          OwnerHubItem(
            icon: Icons.receipt_long_outlined,
            title: l10n.prescriptionSettings,
            subtitle: l10n.prescriptionSettingsHint,
            route: '$prefix/prescription-settings',
          ),
        ],
      ),
    );
  }
}
