import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/staff_auth_identifiers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/auth/auth_text_field.dart';

/// Login method picker + credential fields for admin-created staff accounts.
class StaffAccountLoginFields extends StatelessWidget {
  const StaffAccountLoginFields({
    super.key,
    required this.loginMethod,
    required this.onLoginMethodChanged,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    this.accentColor = AppTheme.primaryDark,
  });

  final StaffLoginMethod loginMethod;
  final ValueChanged<StaffLoginMethod> onLoginMethodChanged;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final usePhone = loginMethod == StaffLoginMethod.phone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.accountLoginMethod,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: Text(l10n.phoneNumber),
                selected: usePhone,
                selectedColor: accentColor.withOpacity(0.15),
                onSelected: (_) => onLoginMethodChanged(StaffLoginMethod.phone),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: Text(l10n.email),
                selected: !usePhone,
                selectedColor: accentColor.withOpacity(0.15),
                onSelected: (_) => onLoginMethodChanged(StaffLoginMethod.email),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (usePhone) ...[
          AuthTextField(
            controller: phoneController,
            label: l10n.phoneNumber,
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || !StaffAuthIdentifiers.isValidPhone(v)) {
                return l10n.invalidPhone;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: emailController,
            label: l10n.emailOptional,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null;
              if (!StaffAuthIdentifiers.looksLikeEmail(v)) {
                return l10n.invalidEmail;
              }
              return null;
            },
          ),
        ] else ...[
          AuthTextField(
            controller: emailController,
            label: l10n.email,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
              if (!StaffAuthIdentifiers.looksLikeEmail(v)) {
                return l10n.invalidEmail;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: phoneController,
            label: l10n.phoneOptional,
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null;
              if (!StaffAuthIdentifiers.isValidPhone(v)) {
                return l10n.invalidPhone;
              }
              return null;
            },
          ),
        ],
        const SizedBox(height: 16),
        AuthTextField(
          controller: passwordController,
          label: l10n.password,
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          validator: (v) =>
              v == null || v.length < 6 ? l10n.weakPassword : null,
        ),
      ],
    );
  }
}
