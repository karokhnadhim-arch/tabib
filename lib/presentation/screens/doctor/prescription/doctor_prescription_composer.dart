import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/medicine.dart';
import '../../../../models/prescription_line_item.dart';
import '../../../../services/doctor_medicine_favorites_service.dart';
import '../../../../services/medicine_search_service.dart';
import '../../../../services/platform_medicine_catalog_service.dart';
import '../doctor_consultation_widgets.dart';

/// Fast medicine search + structured prescription lines — Material 3.
class DoctorPrescriptionComposer extends StatefulWidget {
  const DoctorPrescriptionComposer({
    super.key,
    required this.doctorId,
    required this.items,
    required this.onItemsChanged,
    this.readOnly = false,
    this.legacyMedications,
    this.onPrint,
  });

  final String doctorId;
  final List<PrescriptionLineItem> items;
  final ValueChanged<List<PrescriptionLineItem>> onItemsChanged;
  final bool readOnly;
  final String? legacyMedications;
  final VoidCallback? onPrint;

  @override
  State<DoctorPrescriptionComposer> createState() =>
      _DoctorPrescriptionComposerState();
}

class _DoctorPrescriptionComposerState extends State<DoctorPrescriptionComposer> {
  final _searchController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();
  final _lineNotesController = TextEditingController();
  final _searchFocus = FocusNode();

  Medicine? _pendingMedicine;
  List<Medicine> _suggestions = [];
  Timer? _searchDebounce;
  int? _editingIndex;

