import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/specialty_catalog_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../models/localized_text.dart';
import '../../models/service_provider_type.dart';
import '../../models/specialty.dart';
import '../../services/clinic_data_service.dart';
import '../../utils/localization_utils.dart';

/// Searchable specialty / business-type picker with localized create support.
class LocalizedSpecialtyAutocompleteField extends StatefulWidget {
  const LocalizedSpecialtyAutocompleteField({
    super.key,
    required this.accountType,
    required this.selectedSpecialtyId,
    required this.onSpecialtySelected,
    this.validator,
  });

  final ServiceProviderAccountType accountType;
  final String? selectedSpecialtyId;
  final ValueChanged<Specialty> onSpecialtySelected;
  final String? Function(Specialty?)? validator;

  @override
  State<LocalizedSpecialtyAutocompleteField> createState() =>
      _LocalizedSpecialtyAutocompleteFieldState();
}

class _LocalizedSpecialtyAutocompleteFieldState
    extends State<LocalizedSpecialtyAutocompleteField> {
  final _focusNode = FocusNode();
  Specialty? _selected;
  String _query = '';

  bool get _forBusiness => widget.accountType.isBusiness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFromCatalog());
  }

  @override
  void didUpdateWidget(LocalizedSpecialtyAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accountType != widget.accountType ||
        oldWidget.selectedSpecialtyId != widget.selectedSpecialtyId) {
      _syncFromCatalog();
    }
  }

  void _syncFromCatalog() {
    final data = context.read<ClinicDataService>();
    final id = widget.selectedSpecialtyId;
    if (id == null) {
      setState(() => _selected = null);
      return;
    }
    for (final specialty in data.specialties) {
      if (specialty.id == id) {
        setState(() => _selected = specialty);
        return;
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  List<Specialty> _options(String query) {
    final catalog = context.read<ClinicDataService>().specialties;
    final filtered = SpecialtyCatalogUtils.forAccountType(catalog, _forBusiness)
        .where((s) => s.isActive);
    return SpecialtyCatalogUtils.filterQuery(filtered.toList(), query);
  }

  Future<Specialty?> _promptCreateType(String typed) async {
    final l10n = AppLocalizations.of(context);
    final ku = TextEditingController(text: typed);
    final ar = TextEditingController(text: typed);
    final en = TextEditingController(text: typed);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_forBusiness ? l10n.addBusinessType : l10n.addSpecialty),
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
    );

    if (ok != true || !mounted) return null;

    final name = LocalizedText(
      ku: ku.text.trim(),
      ar: ar.text.trim(),
      en: en.text.trim(),
    );
    if (name.ku.isEmpty && name.ar.isEmpty && name.en.isEmpty) return null;

    return context.read<ClinicDataService>().findOrCreateSpecialty(
          name: name,
          forBusiness: _forBusiness,
        );
  }

  Future<void> _createFromQuery(
    String typed,
    void Function(Specialty?) fieldDidChange,
  ) async {
    _focusNode.unfocus();
    final created = await _promptCreateType(typed);
    if (created != null && mounted) {
      setState(() => _selected = created);
      widget.onSpecialtySelected(created);
      fieldDidChange(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FormField<Specialty>(
      initialValue: _selected,
      validator: widget.validator,
      builder: (field) {
        return Autocomplete<Specialty>(
          key: ValueKey('${widget.accountType}_${widget.selectedSpecialtyId}'),
          initialValue: TextEditingValue(
            text: _selected?.name.localized(context) ?? '',
          ),
          displayStringForOption: (s) => s.name.localized(context),
          optionsBuilder: (textEditingValue) {
            _query = textEditingValue.text;
            return _options(textEditingValue.text);
          },
          onSelected: (specialty) {
            setState(() => _selected = specialty);
            widget.onSpecialtySelected(specialty);
            field.didChange(specialty);
          },
          fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
            return TextFormField(
              controller: controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                labelText:
                    _forBusiness ? l10n.businessType : l10n.specialty,
                hintText: l10n.typeToSearchOrCreate,
                prefixIcon: Icon(
                  _forBusiness
                      ? Icons.storefront_outlined
                      : Icons.category_outlined,
                ),
                suffixIcon: _selected != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.clear();
                          setState(() => _selected = null);
                          field.didChange(null);
                        },
                      )
                    : null,
                errorText: field.errorText,
              ),
              onChanged: (value) {
                _query = value;
                if (_selected != null &&
                    value != _selected!.name.localized(context)) {
                  setState(() => _selected = null);
                  field.didChange(null);
                }
              },
              onFieldSubmitted: (_) => onSubmitted(),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            final typed = _query.trim();
            final showCreate = typed.isNotEmpty &&
                !options.any(
                  (s) => SpecialtyCatalogUtils.namesMatch(
                    s.name,
                    LocalizedText(ku: typed, ar: typed, en: typed),
                  ),
                );

            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 260,
                    maxWidth: 420,
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: [
                      ...options.map(
                        (s) => ListTile(
                          title: Text(s.name.localized(context)),
                          subtitle: Text(
                            s.name.en.isNotEmpty ? s.name.en : s.name.ku,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () => onSelected(s),
                        ),
                      ),
                      if (showCreate)
                        ListTile(
                          leading: const Icon(Icons.add),
                          title: Text(l10n.createNewType(typed)),
                          onTap: () => _createFromQuery(typed, field.didChange),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
