import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';
import '../models/user_account.dart';
import 'localization_utils.dart';

/// Formats assigned secretary names for admin doctor lists.
abstract final class SecretaryDisplayFormatter {
  static const _previewCount = 2;

  static List<String> localizedNames(
    BuildContext context,
    List<UserAccount> secretaries,
  ) =>
      secretaries.map((s) => s.name.localized(context)).toList();

  /// Single-line summary, e.g. "Secretary: Sarah" or "Secretaries: A, B (+2 more)".
  static String? summaryLine(
    AppLocalizations l10n,
    BuildContext context,
    List<UserAccount> secretaries,
  ) {
    if (secretaries.isEmpty) return null;

    final names = localizedNames(context, secretaries);
    if (names.length == 1) {
      return l10n.doctorSecretarySingle(names.first);
    }

    final preview = names.take(_previewCount).join(', ');
    final remaining = names.length - _previewCount;
    if (remaining > 0) {
      return l10n.doctorSecretariesMultipleWithMore(preview, remaining);
    }
    return l10n.doctorSecretariesMultiple(preview);
  }
}
