import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/locale_service.dart';
import '../../l10n/app_localizations.dart';

class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final localeService = context.watch<LocaleService>();
    final l10n = AppLocalizations.of(context);

    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      tooltip: l10n.language,
      onSelected: localeService.setLocale,
      itemBuilder: (context) => [
        PopupMenuItem(value: const Locale('ku'), child: Text(l10n.langKurdish)),
        PopupMenuItem(value: const Locale('ar'), child: Text(l10n.langArabic)),
        PopupMenuItem(value: const Locale('en'), child: Text(l10n.langEnglish)),
      ],
    );
  }
}
