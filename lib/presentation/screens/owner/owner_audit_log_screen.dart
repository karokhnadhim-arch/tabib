import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../presentation/widgets/system_owner_guard.dart';
import '../../../presentation/widgets/owner_audit_log_panel.dart';

/// Immutable audit trail — system owner only.
class OwnerAuditLogScreen extends StatelessWidget {
  const OwnerAuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SystemOwnerGuard(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          title: Text(l10n.auditLog),
          backgroundColor: AppTheme.primaryDark,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.auditLogHint,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            const OwnerAuditLogPanel(),
          ],
        ),
      ),
    );
  }
}
