/// Reserved extension points — add features without rewriting core services.
abstract final class FutureCapabilities {
  static const bool onlinePayments = false;
  static const bool videoConsultation = false;
  static const bool multiBranchClinics = false;
  static const bool reportsAnalytics = false;
  static const bool externalApiIntegrations = false;

  /// Collections / services to add when enabling each capability.
  static const paymentsCollection = 'payments';
  static const videoSessionsCollection = 'video_sessions';
  static const branchesCollection = 'clinic_branches';
  static const analyticsEventsCollection = 'analytics_events';
  static const apiWebhooksCollection = 'api_webhooks';
}
