import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/l10n/kurdish_material_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/demo_mode_banner.dart';
import 'data/repositories/appointment_repository_impl.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'data/repositories/in_memory_repositories.dart';
import 'data/repositories/notification_repository_impl.dart';
import 'data/repositories/prescription_repository_impl.dart';
import 'domain/repositories/repositories.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/app_providers.dart';
import 'models/user_account.dart';
import 'services/appointment_service.dart';
import 'services/auth_service.dart';
import 'services/backend/clinic_backend.dart';
import 'services/backend/firestore_clinic_backend.dart';
import 'services/backend/in_memory_clinic_backend.dart';
import 'services/clinic_data_service.dart';
import 'services/business_type_usage_service.dart';
import 'services/advertisement_service.dart';
import 'services/favorites_service.dart';
import 'services/patient_profile_service.dart';
import 'services/recently_visited_service.dart';
import 'services/firebase_bootstrap.dart';
import 'services/locale_service.dart';
import 'services/queue_service.dart';
import 'services/staff_data_service.dart';
import 'services/owner_audit_service.dart';
import 'services/subscription_monitor_service.dart';
import 'services/theme_service.dart';
import 'services/patient_contact_service.dart';
import 'services/staff_communication_log_service.dart';
import 'services/platform_notification_config_service.dart';
import 'services/smart_notification_service.dart';
import 'services/queue_notification_monitor.dart';
import 'services/user_preferences_service.dart';
import 'services/dashboard_summary_repository.dart';
import 'services/owner_dashboard_appearance_service.dart';
import 'services/owner_dashboard_filter_service.dart';
import 'services/owner_dashboard_search_service.dart';
import 'services/owner_forecast_service.dart';
import 'services/owner_insights_service.dart';
import 'services/owner_monitoring_settings_service.dart';
import 'services/firebase_cost_optimizer_service.dart';
import 'services/smart_owner_notification_service.dart';
import 'services/system_monitoring_service.dart';
import 'services/system_error_log_service.dart';
import 'services/system_activity_feed_service.dart';
import 'services/system_maintenance_service.dart';
import 'services/organization_billing_service.dart';
import 'services/organization_service.dart';
import 'services/tenant_context_service.dart';
import 'core/widgets/maintenance_mode_gate.dart';

/// Root widget for Tabib — medical appointment platform.
class TabibApp extends StatefulWidget {
  const TabibApp({super.key, required this.firebaseReady});

  final bool firebaseReady;

  static final List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    const KurdishMaterialLocalizationsDelegate(),
    const KurdishWidgetsLocalizationsDelegate(),
    const KurdishCupertinoLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  @override
  State<TabibApp> createState() => _TabibAppState();
}

class _TabibAppState extends State<TabibApp> {
  late final bool _demoMode;
  late final ClinicBackend _backend;
  late final AuthService _authService;
  late final ClinicDataService _dataService;
  late final StaffDataService _staffDataService;
  late final QueueService _queueService;
  late final AppointmentService _appointmentService;
  late final LocaleService _localeService;
  late final ThemeService _themeService;
  late final UserPreferencesService _userPreferencesService;
  late final FavoritesService _favoritesService;
  late final PatientProfileService _patientProfileService;
  late final RecentlyVisitedService _recentlyVisitedService;
  late final AdvertisementService _advertisementService;
  late final BusinessTypeUsageService _businessTypeUsageService;
  late final AppointmentRepository _appointmentRepository;
  late final PrescriptionRepository _prescriptionRepository;
  late final NotificationRepository _notificationRepository;
  late final ChatRepository _chatRepository;
  late final AppointmentProvider _appointmentProvider;
  late final PrescriptionProvider _prescriptionProvider;
  late final NotificationProvider _notificationProvider;
  late final ChatProvider _chatProvider;
  late final OwnerAuditService _ownerAuditService;
  late final SubscriptionMonitorService _subscriptionMonitor;
  late final PlatformNotificationConfigService _platformNotificationConfig;
  late final SmartNotificationService _smartNotificationService;
  late final StaffCommunicationLogService _staffCommunicationLog;
  late final PatientContactService _patientContactService;
  late final SystemMonitoringService _systemMonitoringService;
  late final SystemErrorLogService _systemErrorLogService;
  late final SystemActivityFeedService _systemActivityFeedService;
  late final SystemMaintenanceService _systemMaintenanceService;
  late final OwnerInsightsService _ownerInsightsService;
  late final OwnerForecastService _ownerForecastService;
  late final SmartOwnerNotificationService _smartOwnerNotificationService;
  late final OwnerDashboardSearchService _ownerDashboardSearchService;
  late final OwnerDashboardFilterService _ownerDashboardFilterService;
  late final OwnerDashboardAppearanceService _ownerDashboardAppearanceService;
  late final FirebaseCostOptimizerService _firebaseCostOptimizerService;
  late final OwnerMonitoringSettingsService _ownerMonitoringSettingsService;
  late final OrganizationService _organizationService;
  late final TenantContextService _tenantContextService;
  late final OrganizationBillingService _organizationBillingService;
  QueueNotificationMonitor? _queueNotificationMonitor;
  late final GoRouter _router;
  String? _activePatientQueueId;

