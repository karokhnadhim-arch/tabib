/// Firestore query limits tuned for scale (thousands of concurrent users).
abstract final class FirestoreLimits {
  static const int doctorsPageSize = 24;
  static const int maxDoctorsCatalog = 200;
  static const int appointmentsPageSize = 40;
  static const int upcomingAppointmentsDays = 14;
  static const int notificationsPageSize = 30;
  static const int chatMessagesPageSize = 50;
  static const int prescriptionsPageSize = 30;
  static const int dailyScheduleMax = 200;
  static const int queueActiveMax = 500;
}
