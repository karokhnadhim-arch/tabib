import '../models/investigation_catalog_item.dart';
import '../models/investigation_category.dart';

/// In-memory investigation catalog — fast search, grouped by category.
class InvestigationCatalog {
  InvestigationCatalog._();

  static final InvestigationCatalog instance = InvestigationCatalog._();

  static const List<InvestigationCatalogItem> _items = [
    // Laboratory
    InvestigationCatalogItem(id: 'lab_cbc', name: 'Complete Blood Count (CBC)', category: InvestigationCategory.laboratory),
    InvestigationCatalogItem(id: 'lab_fbs', name: 'Fasting Blood Sugar', category: InvestigationCategory.laboratory),
    InvestigationCatalogItem(id: 'lab_rbs', name: 'Random Blood Sugar', category: InvestigationCategory.laboratory),
    InvestigationCatalogItem(id: 'lab_hba1c', name: 'HbA1c', category: InvestigationCategory.laboratory),
    InvestigationCatalogItem(id: 'lab_lipid', name: 'Lipid Profile', category: InvestigationCategory.laboratory),
    InvestigationCatalogItem(id: 'lab_lft', name: 'Liver Function Tests (LFT)', category: InvestigationCategory.laboratory),
    InvestigationCatalogItem(id: 'lab_kft', name: 'Kidney Function Tests (KFT)', category: InvestigationCategory.laboratory),
    InvestigationCatalogItem(id: 'lab_urine', name: 'Urinalysis', category: InvestigationCategory.laboratory),
    InvestigationCatalogItem(id: 'lab_tsh', name: 'Thyroid Stimulating Hormone (TSH)', category: InvestigationCategory.laboratory),
    InvestigationCatalogItem(id: 'lab_t3t4', name: 'Free T3 / T4', category: InvestigationCategory.laboratory),
    InvestigationCatalogItem(id: 'lab_esr', name: 'Erythrocyte Sedimentation Rate (ESR)', category: InvestigationCategory.laboratory),
    InvestigationCatalogItem(id: 'lab_crp', name: 'C-Reactive Protein (CRP)', category: InvestigationCategory.laboratory),
    InvestigationCatalogItem(id: 'lab_pt_inr', name: 'PT / INR', category: InvestigationCategory.laboratory),
    InvestigationCatalogItem(id: 'lab_blood_group', name: 'Blood Group & Rh', category: InvestigationCategory.laboratory),
    InvestigationCatalogItem(id: 'lab_vit_d', name: 'Vitamin D', category: InvestigationCategory.laboratory),
    InvestigationCatalogItem(id: 'lab_vit_b12', name: 'Vitamin B12', category: InvestigationCategory.laboratory),
    InvestigationCatalogItem(id: 'lab_ferritin', name: 'Ferritin', category: InvestigationCategory.laboratory),
    InvestigationCatalogItem(id: 'lab_pregnancy', name: 'Pregnancy Test (Beta-hCG)', category: InvestigationCategory.laboratory),
    InvestigationCatalogItem(id: 'lab_stool', name: 'Stool Analysis', category: InvestigationCategory.laboratory),
    InvestigationCatalogItem(id: 'lab_culture_blood', name: 'Blood Culture', category: InvestigationCategory.laboratory),
    // Radiology
    InvestigationCatalogItem(id: 'rad_cxr', name: 'Chest X-Ray', category: InvestigationCategory.radiology),
    InvestigationCatalogItem(id: 'rad_abd_xr', name: 'Abdominal X-Ray', category: InvestigationCategory.radiology),
    InvestigationCatalogItem(id: 'rad_skull_xr', name: 'Skull X-Ray', category: InvestigationCategory.radiology),
    InvestigationCatalogItem(id: 'rad_ct_head', name: 'CT Brain / Head', category: InvestigationCategory.radiology),
    InvestigationCatalogItem(id: 'rad_ct_chest', name: 'CT Chest', category: InvestigationCategory.radiology),
    InvestigationCatalogItem(id: 'rad_ct_abd', name: 'CT Abdomen & Pelvis', category: InvestigationCategory.radiology),
    InvestigationCatalogItem(id: 'rad_mri_brain', name: 'MRI Brain', category: InvestigationCategory.radiology),
    InvestigationCatalogItem(id: 'rad_mri_spine', name: 'MRI Spine', category: InvestigationCategory.radiology),
    InvestigationCatalogItem(id: 'rad_mammogram', name: 'Mammography', category: InvestigationCategory.radiology),
    InvestigationCatalogItem(id: 'rad_bone_scan', name: 'Bone Scan', category: InvestigationCategory.radiology),
    // Cardiology
    InvestigationCatalogItem(id: 'card_ecg', name: 'Electrocardiogram (ECG)', category: InvestigationCategory.cardiology),
    InvestigationCatalogItem(id: 'card_echo', name: 'Echocardiography (Echo)', category: InvestigationCategory.cardiology),
    InvestigationCatalogItem(id: 'card_stress', name: 'Exercise Stress Test', category: InvestigationCategory.cardiology),
    InvestigationCatalogItem(id: 'card_holter', name: 'Holter Monitor (24h ECG)', category: InvestigationCategory.cardiology),
    InvestigationCatalogItem(id: 'card_trop', name: 'Troponin', category: InvestigationCategory.cardiology),
    InvestigationCatalogItem(id: 'card_bnp', name: 'BNP / NT-proBNP', category: InvestigationCategory.cardiology),
    // Ultrasound
    InvestigationCatalogItem(id: 'us_abd', name: 'Abdominal Ultrasound', category: InvestigationCategory.ultrasound),
    InvestigationCatalogItem(id: 'us_pelvic', name: 'Pelvic Ultrasound', category: InvestigationCategory.ultrasound),
    InvestigationCatalogItem(id: 'us_thyroid', name: 'Thyroid Ultrasound', category: InvestigationCategory.ultrasound),
    InvestigationCatalogItem(id: 'us_ob', name: 'Obstetric Ultrasound', category: InvestigationCategory.ultrasound),
    InvestigationCatalogItem(id: 'us_doppler_legs', name: 'Doppler Ultrasound — Lower Limbs', category: InvestigationCategory.ultrasound),
    InvestigationCatalogItem(id: 'us_doppler_carotid', name: 'Carotid Doppler Ultrasound', category: InvestigationCategory.ultrasound),
    InvestigationCatalogItem(id: 'us_breast', name: 'Breast Ultrasound', category: InvestigationCategory.ultrasound),
    InvestigationCatalogItem(id: 'us_renal', name: 'Renal Ultrasound', category: InvestigationCategory.ultrasound),
    // Other
    InvestigationCatalogItem(id: 'oth_pft', name: 'Pulmonary Function Test (PFT)', category: InvestigationCategory.other),
    InvestigationCatalogItem(id: 'oth_endoscopy', name: 'Upper GI Endoscopy', category: InvestigationCategory.other),
    InvestigationCatalogItem(id: 'oth_colonoscopy', name: 'Colonoscopy', category: InvestigationCategory.other),
    InvestigationCatalogItem(id: 'oth_biopsy', name: 'Tissue Biopsy', category: InvestigationCategory.other),
    InvestigationCatalogItem(id: 'oth_allergy', name: 'Allergy Panel', category: InvestigationCategory.other),
  ];

  List<InvestigationCatalogItem> get all => List.unmodifiable(_items);

  InvestigationCatalogItem? byId(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  List<InvestigationCatalogItem> byCategory(InvestigationCategory category) =>
      _items.where((i) => i.category == category).toList();
}
