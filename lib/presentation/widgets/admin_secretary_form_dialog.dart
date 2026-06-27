import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/staff_auth_identifiers.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_account.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/auth_text_field.dart';
import 'staff_account_login_fields.dart';

/// Add or edit a secretary bound to exactly one doctor.
class AdminSecretaryFormDialog extends StatefulWidget {
  const AdminSecretaryFormDialog({
    super.key,
    required this.doctorId,
    this.secretary,
  });

  final String doctorId;
  final UserAccount? secretary;

  bool get isEdit => secretary != null;

  static Future<bool?> show(
    BuildContext context, {
    required String doctorId,
    UserAccount? secretary,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AdminSecretaryFormDialog(
        doctorId: doctorId,
        secretary: secretary,
      ),
    );
  }

  @override
  State<AdminSecretaryFormDialog> createState() =>
      _AdminSecretaryFormDialogState();
}

class _AdminSecretaryFormDialogState extends State<AdminSecretaryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  StaffLoginMethod _loginMethod = StaffLoginMethod.phone;
  bool _isActive = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = widget.secretary;
    _nameController = TextEditingController(
      text: s?.name.en.isNotEmpty == true
          ? s!.name.en
          : (s?.name.ku ?? s?.name.ar ?? ''),
    );
    _emailController = TextEditingController(text: s?.email ?? '');
    _phoneController = TextEditingController(text: s?.phone ?? '');
    _passwordController = TextEditingController();
    _isActive = s?.isActive ?? true;
    if (s?.email != null && s!.email!.trim().isNotEmpty) {
      _loginMethod = StaffLoginMethod.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _mapError(String? err, AppLocalizations l10n) {
    if (err == null) return null;
    return switch (err) {
      'email_in_use' => l10n.emailInUse,
      'phone_in_use' => l10n.phoneInUse,
      'weak_password' => l10n.weakPassword,
      'invalid_phone' => l10n.invalidPhone,
      _ => l10n.errorGeneric,
    };
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = context.read<AuthService>();
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();

    String? err;
    if (widget.isEdit) {
      err = await auth.updateSecretaryAccount(
        secretaryId: widget.secretary!.id,
        name: name,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        isActive: _isActive,
      );
    } else {
      err = await auth.createSecretaryAccount(
        name: name,
        loginMethod: _loginMethod,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        linkedDoctorId: widget.doctorId,
      );
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (err == null) {
      Navigator.pop(context, true);
    } else {
      setState(() => _error = _mapError(err, l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(
        widget.isEdit ? l10n.editSecretary : l10n.addSecretary,
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthTextField(
                  controller: _nameController,
                  label: l10n.fullName,
                  prefixIcon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.trim().length < 2 ? l10n.invalidName : null,
                ),
                const SizedBox(height: 12),
                if (widget.isEdit) ...[
                  AuthTextField(
                    controller: _emailController,
                    label: l10n.emailOptional,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: _phoneController,
                    label: l10n.phoneOptional,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.status),
                    subtitle: Text(
                      _isActive ? l10n.accountActive : l10n.accountInactive,
                    ),
                    value: _isActive,
                    activeColor: AppTheme.medicalGreen,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                ] else
                  StaffAccountLoginFields(
                    loginMethod: _loginMethod,
                    onLoginMethodChanged: (m) =>
                        setState(() => _loginMethod = m),
                    emailController: _emailController,
                    phoneController: _phoneController,
                    passwordController: _passwordController,
                  ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancelQueue),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
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
              : Text(l10n.save),
        ),
      ],
    );
  }
}
