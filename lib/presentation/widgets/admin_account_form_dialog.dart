import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/staff_auth_identifiers.dart';
import '../../l10n/app_localizations.dart';
import '../../models/account_status.dart';
import '../../models/admin_capability.dart';
import '../../models/user_account.dart';
import '../../presentation/widgets/account_status_badge.dart';
import '../../services/auth_service.dart';
import '../../utils/admin_capability_labels.dart';
import '../../widgets/auth/auth_text_field.dart';
import 'staff_account_login_fields.dart';

class AdminAccountFormDialog extends StatefulWidget {
  const AdminAccountFormDialog({super.key, this.admin});

  final UserAccount? admin;

  bool get isEdit => admin != null;

  static Future<bool?> show(BuildContext context, {UserAccount? admin}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AdminAccountFormDialog(admin: admin),
    );
  }

  @override
  State<AdminAccountFormDialog> createState() => _AdminAccountFormDialogState();
}

class _AdminAccountFormDialogState extends State<AdminAccountFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  StaffLoginMethod _loginMethod = StaffLoginMethod.email;
  AccountStatus _accountStatus = AccountStatus.active;
  late Set<AdminCapability> _permissions;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final admin = widget.admin;
    _nameController = TextEditingController(
      text: admin?.name.en.isNotEmpty == true
          ? admin!.name.en
          : (admin?.name.ku ?? admin?.name.ar ?? ''),
    );
    _emailController = TextEditingController(text: admin?.email ?? '');
    _phoneController = TextEditingController(text: admin?.phone ?? '');
    _passwordController = TextEditingController();
    _accountStatus = admin?.accountStatus ?? AccountStatus.active;
    _permissions = Set.of(admin?.adminPermissions.capabilities ?? const {});
    if (admin?.phone != null && admin!.phone!.trim().isNotEmpty) {
      _loginMethod = StaffLoginMethod.phone;
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_permissions.isEmpty) {
      setState(() => _error = AppLocalizations.of(context).adminPermissionsRequired);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = context.read<AuthService>();
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    final permissionSet = AdminPermissionSet(_permissions);

    String? err;
    if (widget.isEdit) {
      err = await auth.updateAdminAccount(
        adminId: widget.admin!.id,
        name: name,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        permissions: permissionSet,
        accountStatus: _accountStatus,
      );
    } else {
      err = await auth.createAdminAccount(
        name: name,
        loginMethod: _loginMethod,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        permissions: permissionSet,
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

  String? _mapError(String? err, AppLocalizations l10n) => switch (err) {
        'email_in_use' => l10n.emailInUse,
        'phone_in_use' => l10n.phoneInUse,
        'weak_password' => l10n.weakPassword,
        'invalid_phone' => l10n.invalidPhone,
        _ => l10n.errorGeneric,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final assignable = AdminCapabilityLabels.assignableToAdmin();

    return AlertDialog(
      title: Text(widget.isEdit ? l10n.editAdminAccount : l10n.createAdminAccount),
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.92,
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
                  DropdownButtonFormField<AccountStatus>(
                    value: _accountStatus,
                    decoration: InputDecoration(
                      labelText: l10n.status,
                      border: const OutlineInputBorder(),
                    ),
                    items: AccountStatus.values
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: AccountStatusBadge(status: status, compact: true),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _accountStatus = v);
                    },
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
                const SizedBox(height: 16),
                Text(
                  l10n.adminPermissionsTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...assignable.map(
                  (cap) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(AdminCapabilityLabels.label(l10n, cap)),
                    value: _permissions.contains(cap),
                    onChanged: (v) => setState(() {
                      if (v == true) {
                        _permissions.add(cap);
                      } else {
                        _permissions.remove(cap);
                      }
                    }),
                  ),
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
