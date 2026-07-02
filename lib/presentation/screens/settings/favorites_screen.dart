import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/doctor.dart';
import '../../../models/provider_catalog_mode.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/favorites_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/provider_labels.dart';
import '../../widgets/doctor_avatar.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.kind});

  final FavoriteKind kind;

  bool get isBusiness => kind == FavoriteKind.business;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final favorites = context.watch<FavoritesService>();
    final data = context.watch<ClinicDataService>();
    final ids = isBusiness
        ? favorites.favoriteBusinessIds
        : favorites.favoriteDoctorIds;

    final providers = ids
        .map(data.doctorById)
        .whereType<Doctor>()
        .where((d) => isBusiness ? d.isBusiness : d.isDoctorAccount)
        .toList();

    final title = isBusiness ? l10n.favoriteBusinesses : l10n.favoriteDoctors;
    final emptyMessage =
        isBusiness ? l10n.noFavoriteBusinesses : l10n.noFavoriteDoctors;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.patientColor,
      ),
      body: ResponsiveBody(
        child: providers.isEmpty
            ? Center(child: Text(emptyMessage))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: providers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final provider = providers[index];
                  final route = ProviderLabels.detailRoute(
                    isBusiness
                        ? ProviderCatalogMode.businesses
                        : ProviderCatalogMode.doctors,
                    provider.id,
                  );
                  return Card(
                    child: ListTile(
                      onTap: () => context.push(route),
                      leading: DoctorAvatar(
                        photoUrl: provider.patientVisiblePhotoUrl,
                        thumbnailUrl: provider.patientVisiblePhotoThumbnailUrl,
                        radius: 22,
                        fallback: Icon(
                          isBusiness
                              ? Icons.storefront_outlined
                              : Icons.medical_services_outlined,
                          color: AppTheme.medicalBlue,
                        ),
                      ),
                      title: Text(provider.name.localized(context)),
                      subtitle: Text(
                        ProviderLabels.displayCategory(context, l10n, provider),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () => favorites.toggle(provider.id, kind),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
