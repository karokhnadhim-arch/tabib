import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/notification.dart';
import '../../models/notification_channel.dart';

/// Compact unread notifications on the patient home dashboard.
class PatientNotificationsStrip extends StatelessWidget {
  const PatientNotificationsStrip({
    super.key,
    required this.notifications,
    this.maxItems = 3,
  });

  final List<AppNotification> notifications;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unread = notifications.where((n) => !n.read).toList();
    if (unread.isEmpty) return const SizedBox.shrink();

    final shown = unread.take(maxItems).toList();
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              l10n.notifications,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/notifications'),
              child: Text(l10n.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...shown.map(
          (n) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: AppTheme.medicalBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => context.push('/notifications'),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _iconFor(n),
                        color: AppTheme.medicalBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              n.body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _iconFor(AppNotification n) {
    if (n.eventType != null) {
      return switch (n.eventType!) {
        NotificationEventType.queueTenRemaining ||
        NotificationEventType.queueFiveRemaining ||
        NotificationEventType.queueThreeRemaining ||
        NotificationEventType.queueYourTurn =>
          Icons.notifications_active_outlined,
        _ => Icons.notifications_outlined,
      };
    }
    return switch (n.type) {
      AppNotificationType.prescription => Icons.medication_outlined,
      AppNotificationType.appointment => Icons.event_outlined,
      AppNotificationType.queue => Icons.queue_outlined,
      _ => Icons.notifications_outlined,
    };
  }
}
