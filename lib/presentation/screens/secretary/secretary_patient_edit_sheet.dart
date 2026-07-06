import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/queue_entry.dart';
import 'secretary_queue_actions.dart';

Future<bool?> showSecretaryPatientEditSheet({
  required BuildContext context,
  required QueueEntry entry,
  required String doctorId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _PatientEditSheet(entry: entry, doctorId: doctorId),
  );
}

class _PatientEditSheet extends StatefulWidget {
  const _PatientEditSheet({
    required this.entry,
    required this.doctorId,
  });

  final QueueEntry entry;
  final String doctorId;

  @override
  State<_PatientEditSheet> createState() => _PatientEditSheetState();
}

class _PatientEditSheetState extends State<_PatientEditSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.entry.patientName);
    _phoneController = TextEditingController(text: widget.entry.patientPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.length < 2 || phone.length < 10) return;

    setState(() => _saving = true);
    await SecretaryQueueActions.updatePatientContact(
      context,
      entry: widget.entry,
      doctorId: widget.doctorId,
      name: name,
      phone: phone,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.patientInfoUpdated)),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.editPatientInfo,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.patientName,
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: l10n.phoneNumber,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
