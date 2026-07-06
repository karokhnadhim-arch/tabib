import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/investigation_request.dart';
import '../../../models/investigation_request_item.dart';
import '../../../utils/investigation_category_utils.dart';

/// Compact pending investigations list — secretary, patient, doctor.
class PendingInvestigationsPanel extends StatelessWidget {
  const PendingInvestigationsPanel({
    super.key,
    required this.requests,
    this.compact = false,
  });

  final List<InvestigationRequest> requests;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pending = <InvestigationRequestItem>[];
    for (final request in requests) {
      pending.addAll(request.pendingItems);
    }
    if (pending.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        color: AppTheme.medicalBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.medicalBlue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.biotech_outlined,
                size: compact ? 16 : 18,
                color: AppTheme.medicalBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.pendingInvestigations,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.medicalBlue,
                        fontSize: compact ? 12 : null,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.medicalBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${pending.length}',
                  style: TextStyle(
                    color: AppTheme.medicalBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 11 : 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final item in pending.take(compact ? 4 : 12))
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: Text(
                      '${item.name} (${item.category.label(l10n)})'
                      '${item.note != null && item.note!.trim().isNotEmpty ? ' — ${item.note!.trim()}' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface,
                            fontSize: compact ? 11 : null,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          if (pending.length > (compact ? 4 : 12))
            Text(
              l10n.andMoreInvestigations(pending.length - (compact ? 4 : 12)),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: compact ? 11 : null,
                  ),
            ),
        ],
      ),
    );
  }
}
