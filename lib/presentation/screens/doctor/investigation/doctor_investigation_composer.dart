import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/investigation_catalog_item.dart';
import '../../../../models/investigation_category.dart';
import '../../../../models/investigation_request_item.dart';
import '../../../../services/investigation_search_service.dart';
import '../../../../services/platform_investigation_catalog_service.dart';
import '../../../../utils/investigation_category_utils.dart';
import '../doctor_consultation_widgets.dart';

/// Fast investigation search + one-click request lines — Material 3.
class DoctorInvestigationComposer extends StatefulWidget {
  const DoctorInvestigationComposer({
    super.key,
    required this.items,
    required this.onItemsChanged,
    this.readOnly = false,
  });

  final List<InvestigationRequestItem> items;
  final ValueChanged<List<InvestigationRequestItem>> onItemsChanged;
  final bool readOnly;

  @override
  State<DoctorInvestigationComposer> createState() =>
      _DoctorInvestigationComposerState();
}

class _DoctorInvestigationComposerState extends State<DoctorInvestigationComposer> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  Map<InvestigationCategory, List<InvestigationCatalogItem>> _grouped = {};

  InvestigationSearchService _searchService(BuildContext context) {
    final platform = context.read<PlatformInvestigationCatalogService>();
    return InvestigationSearchService(
      additionalItems: platform.activeCustom,
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _refreshSuggestions();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 120), () {
      if (mounted) _refreshSuggestions();
    });
  }

  void _refreshSuggestions() {
    setState(() {
      _grouped =
          _searchService(context).grouped(query: _searchController.text);
    });
  }

  bool _isSelected(String id) =>
      widget.items.any((i) => i.investigationId == id);

  void _toggleItem(InvestigationCatalogItem catalogItem) {
    if (widget.readOnly) return;
    final next = List<InvestigationRequestItem>.from(widget.items);
    final index =
        next.indexWhere((i) => i.investigationId == catalogItem.id);
    if (index >= 0) {
      next.removeAt(index);
    } else {
      next.add(InvestigationRequestItem(
        investigationId: catalogItem.id,
        name: catalogItem.name,
        category: catalogItem.category,
      ));
    }
    widget.onItemsChanged(next);
  }

  Future<void> _editNote(InvestigationRequestItem item) async {
    if (widget.readOnly) return;
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: item.note ?? '');
    final note = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.investigationNote),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: l10n.investigationNoteHint),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (note == null || !mounted) return;

    final next = widget.items
        .map((i) => i.investigationId == item.investigationId
            ? i.copyWith(note: note.isEmpty ? null : note)
            : i)
        .toList();
    widget.onItemsChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.readOnly) ...[
          SearchBar(
            controller: _searchController,
            hintText: l10n.searchInvestigation,
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
          if (_grouped.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final entry in _grouped.entries) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 4, top: 4),
                child: Text(
                  entry.key.label(l10n),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                ),
              ),
              Material(
                elevation: 0,
                color: scheme.surfaceContainerLow,
                borderRadius: DoctorConsultationTokens.cardRadius,
                child: Column(
                  children: [
                    for (var i = 0; i < entry.value.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          color: scheme.outlineVariant.withOpacity(0.35),
                        ),
                      _CatalogTile(
                        item: entry.value[i],
                        selected: _isSelected(entry.value[i].id),
                        onTap: () => _toggleItem(entry.value[i]),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
        if (widget.items.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            l10n.requestedInvestigations,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < widget.items.length; i++)
            _RequestedItemCard(
              item: widget.items[i],
              index: i,
              readOnly: widget.readOnly,
              categoryLabel: widget.items[i].category.label(l10n),
              onRemove: () {
                final next = List<InvestigationRequestItem>.from(widget.items)
                  ..removeAt(i);
                widget.onItemsChanged(next);
              },
              onEditNote: () => _editNote(widget.items[i]),
            ),
        ],
      ],
    );
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final InvestigationCatalogItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : Icons.add_circle_outline,
              color: selected ? AppTheme.doctorColor : scheme.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? AppTheme.doctorColor : scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestedItemCard extends StatelessWidget {
  const _RequestedItemCard({
    required this.item,
    required this.index,
    required this.readOnly,
    required this.categoryLabel,
    required this.onRemove,
    required this.onEditNote,
  });

  final InvestigationRequestItem item;
  final int index;
  final bool readOnly;
  final String categoryLabel;
  final VoidCallback onRemove;
  final VoidCallback onEditNote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                style: const TextStyle(
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
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    categoryLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  if (item.note != null && item.note!.trim().isNotEmpty)
                    Text(
                      item.note!.trim(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            if (!readOnly) ...[
              IconButton(
                tooltip: l10n.investigationNote,
                icon: const Icon(Icons.notes_outlined, size: 20),
                onPressed: onEditNote,
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, size: 20, color: scheme.error),
                onPressed: onRemove,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
