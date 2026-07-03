import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/admin_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/service_provider_type.dart';
import '../../../utils/provider_labels.dart';
import 'owner_module_hub_screen.dart';

/// Business management hub — browse by healthcare business category.
class OwnerBusinessManagementScreen extends StatelessWidget {
  const OwnerBusinessManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final items = [
      OwnerHubItem(
        icon: Icons.medical_services_outlined,
        title: l10n.allBusinesses,
        subtitle: l10n.allBusinessesHint,
        route: '${AdminRoutes.platformPrefix}/businesses',
      ),
      ...BusinessCategory.values.map(
        (category) => OwnerHubItem(
          icon: _iconFor(category),
          title: ProviderLabels.businessCategoryLabel(l10n, category),
          subtitle: l10n.businessCategoryBrowseHint,
          onTap: () => context.push(
            '${AdminRoutes.platformPrefix}/businesses?category=${category.storageKey}',
          ),
        ),
      ),
    ];

    return OwnerModuleHubScreen(
      title: l10n.businessManagement,
      header: l10n.businessManagement,
      items: items,
    );
  }

  static IconData _iconFor(BusinessCategory category) => switch (category) {
        BusinessCategory.clinic => Icons.local_hospital_outlined,
        BusinessCategory.beautyCenter => Icons.spa_outlined,
        BusinessCategory.medicalLaboratory => Icons.biotech_outlined,
        BusinessCategory.radiologyCenter => Icons.monitor_heart_outlined,
        BusinessCategory.physiotherapyCenter => Icons.self_improvement_outlined,
        BusinessCategory.dentalCenter => Icons.masks_outlined,
        BusinessCategory.eyeCenter => Icons.visibility_outlined,
        BusinessCategory.hearingCenter => Icons.hearing_outlined,
        BusinessCategory.vaccinationCenter => Icons.vaccines_outlined,
        BusinessCategory.bloodTestCenter => Icons.bloodtype_outlined,
        BusinessCategory.pharmacy => Icons.local_pharmacy_outlined,
        BusinessCategory.otherHealthcare => Icons.health_and_safety_outlined,
      };
}
