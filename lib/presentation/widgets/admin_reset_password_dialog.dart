import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/admin_permissions.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_account.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/auth_text_field.dart';

/// System Owner / Admin — reset a staff account password.
class AdminResetPasswordDialog extends StatefulWidget {
  const AdminResetPasswordDialog({super.key, required this.account});

  final UserAccount account;

  static Future<bool?> show(BuildContext context, UserAccount account) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AdminResetPasswordDialog(account: account),
    );
  }

  @override
  State<AdminResetPasswordDialog> createState() =>
      _AdminResetPasswordDialogState();
}

class _AdminResetPasswordDialogState extends State<AdminResetPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submitDemo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = context.read<AuthService>();
    final l10n = AppLocalizations.of(context);
    final err = await auth.resetSecretaryPassword(
      secretaryId: widget.account.id,
      newPassword: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (err == null) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.secretaryPasswordResetSuccess)),
      );
    } else {
      setState(() {
        _error = switch (err) {
          'weak_password' => l10n.weakPassword,
          'unauthorized' => l10n.errorGeneric,
          'invalid_credentials' => l10n.invalidCredentials,
          _ => l10n.errorGeneric,
        };
      });
    }
  }

  Future<void> _submitFirebase() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = context.read<AuthService>();
    final l10n = AppLocalizations.of(context);
    final err = await auth.resetSecretaryPassword(
      secretaryId: widget.account.id,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (err == null || err == 'password_reset_email_sent') {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.secretaryPasswordResetEmailSent)),
      );
    } else {
      setState(() {
        _error = switch (err) {
          'unauthorized' => l10n.errorGeneric,
          'invalid_credentials' => l10n.invalidCredentials,
          _ => l10n.errorGeneric,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    if (!AdminPermissions.canResetPasswords(auth)) {
      return const SizedBox.shrink();
    }
    final isDemo = auth.demoMode;

    return AlertDialog(
      title: Text(l10n.resetPassword),
      content: isDemo
          ? Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthTextField(
                    controller: _passwordController,
                    label: l10n.newPassword,
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (v) =>
                        v == null || v.length < 6 ? l10n.weakPassword : null,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: _confirmController,
                    label: l10n.confirmPassword,
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (v) {
                      if (v != _passwordController.text) {
                        return l10n.passwordsDoNotMatch;
                      }
                      return null;
                    },
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
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.resetSecretaryPasswordFirebaseHint,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
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
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancelQueue),
        ),
        FilledButton(
          onPressed: _loading
              ? null
              : (isDemo ? _submitDemo : _submitFirebase),
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
              : Text(l10n.resetPassword),
        ),
      ],
    );
  }
}
