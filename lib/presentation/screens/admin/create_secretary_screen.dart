import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/admin_permissions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/staff_auth_identifiers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/doctor.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../presentation/widgets/owner_module_app_bar.dart';
import '../../../presentation/widgets/secretary_doctor_account_code_linker.dart';
import '../../../presentation/widgets/staff_account_login_fields.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../widgets/auth/auth_text_field.dart';

class CreateSecretaryScreen extends StatefulWidget {
  const CreateSecretaryScreen({super.key});

  @override
  State<CreateSecretaryScreen> createState() => _CreateSecretaryScreenState();
}

class _CreateSecretaryScreenState extends State<CreateSecretaryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  StaffLoginMethod _loginMethod = StaffLoginMethod.phone;
  Doctor? _linkedDoctor;
  bool _loading = false;
  String? _error;
  String? _linkValidationError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClinicDataService>().ensureCatalogLoaded();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_linkedDoctor == null) {
      setState(() {
        _linkValidationError =
            AppLocalizations.of(context).doctorAccountCodeRequired;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _linkValidationError = null;
    });

    final auth = context.read<AuthService>();
    final l10n = AppLocalizations.of(context);
    final err = await auth.createSecretaryAccount(
      name: _nameController.text.trim(),
      loginMethod: _loginMethod,
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      linkedDoctorId: _linkedDoctor!.id,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.accountCreated)),
      );
      context.pop();
    } else {
      setState(() {
        _error = err == 'email_in_use'
            ? l10n.emailInUse
            : err == 'phone_in_use'
                ? l10n.phoneInUse
                : err == 'weak_password'
                    ? l10n.weakPassword
                    : err == 'linked_doctor_required'
                        ? l10n.linkedDoctorRequired
                        : err == 'invalid_phone'
                            ? l10n.invalidPhone
                            : l10n.errorGeneric;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    if (!AdminPermissions.canCreateSecretaries(auth)) {
      return const SizedBox.shrink();
    }

    return AdminGuard(
      child: Scaffold(
        appBar: ownerModuleAppBar(context, title: l10n.createSecretaryAccount),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SecretaryDoctorAccountCodeLinker(
                  doctor: _linkedDoctor,
                  errorText: _linkValidationError,
                  onDoctorChanged: (doctor) {
                    setState(() {
                      _linkedDoctor = doctor;
                      if (doctor != null) _linkValidationError = null;
                    });
                  },
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  controller: _nameController,
                  label: l10n.fullName,
                  prefixIcon: Icons.person_outline,
                  validator: (v) => v == null || v.trim().length < 2
                      ? l10n.invalidName
                      : null,
                ),
                const SizedBox(height: 20),
                StaffAccountLoginFields(
                  loginMethod: _loginMethod,
                  onLoginMethodChanged: (method) =>
                      setState(() => _loginMethod = method),
                  emailController: _emailController,
                  phoneController: _phoneController,
                  passwordController: _passwordController,
                ),
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
                  onPressed: _loading || _linkedDoctor == null ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
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
                      : Text(l10n.createSecretaryAccount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
