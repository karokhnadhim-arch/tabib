import '../../core/utils/clinic_subscription.dart';
import '../../models/clinic.dart';
import '../../models/doctor.dart';
import '../../services/clinic_data_service.dart';

/// Resolves a doctor's clinic subscription (subscriptions are per clinic).
class DoctorSubscriptionResolver {
  DoctorSubscriptionResolver._();

  static Clinic? clinicFor(Doctor doctor, ClinicDataService data) =>
      data.clinicById(doctor.clinicId);

  static ClinicSubscriptionStatus statusFor(
    Doctor doctor,
    ClinicDataService data,
  ) {
    final clinic = clinicFor(doctor, data);
    if (clinic == null) return ClinicSubscriptionStatus.expired;
    return ClinicSubscriptionHelper.statusFor(clinic);
  }

  static int remainingDays(Doctor doctor, ClinicDataService data) {
    final clinic = clinicFor(doctor, data);
    if (clinic == null) return -1;
    return ClinicSubscriptionHelper.remainingDays(clinic);
  }

  static SubscriptionPlan? planFor(Doctor doctor, ClinicDataService data) =>
      clinicFor(doctor, data)?.subscriptionPlan;

  static bool matchesFilter(
    Doctor doctor,
    ClinicDataService data,
    DoctorSubscriptionFilter filter,
  ) {
    if (filter == DoctorSubscriptionFilter.all) return true;
    final status = statusFor(doctor, data);
    return switch (filter) {
      DoctorSubscriptionFilter.active =>
        status == ClinicSubscriptionStatus.active,
      DoctorSubscriptionFilter.expiringSoon =>
        status == ClinicSubscriptionStatus.expiringSoon,
      DoctorSubscriptionFilter.expired =>
        status == ClinicSubscriptionStatus.expired,
      DoctorSubscriptionFilter.all => true,
    };
  }
}

enum DoctorSubscriptionFilter { all, active, expiringSoon, expired }
