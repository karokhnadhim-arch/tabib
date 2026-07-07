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
import 'prescription/prescription_action_bar.dart';
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
  bool _savedForPrint = false;
  String? _doctorId;

  @override
  void initState() {
    super.initState();
    _diagnosisController.addListener(_onFieldsChanged);
    _notesController.addListener(_onFieldsChanged);
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

  void _onFieldsChanged() {
    setState(() => _savedForPrint = false);
    _scheduleAutoSave();
  }

  void _onItemsChanged(List<PrescriptionLineItem> items) {
    setState(() {
      _items = items;
      _savedForPrint = false;
    });
    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), _autoSave);
  }

  Future<void> _autoSave() async {
    if (!_canSave || _saving) return;

    setState(() => _saving = true);

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
      if (mounted) setState(() => _saving = false);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _savePrescription() async {
    if (!_canSave || _saving) return;

    setState(() {
      _saving = true;
      _savedForPrint = false;
    });

    final auth = context.read<AuthService>();
    final user = auth.currentUser!;
    final l10n = AppLocalizations.of(context);
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
      if (!mounted) return;
      setState(() {
        _saving = false;
        _savedForPrint = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.savedSuccessfully)),
      );
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _printPrescription() async {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    await printPrescriptionDocument(
      context: context,
      patientName: widget.patientName ?? AppLocalizations.of(context).patientName,
      doctorName: user?.name.localized(context) ?? '',
      diagnosis: _diagnosisController.text.trim(),
      items: _items,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final doctorId = _doctorId;

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
            if (doctorId != null)
              DoctorPrescriptionComposer(
                doctorId: doctorId,
                items: _items,
                onItemsChanged: _onItemsChanged,
              )
            else
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(labelText: l10n.notesOptional),
              maxLines: 2,
            ),
            DoctorPrescriptionActionBar(
              saving: _saving,
              saveEnabled: _canSave,
              canPrint: _savedForPrint,
              onSave: _savePrescription,
              onPrint: _printPrescription,
            ),
          ],
        ),
      ),
    );
  }
}
