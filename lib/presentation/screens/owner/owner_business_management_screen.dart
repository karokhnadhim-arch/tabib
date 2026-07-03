import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/admin_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/clinic_data_service.dart';
import '../../../utils/localization_utils.dart';
import 'package:provider/provider.dart';
import 'owner_module_hub_screen.dart';

/// Business management hub — centralized business types and provider browse.
class OwnerBusinessManagementScreen extends StatefulWidget {
  const OwnerBusinessManagementScreen({super.key});

  @override
  State<OwnerBusinessManagementScreen> createState() =>
      _OwnerBusinessManagementScreenState();
}

class _OwnerBusinessManagementScreenState
    extends State<OwnerBusinessManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClinicDataService>().ensureCatalogLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = context.watch<ClinicDataService>();
    final types = data.businessTypes;

    final items = [
      OwnerHubItem(
        icon: Icons.category_outlined,
        title: l10n.manageBusinessTypes,
        subtitle: l10n.manageBusinessTypesHint,
        route: '${AdminRoutes.platformPrefix}/business-types',
      ),
      OwnerHubItem(
        icon: Icons.medical_services_outlined,
        title: l10n.allBusinesses,
        subtitle: l10n.allBusinessesHint,
        route: '${AdminRoutes.platformPrefix}/businesses',
      ),
      ...types.map(
        (type) => OwnerHubItem(
          icon: Icons.storefront_outlined,
          title: type.name.localized(context),
          subtitle: l10n.businessCategoryBrowseHint,
          onTap: () => context.push(
            '${AdminRoutes.platformPrefix}/businesses?type=${type.id}',
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
}
