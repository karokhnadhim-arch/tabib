import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabib/core/l10n/kurdish_material_localizations.dart';
import 'package:tabib/l10n/app_localizations.dart';
import 'package:tabib/presentation/screens/patient/patient_profile_screen.dart';
import 'package:tabib/services/advertisement_service.dart';
import 'package:tabib/services/auth_service.dart';
import 'package:tabib/services/backend/in_memory_clinic_backend.dart';
import 'package:tabib/services/locale_service.dart';
import 'package:tabib/services/patient_profile_service.dart';
import 'package:tabib/services/theme_service.dart';

void main() {
  late AuthService auth;
  late PatientProfileService profileService;
  late ThemeService themeService;
  late LocaleService localeService;
  late AdvertisementService adService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final backend = InMemoryClinicBackend();
    auth = AuthService(backend: backend, demoMode: true);
    await auth.loginPatient(
      name: 'Very Long Patient Name That Should Not Overflow',
      phone: '07501234567',
    );
    profileService = PatientProfileService();
    await profileService.bindUser(auth.patientId);
    themeService = ThemeService();
    localeService = LocaleService();
    adService = AdvertisementService(backend: backend);
  });

  Widget wrap(Widget child, {Locale? locale}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: auth),
        ChangeNotifierProvider<PatientProfileService>.value(
          value: profileService,
        ),
        ChangeNotifierProvider<ThemeService>.value(value: themeService),
        ChangeNotifierProvider<LocaleService>.value(value: localeService),
        ChangeNotifierProvider<AdvertisementService>.value(value: adService),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          KurdishMaterialLocalizationsDelegate(),
          KurdishWidgetsLocalizationsDelegate(),
          KurdishCupertinoLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  Future<void> pumpSized(
    WidgetTester tester,
    Size size,
    Widget child,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(child);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  const sizes = <Size>[
    Size(360, 800),
    Size(768, 1024),
    Size(1280, 800),
  ];

  for (final size in sizes) {
    testWidgets(
      'PatientProfileScreen embedded at ${size.width}x${size.height}',
      (tester) async {
        await pumpSized(
          tester,
          size,
          wrap(const PatientProfileScreen(embedded: true)),
        );
      },
    );

    testWidgets(
      'PatientProfileScreen standalone at ${size.width}x${size.height}',
      (tester) async {
        await pumpSized(
          tester,
          size,
          wrap(const PatientProfileScreen()),
        );
      },
    );
  }

  testWidgets('PatientProfileScreen embedded Kurdish RTL at 360px', (
    tester,
  ) async {
    await pumpSized(
      tester,
      const Size(360, 800),
      wrap(
        const PatientProfileScreen(embedded: true),
        locale: const Locale('ku'),
      ),
    );
  });
}
