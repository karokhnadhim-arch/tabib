import 'package:flutter/material.dart';

import '../../../core/constants/app_info.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';

class LegalContentScreen extends StatelessWidget {
  const LegalContentScreen({super.key, required this.document});

  final String document;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (title, body) = _content(l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.medicalBlue,
      ),
      body: ResponsiveBody(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Text(
            body,
            style: TextStyle(
              height: 1.6,
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  (String, String) _content(AppLocalizations l10n) => switch (document) {
        'terms' => (l10n.termsAndConditions, l10n.termsContent),
        'privacy' => (l10n.privacyPolicy, l10n.privacyPolicyContent),
        'about' => (l10n.about, l10n.aboutContent(AppInfo.version)),
        'help' => (l10n.helpAndSupport, l10n.helpContent(AppInfo.supportEmail)),
        _ => (l10n.about, l10n.aboutContent(AppInfo.version)),
      };
}
