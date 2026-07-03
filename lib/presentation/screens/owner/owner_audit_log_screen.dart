import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/staff_communication_log.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../services/owner_audit_service.dart';
import '../../../services/staff_communication_log_service.dart';

/// Immutable audit trail for the System Owner.
class OwnerAuditLogScreen extends StatelessWidget {
  const OwnerAuditLogScreen({super.key});

  String _communicationLabel(AppLocalizations l10n, StaffCommunicationType type) {
    return switch (type) {
      StaffCommunicationType.call => l10n.contactActionCall,
      StaffCommunicationType.whatsapp => l10n.contactActionWhatsApp,
      StaffCommunicationType.sms => l10n.contactActionSms,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = context.watch<OwnerAuditService>().entries;
    final communicationLogs =
        context.watch<StaffCommunicationLogService>().entries;
    final dateFormat = DateFormat.yMMMd().add_Hm();

    return AdminGuard(
      child: ColoredBox(
        color: const Color(0xFFF4F6F9),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.communicationAuditLog,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (communicationLogs.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  l10n.noCommunicationLogs,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              )
            else
              ...communicationLogs.map(
                (entry) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.secretaryColor.withOpacity(0.12),
                      child: Icon(
                        switch (entry.type) {
                          StaffCommunicationType.call => Icons.call,
                          StaffCommunicationType.whatsapp => Icons.chat,
                          StaffCommunicationType.sms => Icons.sms_outlined,
                        },
                        color: AppTheme.secretaryColor,
                      ),
                    ),
                    title: Text(
                      '${_communicationLabel(l10n, entry.type)} • ${entry.patientName}',
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${l10n.sentBy}: ${entry.staffName}'),
                        Text('${l10n.doctor}: ${entry.doctorName}'),
                        Text(dateFormat.format(entry.timestamp)),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              l10n.auditLog,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              Text(
                l10n.noAuditEntries,
                style: TextStyle(color: Colors.grey.shade600),
              )
            else
              ...entries.map(
                (entry) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
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
                          Text(
                            entry.details!,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
