import 'package:flutter/material.dart';

class LocalizedText {
  const LocalizedText({
    required this.ku,
    required this.ar,
    required this.en,
  });

  final String ku;
  final String ar;
  final String en;

  /// True when Kurdish, Arabic, and English names are all non-empty.
  bool get hasAllTranslations =>
      ku.trim().isNotEmpty &&
      ar.trim().isNotEmpty &&
      en.trim().isNotEmpty;

  String forLocale(Locale locale) {
    final primary = switch (locale.languageCode) {
      'ar' => ar,
      'en' => en,
      'ku' => ku,
      _ => ku,
    };
    if (primary.trim().isNotEmpty) return primary.trim();
    for (final fallback in [ku, ar, en]) {
      if (fallback.trim().isNotEmpty) return fallback.trim();
    }
    return '';
  }

  Map<String, dynamic> toMap() => {'ku': ku, 'ar': ar, 'en': en};

  factory LocalizedText.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const LocalizedText(ku: '', ar: '', en: '');
    }
    return LocalizedText(
      ku: map['ku'] as String? ?? '',
      ar: map['ar'] as String? ?? '',
      en: map['en'] as String? ?? '',
    );
  }
}
