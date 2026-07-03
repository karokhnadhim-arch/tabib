import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../presentation/widgets/admin_guard.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/notification_channel.dart';
import '../../../services/platform_notification_config_service.dart';
import '../../widgets/settings/settings_widgets.dart';

class OwnerNotificationConfigScreen extends StatefulWidget {
  const OwnerNotificationConfigScreen({super.key});

  @override
  State<OwnerNotificationConfigScreen> createState() =>
      _OwnerNotificationConfigScreenState();
}

class _OwnerNotificationConfigScreenState
    extends State<OwnerNotificationConfigScreen> {
  String _editLocale = 'en';
  String _editEvent = NotificationEventType.queueTenRemaining.storageKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final configService = context.watch<PlatformNotificationConfigService>();
    final config = configService.config;

    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.notificationSystemSettings),
          backgroundColor: AppTheme.primaryDark,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SettingsSection(
              title: l10n.notificationChannels,
              icon: Icons.send_outlined,
              children: [
                SettingsSwitchTile(
                  title: l10n.pushNotifications,
                  subtitle: l10n.pushNotificationsOwnerHint,
                  value: config.pushEnabled,
                  onChanged: (v) => configService.updateField(
                    (c) => c.copyWith(pushEnabled: v),
                  ),
                ),
                const SettingsDivider(),
                SettingsSwitchTile(
                  title: l10n.whatsappNotifications,
                  value: config.whatsappEnabled,
                  onChanged: (v) => configService.updateField(
                    (c) => c.copyWith(whatsappEnabled: v),
                  ),
                ),
                const SettingsDivider(),
                SettingsSwitchTile(
                  title: l10n.smsNotifications,
                  subtitle: l10n.smsNotificationsHint,
                  value: config.smsEnabled,
                  onChanged: (v) => configService.updateField(
                    (c) => c.copyWith(smsEnabled: v),
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: l10n.queueAlertThresholds,
              icon: Icons.format_list_numbered,
              children: [
                Text(l10n.queueAlertThresholdsHint),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [10, 5, 3, 0].map((value) {
                    final selected = config.queueThresholds.contains(value);
                    return FilterChip(
                      label: Text(value == 0 ? l10n.yourTurn : '$value'),
                      selected: selected,
                      onSelected: (on) {
                        final next = List<int>.from(config.queueThresholds);
                        if (on) {
                          if (!next.contains(value)) next.add(value);
                        } else {
                          next.remove(value);
                        }
                        next.sort((a, b) => b.compareTo(a));
                        configService.updateField(
                          (c) => c.copyWith(queueThresholds: next),
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            SettingsSection(
              title: l10n.notificationTemplates,
              icon: Icons.text_snippet_outlined,
              children: [
                Text(l10n.notificationTemplatesHint),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _editEvent,
                  decoration: InputDecoration(
                    labelText: l10n.notificationType,
                    border: const OutlineInputBorder(),
                  ),
                  items: NotificationEventType.values
                      .where((e) => e != NotificationEventType.general)
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.storageKey,
                          child: Text(_eventLabel(l10n, e)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _editEvent = v ?? _editEvent),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'ku', label: Text(l10n.langKurdish)),
                    ButtonSegment(value: 'ar', label: Text(l10n.langArabic)),
                    ButtonSegment(value: 'en', label: Text(l10n.langEnglish)),
                  ],
                  selected: {_editLocale},
                  onSelectionChanged: (s) =>
                      setState(() => _editLocale = s.first),
                ),
                const SizedBox(height: 12),
                _TemplateEditor(
                  key: ValueKey('$_editEvent-$_editLocale'),
                  initialText: config.templateFor(
                    NotificationEventType.values.firstWhere(
                      (e) => e.storageKey == _editEvent,
                    ),
                    _editLocale,
                  ),
                  onSave: (text) {
                    final templates = Map<String, Map<String, String>>.from(
                      config.templates.map(
                        (k, v) => MapEntry(k, Map<String, String>.from(v)),
                      ),
                    );
                    templates.putIfAbsent(_editEvent, () => {});
                    templates[_editEvent]![_editLocale] = text;
                    configService.updateField(
                      (c) => c.copyWith(templates: templates),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.templateSaved)),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

class _TemplateEditor extends StatefulWidget {
  const _TemplateEditor({
    super.key,
    required this.initialText,
    required this.onSave,
  });

  final String initialText;
  final ValueChanged<String> onSave;

  @override
  State<_TemplateEditor> createState() => _TemplateEditorState();
}

class _TemplateEditorState extends State<_TemplateEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void didUpdateWidget(covariant _TemplateEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialText != widget.initialText) {
      _controller.text = widget.initialText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: l10n.templateVariablesHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () => widget.onSave(_controller.text.trim()),
          child: Text(l10n.saveTemplate),
        ),
      ],
    );
  }
}
