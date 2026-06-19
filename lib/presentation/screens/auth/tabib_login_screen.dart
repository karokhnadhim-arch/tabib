import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/medical_logo.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/auth/auth_text_field.dart';
import '../../../widgets/language_picker.dart';

enum _LoginRole { patient, doctor, secretary }

class TabibLoginScreen extends StatefulWidget {
  const TabibLoginScreen({super.key});

  @override
  State<TabibLoginScreen> createState() => _TabibLoginScreenState();
}

class _TabibLoginScreenState extends State<TabibLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  _LoginRole _role = _LoginRole.patient;
  bool _useEmailLogin = false;
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

  Color _accentForRole() {
    switch (_role) {
      case _LoginRole.patient:
        return AppTheme.patientColor;
      case _LoginRole.doctor:
        return AppTheme.doctorColor;
      case _LoginRole.secretary:
        return AppTheme.secretaryColor;
    }
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

    if (_role == _LoginRole.patient) {
      if (_useEmailLogin) {
        err = await auth.loginPatientWithEmail(
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
    } else {
      err = await auth.loginStaff(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (err != null) err = l10n.invalidCredentials;
      if (err == null) {
        if (_role == _LoginRole.doctor && !auth.isDoctor) {
          await auth.logout();
          err = l10n.invalidCredentials;
        }
        if (_role == _LoginRole.secretary && !auth.isSecretary) {
          await auth.logout();
          err = l10n.invalidCredentials;
        }
      }
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (err == null) {
      if (auth.isDoctor) {
        context.go('/doctor');
      } else if (auth.isSecretary) {
        context.go('/secretary');
      } else {
        context.go('/home');
      }
    } else {
      setState(() => _error = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = _accentForRole();
    final isStaff = _role != _LoginRole.patient;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveBody(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: const LanguagePicker(),
                ),
                const SizedBox(height: 8),
                const Center(child: MedicalLogo(size: 72)),
                const SizedBox(height: 8),
                Text(
                  l10n.appTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.medicalBlueDark,
                  ),
                ),
                Text(
                  l10n.appSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SegmentedButton<_LoginRole>(
                            segments: [
                              ButtonSegment(
                                value: _LoginRole.patient,
                                label: Text(l10n.patientApp),
                                icon: const Icon(Icons.person_outline),
                              ),
                              ButtonSegment(
                                value: _LoginRole.doctor,
                                label: Text(l10n.roleDoctor),
                                icon: const Icon(Icons.medical_services_outlined),
                              ),
                              ButtonSegment(
                                value: _LoginRole.secretary,
                                label: Text(l10n.roleSecretary),
                                icon: const Icon(Icons.support_agent_outlined),
                              ),
                            ],
                            selected: {_role},
                            onSelectionChanged: (v) {
                              setState(() {
                                _role = v.first;
                                _error = null;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          if (!isStaff) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: ChoiceChip(
                                    label: Text(l10n.phoneNumber),
                                    selected: !_useEmailLogin,
                                    onSelected: (_) =>
                                        setState(() => _useEmailLogin = false),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ChoiceChip(
                                    label: Text(l10n.email),
                                    selected: _useEmailLogin,
                                    onSelected: (_) =>
                                        setState(() => _useEmailLogin = true),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (isStaff || _useEmailLogin) ...[
                            AuthTextField(
                              controller: _emailController,
                              label: l10n.email,
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return l10n.fieldRequired;
                                }
                                if (!v.contains('@')) return l10n.invalidEmail;
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            AuthTextField(
                              controller: _passwordController,
                              label: l10n.password,
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () =>
                                    setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
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
                              validator: (v) {
                                if (v == null || v.trim().length < 2) {
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
                              validator: (v) {
                                if (v == null || v.trim().length < 10) {
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
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: Colors.red.shade700)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    minimumSize: const Size.fromHeight(52),
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
                if (_role == _LoginRole.patient) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.push('/register'),
                    child: Text(l10n.register),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
