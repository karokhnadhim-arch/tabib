import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/admin_doctor_staff_resolver.dart';
import '../../core/widgets/responsive_scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_account.dart';
import '../../services/auth_service.dart';
import '../../services/clinic_data_service.dart';
import '../../utils/localization_utils.dart';
import 'admin_secretary_form_dialog.dart';

/// Secretaries assigned to one doctor — minimal internal staff records only.
class AdminDoctorSecretariesSection extends StatelessWidget {
  const AdminDoctorSecretariesSection({
    super.key,
    required this.doctorId,
    required this.staff,
  });

  final String doctorId;
  final List<UserAccount> staff;

  List<UserAccount> get _secretaries =>
      AdminDoctorStaffResolver.secretariesFor(doctorId, staff);

  Future<void> _confirmDelete(
    BuildContext context,
    UserAccount secretary,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteSecretary),
        content: Text(l10n.deleteSecretaryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelQueue),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final err = await context
        .read<AuthService>()
        .deleteSecretaryAccount(secretary.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          err == null ? l10n.deletedSuccessfully : l10n.errorGeneric,
        ),
      ),
    );
  }

  Future<void> _toggleActive(
    BuildContext context,
    UserAccount secretary,
    bool active,
  ) async {
    final l10n = AppLocalizations.of(context);
    final err = await context.read<AuthService>().setStaffActive(
          secretary.id,
          active,
        );
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final secretaries = _secretaries;
    final provider =
        context.watch<ClinicDataService>().doctorById(doctorId);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 720;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ResponsiveHeaderRow(
              title: Text(
                l10n.assignedSecretaries,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              trailing: [
                Text(
                  l10n.secretariesCount(secretaries.length),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    await AdminSecretaryFormDialog.show(
                      context,
                      doctorId: doctorId,
                    );
                  },
                  icon: const Icon(Icons.person_add_outlined, size: 18),
                  label: Text(l10n.addSecretary),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (secretaries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  provider?.isBusiness == true
                      ? l10n.noSecretariesAssignedBusiness
                      : l10n.noSecretariesAssigned,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              )
            else if (isWide)
              _SecretaryTable(
                secretaries: secretaries,
                onEdit: (s) => AdminSecretaryFormDialog.show(
                  context,
                  doctorId: doctorId,
                  secretary: s,
                ),
                onDelete: (s) => _confirmDelete(context, s),
                onToggleActive: (s, active) => _toggleActive(context, s, active),
              )
            else
              ...secretaries.map(
                (s) => _SecretaryCard(
                  secretary: s,
                  onEdit: () => AdminSecretaryFormDialog.show(
                    context,
                    doctorId: doctorId,
                    secretary: s,
                  ),
                  onDelete: () => _confirmDelete(context, s),
                  onToggleActive: (active) =>
                      _toggleActive(context, s, active),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Chip(
      label: Text(
        isActive ? l10n.accountActive : l10n.accountInactive,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: isActive
          ? AppTheme.medicalGreen.withOpacity(0.12)
          : Colors.red.shade50,
      side: BorderSide(
        color: isActive ? AppTheme.medicalGreen : Colors.red.shade300,
      ),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}

class _SecretaryCard extends StatelessWidget {
  const _SecretaryCard({
    required this.secretary,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  final UserAccount secretary;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleActive;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = secretary.name.localized(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (secretary.phone != null && secretary.phone!.isNotEmpty)
                        Text(
                          secretary.phone!,
                          style: const TextStyle(fontSize: 13),
                        ),
                      if (secretary.email != null && secretary.email!.isNotEmpty)
                        Text(
                          secretary.email!,
                          style: const TextStyle(fontSize: 13),
                        ),
                    ],
                  ),
                ),
                _StatusChip(isActive: secretary.isActive),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 4,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(l10n.edit),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.red.shade700,
                  ),
                  label: Text(
                    l10n.delete,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: secretary.isActive,
                      activeColor: AppTheme.medicalGreen,
                      onChanged: onToggleActive,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SecretaryTable extends StatelessWidget {
  const _SecretaryTable({
    required this.secretaries,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  final List<UserAccount> secretaries;
  final Future<void> Function(UserAccount) onEdit;
  final Future<void> Function(UserAccount) onDelete;
  final Future<void> Function(UserAccount, bool) onToggleActive;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          AppTheme.primaryDark.withOpacity(0.04),
        ),
        columns: [
          DataColumn(label: Text(l10n.fullName)),
          DataColumn(label: Text(l10n.phoneNumber)),
          DataColumn(label: Text(l10n.email)),
          DataColumn(label: Text(l10n.status)),
          DataColumn(label: Text(l10n.actions)),
        ],
        rows: secretaries.map((s) {
          final name = s.name.localized(context);
          return DataRow(
            cells: [
              DataCell(Text(name)),
              DataCell(Text(s.phone ?? l10n.notAvailable)),
              DataCell(Text(s.email ?? l10n.notAvailable)),
              DataCell(_StatusChip(isActive: s.isActive)),
              DataCell(
                Wrap(
                  spacing: 0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    IconButton(
                      tooltip: l10n.edit,
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => onEdit(s),
                    ),
                    IconButton(
                      tooltip: l10n.delete,
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade700,
                      ),
                      onPressed: () => onDelete(s),
                    ),
                    Switch(
                      value: s.isActive,
                      activeColor: AppTheme.medicalGreen,
                      onChanged: (v) => onToggleActive(s, v),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
