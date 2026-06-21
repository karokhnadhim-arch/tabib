import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../utils/localization_utils.dart';
import '../../providers/app_providers.dart';

class WritePrescriptionScreen extends StatefulWidget {
  const WritePrescriptionScreen({
    super.key,
    required this.patientId,
    this.patientName,
  });

  final String patientId;
  final String? patientName;

  @override
  State<WritePrescriptionScreen> createState() => _WritePrescriptionScreenState();
}

class _WritePrescriptionScreenState extends State<WritePrescriptionScreen> {
  final _diagnosisController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _notesController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _diagnosisController.dispose();
    _medicationsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_diagnosisController.text.trim().isEmpty ||
        _medicationsController.text.trim().isEmpty) {
      return;
    }

    setState(() => _loading = true);
    final auth = context.read<AuthService>();
    final user = auth.currentUser!;

    await context.read<PrescriptionProvider>().write(
      patientId: widget.patientId,
      patientName: widget.patientName ?? 'Patient',
      doctorId: user.doctorId ?? user.id,
      doctorName: user.name.localized(context),
      diagnosis: _diagnosisController.text.trim(),
      medications: _medicationsController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).prescriptionSaved)),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.writePrescription),
        backgroundColor: AppTheme.doctorColor,
      ),
      body: ScrollableResponsiveBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.patientName != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person, color: AppTheme.medicalBlue),
                  title: Text(widget.patientName!),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _diagnosisController,
              decoration: InputDecoration(labelText: l10n.diagnosis),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _medicationsController,
              decoration: InputDecoration(labelText: l10n.medications),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(labelText: l10n.notesOptional),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.doctorColor,
                minimumSize: const Size.fromHeight(52),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
