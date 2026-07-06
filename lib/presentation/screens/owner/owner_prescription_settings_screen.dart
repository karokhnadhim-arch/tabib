import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../presentation/widgets/owner_module_app_bar.dart';
import '../../../services/platform_clinical_settings_service.dart';

class OwnerPrescriptionSettingsScreen extends StatefulWidget {
  const OwnerPrescriptionSettingsScreen({super.key});

  @override
  State<OwnerPrescriptionSettingsScreen> createState() =>
      _OwnerPrescriptionSettingsScreenState();
}

class _OwnerPrescriptionSettingsScreenState
    extends State<OwnerPrescriptionSettingsScreen> {
  final _clinicName = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _footer = TextEditingController();
  bool _bound = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final service = context.read<PlatformClinicalSettingsService>();
      await service.load();
      if (mounted) _bind(service.settings);
    });
  }

  void _bind(dynamic settings) {
    if (_bound) return;
    _clinicName.text = settings.prescriptionHeaderClinicName as String;
    _address.text = settings.prescriptionHeaderAddress as String;
    _phone.text = settings.prescriptionHeaderPhone as String;
    _footer.text = settings.prescriptionFooterNote as String;
    _bound = true;
  }

  @override
  void dispose() {
    _clinicName.dispose();
    _address.dispose();
    _phone.dispose();
    _footer.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    final service = context.read<PlatformClinicalSettingsService>();
    await service.updateField(
      (s) => s.copyWith(
        prescriptionHeaderClinicName: _clinicName.text.trim(),
        prescriptionHeaderAddress: _address.text.trim(),
        prescriptionHeaderPhone: _phone.text.trim(),
        prescriptionFooterNote: _footer.text.trim(),
      ),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).prescriptionSaved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final service = context.watch<PlatformClinicalSettingsService>();
    _bind(service.settings);

    return AdminGuard(
      child: Scaffold(
        appBar: ownerModuleAppBar(
          context,
          title: l10n.prescriptionSettings,
          actions: [
            TextButton(
              onPressed: () => _save(context),
              child: Text(l10n.save),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.prescriptionSettingsHint,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _clinicName,
                      decoration: InputDecoration(
                        labelText: l10n.prescriptionHeaderClinicName,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _address,
                      decoration: InputDecoration(
                        labelText: l10n.prescriptionHeaderAddress,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phone,
                      decoration: InputDecoration(
                        labelText: l10n.prescriptionHeaderPhone,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _footer,
                      decoration: InputDecoration(
                        labelText: l10n.prescriptionFooterNote,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.prescriptionShowDiagnosis),
                      value: service.settings.prescriptionShowDiagnosis,
                      onChanged: (v) {
                        service.updateField(
                          (s) => s.copyWith(prescriptionShowDiagnosis: v),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
