import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabib/l10n/app_localizations.dart';
import 'package:tabib/models/doctor.dart';
import 'package:tabib/models/localized_text.dart';
import 'package:tabib/models/queue_entry.dart';
import 'package:tabib/presentation/widgets/patient_active_queue_card.dart';
import 'package:tabib/services/backend/in_memory_clinic_backend.dart';
import 'package:tabib/services/favorites_service.dart';
import 'package:tabib/services/queue_service.dart';

void main() {
  late QueueService queueService;
  late FavoritesService favoritesService;
  late Doctor doctor;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final backend = InMemoryClinicBackend();
    queueService = QueueService(backend: backend);
    favoritesService = FavoritesService();
    final seeded = await backend.getDoctor('doc_1');
    doctor = seeded!.copyWith(
      name: const LocalizedText(
        ku: 'دکتۆری ناوی زۆر درێژ بۆ تاقیکردنەوە',
        ar: 'طبيب باسم طويل جدا للاختبار',
        en: 'Very Long Doctor Name For Overflow Testing',
      ),
      clinicName: const LocalizedText(
        ku: 'نەخۆشخانەی گشتی هەولێر',
        ar: 'مستشفى أربيل العام',
        en: 'Erbil General Hospital With A Very Long Name',
      ),
    );
  });

  final entry = QueueEntry(
    id: 'q1',
    patientId: 'p1',
    patientName: 'Patient',
    patientPhone: '07501234567',
    doctorId: 'doc_1',
    position: 12,
    status: QueueStatus.waiting,
    bookedAt: DateTime(2026, 6, 27, 10, 30),
    queueDate: '2026-06-27',
    slotStart: '10:30',
    slotEnd: '11:00',
  );

  Future<void> pumpSized(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<QueueService>.value(value: queueService),
          ChangeNotifierProvider<FavoritesService>.value(
            value: favoritesService,
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: PatientActiveQueueCard(
                entry: entry,
                doctor: doctor,
                queueService: queueService,
              ),
            ),
          ),
        ),
      ),
    );
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
      'PatientActiveQueueCard at ${size.width}x${size.height}',
      (tester) async {
        await pumpSized(tester, size);
      },
    );
  }
}
