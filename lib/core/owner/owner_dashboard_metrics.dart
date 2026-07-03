import '../../core/privacy/system_owner_privacy.dart';
import '../../core/utils/clinic_subscription.dart';
import '../../models/user_account.dart';
import '../../services/clinic_data_service.dart';
import '../../services/staff_data_service.dart';

/// Snapshot metrics for the System Owner overview dashboard.
class OwnerDashboardMetrics {
  const OwnerDashboardMetrics({
    required this.totalDoctors,
    required this.totalBusinesses,
    required this.totalSecretaries,
    required this.totalPatients,
    required this.activeUsersToday,
    required this.activeSubscriptions,
    required this.expiredSubscriptions,
    required this.expiringSoonSubscriptions,
    required this.catalogDoctors,
    required this.catalogBusinesses,
    required this.queueWaiting,
    required this.queueInProgress,
    required this.newRegistrationsEstimate,
    required this.revenueEstimateLabel,
  });

  final int totalDoctors;
  final int totalBusinesses;
  final int totalSecretaries;
  final int totalPatients;
  final int activeUsersToday;
  final int activeSubscriptions;
  final int expiredSubscriptions;
  final int expiringSoonSubscriptions;
  final int catalogDoctors;
  final int catalogBusinesses;
  final int queueWaiting;
  final int queueInProgress;
  final int newRegistrationsEstimate;
  final String revenueEstimateLabel;

  static OwnerDashboardMetrics compute({
    required StaffDataService staffData,
    required ClinicDataService clinicData,
    List<UserAccount> allAccounts = const [],
    int queueWaiting = 0,
    int queueInProgress = 0,
  }) {
    final staff = staffData.staff;
    final doctors = staff.where((s) => s.role == UserRole.doctor).length;
    final secretaries =
        staff.where((s) => s.role == UserRole.secretary).length;

    final patientsInStaff =
        staff.where((s) => s.role == UserRole.patient).length;
    final patientsInAll = allAccounts
        .where(
          (a) =>
              a.role == UserRole.patient &&
              !SystemOwnerPrivacy.isInternalPlatformAccount(a),
        )
        .length;
    final patients =
        patientsInAll > patientsInStaff ? patientsInAll : patientsInStaff;

    final catalog = clinicData.doctors;
    final catalogDoctors =
        catalog.where((d) => d.isDoctorAccount).length;
    final catalogBusinesses = catalog.where((d) => d.isBusiness).length;
    final businessStaff = staff
        .where(
          (s) =>
              s.role == UserRole.doctor &&
              catalog.any(
                (d) => d.id == s.doctorId && d.isBusiness,
              ),
        )
        .length;
    final totalBusinesses =
        catalogBusinesses > businessStaff ? catalogBusinesses : businessStaff;

    final clinics = clinicData.clinics;
    var active = 0;
    var expired = 0;
    var expiring = 0;
    for (final clinic in clinics) {
      switch (ClinicSubscriptionHelper.statusFor(clinic)) {
        case ClinicSubscriptionStatus.active:
          active++;
        case ClinicSubscriptionStatus.expired:
          expired++;
        case ClinicSubscriptionStatus.expiringSoon:
          expiring++;
          active++;
      }
    }

    final activeAccounts = allAccounts.isEmpty
        ? staff.where((s) => s.accountStatus.isActive).length
        : allAccounts
            .where(
              (a) =>
                  a.accountStatus.isActive &&
                  !SystemOwnerPrivacy.isInternalPlatformAccount(a),
            )
            .length;

    final revenueLabel = active > 0 ? '${active * 150}K IQD' : '—';

    return OwnerDashboardMetrics(
      totalDoctors: doctors > catalogDoctors ? doctors : catalogDoctors,
      totalBusinesses: totalBusinesses,
      totalSecretaries: secretaries,
      totalPatients: patients,
      activeUsersToday: activeAccounts,
      activeSubscriptions: active,
      expiredSubscriptions: expired,
      expiringSoonSubscriptions: expiring,
      catalogDoctors: catalogDoctors,
      catalogBusinesses: catalogBusinesses,
      queueWaiting: queueWaiting,
      queueInProgress: queueInProgress,
      newRegistrationsEstimate: patients.clamp(0, 999),
      revenueEstimateLabel: revenueLabel,
    );
  }
}