  @override
  void initState() {
    super.initState();
    _demoMode = FirebaseBootstrap.shouldUseDemoMode;

    if (_demoMode) {
      _backend = InMemoryClinicBackend();
      _authService = AuthService(backend: _backend, demoMode: true);
      final inMemoryNotifications = InMemoryNotificationRepository();
      final inMemoryAppointments = InMemoryAppointmentRepository();
      inMemoryAppointments.seedDemoAppointments();
      _appointmentRepository = inMemoryAppointments;
      _notificationRepository = inMemoryNotifications;
      _prescriptionRepository = InMemoryPrescriptionRepository(
        notifications: inMemoryNotifications,
      );
      _chatRepository = InMemoryChatRepository();
      _appointmentService = AppointmentService(demoMode: true);
    } else {
      _backend = FirestoreClinicBackend();
      _authService = AuthService(backend: _backend)..setFirebaseReady(true);
      _appointmentRepository = FirestoreAppointmentRepository();
      _prescriptionRepository = FirestorePrescriptionRepository();
      _notificationRepository = FirestoreNotificationRepository();
      _chatRepository = FirestoreChatRepository();
      _appointmentService = AppointmentService();
    }

    _dataService = ClinicDataService(backend: _backend);
    _staffDataService = StaffDataService(backend: _backend);
    _queueService = QueueService(backend: _backend);
    _localeService = LocaleService();
    _themeService = ThemeService();
    _userPreferencesService = UserPreferencesService();
    _platformNotificationConfig = PlatformNotificationConfigService()..load();
    _smartNotificationService = SmartNotificationService(
      notifications: _notificationRepository,
      configService: _platformNotificationConfig,
      userPreferences: _userPreferencesService,
      authService: _authService,
    );
    _staffCommunicationLog = StaffCommunicationLogService();
    _patientContactService = PatientContactService(
      authService: _authService,
      communicationLog: _staffCommunicationLog,
    );
    _favoritesService = FavoritesService();
    _patientProfileService = PatientProfileService();
    _recentlyVisitedService = RecentlyVisitedService();
    _advertisementService = AdvertisementService(backend: _backend);
    _businessTypeUsageService = BusinessTypeUsageService()..load();
    _authService.addListener(_onAuthChanged);
    _appointmentProvider = AppointmentProvider(
      repository: _appointmentRepository,
      smartNotifications: _smartNotificationService,
    );
    _prescriptionProvider = PrescriptionProvider(repository: _prescriptionRepository);
    _notificationProvider = NotificationProvider(repository: _notificationRepository);
    _chatProvider = ChatProvider(repository: _chatRepository);
    _ownerAuditService = OwnerAuditService();
    _systemErrorLogService = SystemErrorLogService();
    final dashboardSummaryRepo = DashboardSummaryRepository(backend: _backend);
    _systemActivityFeedService = SystemActivityFeedService(
      summaryRepo: dashboardSummaryRepo,
    );
    _systemMaintenanceService = SystemMaintenanceService()..load();
    _ownerInsightsService = OwnerInsightsService();
    _ownerForecastService = OwnerForecastService();
    _smartOwnerNotificationService = SmartOwnerNotificationService();
    _ownerDashboardSearchService = OwnerDashboardSearchService(
      clinicData: _dataService,
      staffData: _staffDataService,
      auditService: _ownerAuditService,
      advertisementService: _advertisementService,
    );
    _ownerDashboardFilterService = OwnerDashboardFilterService(
      clinicData: _dataService,
    );
    _ownerDashboardAppearanceService = OwnerDashboardAppearanceService()..load();
    _firebaseCostOptimizerService = FirebaseCostOptimizerService();
    _ownerMonitoringSettingsService = OwnerMonitoringSettingsService(
      maintenance: _systemMaintenanceService,
    )..load();
    _organizationService = OrganizationService();
    _tenantContextService = TenantContextService();
    _organizationBillingService = OrganizationBillingService(
      organizations: _organizationService,
    );
    _systemMonitoringService = SystemMonitoringService(
      backend: _backend,
      clinicData: _dataService,
      staffData: _staffDataService,
      communicationLog: _staffCommunicationLog,
      errorLog: _systemErrorLogService,
      advertisementService: _advertisementService,
    )
      ..attachActivityFeed(_systemActivityFeedService)
      ..attachPhase4Services(
        insights: _ownerInsightsService,
        forecast: _ownerForecastService,
        smartNotifications: _smartOwnerNotificationService,
        costOptimizer: _firebaseCostOptimizerService,
        search: _ownerDashboardSearchService,
      );
    _subscriptionMonitor = SubscriptionMonitorService(
      backend: _backend,
      catalog: _dataService,
      staffData: _staffDataService,
      notifications: _notificationRepository,
    )..start();
    _queueNotificationMonitor = QueueNotificationMonitor(
      queueService: _queueService,
      notifications: _smartNotificationService,
      clinicData: _dataService,
    );
    _dataService.startRealtimeCatalog();
    _staffDataService.startRealtime();
    _router = AppRouter(
      authService: _authService,
      appReady: true,
    ).router;
  }

