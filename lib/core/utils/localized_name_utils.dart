import '../../l10n/app_localizations.dart';
import '../../models/localized_text.dart';

/// Validation and formatting for tri-lingual catalog names (KU / AR / EN).
abstract final class LocalizedNameUtils {
  LocalizedNameUtils._();

  static bool isComplete(LocalizedText name) => name.hasAllTranslations;

  static LocalizedText? parseRequired({
    required String ku,
    required String ar,
    required String en,
  }) {
    final parsed = LocalizedText(
      ku: ku.trim(),
      ar: ar.trim(),
      en: en.trim(),
    );
    return isComplete(parsed) ? parsed : null;
  }

  /// Admin list subtitle — all three stored translations.
  static String catalogSubtitle(LocalizedText name) =>
      '${name.ku.trim()} · ${name.ar.trim()} · ${name.en.trim()}';

  static String? fieldError(
    String? value,
    AppLocalizations l10n, {
    required bool required,
  }) {
    if (!required) return null;
    if (value == null || value.trim().isEmpty) {
      return l10n.translationRequired;
    }
    return null;
  }
}
