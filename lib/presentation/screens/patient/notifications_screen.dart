import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../providers/app_providers.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthService>();
      context.read<NotificationProvider>().watch(auth.patientId);
    });
  }

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
                      color: n.read ? null : AppTheme.medicalBlue.withOpacity(0.05),
                      child: ListTile(
                        leading: Icon(
                          _iconForType(n.type),
                          color: AppTheme.medicalBlue,
                        ),
                        title: Text(n.title),
                        subtitle: Text(
                          '${n.body}\n${DateFormat.yMMMd().add_jm().format(n.createdAt)}',
                        ),
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
    return Icons.notifications;
  }
}
