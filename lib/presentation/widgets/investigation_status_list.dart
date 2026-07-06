import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/investigation_request.dart';
import '../../models/investigation_request_item.dart';
import '../../utils/investigation_category_utils.dart';

/// Investigation items with clear pending / completed status.
class InvestigationStatusList extends StatelessWidget {
  const InvestigationStatusList({
    super.key,
    required this.requests,
    this.showPending = true,
    this.showCompleted = true,
  });

  final List<InvestigationRequest> requests;
  final bool showPending;
  final bool showCompleted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <({InvestigationRequestItem item, InvestigationRequest request})>[];

    for (final request in requests) {
      for (final item in request.items) {
        if (item.isPending && showPending) {
          items.add((item: item, request: request));
        } else if (!item.isPending && showCompleted) {
          items.add((item: item, request: request));
        }
      }
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final row in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _InvestigationRow(
              item: row.item,
              doctorName: row.request.doctorName,
              l10n: l10n,
            ),
          ),
      ],
    );
  }
}

class _InvestigationRow extends StatelessWidget {
  const _InvestigationRow({
    required this.item,
    required this.doctorName,
    required this.l10n,
  });

  final InvestigationRequestItem item;
  final String doctorName;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isPending = item.isPending;
    final statusColor = isPending ? Colors.orange.shade800 : AppTheme.medicalGreen;
    final statusLabel =
        isPending ? l10n.investigationStatusPending : l10n.investigationStatusCompleted;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isPending ? Icons.hourglass_top_outlined : Icons.check_circle_outline,
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '${item.category.label(l10n)} · $doctorName',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                if (item.note != null && item.note!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.note!.trim(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
