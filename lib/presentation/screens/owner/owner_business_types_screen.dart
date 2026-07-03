import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/localized_name_utils.dart';
import '../../../core/utils/specialty_catalog_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/specialty.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../presentation/widgets/localized_name_form_fields.dart';
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
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? l10n.editBusinessType : l10n.addBusinessType),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LocalizedNameFormFields(
                    kuController: ku,
                    arController: ar,
                    enController: en,
                    requireAll: true,
                    hint: l10n.localizedTypeHint,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: iconController,
                    decoration: InputDecoration(labelText: l10n.iconName),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      l10n.businessTypeActive,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      l10n.businessTypeActiveHint,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    value: isActive,
                    onChanged: (value) =>
                        setDialogState(() => isActive = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancelQueue),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() != true) return;
                Navigator.pop(ctx, true);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );

    if (saved != true || !mounted) {
      ku.dispose();
      ar.dispose();
      en.dispose();
      iconController.dispose();
      return;
    }

    final iconName = iconController.text.trim().isEmpty
        ? 'storefront'
        : iconController.text.trim();
    final name = LocalizedNameUtils.parseRequired(
      ku: ku.text,
      ar: ar.text,
      en: en.text,
    );

    ku.dispose();
    ar.dispose();
    en.dispose();
    iconController.dispose();

    if (name == null) return;

    final data = context.read<ClinicDataService>();
    if (isEdit) {
      await data.saveSpecialty(
        existing.copyWith(
          name: name,
          iconName: iconName,
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
          iconName: iconName,
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
                  final incomplete = !type.name.hasAllTranslations;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    AppTheme.primaryDark.withOpacity(0.12),
                                child: Icon(
                                  Icons.storefront_outlined,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      type.name.localized(context),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      LocalizedNameUtils.catalogSubtitle(
                                        type.name,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.businessTypeAssignedCount(assigned),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (incomplete) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        l10n.translationsIncomplete,
                                        style: TextStyle(
                                          color: Colors.orange.shade800,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.end,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              Text(
                                type.isActive
                                    ? l10n.businessTypeActive
                                    : l10n.subscriptionStatusExpired,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: type.isActive
                                      ? AppTheme.medicalGreen
                                      : Colors.grey.shade600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Switch(
                                value: type.isActive,
                                onChanged: (value) =>
                                    _toggleActive(type, value),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: l10n.editBusinessType,
                                onPressed: () => _openEditor(existing: type),
                              ),
                            ],
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
