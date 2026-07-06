import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/medicine.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../presentation/widgets/owner_module_app_bar.dart';
import '../../../presentation/widgets/owner_paginated_search_list.dart';
import '../../../services/platform_medicine_catalog_service.dart';

class OwnerMedicineDatabaseScreen extends StatefulWidget {
  const OwnerMedicineDatabaseScreen({super.key});

  @override
  State<OwnerMedicineDatabaseScreen> createState() =>
      _OwnerMedicineDatabaseScreenState();
}

class _OwnerMedicineDatabaseScreenState extends State<OwnerMedicineDatabaseScreen> {
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlatformMedicineCatalogService>().load();
    });
  }

  Future<void> _showForm({Medicine? existing}) async {
    final l10n = AppLocalizations.of(context);
    final generic = TextEditingController(text: existing?.genericName ?? '');
    final brands = TextEditingController(
      text: existing?.brandNames.join(', ') ?? '',
    );
    final strength = TextEditingController(text: existing?.strength ?? '');
    final form = TextEditingController(text: existing?.form ?? '');
    final category = TextEditingController(text: existing?.category ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? l10n.addMedicine : l10n.edit),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: generic,
                decoration: InputDecoration(labelText: l10n.genericName),
                textCapitalization: TextCapitalization.sentences,
              ),
              TextField(
                controller: brands,
                decoration: InputDecoration(labelText: l10n.brandNames),
              ),
              TextField(
                controller: strength,
                decoration: InputDecoration(labelText: l10n.strength),
              ),
              TextField(
                controller: form,
                decoration: InputDecoration(labelText: l10n.dosageForm),
              ),
              TextField(
                controller: category,
                decoration: InputDecoration(labelText: l10n.category),
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

    if (ok != true || !mounted) return;
    if (generic.text.trim().isEmpty) return;

    await context.read<PlatformMedicineCatalogService>().upsert(
          id: existing?.id,
          genericName: generic.text,
          brandNames: brands.text
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList(),
          strength: strength.text,
          form: form.text,
          category: category.text.isEmpty ? null : category.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final service = context.watch<PlatformMedicineCatalogService>();
    final items = service.customMedicines
        .where((m) => _showArchived || !m.archived)
        .toList()
      ..sort((a, b) => a.genericName.compareTo(b.genericName));

    return AdminGuard(
      child: Scaffold(
        appBar: ownerModuleAppBar(
          context,
          title: l10n.medicineDatabase,
          actions: [
            IconButton(
              tooltip: _showArchived ? l10n.activeOnly : l10n.showArchived,
              icon: Icon(_showArchived ? Icons.inventory_2 : Icons.archive_outlined),
              onPressed: () => setState(() => _showArchived = !_showArchived),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showForm(),
          child: const Icon(Icons.add),
        ),
        body: OwnerPaginatedSearchList<Medicine>(
          items: items,
          searchHint: l10n.searchMedicine,
          emptyMessage: l10n.noMedicinesInDatabase,
          searchFilter: (m, q) {
            final lower = q.toLowerCase();
            return m.genericName.toLowerCase().contains(lower) ||
                m.brandNames.any((b) => b.toLowerCase().contains(lower)) ||
                m.strength.toLowerCase().contains(lower) ||
                (m.category?.toLowerCase().contains(lower) ?? false);
          },
          itemBuilder: (context, medicine) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(medicine.displayLabel),
                subtitle: Text(
                  [
                    if (medicine.category != null) medicine.category!,
                    if (medicine.brandNames.isNotEmpty)
                      medicine.brandNames.join(', '),
                  ].join(' · '),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) async {
                    final catalog = context.read<PlatformMedicineCatalogService>();
                    if (action == 'edit') {
                      await _showForm(existing: medicine);
                    } else if (action == 'archive') {
                      await catalog.setArchived(medicine.id, !medicine.archived);
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                    PopupMenuItem(
                      value: 'archive',
                      child: Text(
                        medicine.archived ? l10n.restoreItem : l10n.archiveItem,
                      ),
                    ),
                  ],
                ),
                leading: CircleAvatar(
                  child: Icon(
                    medicine.archived ? Icons.archive_outlined : Icons.medication_outlined,
                    size: 20,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
