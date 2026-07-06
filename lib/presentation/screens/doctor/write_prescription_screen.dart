import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/prescription_line_item.dart';
import '../../../services/auth_service.dart';
import '../../../services/doctor_medicine_favorites_service.dart';
import '../../../utils/localization_utils.dart';
import '../../providers/app_providers.dart';
import 'prescription/doctor_prescription_composer.dart';
import 'prescription/prescription_formatter.dart';
import 'prescription/prescription_print_sheet.dart';

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
  final _notesController = TextEditingController();
  List<PrescriptionLineItem> _items = [];
  Timer? _autoSaveTimer;
  bool _saving = false;
  bool _saved = false;
  String? _doctorId;

  @override
  void initState() {
    super.initState();
    _diagnosisController.addListener(_scheduleAutoSave);
    _notesController.addListener(_scheduleAutoSave);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    if (user == null) return;
    _doctorId = user.doctorId ?? user.id;
    await context.read<DoctorMedicineFavoritesService>().load(_doctorId!);
    if (!mounted) return;
    context.read<PrescriptionProvider>().watchPatient(widget.patientId);
    setState(() {});
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _diagnosisController.text.trim().isNotEmpty && _items.isNotEmpty;

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), _autoSave);
  }

  void _onItemsChanged(List<PrescriptionLineItem> items) {
    setState(() => _items = items);
    _scheduleAutoSave();
  }

  Future<void> _autoSave() async {
    if (!_canSave || _saving) return;

    setState(() {
      _saving = true;
      _saved = false;
    });

    final auth = context.read<AuthService>();
    final user = auth.currentUser!;
    final medications = PrescriptionFormatter.formatItems(_items);

    try {
      await context.read<PrescriptionProvider>().write(
            patientId: widget.patientId,
            patientName: widget.patientName ?? 'Patient',
            doctorId: user.doctorId ?? user.id,
            doctorName: user.name.localized(context),
            diagnosis: _diagnosisController.text.trim(),
            medications: medications,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            items: _items,
          );
      if (mounted) {
        setState(() {
          _saving = false;
          _saved = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final doctorId = _doctorId;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.writePrescription),
        backgroundColor: AppTheme.doctorColor,
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              tooltip: l10n.printPrescription,
              onPressed: () => showPrescriptionPrintSheet(
                context: context,
                patientName: widget.patientName ?? l10n.patientName,
                doctorName: context.read<AuthService>().currentUser?.name
                        .localized(context) ??
                    '',
                diagnosis: _diagnosisController.text.trim(),
                items: _items,
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
              ),
              icon: const Icon(Icons.print_outlined),
            ),
        ],
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
            if (_saving || _saved) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (_saving)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(Icons.cloud_done_outlined, size: 18, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Text(
                    _saving ? l10n.syncingData : l10n.prescriptionAutoSaved,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _diagnosisController,
              decoration: InputDecoration(labelText: l10n.diagnosis),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            if (doctorId != null)
              DoctorPrescriptionComposer(
                doctorId: doctorId,
                items: _items,
                onItemsChanged: _onItemsChanged,
                onPrint: _items.isEmpty
                    ? null
                    : () => showPrescriptionPrintSheet(
                          context: context,
                          patientName: widget.patientName ?? l10n.patientName,
                          doctorName: context
                                  .read<AuthService>()
                                  .currentUser
                                  ?.name
                                  .localized(context) ??
                              '',
                          diagnosis: _diagnosisController.text.trim(),
                          items: _items,
                          notes: _notesController.text.trim().isEmpty
                              ? null
                              : _notesController.text.trim(),
                        ),
              )
            else
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(labelText: l10n.notesOptional),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
