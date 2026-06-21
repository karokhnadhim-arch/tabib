import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../utils/localization_utils.dart';
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
  final _passwordController = TextEditingController();

  String? _linkedDoctorId;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = context.read<ClinicDataService>();
      await data.ensureCatalogLoaded();
      await data.loadDoctors(refresh: true);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_linkedDoctorId == null) {
      setState(() => _error = AppLocalizations.of(context).linkedDoctorRequired);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = context.read<AuthService>();
    final l10n = AppLocalizations.of(context);
    final err = await auth.createSecretaryAccount(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      linkedDoctorId: _linkedDoctorId!,
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
            : err == 'weak_password'
                ? l10n.weakPassword
                : err == 'linked_doctor_required'
                    ? l10n.linkedDoctorRequired
                    : l10n.errorGeneric;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = context.watch<ClinicDataService>();

    _linkedDoctorId ??= data.doctors.isNotEmpty ? data.doctors.first.id : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createSecretaryAccount),
        backgroundColor: AppTheme.primaryDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: _nameController,
                label: l10n.patientName,
                prefixIcon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.trim().length < 2 ? l10n.invalidName : null,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _emailController,
                label: l10n.email,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                  if (!v.contains('@')) return l10n.invalidEmail;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _passwordController,
                label: l10n.password,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (v) =>
                    v == null || v.length < 6 ? l10n.weakPassword : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _linkedDoctorId,
                decoration: InputDecoration(
                  labelText: l10n.linkedDoctor,
                  prefixIcon: const Icon(Icons.link),
                ),
                items: data.doctors
                    .map(
                      (d) => DropdownMenuItem(
                        value: d.id,
                        child: Text(d.name.localized(context)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _linkedDoctorId = v),
                validator: (v) =>
                    v == null ? l10n.linkedDoctorRequired : null,
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
                onPressed: _loading ? null : _submit,
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
    );
  }
}
