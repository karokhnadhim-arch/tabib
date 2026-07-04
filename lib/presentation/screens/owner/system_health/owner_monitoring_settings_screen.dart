import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/owner_monitoring_phase4.dart';
import '../../../../services/owner_monitoring_settings_service.dart';
import '../../../widgets/system_owner_guard.dart';
import 'system_health_widgets.dart';

/// Centralized owner monitoring settings — local configuration only.
class OwnerMonitoringSettingsScreen extends StatelessWidget {
  const OwnerMonitoringSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<OwnerMonitoringSettingsService>();

    return SystemOwnerGuard(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.advancedSystemSettings)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Section(
              title: l10n.firebaseMonitoring,
              children: [
                _SwitchTile(
                  title: l10n.useAggregatedMetrics,
                  value: settings.getSectionBool(
                    MonitoringSettingsSection.firebase,
                    'useAggregatedMetrics',
                    fallback: true,
                  ),
                  onChanged: (v) => settings.setSectionValue(
                    MonitoringSettingsSection.firebase,
                    'useAggregatedMetrics',
                    v,
                  ),
                ),
                _SwitchTile(
                  title: l10n.warnBeforeExpensiveOps,
                  value: settings.getSectionBool(
                    MonitoringSettingsSection.firebase,
                    'warnBeforeBulkExport',
                    fallback: true,
                  ),
                  onChanged: (v) => settings.setSectionValue(
                    MonitoringSettingsSection.firebase,
                    'warnBeforeBulkExport',
                    v,
                  ),
                ),
              ],
            ),
            _Section(
              title: l10n.liveQueueStatistics,
              children: [
                _SwitchTile(
                  title: l10n.queueRealtimeEnabled,
                  value: settings.getSectionBool(
                    MonitoringSettingsSection.queue,
                    'realtimeEnabled',
                    fallback: true,
                  ),
                  onChanged: (v) => settings.setSectionValue(
                    MonitoringSettingsSection.queue,
                    'realtimeEnabled',
                    v,
                  ),
                ),
                _SwitchTile(
                  title: l10n.autoCleanupListeners,
                  value: settings.getSectionBool(
                    MonitoringSettingsSection.queue,
                    'autoCleanupListeners',
                    fallback: true,
                  ),
                  onChanged: (v) => settings.setSectionValue(
                    MonitoringSettingsSection.queue,
                    'autoCleanupListeners',
                    v,
                  ),
                ),
              ],
            ),
            _Section(
              title: l10n.advertisementMonitoring,
              children: [
                _SwitchTile(
                  title: l10n.cityTargeting,
                  value: settings.getSectionBool(
                    MonitoringSettingsSection.advertisements,
                    'cityTargeting',
                    fallback: true,
                  ),
                  onChanged: (v) => settings.setSectionValue(
                    MonitoringSettingsSection.advertisements,
                    'cityTargeting',
                    v,
                  ),
                ),
              ],
            ),
            _Section(
              title: l10n.activePackages,
              children: [
                _SwitchTile(
                  title: l10n.renewalReminders,
                  value: settings.getSectionBool(
                    MonitoringSettingsSection.packages,
                    'renewalReminders',
                    fallback: true,
                  ),
                  onChanged: (v) => settings.setSectionValue(
                    MonitoringSettingsSection.packages,
                    'renewalReminders',
                    v,
                  ),
                ),
              ],
            ),
            _Section(
              title: l10n.notificationMonitoring,
              children: [
                _SwitchTile(
                  title: l10n.smartOwnerNotifications,
                  value: settings.getSectionBool(
                    MonitoringSettingsSection.notifications,
                    'ownerSmartAlerts',
                    fallback: true,
                  ),
                  onChanged: (v) => settings.setSectionValue(
                    MonitoringSettingsSection.notifications,
                    'ownerSmartAlerts',
                    v,
                  ),
                ),
              ],
            ),
            _Section(
              title: l10n.backupRestore,
              children: [
                _SwitchTile(
                  title: l10n.autoBackup,
                  value: settings.getSectionBool(
                    MonitoringSettingsSection.backup,
                    'autoBackup',
                    fallback: true,
                  ),
                  onChanged: (v) => settings.setSectionValue(
                    MonitoringSettingsSection.backup,
                    'autoBackup',
                    v,
                  ),
                ),
              ],
            ),
            _Section(
              title: l10n.enableMaintenanceMode,
              children: [
                _SwitchTile(
                  title: l10n.enableMaintenanceMode,
                  value: settings.getSectionBool(
                    MonitoringSettingsSection.maintenance,
                    'enabled',
                  ),
                  onChanged: (v) => settings.setSectionValue(
                    MonitoringSettingsSection.maintenance,
                    'enabled',
                    v,
                  ),
                ),
                ListTile(
                  title: Text(l10n.maintenanceMessage),
                  subtitle: Text(
                    settings.getSection(
                      MonitoringSettingsSection.maintenance,
                      'message',
                      fallback: l10n.maintenanceMessage,
                    ),
                  ),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _editMaintenanceMessage(context, settings),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editMaintenanceMessage(
    BuildContext context,
    OwnerMonitoringSettingsService settings,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(
      text: settings.getSection(MonitoringSettingsSection.maintenance, 'message'),
    );
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.maintenanceMessage),
        content: TextField(controller: controller, maxLines: 3),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (result != null && context.mounted) {
      await settings.setSectionValue(
        MonitoringSettingsSection.maintenance,
        'message',
        result,
      );
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonitoringSectionHeader(title: title),
        MonitoringPanelCard(child: Column(children: children)),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
