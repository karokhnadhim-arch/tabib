import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/privacy/system_owner_privacy.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/account_status.dart';
import '../../../models/user_account.dart';
import '../../../presentation/widgets/account_status_badge.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../presentation/widgets/owner_module_app_bar.dart';
import '../../../presentation/widgets/owner_paginated_search_list.dart';
import '../../../services/auth_service.dart';
import '../../../services/backend/clinic_backend.dart';
import '../../../utils/localization_utils.dart';

/// Owner patient search, statistics, merge, and archive controls.
class OwnerPatientManagementScreen extends StatefulWidget {
  const OwnerPatientManagementScreen({super.key});

  @override
  State<OwnerPatientManagementScreen> createState() =>
      _OwnerPatientManagementScreenState();
}

class _OwnerPatientManagementScreenState extends State<OwnerPatientManagementScreen> {
  List<UserAccount> _patients = const [];
  bool _loading = true;
  AccountStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final accounts = await context.read<ClinicBackend>().fetchAllAccounts();
      if (mounted) {
        setState(() {
          _patients = SystemOwnerPrivacy.filterPublic(accounts)
              .where((a) => a.role == UserRole.patient)
              .toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<UserAccount> get _filtered {
    var list = _patients;
    if (_statusFilter != null) {
      list = list.where((p) => p.accountStatus == _statusFilter).toList();
    }
    return list;
  }

  Future<void> _mergePatients() async {
    final l10n = AppLocalizations.of(context);
    if (_patients.length < 2) return;

    UserAccount? primary;
    UserAccount? duplicate;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(l10n.mergePatients),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.mergePatientsHint),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserAccount>(
                  decoration: InputDecoration(labelText: l10n.selectPrimaryPatient),
                  items: _patients
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(p.name.localized(context)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setLocal(() => primary = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserAccount>(
                  decoration: InputDecoration(labelText: l10n.selectDuplicatePatient),
                  items: _patients
                      .where((p) => p.id != primary?.id)
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(p.name.localized(context)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setLocal(() => duplicate = v),
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
              onPressed: primary != null && duplicate != null
                  ? () => Navigator.pop(ctx, true)
                  : null,
              child: Text(l10n.mergePatients),
            ),
          ],
        ),
      ),
    );

    if (ok != true || primary == null || duplicate == null || !mounted) return;

    final auth = context.read<AuthService>();
    final err = await auth.setAccountStatus(
      duplicate!.id,
      AccountStatus.disabled,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          err == null ? l10n.patientsMerged : l10n.errorGeneric,
        ),
      ),
    );
    if (err == null) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = _patients.where((p) => p.accountStatus.isActive).length;
    final disabled = _patients.length - active;

    if (_loading) {
      return AdminGuard(
        child: Scaffold(
          appBar: ownerModuleAppBar(context, title: l10n.patientManagement),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AdminGuard(
      child: Scaffold(
        appBar: ownerModuleAppBar(
          context,
          title: l10n.patientManagement,
          actions: [
            IconButton(
              icon: const Icon(Icons.merge_type),
              tooltip: l10n.mergePatients,
              onPressed: _mergePatients,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      label: l10n.activePatients,
                      value: '$active',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatChip(
                      label: l10n.disabledPatients,
                      value: '$disabled',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SegmentedButton<AccountStatus?>(
                segments: [
                  ButtonSegment(value: null, label: Text(l10n.all)),
                  ButtonSegment(
                    value: AccountStatus.active,
                    label: Text(l10n.activePatients),
                  ),
                  ButtonSegment(
                    value: AccountStatus.disabled,
                    label: Text(l10n.disabledPatients),
                  ),
                ],
                selected: {_statusFilter},
                onSelectionChanged: (s) {
                  setState(() => _statusFilter = s.first);
                },
              ),
            ),
            Expanded(
              child: OwnerPaginatedSearchList<UserAccount>(
                items: _filtered,
                searchHint: l10n.searchPatients,
                emptyMessage: l10n.noPatientsFound,
                searchFilter: (p, q) {
                  final lower = q.toLowerCase();
                  return p.name.localized(context).toLowerCase().contains(lower) ||
                      (p.phone?.contains(q) ?? false) ||
                      (p.email?.toLowerCase().contains(lower) ?? false);
                },
                itemBuilder: (context, patient) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(patient.name.localized(context)),
                      subtitle: Text(
                        [patient.phone, patient.email]
                            .where((s) => s != null && s.isNotEmpty)
                            .join(' · '),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AccountStatusBadge(status: patient.accountStatus),
                          PopupMenuButton<String>(
                            onSelected: (action) async {
                              final auth = context.read<AuthService>();
                              if (action == 'archive') {
                                await auth.setAccountStatus(
                                  patient.id,
                                  AccountStatus.disabled,
                                );
                                await _load();
                              } else if (action == 'activate') {
                                await auth.setAccountStatus(
                                  patient.id,
                                  AccountStatus.active,
                                );
                                await _load();
                              }
                            },
                            itemBuilder: (ctx) => [
                              if (!patient.accountStatus.isActive)
                                PopupMenuItem(
                                  value: 'activate',
                                  child: Text(l10n.activate),
                                ),
                              if (patient.accountStatus.isActive)
                                PopupMenuItem(
                                  value: 'archive',
                                  child: Text(l10n.archiveItem),
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
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