  void _onAuthChanged() {
    final user = _authService.currentUser;
    final userId = user?.id;

    if (userId == null) {
      if (_activePatientQueueId != null) {
        _queueService.stopWatchingPatientQueue(_activePatientQueueId!);
        _activePatientQueueId = null;
      }
      _chatProvider.stopWatching();
    } else if (user!.role == UserRole.patient) {
      _activePatientQueueId = userId;
    } else {
      _activePatientQueueId = null;
    }

    _userPreferencesService.bindUser(userId);
    _favoritesService.bindUser(userId);
    _patientProfileService.bindUser(userId);
    _recentlyVisitedService.bindUser(userId);
    _tenantContextService.bindUser(user);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    _subscriptionMonitor.dispose();
    _systemMonitoringService.dispose();
    _queueNotificationMonitor?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ClinicBackend>.value(value: _backend),
        ChangeNotifierProvider.value(value: _authService),
        ChangeNotifierProvider.value(value: _dataService),
        ChangeNotifierProvider.value(value: _staffDataService),
        ChangeNotifierProvider.value(value: _queueService),
        ChangeNotifierProvider.value(value: _appointmentService),
        ChangeNotifierProvider.value(value: _localeService),
        ChangeNotifierProvider.value(value: _themeService),
        ChangeNotifierProvider.value(value: _userPreferencesService),
        ChangeNotifierProvider.value(value: _platformNotificationConfig),
        ChangeNotifierProvider.value(value: _smartNotificationService),
        Provider<PatientContactService>.value(value: _patientContactService),
        ChangeNotifierProvider.value(value: _staffCommunicationLog),
        ChangeNotifierProvider.value(value: _favoritesService),
        ChangeNotifierProvider.value(value: _patientProfileService),
        ChangeNotifierProvider.value(value: _recentlyVisitedService),
        ChangeNotifierProvider.value(value: _advertisementService),
        ChangeNotifierProvider.value(value: _businessTypeUsageService),
        ChangeNotifierProvider.value(value: _appointmentProvider),
        ChangeNotifierProvider.value(value: _prescriptionProvider),
        ChangeNotifierProvider.value(value: _notificationProvider),
        ChangeNotifierProvider.value(value: _chatProvider),
        ChangeNotifierProvider.value(value: _ownerAuditService),
        ChangeNotifierProvider.value(value: _subscriptionMonitor),
        ChangeNotifierProvider.value(value: _systemMonitoringService),
        ChangeNotifierProvider.value(value: _systemErrorLogService),
        ChangeNotifierProvider.value(value: _systemActivityFeedService),
        ChangeNotifierProvider.value(value: _systemMaintenanceService),
        ChangeNotifierProvider.value(value: _ownerInsightsService),
        ChangeNotifierProvider.value(value: _ownerForecastService),
        ChangeNotifierProvider.value(value: _smartOwnerNotificationService),
        ChangeNotifierProvider.value(value: _ownerDashboardSearchService),
        ChangeNotifierProvider.value(value: _ownerDashboardFilterService),
        ChangeNotifierProvider.value(value: _ownerDashboardAppearanceService),
        ChangeNotifierProvider.value(value: _firebaseCostOptimizerService),
        ChangeNotifierProvider.value(value: _ownerMonitoringSettingsService),
        ChangeNotifierProvider.value(value: _organizationService),
        ChangeNotifierProvider.value(value: _tenantContextService),
        ChangeNotifierProvider.value(value: _organizationBillingService),
      ],
      child: Consumer2<LocaleService, ThemeService>(
        builder: (context, localeService, themeService, _) {
          return MaterialApp.router(
            title: 'Tabib',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeService.themeMode,
            locale: localeService.locale,
            supportedLocales: LocaleService.supportedLocales,
            localizationsDelegates: TabibApp.localizationsDelegates,
            localeResolutionCallback: (locale, supported) {
              if (locale == null) return const Locale('ku');
              for (final l in supported) {
                if (l.languageCode == locale.languageCode) return l;
              }
              return const Locale('ku');
            },
            routerConfig: _router,
            builder: (context, child) {
              return Directionality(
                textDirection:
                    localeService.isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: Column(
                  children: [
                    if (_demoMode) const DemoModeBanner(),
                    Expanded(
                      child: MaintenanceModeGate(
                        child: child ??
                            const ColoredBox(
                              color: AppTheme.medicalWhite,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.medicalBlue,
                                ),
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
