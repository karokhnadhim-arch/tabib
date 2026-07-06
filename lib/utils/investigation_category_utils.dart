import '../../l10n/app_localizations.dart';
import '../../models/investigation_category.dart';

extension InvestigationCategoryL10n on InvestigationCategory {
  String label(AppLocalizations l10n) {
    switch (this) {
      case InvestigationCategory.laboratory:
        return l10n.investigationCategoryLaboratory;
      case InvestigationCategory.radiology:
        return l10n.investigationCategoryRadiology;
      case InvestigationCategory.cardiology:
        return l10n.investigationCategoryCardiology;
      case InvestigationCategory.ultrasound:
        return l10n.investigationCategoryUltrasound;
      case InvestigationCategory.other:
        return l10n.investigationCategoryOther;
    }
  }
}
