import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/doctor.dart';
import '../../models/user_account.dart';
import '../../services/auth_service.dart';
import '../../services/clinic_data_service.dart';
import '../../utils/localization_utils.dart';

/// Move a secretary from one doctor to another.
class AdminTransferSecretaryDialog extends StatefulWidget {
  const AdminTransferSecretaryDialog({
    super.key,
    required this.secretary,
    required this.currentDoctorId,
  });

  final UserAccount secretary;
  final String currentDoctorId;

  static Future<bool?> show(
    BuildContext context, {
    required UserAccount secretary,
    required String currentDoctorId,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AdminTransferSecretaryDialog(
        secretary: secretary,
        currentDoctorId: currentDoctorId,
      ),
    );
  }

  @override
  State<AdminTransferSecretaryDialog> createState() =>
      _AdminTransferSecretaryDialogState();
}

class _AdminTransferSecretaryDialogState
    extends State<AdminTransferSecretaryDialog> {
  String? _targetDoctorId;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = context.read<ClinicDataService>();
      await data.ensureCatalogLoaded();
      data.startRealtimeCatalog();
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final doctors = context
        .watch<ClinicDataService>()
        .doctors
        .where((d) => d.id != widget.currentDoctorId)
        .toList();
    _targetDoctorId ??=
        doctors.isNotEmpty ? doctors.first.id : null;

    return AlertDialog(
      title: Text(l10n.transferSecretaryTitle),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.transferSecretaryHint(
                widget.secretary.name.localized(context),
              ),
            ),
            const SizedBox(height: 16),
            if (doctors.isEmpty)
              Text(
                l10n.noDoctorsFound,
                style: TextStyle(color: Colors.grey.shade700),
              )
            else
              DropdownButtonFormField<String>(
                value: _targetDoctorId,
                decoration: InputDecoration(
                  labelText: l10n.selectDoctor,
                  border: const OutlineInputBorder(),
                ),
                items: doctors
                    .map(
                      (d) => DropdownMenuItem(
                        value: d.id,
                        child: Text(_doctorLabel(context, d)),
                      ),
                    )
                    .toList(),
                onChanged: _loading
                    ? null
                    : (v) => setState(() => _targetDoctorId = v),
              ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancelQueue),
        ),
        FilledButton(
          onPressed: _loading || _targetDoctorId == null ? null : _submit,
          style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryDark),
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(l10n.transferSecretary),
        ),
      ],
    );
  }

  String _doctorLabel(BuildContext context, Doctor doctor) {
    final name = doctor.name.localized(context);
    final clinic = doctor.clinic.name.localized(context);
    return '$name · $clinic';
  }

  Future<void> _submit() async {
    final targetId = _targetDoctorId;
    if (targetId == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final l10n = AppLocalizations.of(context);
    final err = await context.read<AuthService>().transferSecretaryAccount(
          secretaryId: widget.secretary.id,
          newLinkedDoctorId: targetId,
        );

    if (!mounted) return;
    setState(() => _loading = false);

    if (err == null) {
      Navigator.pop(context, true);
    } else {
      setState(() => _error = l10n.errorGeneric);
    }
  }
}
