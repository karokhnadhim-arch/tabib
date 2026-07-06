import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/platform_clinical_settings.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../presentation/widgets/owner_module_app_bar.dart';
import '../../../services/platform_clinical_settings_service.dart';

class OwnerQueueSettingsScreen extends StatefulWidget {
  const OwnerQueueSettingsScreen({super.key});

  @override
  State<OwnerQueueSettingsScreen> createState() => _OwnerQueueSettingsScreenState();
}

class _OwnerQueueSettingsScreenState extends State<OwnerQueueSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlatformClinicalSettingsService>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final service = context.watch<PlatformClinicalSettingsService>();
    final settings = service.settings;

    return AdminGuard(
      child: Scaffold(
        appBar: ownerModuleAppBar(context, title: l10n.queueSettings),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.queueSettingsHint,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(l10n.consultationDurationDefault),
                      subtitle: Slider(
                        value: settings.consultationMinutesDefault.toDouble(),
                        min: 5,
                        max: 60,
                        divisions: 11,
                        label: '${settings.consultationMinutesDefault} min',
                        onChanged: (v) {
                          service.updateField(
                            (s) => s.copyWith(
                              consultationMinutesDefault: v.round(),
                            ),
                          );
                        },
                      ),
                      trailing: Text('${settings.consultationMinutesDefault} min'),
                    ),
                    SwitchListTile(
                      title: Text(l10n.autoAssignQueueNumbers),
                      subtitle: Text(l10n.autoAssignQueueNumbersHint),
                      value: settings.autoAssignQueueNumbers,
                      onChanged: (v) {
                        service.updateField(
                          (s) => s.copyWith(autoAssignQueueNumbers: v),
                        );
                      },
                    ),
                    ListTile(
                      title: Text(l10n.queueStartNumber),
                      trailing: SizedBox(
                        width: 80,
                        child: TextFormField(
                          key: ValueKey(settings.queueStartNumber),
                          initialValue: '${settings.queueStartNumber}',
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onFieldSubmitted: (v) {
                            final n = int.tryParse(v) ?? 1;
                            service.updateField(
                              (s) => s.copyWith(
                                queueStartNumber: n.clamp(1, 999),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SwitchListTile(
                      title: Text(l10n.showCompletedInQueue),
                      value: settings.showCompletedInSecretaryQueue,
                      onChanged: (v) {
                        service.updateField(
                          (s) => s.copyWith(showCompletedInSecretaryQueue: v),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
