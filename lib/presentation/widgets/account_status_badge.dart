import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/account_status.dart';
import '../../utils/account_status_labels.dart';

class AccountStatusBadge extends StatelessWidget {
  const AccountStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final AccountStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (color, bg) = _colors(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        AccountStatusLabels.label(l10n, status),
        style: TextStyle(
          color: color,
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, Color) _colors(AccountStatus status) => switch (status) {
        AccountStatus.active => (
            AppTheme.medicalGreen,
            AppTheme.medicalGreen.withOpacity(0.12),
          ),
        AccountStatus.suspended => (
            Colors.orange.shade800,
            Colors.orange.withOpacity(0.12),
          ),
        AccountStatus.disabled => (
            Colors.red.shade700,
            Colors.red.withOpacity(0.1),
          ),
        AccountStatus.expiredSubscription => (
            Colors.deepPurple.shade700,
            Colors.deepPurple.withOpacity(0.1),
          ),
      };
}
