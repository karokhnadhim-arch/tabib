import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/medical_logo.dart';
import '../../../core/widgets/medical_ui.dart';
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

  void _applyDemoCredentialsForRole(_LoginRole role) {
    switch (role) {
      case _LoginRole.doctor:
        _emailController.text = AuthService.demoDoctorEmail;
        _passwordController.text = AuthService.demoPassword;
      case _LoginRole.secretary:
        _emailController.text = AuthService.demoSecretaryEmail;
        _passwordController.text = AuthService.demoPassword;
      case _LoginRole.patient:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<AuthService>().demoMode && _role != _LoginRole.patient) {
        _applyDemoCredentialsForRole(_role);
      }
    });
  }

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
      if (err == null && !auth.isAdmin) {
        if (_role == _LoginRole.doctor && !auth.isDoctor) {
          await auth.logout();
          err = l10n.invalidCredentials;
        } else if (_role == _LoginRole.secretary && !auth.isSecretary) {
          await auth.logout();
          err = l10n.invalidCredentials;
        }
      }
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (err == null) {
      if (auth.isAdmin) {
        context.go('/admin');
      } else if (auth.isDoctor) {
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
    final auth = context.watch<AuthService>();
    final accent = _accentForRole();
    final isStaff = _role != _LoginRole.patient;
    final demoMode = auth.demoMode;

    return Scaffold(
      backgroundColor: AppTheme.medicalWhite,
      body: SafeArea(
        child: Column(
          children: [
            MedicalGradientHeader(
              height: 200,
              title: l10n.appTitle,
              subtitle: l10n.appSubtitle,
              actions: [
                const LanguagePicker(iconColor: Colors.white),
              ],
              leading: const Center(child: MedicalLogo(size: 56, showLabel: false)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.login,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.medicalBlueDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _RolePicker(
                        role: _role,
                        onChanged: (r) => setState(() {
                          _role = r;
                          _error = null;
                          if (demoMode && r != _LoginRole.patient) {
                            _applyDemoCredentialsForRole(r);
                          }
                        }),
                        patientLabel: l10n.patientApp,
                        doctorLabel: l10n.roleDoctor,
                        secretaryLabel: l10n.roleSecretary,
                      ),
                      if (demoMode && isStaff) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: accent.withOpacity(0.3)),
                          ),
                          child: Text(
                            _role == _LoginRole.doctor
                                ? '${AuthService.demoDoctorEmail} / ${AuthService.demoPassword}'
                                : '${AuthService.demoSecretaryEmail} / ${AuthService.demoPassword}',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      if (!isStaff) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: Text(l10n.phoneNumber),
                                selected: !_useEmailLogin,
                                selectedColor: accent.withOpacity(0.15),
                                onSelected: (_) =>
                                    setState(() => _useEmailLogin = false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                label: Text(l10n.email),
                                selected: _useEmailLogin,
                                selectedColor: accent.withOpacity(0.15),
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
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: TextStyle(color: Colors.red.shade700),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
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
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            side: const BorderSide(color: AppTheme.medicalBlue),
                          ),
                          child: Text(l10n.register),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => context.push('/admin/login'),
                        child: Text(l10n.adminLogin),
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

class _RolePicker extends StatelessWidget {
  const _RolePicker({
    required this.role,
    required this.onChanged,
    required this.patientLabel,
    required this.doctorLabel,
    required this.secretaryLabel,
  });

  final _LoginRole role;
  final ValueChanged<_LoginRole> onChanged;
  final String patientLabel;
  final String doctorLabel;
  final String secretaryLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RoleCard(
            icon: Icons.person_outline,
            label: patientLabel,
            color: AppTheme.patientColor,
            selected: role == _LoginRole.patient,
            onTap: () => onChanged(_LoginRole.patient),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _RoleCard(
            icon: Icons.medical_services_outlined,
            label: doctorLabel,
            color: AppTheme.doctorColor,
            selected: role == _LoginRole.doctor,
            onTap: () => onChanged(_LoginRole.doctor),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _RoleCard(
            icon: Icons.support_agent_outlined,
            label: secretaryLabel,
            color: AppTheme.secretaryColor,
            selected: role == _LoginRole.secretary,
            onTap: () => onChanged(_LoginRole.secretary),
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color.withOpacity(0.12) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? color : Colors.grey.shade300,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            children: [
              Icon(icon, color: selected ? color : Colors.grey.shade600, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? color : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
