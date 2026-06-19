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

  String forLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return ar;
      case 'en':
        return en;
      case 'ku':
      default:
        return ku;
    }
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
