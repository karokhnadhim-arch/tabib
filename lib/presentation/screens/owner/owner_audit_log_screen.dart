import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../services/owner_audit_service.dart';

/// Immutable audit trail for the System Owner.
class OwnerAuditLogScreen extends StatelessWidget {
  const OwnerAuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = context.watch<OwnerAuditService>().entries;
    final dateFormat = DateFormat.yMMMd().add_Hm();

    return AdminGuard(
      child: ColoredBox(
        color: const Color(0xFFF4F6F9),
        child: entries.isEmpty
            ? Center(child: Text(l10n.noAuditEntries))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppTheme.primaryDark.withOpacity(0.1),
                        child: const Icon(
                          Icons.history,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      title: Text(entry.action),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${l10n.user}: ${entry.userName}'),
                          Text(dateFormat.format(entry.timestamp)),
                          if (entry.device != null)
                            Text('${l10n.device}: ${entry.device}'),
                          if (entry.ipAddress != null &&
                              entry.ipAddress!.isNotEmpty &&
                              entry.ipAddress != '—')
                            Text('${l10n.ipAddress}: ${entry.ipAddress}'),
                          if (entry.details != null)
                            Text(entry.details!,
                                style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
