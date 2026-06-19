import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/login_hero.dart';
import '../../widgets/language_picker.dart';

enum _LoginMode { patient, staff }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  _LoginMode _mode = _LoginMode.patient;
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = context.read<AuthService>();
    final l10n = AppLocalizations.of(context);
    String? err;

    if (_mode == _LoginMode.staff) {
      err = await auth.loginStaff(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (err != null) err = l10n.invalidCredentials;
    } else {
      err = await auth.loginPatient(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      if (err != null) err = l10n.invalidPhone;
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (err == null) {
      if (auth.isAdmin) {
        context.go('/admin');
      } else if (auth.isStaff) {
        context.go('/staff');
      } else {
        context.go('/dashboard');
      }
    } else {
      setState(() => _error = err);
    }
  }

  void _onModeChanged(_LoginMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isStaff = _mode == _LoginMode.staff;
    final accent = loginAccentForStaff(isStaff);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: const LanguagePicker(),
              ),
            ),
            LoginHero(
              title: l10n.appTitle,
              subtitle: isStaff ? l10n.loginPromptStaff : l10n.loginPromptPatient,
              accentColor: accent,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SegmentedButton<_LoginMode>(
                                segments: [
                                  ButtonSegment(
                                    value: _LoginMode.patient,
                                    label: Text(l10n.patientApp),
                                    icon: const Icon(Icons.person_outline),
                                  ),
                                  ButtonSegment(
                                    value: _LoginMode.staff,
                                    label: Text(l10n.staffApp),
                                    icon: const Icon(Icons.badge_outlined),
                                  ),
                                ],
                                selected: {_mode},
                                onSelectionChanged: (value) => _onModeChanged(value.first),
                              ),
                              const SizedBox(height: 24),
                              if (isStaff) ...[
                                AuthTextField(
                                  controller: _emailController,
                                  label: l10n.email,
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return l10n.fieldRequired;
                                    }
                                    if (!value.contains('@')) {
                                      return l10n.invalidEmail;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                AuthTextField(
                                  controller: _passwordController,
                                  label: l10n.password,
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: _obscurePassword,
                                  autofillHints: const [AutofillHints.password],
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return l10n.fieldRequired;
                                    }
                                    return null;
                                  },
                                ),
                              ] else ...[
                                AuthTextField(
                                  controller: _nameController,
                                  label: l10n.patientName,
                                  prefixIcon: Icons.person_outline,
                                  textCapitalization: TextCapitalization.words,
                                  validator: (value) {
                                    if (value == null || value.trim().length < 2) {
                                      return l10n.invalidName;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                AuthTextField(
                                  controller: _phoneController,
                                  label: l10n.phoneNumber,
                                  prefixIcon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  autofillHints: const [AutofillHints.telephoneNumber],
                                  validator: (value) {
                                    if (value == null || value.trim().length < 10) {
                                      return l10n.invalidPhone;
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Material(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(color: Colors.red.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _loading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                            : Text(l10n.login),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.go('/'),
                        child: Text(
                          l10n.appSubtitle,
                          style: TextStyle(color: AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
