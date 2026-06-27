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
import 'services/appointment_service.dart';
import 'services/auth_service.dart';
import 'services/backend/clinic_backend.dart';
import 'services/backend/firestore_clinic_backend.dart';
import 'services/backend/in_memory_clinic_backend.dart';
import 'services/clinic_data_service.dart';
import 'services/firebase_bootstrap.dart';
import 'services/image_storage_service.dart';
import 'services/locale_service.dart';
import 'services/queue_service.dart';
import 'services/staff_data_service.dart';
import 'services/subscription_monitor_service.dart';

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
  late final AppointmentRepository _appointmentRepository;
  late final PrescriptionRepository _prescriptionRepository;
  late final NotificationRepository _notificationRepository;
  late final ChatRepository _chatRepository;
  late final AppointmentProvider _appointmentProvider;
  late final PrescriptionProvider _prescriptionProvider;
  late final NotificationProvider _notificationProvider;
  late final ChatProvider _chatProvider;
  late final SubscriptionMonitorService _subscriptionMonitor;
  late final ImageStorageService _imageStorage;
  late final GoRouter _router;

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
    _imageStorage = ImageStorageService(demoMode: _demoMode);
    _appointmentProvider = AppointmentProvider(repository: _appointmentRepository);
    _prescriptionProvider = PrescriptionProvider(repository: _prescriptionRepository);
    _notificationProvider = NotificationProvider(repository: _notificationRepository);
    _chatProvider = ChatProvider(repository: _chatRepository);
    _subscriptionMonitor = SubscriptionMonitorService(
      backend: _backend,
      catalog: _dataService,
      staffData: _staffDataService,
      notifications: _notificationRepository,
    )..start();
    _dataService.startRealtimeCatalog();
    _staffDataService.startRealtime();
    _router = AppRouter(
      authService: _authService,
      appReady: true,
    ).router;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ClinicBackend>.value(value: _backend),
        Provider<ImageStorageService>.value(value: _imageStorage),
        ChangeNotifierProvider.value(value: _authService),
        ChangeNotifierProvider.value(value: _dataService),
        ChangeNotifierProvider.value(value: _staffDataService),
        ChangeNotifierProvider.value(value: _queueService),
        ChangeNotifierProvider.value(value: _appointmentService),
        ChangeNotifierProvider.value(value: _localeService),
        ChangeNotifierProvider.value(value: _appointmentProvider),
        ChangeNotifierProvider.value(value: _prescriptionProvider),
        ChangeNotifierProvider.value(value: _notificationProvider),
        ChangeNotifierProvider.value(value: _chatProvider),
        ChangeNotifierProvider.value(value: _subscriptionMonitor),
      ],
      child: Consumer<LocaleService>(
        builder: (context, localeService, _) {
          return MaterialApp.router(
            title: 'Tabib',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
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
