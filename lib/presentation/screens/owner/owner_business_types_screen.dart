import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/specialty_catalog_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/localized_text.dart';
import '../../../models/specialty.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../presentation/widgets/owner_module_app_bar.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../utils/localization_utils.dart';

/// System Owner console — centralized business type catalog management.
class OwnerBusinessTypesScreen extends StatefulWidget {
  const OwnerBusinessTypesScreen({super.key});

  @override
  State<OwnerBusinessTypesScreen> createState() =>
      _OwnerBusinessTypesScreenState();
}

class _OwnerBusinessTypesScreenState extends State<OwnerBusinessTypesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = context.read<ClinicDataService>();
      await data.ensureCatalogLoaded();
      data.startRealtimeCatalog();
    });
  }

  Future<void> _openEditor({Specialty? existing}) async {
    final l10n = AppLocalizations.of(context);
    final isEdit = existing != null;
    final ku = TextEditingController(text: existing?.name.ku ?? '');
    final ar = TextEditingController(text: existing?.name.ar ?? '');
    final en = TextEditingController(text: existing?.name.en ?? '');
    final iconController =
        TextEditingController(text: existing?.iconName ?? 'storefront');
    var isActive = existing?.isActive ?? false;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? l10n.editBusinessType : l10n.addBusinessType),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.localizedTypeHint),
                const SizedBox(height: 12),
                TextField(
                  controller: ku,
                  decoration: InputDecoration(labelText: l10n.nameKu),
                ),
                TextField(
                  controller: ar,
                  decoration: InputDecoration(labelText: l10n.nameAr),
                ),
                TextField(
                  controller: en,
                  decoration: InputDecoration(labelText: l10n.nameEn),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: iconController,
                  decoration: InputDecoration(labelText: l10n.iconName),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.businessTypeActive),
                  subtitle: Text(l10n.businessTypeActiveHint),
                  value: isActive,
                  onChanged: (value) => setDialogState(() => isActive = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancelQueue),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );

    if (saved != true || !mounted) return;

    final name = LocalizedText(
      ku: ku.text.trim(),
      ar: ar.text.trim(),
      en: en.text.trim(),
    );
    if (name.ku.isEmpty && name.ar.isEmpty && name.en.isEmpty) return;

    final data = context.read<ClinicDataService>();
    if (isEdit) {
      await data.saveSpecialty(
        existing.copyWith(
          name: name,
          iconName: iconController.text.trim().isEmpty
              ? 'storefront'
              : iconController.text.trim(),
          isActive: isActive,
          isBusinessType: true,
        ),
      );
    } else {
      final duplicate = SpecialtyCatalogUtils.findDuplicate(
        data.specialties,
        name,
        forBusiness: true,
      );
      if (duplicate != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.businessTypeDuplicate)),
        );
        return;
      }
      await data.saveSpecialty(
        Specialty(
          id: SpecialtyCatalogUtils.uniqueId(
            data.specialties,
            name,
            forBusiness: true,
          ),
          name: name,
          iconName: iconController.text.trim().isEmpty
              ? 'storefront'
              : iconController.text.trim(),
          isBusinessType: true,
          isActive: isActive,
        ),
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.savedSuccessfully)),
    );
  }

  Future<void> _toggleActive(Specialty type, bool active) async {
    await context.read<ClinicDataService>().saveSpecialty(
          type.copyWith(isActive: active),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    if (!auth.isSystemOwner) return const SizedBox.shrink();

    final data = context.watch<ClinicDataService>();
    final types = data.businessTypes;

    return AdminGuard(
      child: Scaffold(
        appBar: ownerModuleAppBar(context, title: l10n.manageBusinessTypes),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openEditor(),
          child: const Icon(Icons.add),
        ),
        body: types.isEmpty
            ? Center(child: Text(l10n.noBusinessTypesYet))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: types.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final type = types[index];
                  final assigned = data.doctors
                      .where((d) => d.isBusiness && d.specialtyId == type.id)
                      .length;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppTheme.primaryDark.withOpacity(0.12),
                        child: Icon(
                          Icons.storefront_outlined,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      title: Text(type.name.localized(context)),
                      subtitle: Text(
                        '${type.name.en.isNotEmpty ? type.name.en : type.name.ku} • '
                        '${l10n.businessTypeAssignedCount(assigned)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: type.isActive,
                            onChanged: (value) => _toggleActive(type, value),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _openEditor(existing: type),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