  static const _frequencyOptions = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Every 8 hours',
    'As needed',
  ];

  static const _durationOptions = ['3 days', '5 days', '7 days', '14 days', '30 days'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context
          .read<DoctorMedicineFavoritesService>()
          .load(widget.doctorId);
      if (mounted) _refreshSuggestions();
    });
  }

  @override
  void didUpdateWidget(covariant DoctorPrescriptionComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.doctorId != widget.doctorId) {
      _refreshSuggestions();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    _lineNotesController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  MedicineSearchService _searchService(BuildContext context) {
    final platform = context.read<PlatformMedicineCatalogService>();
    return MedicineSearchService(
      favorites: context.read<DoctorMedicineFavoritesService>(),
      additionalMedicines: platform.activeCustom,
    );
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 120), () {
      if (mounted) _refreshSuggestions();
    });
  }

  void _refreshSuggestions() {
    final service = _searchService(context);
    setState(() {
      _suggestions = service.search(
        query: _searchController.text,
        doctorId: widget.doctorId,
      );
    });
  }

  void _selectMedicine(Medicine medicine) {
    if (widget.readOnly) return;
    setState(() {
      _pendingMedicine = medicine;
      _editingIndex = null;
      _dosageController.text = _defaultDosage(medicine);
      _frequencyController.text = _frequencyOptions.first;
      _durationController.text = '7 days';
      _lineNotesController.clear();
      _searchController.clear();
      _suggestions = _searchService(context).search(
        query: '',
        doctorId: widget.doctorId,
      );
    });
  }

  String _defaultDosage(Medicine medicine) {
    final form = medicine.form.toLowerCase();
    if (form.contains('syrup') || form.contains('suspension')) return '5 ml';
    if (form.contains('injection') || form.contains('ampoule')) return '1 dose';
    if (form.contains('cream') || form.contains('ointment') || form.contains('gel')) {
      return 'Apply thin layer';
    }
    if (form.contains('drop')) return '2 drops';
    if (form.contains('inhaler')) return '2 puffs';
    return '1 tablet';
  }

  void _editItem(int index) {
    final item = widget.items[index];
    setState(() {
      _editingIndex = index;
      _pendingMedicine = Medicine(
        id: item.medicineId,
        genericName: item.genericName,
        brandNames: item.brandName.isNotEmpty ? [item.brandName] : const [],
        strength: item.strength,
        form: item.form,
      );
      _dosageController.text = item.dosage;
      _frequencyController.text = item.frequency;
      _durationController.text = item.duration;
      _lineNotesController.text = item.notes ?? '';
    });
  }

  void _cancelPending() {
    setState(() {
      _pendingMedicine = null;
      _editingIndex = null;
    });
  }

  void _commitLine() {
    final medicine = _pendingMedicine;
    if (medicine == null) return;
    if (_dosageController.text.trim().isEmpty ||
        _frequencyController.text.trim().isEmpty ||
        _durationController.text.trim().isEmpty) {
      return;
    }

    final line = PrescriptionLineItem(
      medicineId: medicine.id,
      genericName: medicine.genericName,
      brandName: medicine.primaryBrand,
      strength: medicine.strength,
      form: medicine.form,
      dosage: _dosageController.text.trim(),
      frequency: _frequencyController.text.trim(),
      duration: _durationController.text.trim(),
      notes: _lineNotesController.text.trim().isEmpty
          ? null
          : _lineNotesController.text.trim(),
    );

    final next = List<PrescriptionLineItem>.from(widget.items);
    if (_editingIndex != null) {
      next[_editingIndex!] = line;
    } else {
      next.add(line);
    }
    widget.onItemsChanged(next);
    _cancelPending();
    _searchFocus.requestFocus();
  }

  void _removeItem(int index) {
    final next = List<PrescriptionLineItem>.from(widget.items)..removeAt(index);
    widget.onItemsChanged(next);
    if (_editingIndex == index) _cancelPending();
  }

  Future<void> _toggleFavorite(String medicineId) async {
    await context
        .read<DoctorMedicineFavoritesService>()
        .toggleFavorite(widget.doctorId, medicineId);
    _refreshSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final favorites = context.watch<DoctorMedicineFavoritesService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.readOnly) ...[
          if (_pendingMedicine == null) ...[
            SearchBar(
              controller: _searchController,
              focusNode: _searchFocus,
              hintText: l10n.searchMedicine,
              leading: const Icon(Icons.search_rounded),
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchController.clear();
                      _refreshSuggestions();
                    },
                  ),
              ],
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(
                scheme.surfaceContainerLowest,
              ),
              side: WidgetStateProperty.all(
                BorderSide(color: scheme.outlineVariant.withOpacity(0.6)),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: DoctorConsultationTokens.cardRadius,
                ),
              ),
            ),
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              _SuggestionList(
                medicines: _suggestions,
                favorites: favorites,
                doctorId: widget.doctorId,
                onSelect: _selectMedicine,
                onToggleFavorite: _toggleFavorite,
                favoriteLabel: l10n.favoriteMedicines,
                showFavoriteHeader: _searchController.text.trim().isEmpty &&
                    favorites.favoritesFor(widget.doctorId).isNotEmpty,
              ),
            ],
          ] else
            _PendingLineForm(
              medicine: _pendingMedicine!,
              dosageController: _dosageController,
              frequencyController: _frequencyController,
              durationController: _durationController,
              notesController: _lineNotesController,
              frequencyOptions: _frequencyOptions,
              durationOptions: _durationOptions,
              isEditing: _editingIndex != null,
              onCancel: _cancelPending,
              onCommit: _commitLine,
              l10n: l10n,
            ),
        ],
        if (widget.items.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.prescriptionLines,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (widget.onPrint != null && widget.items.isNotEmpty)
                TextButton.icon(
                  onPressed: widget.onPrint,
                  icon: const Icon(Icons.print_outlined, size: 18),
                  label: Text(l10n.printPrescription),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < widget.items.length; i++)
            _LineItemCard(
              item: widget.items[i],
              index: i,
              readOnly: widget.readOnly,
              onEdit: () => _editItem(i),
              onRemove: () => _removeItem(i),
            ),
        ] else if (widget.legacyMedications != null &&
            widget.legacyMedications!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.medications,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(widget.legacyMedications!.trim()),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({
    required this.medicines,
    required this.favorites,
    required this.doctorId,
    required this.onSelect,
    required this.onToggleFavorite,
    required this.favoriteLabel,
    required this.showFavoriteHeader,
  });

  final List<Medicine> medicines;
  final DoctorMedicineFavoritesService favorites;
  final String doctorId;
  final ValueChanged<Medicine> onSelect;
  final Future<void> Function(String) onToggleFavorite;
  final String favoriteLabel;
  final bool showFavoriteHeader;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final favIds = favorites.favoritesFor(doctorId).toSet();
  final favCount = medicines.where((m) => favIds.contains(m.id)).length;

    return Material(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      borderRadius: DoctorConsultationTokens.cardRadius,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: medicines.length + (showFavoriteHeader ? 1 : 0),
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: scheme.outlineVariant.withOpacity(0.4),
        ),
        itemBuilder: (context, index) {
          if (showFavoriteHeader && index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Icon(Icons.star_rounded, size: 16, color: scheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    favoriteLabel,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            );
          }
          final medIndex = showFavoriteHeader ? index - 1 : index;
          final medicine = medicines[medIndex];
          final isFav = favIds.contains(medicine.id);
          final showDividerAfterFavs = showFavoriteHeader &&
              favCount > 0 &&
              medIndex == favCount &&
              medIndex < medicines.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showDividerAfterFavs)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    AppLocalizations.of(context).searchResults,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
              InkWell(
                onTap: () => onSelect(medicine),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: isFav
                                ? AppTheme.doctorColor.withOpacity(0.12)
                                : scheme.secondaryContainer.withOpacity(0.5),
                            child: Icon(
                              isFav ? Icons.star_rounded : Icons.medication_outlined,
                              size: 18,
                              color: isFav ? AppTheme.doctorColor : scheme.onSecondaryContainer,
                            ),
                          ),
                          title: Text(
                            medicine.genericName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${medicine.primaryBrand} · ${medicine.strength} (${medicine.form})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: isFav
                            ? AppLocalizations.of(context).removeFavorite
                            : AppLocalizations.of(context).addFavorite,
                        icon: Icon(
                          isFav ? Icons.star : Icons.star_outline_rounded,
                          color: isFav ? AppTheme.doctorColor : scheme.onSurfaceVariant,
                        ),
                        onPressed: () => onToggleFavorite(medicine.id),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PendingLineForm extends StatelessWidget {
  const _PendingLineForm({
    required this.medicine,
    required this.dosageController,
    required this.frequencyController,
    required this.durationController,
    required this.notesController,
    required this.frequencyOptions,
    required this.durationOptions,
    required this.isEditing,
    required this.onCancel,
    required this.onCommit,
    required this.l10n,
  });

  final Medicine medicine;
  final TextEditingController dosageController;
  final TextEditingController frequencyController;
  final TextEditingController durationController;
  final TextEditingController notesController;
  final List<String> frequencyOptions;
  final List<String> durationOptions;
  final bool isEditing;
  final VoidCallback onCancel;
  final VoidCallback onCommit;
  final AppLocalizations l10n;

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: DoctorConsultationTokens.cardRadius),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.primaryContainer.withOpacity(0.25),
      shape: RoundedRectangleBorder(
        borderRadius: DoctorConsultationTokens.cardRadius,
        side: BorderSide(color: scheme.primary.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.genericName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        '${medicine.primaryBrand} · ${medicine.strength} (${medicine.form})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: dosageController,
              decoration: _decoration(l10n.dosage),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: frequencyController,
              decoration: _decoration(l10n.frequency),
            ),
            const SizedBox(height: 6),
            _QuickChipRow(
              options: frequencyOptions,
              selected: frequencyController.text,
              onSelected: (v) => frequencyController.text = v,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: durationController,
              decoration: _decoration(l10n.duration),
            ),
            const SizedBox(height: 6),
            _QuickChipRow(
              options: durationOptions,
              selected: durationController.text,
              onSelected: (v) => durationController.text = v,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notesController,
              decoration: _decoration(l10n.lineNotesOptional),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onCommit,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.doctorColor,
                minimumSize: const Size.fromHeight(44),
              ),
              child: Text(isEditing ? l10n.updateLine : l10n.addMedicine),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickChipRow extends StatefulWidget {
  const _QuickChipRow({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  State<_QuickChipRow> createState() => _QuickChipRowState();
}

class _QuickChipRowState extends State<_QuickChipRow> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in widget.options)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(option, style: const TextStyle(fontSize: 12)),
                selected: widget.selected == option,
                onSelected: (_) {
                  widget.onSelected(option);
                  setState(() {});
                },
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
    );
  }
}

class _LineItemCard extends StatelessWidget {
  const _LineItemCard({
    required this.item,
    required this.index,
    required this.readOnly,
    required this.onEdit,
    required this.onRemove,
  });

  final PrescriptionLineItem item;
  final int index;
  final bool readOnly;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.doctorColor.withOpacity(0.12),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.doctorColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.displayName} · ${item.strength}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${item.dosage} · ${item.frequency} · ${item.duration}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  if (item.notes != null && item.notes!.trim().isNotEmpty)
                    Text(
                      item.notes!.trim(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            if (!readOnly) ...[
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit,
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, size: 20, color: scheme.error),
                onPressed: onRemove,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
