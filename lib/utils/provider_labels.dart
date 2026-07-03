import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';
import '../models/doctor.dart';
import '../models/provider_catalog_mode.dart';
import '../models/service_provider_type.dart';
import '../models/specialty.dart';
import 'localization_utils.dart';

/// Adaptive UI labels for doctor vs business service providers.
abstract final class ProviderLabels {
  static bool isBusiness(Doctor? provider) =>
      provider?.accountType.isBusiness == true;

  static String providerNameLabel(AppLocalizations l10n, Doctor? provider) =>
      isBusiness(provider) ? l10n.businessName : l10n.doctorName;

  static String profileTitle(AppLocalizations l10n, Doctor? provider) =>
      isBusiness(provider) ? l10n.businessProfile : l10n.doctorProfile;

  static String editProfileTitle(AppLocalizations l10n, Doctor? provider) =>
      isBusiness(provider) ? l10n.editBusinessProfile : l10n.editDoctorProfile;

  static String aboutTitle(AppLocalizations l10n, Doctor? provider) =>
      isBusiness(provider) ? l10n.aboutBusiness : l10n.aboutDoctor;

  static String dashboardTitle(AppLocalizations l10n, Doctor? provider) =>
      isBusiness(provider) ? l10n.businessDashboard : l10n.doctorDashboard;

  static String linkedProviderLabel(
    AppLocalizations l10n,
    Doctor? provider,
  ) =>
      isBusiness(provider) ? l10n.linkedBusiness : l10n.linkedDoctor;

  static String searchProvidersTitle(AppLocalizations l10n) =>
      l10n.searchProviders;

  static String searchHint(AppLocalizations l10n) => l10n.searchHintProviders;

  static String catalogTitle(
    AppLocalizations l10n,
    ProviderCatalogMode mode,
  ) =>
      switch (mode) {
        ProviderCatalogMode.doctors => l10n.doctorsSection,
        ProviderCatalogMode.businesses => l10n.clinicsHealthcareCenters,
      };

  static String catalogSearchHint(
    AppLocalizations l10n,
    ProviderCatalogMode mode,
  ) =>
      switch (mode) {
        ProviderCatalogMode.doctors => l10n.searchDoctorsOnly,
        ProviderCatalogMode.businesses => l10n.searchBusinessesOnly,
      };

  static String catalogEmptyMessage(
    AppLocalizations l10n,
    ProviderCatalogMode mode,
  ) =>
      switch (mode) {
        ProviderCatalogMode.doctors => l10n.noDoctorsFound,
        ProviderCatalogMode.businesses => l10n.noBusinessesFound,
      };

  static String detailRoute(
    ProviderCatalogMode mode,
    String providerId,
  ) =>
      switch (mode) {
        ProviderCatalogMode.doctors => '/doctors/$providerId',
        ProviderCatalogMode.businesses => '/businesses/$providerId',
      };

  static String createAccountTitle(
    AppLocalizations l10n,
    ServiceProviderAccountType type,
  ) =>
      type.isBusiness
          ? l10n.createBusinessAccount
          : l10n.createDoctorAccount;

  static String accountTypeLabel(
    AppLocalizations l10n,
    ServiceProviderAccountType type,
  ) =>
      type.isBusiness ? l10n.accountTypeBusiness : l10n.accountTypeDoctor;

  static String displayCategory(
    BuildContext context,
    AppLocalizations l10n,
    Doctor provider, {
    Specialty? catalogSpecialty,
  }) {
    final specialty = catalogSpecialty ?? provider.specialty;
    final localized = specialty.name.localized(context).trim();
    if (localized.isNotEmpty) return localized;
    if (provider.accountType.isBusiness && provider.businessCategory != null) {
      return businessCategoryLabel(l10n, provider.businessCategory!);
    }
    return localized;
  }

  static String businessCategoryLabel(
    AppLocalizations l10n,
    BusinessCategory category,
  ) =>
      switch (category) {
        BusinessCategory.clinic => l10n.businessCategoryClinic,
        BusinessCategory.beautyCenter => l10n.businessCategoryBeautyCenter,
        BusinessCategory.medicalLaboratory =>
          l10n.businessCategoryMedicalLaboratory,
        BusinessCategory.radiologyCenter =>
          l10n.businessCategoryRadiologyCenter,
        BusinessCategory.physiotherapyCenter =>
          l10n.businessCategoryPhysiotherapyCenter,
        BusinessCategory.dentalCenter => l10n.businessCategoryDentalCenter,
        BusinessCategory.eyeCenter => l10n.businessCategoryEyeCenter,
        BusinessCategory.hearingCenter => l10n.businessCategoryHearingCenter,
        BusinessCategory.vaccinationCenter =>
          l10n.businessCategoryVaccinationCenter,
        BusinessCategory.bloodTestCenter =>
          l10n.businessCategoryBloodTestCenter,
        BusinessCategory.pharmacy => l10n.businessCategoryPharmacy,
        BusinessCategory.otherHealthcare =>
          l10n.businessCategoryOtherHealthcare,
      };

  static List<String> searchableCategoryTerms(
    AppLocalizations l10n,
    Doctor provider,
  ) {
    if (provider.accountType.isBusiness && provider.businessCategory != null) {
      return [businessCategoryLabel(l10n, provider.businessCategory!)];
    }
    return [
      provider.specialty.name.ku,
      provider.specialty.name.ar,
      provider.specialty.name.en,
    ];
  }
}
