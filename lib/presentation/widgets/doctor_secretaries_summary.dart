import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/admin_routes.dart';
import '../../core/utils/admin_doctor_staff_resolver.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_account.dart';
import '../../utils/secretary_display_formatter.dart';

/// Gray secretary line under a doctor name — tappable to open the full list.
class DoctorSecretariesSummary extends StatelessWidget {
  const DoctorSecretariesSummary({
    super.key,
    required this.doctorId,
    required this.staff,
    this.style,
    this.onTap,
  });

  final String doctorId;
  final List<UserAccount> staff;
  final TextStyle? style;
  final VoidCallback? onTap;

  static String doctorDetailSecretariesRoute(String doctorId) =>
      '${AdminRoutes.platformPrefix}/doctors/$doctorId?section=secretaries';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final secretaries =
        AdminDoctorStaffResolver.secretariesFor(doctorId, staff);
    final line = SecretaryDisplayFormatter.summaryLine(
      l10n,
      context,
      secretaries,
    );
    if (line == null) return const SizedBox.shrink();

    final textStyle = style ??
        TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        );

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: onTap ?? () => context.push(doctorDetailSecretariesRoute(doctorId)),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            line,
            style: textStyle.copyWith(
              decoration: TextDecoration.underline,
              decorationColor: Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }
}
