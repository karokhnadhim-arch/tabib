import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/queue_entry.dart';
import '../../../services/auth_service.dart';
import '../../../services/queue_service.dart';
import '../../providers/app_providers.dart';
import '../../../widgets/auth/auth_text_field.dart';

/// Register new patients or add existing patients to today's queue.
class RegisterPatientScreen extends StatefulWidget {
  const RegisterPatientScreen({
    super.key,
    required this.clinicId,
    required this.doctorId,
  });

  final String clinicId;
  final String doctorId;

  @override
  State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _searchController = TextEditingController();
  bool _loading = false;
  bool _addToQueue = true;
  String? _message;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_PatientOption> _knownPatients(BuildContext context) {
    final queue = context.read<QueueService>().secretaryQueueForDoctor(widget.doctorId);
    final appointments = context.read<AppointmentProvider>().appointments;
    final map = <String, _PatientOption>{};

    for (final e in queue) {
      map[e.patientId] = _PatientOption(
        patientId: e.patientId,
        name: e.patientName,
        phone: e.patientPhone,
      );
    }
    for (final a in appointments) {
      if (a.doctorId != widget.doctorId || a.patientId == null) continue;
      map.putIfAbsent(
        a.patientId!,
        () => _PatientOption(
          patientId: a.patientId!,
          name: a.patientName ?? '',
          phone: a.patientPhone ?? '',
        ),
      );
    }
    return map.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<_PatientOption> _filteredPatients(List<_PatientOption> all) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return all.take(8).toList();
    return all
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.phone.toLowerCase().contains(q))
        .take(12)
        .toList();
  }

  Future<void> _bookPatient(_PatientOption patient) async {
    final l10n = AppLocalizations.of(context);
    final queue = context.read<QueueService>();
    final now = DateTime.now();
    final date = QueueEntry.dateKey(now);
    final entry = await queue.bookQueue(
      doctorId: widget.doctorId,
      patientId: patient.patientId,
      patientName: patient.name,
      patientPhone: patient.phone,
      queueDate: date,
      slotStart: '09:00',
      slotEnd: '17:00',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          entry != null ? l10n.addedToQueue : l10n.alreadyInQueue,
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _message = null;
    });

    final auth = context.read<AuthService>();
    final queue = context.read<QueueService>();
    final l10n = AppLocalizations.of(context);

    final result = await auth.registerPatientBySecretary(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      clinicId: widget.clinicId,
    );

    if (!mounted) return;

    if (!result.isSuccess) {
      setState(() {
        _loading = false;
        _message = l10n.errorGeneric;
      });
      return;
    }

    if (_addToQueue && result.patientId != null) {
      final now = DateTime.now();
      await queue.bookQueue(
        doctorId: widget.doctorId,
        patientId: result.patientId!,
        patientName: _nameController.text.trim(),
        patientPhone: _phoneController.text.trim(),
        queueDate: QueueEntry.dateKey(now),
        slotStart: '09:00',
        slotEnd: '17:00',
      );
    }

    setState(() {
      _loading = false;
      _message = l10n.patientRegistered;
    });
    _nameController.clear();
    _phoneController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final known = _knownPatients(context);
    final filtered = _filteredPatients(known);

    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.searchExistingPatients,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l10n.searchPatientsHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                ),
              ),
              if (filtered.isNotEmpty) ...[
                const SizedBox(height: 10),
                for (final patient in filtered)
                  Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      dense: true,
                      title: Text(
                        patient.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(patient.phone),
                      trailing: FilledButton.tonal(
                        onPressed: () => _bookPatient(patient),
                        child: Text(l10n.addToQueue),
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 20),
              Text(
                l10n.registerPatientPrompt,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _nameController,
                label: l10n.patientName,
                prefixIcon: Icons.person_outline,
                validator: (v) {
                  if (v == null || v.trim().length < 2) return l10n.invalidName;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _phoneController,
                label: l10n.phoneNumber,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().length < 10) {
                    return l10n.invalidPhone;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.addToQueueAfterRegister),
                value: _addToQueue,
                onChanged: (v) => setState(() => _addToQueue = v),
              ),
              if (_message != null) ...[
                const SizedBox(height: 8),
                Text(
                  _message!,
                  style: TextStyle(
                    color: _message == l10n.patientRegistered
                        ? AppTheme.medicalGreen
                        : Colors.red,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.secretaryColor,
                  minimumSize: const Size.fromHeight(48),
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
                    : Text(l10n.registerPatient),
              ),
            ],
          );

          if (constraints.maxHeight.isFinite) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 8),
              child: content,
            );
          }
          return content;
        },
      ),
    );
  }
}

class _PatientOption {
  const _PatientOption({
    required this.patientId,
    required this.name,
    required this.phone,
  });

  final String patientId;
  final String name;
  final String phone;
}
