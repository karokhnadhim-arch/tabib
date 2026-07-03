import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/account_code.dart';
import '../../l10n/app_localizations.dart';
import '../../models/doctor.dart';
import '../../presentation/widgets/account_code_badge.dart';
import '../../services/clinic_data_service.dart';
import '../../utils/localization_utils.dart';
import '../../utils/provider_labels.dart';

/// Resolves a provider by account code and shows a confirmation preview.
class SecretaryDoctorAccountCodeLinker extends StatefulWidget {
  const SecretaryDoctorAccountCodeLinker({
    super.key,
    required this.onDoctorChanged,
    this.doctor,
    this.errorText,
  });

  final ValueChanged<Doctor?> onDoctorChanged;
  final Doctor? doctor;
  final String? errorText;

  @override
  State<SecretaryDoctorAccountCodeLinker> createState() =>
      _SecretaryDoctorAccountCodeLinkerState();
}

class _SecretaryDoctorAccountCodeLinkerState
    extends State<SecretaryDoctorAccountCodeLinker> {
  final _codeController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  bool _verifying = false;
  String? _lookupError;
  String? _lastVerifiedCode;

  @override
  void initState() {
    super.initState();
    final code = widget.doctor?.accountCode;
    if (code != null && code.isNotEmpty) {
      _codeController.text = code;
      _lastVerifiedCode = AccountCode.normalize(code);
    }
  }

  @override
  void didUpdateWidget(SecretaryDoctorAccountCodeLinker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.doctor == null && oldWidget.doctor != null) {
      _codeController.clear();
      _lastVerifiedCode = null;
      _lookupError = null;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scheduleLookup() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _verifyCode);
  }

  Future<void> _verifyCode() async {
    final raw = _codeController.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _lookupError = null;
        _lastVerifiedCode = null;
      });
      widget.onDoctorChanged(null);
      return;
    }

    final normalized = AccountCode.normalize(raw);
    if (normalized == null) {
      setState(() {
        _lookupError = AppLocalizations.of(context).accountCodeFormatInvalid;
        _lastVerifiedCode = null;
      });
      widget.onDoctorChanged(null);
      return;
    }

    if (normalized == _lastVerifiedCode && widget.doctor != null) return;

    setState(() {
      _verifying = true;
      _lookupError = null;
    });

    final data = context.read<ClinicDataService>();
    await data.ensureCatalogLoaded();
    final doctor = await data.findProviderByAccountCode(normalized);

    if (!mounted) return;

    setState(() {
      _verifying = false;
      if (doctor == null) {
        _lookupError = AppLocalizations.of(context).invalidDoctorAccountCode;
        _lastVerifiedCode = null;
        widget.onDoctorChanged(null);
      } else {
        _lastVerifiedCode = normalized;
        if (_codeController.text.trim().toUpperCase() != normalized) {
          _codeController.text = normalized;
          _codeController.selection =
              TextSelection.collapsed(offset: normalized.length);
        }
        widget.onDoctorChanged(doctor);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final doctor = widget.doctor;
    final displayError = widget.errorText ?? _lookupError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _codeController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  labelText: l10n.doctorAccountCode,
                  hintText: 'DR-10025',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) {
                  if (_lastVerifiedCode != null) {
                    setState(() => _lastVerifiedCode = null);
                    widget.onDoctorChanged(null);
                  }
                  _scheduleLookup();
                },
                onFieldSubmitted: (_) => _verifyCode(),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: FilledButton.tonal(
                onPressed: _verifying ? null : _verifyCode,
                child: _verifying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.verifyAccountCode),
              ),
            ),
          ],
        ),
        if (displayError != null) ...[
          const SizedBox(height: 8),
          Text(
            displayError,
            style: TextStyle(color: Colors.red.shade700, fontSize: 13),
          ),
        ],
        if (doctor != null) ...[
          const SizedBox(height: 16),
          _ProviderPreviewCard(doctor: doctor),
        ],
      ],
    );
  }
}

class _ProviderPreviewCard extends StatelessWidget {
  const _ProviderPreviewCard({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final code = AccountCode.normalize(doctor.accountCode);

    return Card(
      color: AppTheme.primaryDark.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.secretaryLinkProviderPreview,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
            ),
            const SizedBox(height: 12),
            if (code != null) ...[
              AccountCodeBadge(code: code, compact: true),
              const SizedBox(height: 12),
            ],
            _PreviewRow(
              label: ProviderLabels.providerNameLabel(l10n, doctor),
              value: doctor.name.localized(context),
            ),
            const SizedBox(height: 8),
            _PreviewRow(
              label: l10n.clinicName,
              value: doctor.effectiveClinicName.localized(context),
            ),
            const SizedBox(height: 8),
            _PreviewRow(
              label: doctor.isBusiness ? l10n.businessType : l10n.specialty,
              value: ProviderLabels.displayCategory(context, l10n, doctor),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : AppLocalizations.of(context).notAvailable,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
