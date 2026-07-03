import 'package:flutter/material.dart';

import '../../core/utils/localized_name_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../models/localized_text.dart';

/// Kurdish, Arabic, and English name fields with optional required validation.
class LocalizedNameFormFields extends StatelessWidget {
  const LocalizedNameFormFields({
    super.key,
    required this.kuController,
    required this.arController,
    required this.enController,
    this.requireAll = true,
    this.hint,
  });

  final TextEditingController kuController;
  final TextEditingController arController;
  final TextEditingController enController;
  final bool requireAll;
  final String? hint;

  static LocalizedText? parse(
    AppLocalizations l10n, {
    required TextEditingController ku,
    required TextEditingController ar,
    required TextEditingController en,
    required bool requireAll,
  }) {
    if (!requireAll) {
      final name = LocalizedText(
        ku: ku.text.trim(),
        ar: ar.text.trim(),
        en: en.text.trim(),
      );
      if (name.ku.isEmpty && name.ar.isEmpty && name.en.isEmpty) return null;
      return name;
    }
    return LocalizedNameUtils.parseRequired(
      ku: ku.text,
      ar: ar.text,
      en: en.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hint != null) ...[
          Text(
            hint!,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
        ],
        TextFormField(
          controller: kuController,
          decoration: InputDecoration(
            labelText: l10n.nameKu,
            suffixText: requireAll ? '*' : null,
          ),
          validator: (v) => LocalizedNameUtils.fieldError(
            v,
            l10n,
            required: requireAll,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: arController,
          decoration: InputDecoration(
            labelText: l10n.nameAr,
            suffixText: requireAll ? '*' : null,
          ),
          validator: (v) => LocalizedNameUtils.fieldError(
            v,
            l10n,
            required: requireAll,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: enController,
          decoration: InputDecoration(
            labelText: l10n.nameEn,
            suffixText: requireAll ? '*' : null,
          ),
          validator: (v) => LocalizedNameUtils.fieldError(
            v,
            l10n,
            required: requireAll,
          ),
        ),
      ],
    );
  }
}
