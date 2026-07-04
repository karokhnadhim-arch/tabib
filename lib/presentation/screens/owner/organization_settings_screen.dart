import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/organization.dart';
import '../../../presentation/widgets/system_owner_guard.dart';
import '../../../services/organization_service.dart';
import '../../../services/tenant_context_service.dart';

/// Organization-level branding and rules — scoped to active tenant (future-ready).
class OrganizationSettingsScreen extends StatefulWidget {
  const OrganizationSettingsScreen({super.key});

  @override
  State<OrganizationSettingsScreen> createState() =>
      _OrganizationSettingsScreenState();
}

class _OrganizationSettingsScreenState extends State<OrganizationSettingsScreen> {
  OrganizationSettings? _settings;
  bool _loading = true;
  bool _saving = false;
  late TextEditingController _nameController;
  late TextEditingController _colorController;
  String _language = 'ku';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _colorController = TextEditingController(text: '1E88E5');
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final orgId = context.read<TenantContextService>().activeOrganizationId;
    final settings = await context.read<OrganizationService>().loadSettings(orgId);
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _nameController.text = settings.displayName;
      _colorController.text = settings.primaryColorHex;
      _language = settings.defaultLanguage;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final current = _settings;
    if (current == null) return;
    setState(() => _saving = true);
    final updated = OrganizationSettings(
      organizationId: current.organizationId,
      logoUrl: current.logoUrl,
      displayName: _nameController.text.trim(),
      primaryColorHex: _colorController.text.trim(),
      defaultLanguage: _language,
      workingHoursLabel: current.workingHoursLabel,
      queueRulesSummary: current.queueRulesSummary,
      appointmentRulesSummary: current.appointmentRulesSummary,
      notificationSettingsSummary: current.notificationSettingsSummary,
    );
    await context.read<OrganizationService>().saveSettings(updated);
    if (!mounted) return;
    setState(() {
      _settings = updated;
      _saving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).savedSuccessfully)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SystemOwnerGuard(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: AppBar(
          title: Text(l10n.organizationSettings),
          backgroundColor: AppTheme.primaryDark,
          actions: [
            TextButton(
              onPressed: _saving || _loading ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.save),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(l10n.organizationSettingsHint,
                      style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 20),
                  _section(l10n.branding, [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.organizationName,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _colorController,
                      decoration: InputDecoration(
                        labelText: l10n.primaryColor,
                        hintText: '1E88E5',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _language,
                      decoration: InputDecoration(
                        labelText: l10n.language,
                        border: const OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'ku', child: Text('Kurdish')),
                        DropdownMenuItem(value: 'ar', child: Text('Arabic')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _language = v);
                      },
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _section(l10n.rulesAndHours, [
                    _readOnlyTile(l10n.workingHours, _settings!.workingHoursLabel),
                    _readOnlyTile(l10n.queueRules, _settings!.queueRulesSummary),
                    _readOnlyTile(
                      l10n.appointmentRules,
                      _settings!.appointmentRulesSummary,
                    ),
                    _readOnlyTile(
                      l10n.notifications,
                      _settings!.notificationSettingsSummary,
                    ),
                  ]),
                ],
              ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                )),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _readOnlyTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
