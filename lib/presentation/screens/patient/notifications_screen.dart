import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/notification_channel.dart';
import '../../providers/app_providers.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        backgroundColor: AppTheme.patientColor,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.notifications.isEmpty
              ? Center(child: Text(l10n.noNotifications))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final n = provider.notifications[index];
                    return Card(
                      color: n.read
                          ? null
                          : AppTheme.medicalBlue.withOpacity(0.05),
                      child: ListTile(
                        leading: Icon(
                          _iconForType(n.type),
                          color: AppTheme.medicalBlue,
                        ),
                        title: Text(n.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.body),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat.yMMMd()
                                  .add_jm()
                                  .format(n.createdAt),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            if (n.deliveryChannel != null ||
                                n.eventType != null) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  if (n.eventType != null)
                                    _MetaChip(
                                      label: _eventLabel(l10n, n.eventType!),
                                    ),
                                  if (n.deliveryChannel != null)
                                    _MetaChip(
                                      label: _channelLabel(
                                        l10n,
                                        n.deliveryChannel!,
                                      ),
                                    ),
                                  _MetaChip(
                                    label: _statusLabel(
                                      l10n,
                                      n.deliveryStatus,
                                    ),
                                  ),
                                  if (n.sentByName != null &&
                                      n.sentByName!.isNotEmpty)
                                    _MetaChip(
                                      label:
                                          '${l10n.sentBy}: ${n.sentByName}',
                                    ),
                                  if (n.read && n.openedAt != null)
                                    _MetaChip(
                                      label: l10n.notificationOpened,
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () => provider.markRead(n.id),
                      ),
                    );
                  },
                ),
    );
  }

  IconData _iconForType(dynamic type) {
    final name = type.toString();
    if (name.contains('appointment')) return Icons.event;
    if (name.contains('prescription')) return Icons.medication;
    if (name.contains('queue')) return Icons.queue;
    if (name.contains('investigation')) return Icons.biotech_outlined;
    return Icons.notifications;
  }

  String _channelLabel(AppLocalizations l10n, NotificationChannel channel) {
    return switch (channel) {
      NotificationChannel.push => l10n.pushNotifications,
      NotificationChannel.whatsapp => l10n.whatsappNotifications,
      NotificationChannel.sms => l10n.smsNotifications,
      NotificationChannel.inApp => l10n.inAppNotifications,
    };
  }

  String _statusLabel(
    AppLocalizations l10n,
    NotificationDeliveryStatus status,
  ) {
    return switch (status) {
      NotificationDeliveryStatus.pending => l10n.deliveryPending,
      NotificationDeliveryStatus.sent => l10n.deliverySent,
      NotificationDeliveryStatus.delivered => l10n.deliveryDelivered,
      NotificationDeliveryStatus.failed => l10n.deliveryFailed,
      NotificationDeliveryStatus.skipped => l10n.deliverySkipped,
    };
  }

  String _eventLabel(AppLocalizations l10n, NotificationEventType event) {
    return switch (event) {
      NotificationEventType.queueTenRemaining => l10n.queueNotifyTenRemaining,
      NotificationEventType.queueFiveRemaining => l10n.queueNotifyFiveRemaining,
      NotificationEventType.queueThreeRemaining =>
        l10n.queueNotifyThreeRemaining,
      NotificationEventType.queueYourTurn => l10n.queueNotifyYourTurn,
      NotificationEventType.queueMissedTurn => l10n.missedTurnNotification,
      NotificationEventType.doctorDelay => l10n.doctorDelayNotification,
      NotificationEventType.appointmentConfirmed => l10n.appointmentConfirmed,
      NotificationEventType.appointmentRescheduled =>
        l10n.appointmentRescheduled,
      NotificationEventType.appointmentCancelled => l10n.appointmentCancelled,
      NotificationEventType.doctorUnavailable => l10n.doctorUnavailable,
      NotificationEventType.clinicClosed => l10n.clinicClosedUnexpectedly,
      NotificationEventType.general => l10n.notifications,
    };
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
      ),
    );
  }
}
