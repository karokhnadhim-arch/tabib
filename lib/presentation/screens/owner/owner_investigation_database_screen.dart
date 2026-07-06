import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/investigation_catalog_item.dart';
import '../../../models/investigation_category.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../presentation/widgets/owner_module_app_bar.dart';
import '../../../presentation/widgets/owner_paginated_search_list.dart';
import '../../../services/platform_investigation_catalog_service.dart';
import '../../../utils/investigation_category_utils.dart';

class OwnerInvestigationDatabaseScreen extends StatefulWidget {
  const OwnerInvestigationDatabaseScreen({super.key});

  @override
  State<OwnerInvestigationDatabaseScreen> createState() =>
      _OwnerInvestigationDatabaseScreenState();
}

class _OwnerInvestigationDatabaseScreenState
    extends State<OwnerInvestigationDatabaseScreen> {
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlatformInvestigationCatalogService>().load();
    });
  }

  Future<void> _showForm({InvestigationCatalogItem? existing}) async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController(text: existing?.name ?? '');
    var category = existing?.category ?? InvestigationCategory.laboratory;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(
            existing == null ? l10n.addInvestigation : l10n.edit,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: InputDecoration(labelText: l10n.investigationName),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<InvestigationCategory>(
                value: category,
                decoration: InputDecoration(labelText: l10n.category),
                items: InvestigationCategory.values
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.label(l10n)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setLocal(() => category = v);
                },
              ),
            ],
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

    if (ok != true || !mounted) return;
    if (name.text.trim().isEmpty) return;

    await context.read<PlatformInvestigationCatalogService>().upsert(
          id: existing?.id,
          name: name.text,
          category: category,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final service = context.watch<PlatformInvestigationCatalogService>();
    final items = service.customItems
        .where((i) => _showArchived || !i.archived)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return AdminGuard(
      child: Scaffold(
        appBar: ownerModuleAppBar(
          context,
          title: l10n.investigationDatabase,
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
        body: OwnerPaginatedSearchList<InvestigationCatalogItem>(
          items: items,
          searchHint: l10n.searchInvestigations,
          emptyMessage: l10n.noInvestigationsInDatabase,
          searchFilter: (item, q) =>
              item.name.toLowerCase().contains(q.toLowerCase()),
          itemBuilder: (context, item) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    item.archived ? Icons.archive_outlined : Icons.biotech_outlined,
                    size: 20,
                  ),
                ),
                title: Text(item.name),
                subtitle: Text(item.category.label(l10n)),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) async {
                    final catalog =
                        context.read<PlatformInvestigationCatalogService>();
                    if (action == 'edit') {
                      await _showForm(existing: item);
                    } else if (action == 'archive') {
                      await catalog.setArchived(item.id, !item.archived);
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                    PopupMenuItem(
                      value: 'archive',
                      child: Text(
                        item.archived ? l10n.restoreItem : l10n.archiveItem,
                      ),
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
