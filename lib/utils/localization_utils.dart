import 'package:flutter/material.dart';

import '../models/localized_text.dart';

extension LocalizedTextX on LocalizedText {
  String localized(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return forLocale(locale);
  }
}

String roleLabel(BuildContext context, dynamic role, dynamic l10n) {
  switch (role.toString()) {
    case 'UserRole.doctor':
      return l10n.roleDoctor;
    case 'UserRole.secretary':
      return l10n.roleSecretary;
    case 'UserRole.admin':
      return l10n.roleAdmin;
    default:
      return l10n.roleDoctor;
  }
}
