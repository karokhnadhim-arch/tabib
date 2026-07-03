import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/auth/admin_permissions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/localized_name_utils.dart';
import '../../core/utils/specialty_catalog_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../models/service_provider_type.dart';
import '../../models/specialty.dart';
import '../../presentation/widgets/highlighted_search_text.dart';
import '../../presentation/widgets/localized_name_form_fields.dart';
import '../../services/auth_service.dart';
import '../../services/business_type_usage_service.dart';
import '../../services/clinic_data_service.dart';
import '../../utils/localization_utils.dart';

/// Google-style searchable specialty / business-type picker.
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
  static const _minSearchChars = 2;
  static const _maxSuggestions = 50;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  Specialty? _selected;
  String _query = '';
  int _highlightedIndex = 0;
  List<Specialty> _suggestions = [];
  bool _showRecent = false;

  void Function(Specialty?)? _fieldDidChange;
  double _fieldWidth = 480;

  bool get _forBusiness => widget.accountType.isBusiness;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncFromCatalog();
      if (_forBusiness) {
        context.read<BusinessTypeUsageService>().load();
      }
    });
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
      if (_selected != null) {
        setState(() => _selected = null);
        _controller.clear();
      }
      return;
    }
    final specialty = data.specialtyById(id);
    if (specialty == null) return;
    setState(() => _selected = specialty);
    final label = specialty.name.localized(context);
    if (_controller.text != label) {
      _controller.text = label;
      _controller.selection = TextSelection.collapsed(offset: label.length);
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _rebuildSuggestions();
      _showOverlay();
    } else {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!_focusNode.hasFocus && mounted) _removeOverlay();
      });
    }
  }

  List<Specialty> _activeCatalog(ClinicDataService data) =>
      SpecialtyCatalogUtils.activeForAccountType(
        data.specialties,
        _forBusiness,
      );

  void _rebuildSuggestions() {
    final data = context.read<ClinicDataService>();
    final catalog = _activeCatalog(data);
    final trimmed = _query.trim();

    if (_forBusiness && trimmed.length < _minSearchChars) {
      final recent = context.read<BusinessTypeUsageService>().resolveRecent(catalog);
      _suggestions = recent;
      _showRecent = recent.isNotEmpty;
      _highlightedIndex = 0;
      return;
    }

    _showRecent = false;
    if (trimmed.length < _minSearchChars) {
      _suggestions = const [];
      _highlightedIndex = 0;
      return;
    }

    _suggestions = SpecialtyCatalogUtils.filterQuery(
      catalog,
      trimmed,
      limit: _maxSuggestions,
    );
    _highlightedIndex = 0;
  }

  void _showOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => _SuggestionsOverlay(
        layerLink: _layerLink,
        width: _fieldWidth,
        child: _buildSuggestionsPanel(),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _refreshOverlay() {
    _rebuildSuggestions();
    _overlayEntry?.markNeedsBuild();
  }

  bool _canCreateBusinessType(AuthService auth) =>
      _forBusiness && auth.isSystemOwner;

  bool _canCreateSpecialty(AuthService auth) =>
      !_forBusiness && AdminPermissions.canCreateDoctors(auth);

  Future<Specialty?> _promptCreateType({String prefilled = ''}) async {
    final l10n = AppLocalizations.of(context);
    final ku = TextEditingController(text: prefilled);
    final ar = TextEditingController(text: prefilled);
    final en = TextEditingController(text: prefilled);
    final formKey = GlobalKey<FormState>();
    final requireAll = _forBusiness;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_forBusiness ? l10n.addBusinessType : l10n.addSpecialty),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: LocalizedNameFormFields(
              kuController: ku,
              arController: ar,
              enController: en,
              requireAll: requireAll,
              hint: l10n.localizedTypeHint,
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
    );

    final name = LocalizedNameFormFields.parse(
      l10n,
      ku: ku,
      ar: ar,
      en: en,
      requireAll: requireAll,
    );
    ku.dispose();
    ar.dispose();
    en.dispose();

    if (ok != true || !mounted || name == null) return null;

    return context.read<ClinicDataService>().findOrCreateSpecialty(
          name: name,
          forBusiness: _forBusiness,
        );
  }

  Future<void> _createNew(void Function(Specialty?) fieldDidChange) async {
    _focusNode.unfocus();
    final created = await _promptCreateType(prefilled: _query.trim());
    if (created != null && mounted) {
      _select(created, fieldDidChange);
    }
  }

  void _select(Specialty specialty, void Function(Specialty?) fieldDidChange) {
    final label = specialty.name.localized(context);
    setState(() {
      _selected = specialty;
      _query = label;
      _controller.text = label;
      _controller.selection = TextSelection.collapsed(offset: label.length);
    });
    widget.onSpecialtySelected(specialty);
    fieldDidChange(specialty);
    if (_forBusiness) {
      context.read<BusinessTypeUsageService>().recordUsage(specialty.id);
    }
    _removeOverlay();
    _focusNode.unfocus();
  }

  KeyEventResult _handleKey(
    KeyEvent event,
    void Function(Specialty?) fieldDidChange,
  ) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (!_focusNode.hasFocus) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_suggestions.isEmpty) return KeyEventResult.handled;
      setState(() {
        _highlightedIndex =
            (_highlightedIndex + 1).clamp(0, _suggestions.length - 1);
      });
      _overlayEntry?.markNeedsBuild();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_suggestions.isEmpty) return KeyEventResult.handled;
      setState(() {
        _highlightedIndex =
            (_highlightedIndex - 1).clamp(0, _suggestions.length - 1);
      });
      _overlayEntry?.markNeedsBuild();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_suggestions.isNotEmpty) {
        _select(_suggestions[_highlightedIndex], fieldDidChange);
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  Widget _buildSuggestionsPanel() {
    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthService>();
    final theme = Theme.of(context);
    final trimmed = _query.trim();
    final searching = trimmed.length >= _minSearchChars;
    final noMatches = searching && _suggestions.isEmpty;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 320, maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: _suggestions.isEmpty && !noMatches
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _forBusiness
                            ? l10n.businessTypeSearchHint
                            : l10n.specialtySearchHint,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : noMatches
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                          child: Text(
                            _forBusiness
                                ? l10n.noBusinessTypeFound
                                : l10n.noSpecialtyFound,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: _suggestions.length +
                              (_showRecent ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (_showRecent && index == 0) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  16,
                                  4,
                                ),
                                child: Text(
                                  l10n.recentlyUsedBusinessTypes,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }
                            final itemIndex =
                                _showRecent ? index - 1 : index;
                            final specialty = _suggestions[itemIndex];
                            final isHighlighted =
                                itemIndex == _highlightedIndex;
                            final title = specialty.name.localized(context);
                            return InkWell(
                              onTap: () => _select(
                                specialty,
                                _fieldDidChange ?? (_) {},
                              ),
                              child: Container(
                                color: isHighlighted
                                    ? AppTheme.primaryDark.withOpacity(0.08)
                                    : null,
                                child: ListTile(
                                  dense: true,
                                  leading: Icon(
                                    _forBusiness
                                        ? Icons.storefront_outlined
                                        : Icons.category_outlined,
                                    size: 20,
                                    color: isHighlighted
                                        ? AppTheme.primaryDark
                                        : Colors.grey.shade600,
                                  ),
                                  title: HighlightedSearchText(
                                    text: title,
                                    query: trimmed,
                                    style: TextStyle(
                                      fontWeight: isHighlighted
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    LocalizedNameUtils.catalogSubtitle(
                                      specialty.name,
                                    ),
                                    style: const TextStyle(fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
            if (_forBusiness && _canCreateBusinessType(auth))
              Divider(height: 1, color: Colors.grey.shade200),
            if (_forBusiness && _canCreateBusinessType(auth))
              InkWell(
                onTap: () => _createNew(_fieldDidChange ?? (_) {}),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        size: 20,
                        color: AppTheme.primaryDark,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.createNewBusinessType,
                        style: TextStyle(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (!_forBusiness &&
                _canCreateSpecialty(auth) &&
                searching &&
                noMatches)
              InkWell(
                onTap: () => _createNew(_fieldDidChange ?? (_) {}),
                child: ListTile(
                  leading: const Icon(Icons.add),
                  title: Text(l10n.createNewType(trimmed)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Rebuild when catalog or recent usage changes.
    context.watch<ClinicDataService>();
    if (_forBusiness) {
      context.watch<BusinessTypeUsageService>();
    }

    return FormField<Specialty>(
      initialValue: _selected,
      validator: widget.validator,
      builder: (field) {
        _fieldDidChange = field.didChange;
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth.isFinite && constraints.maxWidth > 0) {
              _fieldWidth = constraints.maxWidth;
            }
            return CompositedTransformTarget(
              link: _layerLink,
              child: Focus(
                onKeyEvent: (node, event) =>
                    _handleKey(event, field.didChange),
                child: TextFormField(
                  controller: _controller,
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
                              _controller.clear();
                              setState(() {
                                _selected = null;
                                _query = '';
                              });
                              field.didChange(null);
                              _refreshOverlay();
                            },
                          )
                        : const Icon(Icons.search, size: 20),
                    errorText: field.errorText,
                  ),
                  onChanged: (value) {
                    setState(() => _query = value);
                    if (_selected != null &&
                        value != _selected!.name.localized(context)) {
                      _selected = null;
                      field.didChange(null);
                    }
                    _refreshOverlay();
                    if (_focusNode.hasFocus && _overlayEntry == null) {
                      _showOverlay();
                    }
                  },
                  onTap: () {
                    _refreshOverlay();
                    if (_overlayEntry == null) _showOverlay();
                  },
                  onFieldSubmitted: (_) {
                    if (_suggestions.isNotEmpty) {
                      _select(
                        _suggestions[_highlightedIndex],
                        field.didChange,
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SuggestionsOverlay extends StatelessWidget {
  const _SuggestionsOverlay({
    required this.layerLink,
    required this.width,
    required this.child,
  });

  final LayerLink layerLink;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: width,
      child: CompositedTransformFollower(
        link: layerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 56),
        child: child,
      ),
    );
  }
}
