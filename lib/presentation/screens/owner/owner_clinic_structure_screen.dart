import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/clinic.dart';
import '../../../models/clinic_department.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../presentation/widgets/owner_module_app_bar.dart';
import '../../../services/clinic_structure_service.dart';
import '../../../utils/localization_utils.dart';

class OwnerClinicStructureScreen extends StatefulWidget {
  const OwnerClinicStructureScreen({super.key, required this.clinic});

  final Clinic clinic;

  @override
  State<OwnerClinicStructureScreen> createState() =>
      _OwnerClinicStructureScreenState();
}

class _OwnerClinicStructureScreenState extends State<OwnerClinicStructureScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClinicStructureService>().load();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _addDepartment() async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addDepartment),
        content: TextField(
          controller: name,
          decoration: InputDecoration(labelText: l10n.nameEn),
          autofocus: true,
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
    if (ok != true || name.text.trim().isEmpty || !mounted) return;
    await context.read<ClinicStructureService>().upsertDepartment(
          clinicId: widget.clinic.id,
          name: name.text,
        );
  }

  Future<void> _addRoom(List<ClinicDepartment> departments) async {
    if (departments.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController();
    var departmentId = departments.first.id;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(l10n.addRoom),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: InputDecoration(labelText: l10n.consultationRooms),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: departmentId,
                decoration: InputDecoration(labelText: l10n.departments),
                items: departments
                    .map(
                      (d) => DropdownMenuItem(value: d.id, child: Text(d.name)),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setLocal(() => departmentId = v);
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

    if (ok != true || name.text.trim().isEmpty || !mounted) return;
    await context.read<ClinicStructureService>().upsertRoom(
          clinicId: widget.clinic.id,
          departmentId: departmentId,
          name: name.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final structure = context.watch<ClinicStructureService>();
    final departments = structure.departmentsFor(widget.clinic.id);
    final rooms = structure.roomsFor(widget.clinic.id);

    return AdminGuard(
      child: Scaffold(
        appBar: ownerModuleAppBar(
          context,
          title: widget.clinic.name.localized(context),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_tabs.index == 0) {
              _addDepartment();
            } else {
              _addRoom(departments);
            }
          },
          child: const Icon(Icons.add),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                l10n.clinicStructure,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TabBar(
              controller: _tabs,
              tabs: [
                Tab(text: l10n.departments),
                Tab(text: l10n.consultationRooms),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: departments.length,
                    itemBuilder: (context, i) {
                      final dept = departments[i];
                      return Card(
                        child: ListTile(
                          title: Text(dept.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.archive_outlined),
                            onPressed: () => structure.setDepartmentArchived(
                              dept.id,
                              true,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: rooms.length,
                    itemBuilder: (context, i) {
                      final room = rooms[i];
                      ClinicDepartment? dept;
                      for (final d in departments) {
                        if (d.id == room.departmentId) {
                          dept = d;
                          break;
                        }
                      }
                      return Card(
                        child: ListTile(
                          title: Text(room.name),
                          subtitle: Text(dept?.name ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.archive_outlined),
                            onPressed: () =>
                                structure.setRoomArchived(room.id, true),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
