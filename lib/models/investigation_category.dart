/// Investigation categories for laboratory and imaging requests.
enum InvestigationCategory {
  laboratory,
  radiology,
  cardiology,
  ultrasound,
  other;

  String get storageKey => name;
}

InvestigationCategory parseInvestigationCategory(String? raw) {
  return InvestigationCategory.values.firstWhere(
    (c) => c.name == raw,
    orElse: () => InvestigationCategory.other,
  );
}
