import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/auth/auth_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final newPassword = _newController.text;
    final confirm = _confirmController.text;

    if (newPassword.length < 6) {
      _showError(l10n.weakPassword);
      return;
    }
    if (newPassword != confirm) {
      _showError(l10n.passwordsDoNotMatch);
      return;
    }

    setState(() => _loading = true);
    final err = await context.read<AuthService>().changePassword(
          currentPassword: _currentController.text,
          newPassword: newPassword,
        );
    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      _showError(_mapError(l10n, err));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.passwordChangedSuccessfully)),
    );
    context.pop();
  }

  String _mapError(AppLocalizations l10n, String code) => switch (code) {
        'invalid_credentials' => l10n.invalidCredentials,
        'weak_password' => l10n.weakPassword,
        'password_same' => l10n.passwordSameAsCurrent,
        'password_change_unavailable' => l10n.passwordChangeUnavailable,
        _ => l10n.error,
      };

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.changePassword),
        backgroundColor: AppTheme.medicalBlue,
      ),
      body: ResponsiveBody(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.changePasswordDescription,
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _currentController,
              label: l10n.currentPassword,
              prefixIcon: Icons.lock_outline,
              obscureText: _obscureCurrent,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscureCurrent = !_obscureCurrent),
              ),
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _newController,
              label: l10n.newPassword,
              prefixIcon: Icons.lock_reset,
              obscureText: _obscureNew,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _confirmController,
              label: l10n.confirmPassword,
              prefixIcon: Icons.verified_user_outlined,
              obscureText: _obscureConfirm,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.saveChanges),
            ),
          ],
        ),
      ),
    );
  }
}
