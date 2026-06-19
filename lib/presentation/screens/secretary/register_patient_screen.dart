import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/auth/auth_text_field.dart';

class RegisterPatientScreen extends StatefulWidget {
  const RegisterPatientScreen({super.key, required this.clinicId});

  final String clinicId;

  @override
  State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = false;
  String? _message;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _message = null;
    });

    final auth = context.read<AuthService>();
    final l10n = AppLocalizations.of(context);

    final err = await auth.registerPatientBySecretary(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      clinicId: widget.clinicId,
    );

    if (!mounted) return;
    setState(() {
      _loading = false;
      _message = err == null ? l10n.patientRegistered : l10n.errorGeneric;
    });

    if (err == null) {
      _nameController.clear();
      _phoneController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.registerPatientPrompt,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
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
              if (v == null || v.trim().length < 10) return l10n.invalidPhone;
              return null;
            },
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(
              _message!,
              style: TextStyle(
                color: _message == l10n.patientRegistered
                    ? AppTheme.medicalGreen
                    : Colors.red,
              ),
            ),
          ],
          const SizedBox(height: 20),
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
      ),
    );
  }
}
