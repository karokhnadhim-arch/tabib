import 'dart:async';

import '../../models/clinic.dart';
import '../../models/doctor.dart';
import '../../models/doctor_working_schedule.dart';
import '../../models/service_provider_type.dart';
import '../../models/localized_text.dart';
import '../../models/queue_entry.dart';
import '../../models/specialty.dart';
import '../../models/user_account.dart';
import '../../core/constants/firestore_limits.dart';
import '../../core/utils/staff_auth_identifiers.dart';
import '../../models/doctor_page.dart';
import 'clinic_backend.dart';

/// Local demo backend — works without Firebase.
class InMemoryClinicBackend implements ClinicBackend {
  InMemoryClinicBackend() {
    _seedDemoDataSync();
  }

  final _change = StreamController<void>.broadcast();
  final List<Specialty> _specialties = [];
  final List<Clinic> _clinics = [];
  final List<Doctor> _doctors = [];
  final List<QueueEntry> _queues = [];
  final List<UserAccount> _staff = [];
  final Map<String, String> _staffPasswords = {};

  void _notify() => _change.add(null);

  @override
  Stream<List<Specialty>> watchSpecialties() async* {
    yield List.unmodifiable(_specialties);
    await for (final _ in _change.stream) {
      yield List.unmodifiable(_specialties);
    }
  }

  @override
  Stream<List<Clinic>> watchClinics() async* {
    yield List.unmodifiable(_clinics);
    await for (final _ in _change.stream) {
      yield List.unmodifiable(_clinics);
    }
  }

  @override
  Stream<List<Doctor>> watchDoctors({
    String? specialtyId,
    String? clinicId,
  }) async* {
    yield _filteredDoctors(specialtyId, clinicId);
    await for (final _ in _change.stream) {
      yield _filteredDoctors(specialtyId, clinicId);
    }
  }

  List<Doctor> _filteredDoctors(
    String? specialtyId,
    String? clinicId, {
    ServiceProviderAccountType? accountType,
  }) {
    return _doctors.where((d) {
      if (accountType != null && d.accountType != accountType) return false;
      if (specialtyId != null && d.specialtyId != specialtyId) return false;
      if (clinicId != null && d.clinicId != clinicId) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
  }

  @override
  Future<List<Specialty>> fetchSpecialties() async =>
      List.unmodifiable(_specialties);

  @override
  Future<List<Clinic>> fetchClinics() async => List.unmodifiable(_clinics);

  @override
  Future<DoctorPage> fetchDoctorsPage({
    String? specialtyId,
    String? clinicId,
    ServiceProviderAccountType? accountType,
    int limit = FirestoreLimits.doctorsPageSize,
    Object? startAfterCursor,
  }) async {
    final all = _filteredDoctors(
      specialtyId,
      clinicId,
      accountType: accountType,
    );
    var startIndex = 0;
    if (startAfterCursor is int) startIndex = startAfterCursor;
    final end = (startIndex + limit).clamp(0, all.length);
    final slice = all.sublist(startIndex, end);
    return DoctorPage(
      doctors: slice,
      hasMore: end < all.length,
      nextCursor: end < all.length ? end : null,
    );
  }

  @override
  Stream<List<QueueEntry>> watchQueue(String doctorId) async* {
    yield _activeQueue(doctorId);
    await for (final _ in _change.stream) {
      yield _activeQueue(doctorId);
    }
  }

  @override
  Stream<List<QueueEntry>> watchSecretaryQueue(String doctorId) async* {
    yield _secretaryQueue(doctorId);
    await for (final _ in _change.stream) {
      yield _secretaryQueue(doctorId);
    }
  }

  List<QueueEntry> _secretaryQueue(String doctorId) {
    final entries = _queues
        .where((q) =>
            q.doctorId == doctorId &&
            (activeQueueStatuses.contains(q.status) ||
                q.isInExamination))
        .toList()
      ..sort((a, b) {
        final aExam = a.isInExamination;
        final bExam = b.isInExamination;
        if (aExam != bExam) return aExam ? 1 : -1;
        return a.position.compareTo(b.position);
      });
    return entries;
  }

  @override
  Stream<QueueEntry?> watchPatientActiveQueue(String patientId) async* {
    yield _queues
        .where((q) =>
            q.patientId == patientId &&
            (q.isActive || q.isInExamination))
        .firstOrNull;
    await for (final _ in _change.stream) {
      yield _queues
          .where((q) =>
              q.patientId == patientId &&
              (q.isActive || q.isInExamination))
          .firstOrNull;
    }
  }

  @override
  Future<Doctor?> getDoctor(String doctorId) async =>
      _doctors.where((d) => d.id == doctorId).firstOrNull;

  @override
  Future<Clinic?> getClinic(String clinicId) async =>
      _clinics.where((c) => c.id == clinicId).firstOrNull;

  @override
  Stream<Doctor?> watchDoctor(String doctorId) async* {
    Doctor? current = _doctors.where((d) => d.id == doctorId).firstOrNull;
    yield current;
    await for (final _ in _change.stream) {
      current = _doctors.where((d) => d.id == doctorId).firstOrNull;
      yield current;
    }
  }

  @override
  Future<List<UserAccount>> fetchStaff() async =>
      List.unmodifiable(_staff);

  @override
  Future<List<UserAccount>> fetchAllAccounts() async =>
      List.unmodifiable(_staff);

  @override
  Stream<List<UserAccount>> watchAllAccounts() async* {
    yield List.unmodifiable(_staff);
    await for (final _ in _change.stream) {
      yield List.unmodifiable(_staff);
    }
  }

  @override
  Future<List<UserAccount>> fetchSecretariesForDoctor(String doctorId) async {
    return _staff
        .where(
          (s) =>
              s.role == UserRole.secretary && s.linkedDoctorId == doctorId,
        )
        .toList();
  }

  @override
  Future<QueueEntry?> bookQueue({
    required String doctorId,
    required String patientId,
    required String patientName,
    required String patientPhone,
    required String queueDate,
    required String slotStart,
    required String slotEnd,
  }) async {
    final existing = _queues.where(
      (q) =>
          q.patientId == patientId &&
          activeQueueStatuses.contains(q.status),
    );
    if (existing.isNotEmpty) return null;

    final active = _activeQueue(
      doctorId,
      queueDate: queueDate,
      slotStart: slotStart,
    );
    final position = active.length + 1;
    final entry = QueueEntry(
      id: 'demo_queue_${_queues.length}',
      patientId: patientId,
      patientName: patientName,
      patientPhone: patientPhone,
      doctorId: doctorId,
      position: position,
      status: QueueStatus.waiting,
      bookedAt: DateTime.now(),
      estimatedWaitMinutes: (position - 1) * 15,
      queueDate: queueDate,
      slotStart: slotStart,
      slotEnd: slotEnd,
    );
    _queues.add(entry);
    _notify();
    return entry;
  }

  @override
  Future<void> cancelEntry(String entryId, String doctorId) async {
    final entry = _queues.where((q) => q.id == entryId).firstOrNull;
    if (entry == null) return;
    entry.status = QueueStatus.cancelled;
    _reindexDoctorQueue(
      doctorId,
      queueDate: entry.effectiveQueueDate,
      slotStart: entry.effectiveSlotStart,
    );
    _notify();
  }

  @override
  Future<void> moveUp(String entryId, String doctorId) async {
    await _swapEntry(entryId, doctorId, -1);
  }

  @override
  Future<void> moveDown(String entryId, String doctorId) async {
    await _swapEntry(entryId, doctorId, 1);
  }

  Future<void> _swapEntry(String entryId, String doctorId, int direction) async {
    final entry = _queues.where((q) => q.id == entryId).firstOrNull;
    if (entry == null) return;
    final entries = _activeQueue(
      doctorId,
      queueDate: entry.effectiveQueueDate,
      slotStart: entry.effectiveSlotStart,
    );
    final index = entries.indexWhere((e) => e.id == entryId);
    if (index == -1) return;
    final newIndex = index + direction;
    if (newIndex < 0 || newIndex >= entries.length) return;
    final posA = entries[index].position;
    final posB = entries[newIndex].position;
    entries[index].position = posB;
    entries[newIndex].position = posA;
    _notify();
  }

  @override
  Future<void> callNext(String doctorId) async {
    for (final e in _queues) {
      if (e.doctorId == doctorId && e.status == QueueStatus.inProgress) {
        e.status = QueueStatus.completed;
      }
    }
    final waiting = _activeQueue(doctorId)
        .where((e) => e.status == QueueStatus.waiting)
        .toList();
    if (waiting.isNotEmpty) {
      waiting.first.status = QueueStatus.inProgress;
    }
    _notify();
  }

  @override
  Future<void> completeCurrent(String doctorId) async {
    final current = _queues
        .where((q) =>
            q.doctorId == doctorId && q.status == QueueStatus.inProgress)
        .firstOrNull;
    if (current == null) return;
    current.status = QueueStatus.completed;
    _reindexDoctorQueue(
      doctorId,
      queueDate: current.effectiveQueueDate,
      slotStart: current.effectiveSlotStart,
    );
    _notify();
  }

  List<QueueEntry> _activeQueue(
    String doctorId, {
    String? queueDate,
    String? slotStart,
  }) {
    return _queues
        .where((q) =>
            q.doctorId == doctorId &&
            activeQueueStatuses.contains(q.status) &&
            (queueDate == null || q.effectiveQueueDate == queueDate) &&
            (slotStart == null || q.effectiveSlotStart == slotStart))
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  @override
  Future<void> updateEntryStatus(
    String entryId,
    String doctorId,
    QueueStatus status,
  ) async {
    final entry = _queues.where((q) => q.id == entryId).firstOrNull;
    if (entry == null || entry.doctorId != doctorId) return;
    entry.status = status;
    if (status == QueueStatus.completed ||
        status == QueueStatus.absent ||
        status == QueueStatus.cancelled ||
        status == QueueStatus.examination ||
        status == QueueStatus.sentForTests) {
      _reindexDoctorQueue(
        doctorId,
        queueDate: entry.effectiveQueueDate,
        slotStart: entry.effectiveSlotStart,
      );
    }
    _notify();
  }

  @override
  Future<void> enterDoctorRoom(String entryId, String doctorId) async {
    for (final e in _queues) {
      if (e.doctorId == doctorId && e.status == QueueStatus.inProgress) {
        e.status = QueueStatus.completed;
      }
    }
    final entry = _queues.where((q) => q.id == entryId).firstOrNull;
    if (entry == null || entry.doctorId != doctorId) return;
    entry.status = QueueStatus.inProgress;
    _notify();
  }

  @override
  Future<void> sendToExamination(String entryId, String doctorId) async {
    final entry = _queues.where((q) => q.id == entryId).firstOrNull;
    if (entry == null || entry.doctorId != doctorId) return;
    entry.status = QueueStatus.examination;
    _reindexDoctorQueue(
      doctorId,
      queueDate: entry.effectiveQueueDate,
      slotStart: entry.effectiveSlotStart,
    );
    _notify();
  }

  @override
  Future<void> returnToReview(String entryId, String doctorId) async {
    final entry = _queues.where((q) => q.id == entryId).firstOrNull;
    if (entry == null || entry.doctorId != doctorId || !entry.isInExamination) {
      return;
    }

    final active = _activeQueue(doctorId);
    final inProgress =
        active.where((e) => e.status == QueueStatus.inProgress).toList();
    final waiting = active
        .where((e) =>
            e.status == QueueStatus.waiting ||
            e.status == QueueStatus.review)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));

    entry.status = QueueStatus.review;
    final ordered = <QueueEntry>[...inProgress, entry, ...waiting];
    for (var i = 0; i < ordered.length; i++) {
      ordered[i].position = i + 1;
      ordered[i].estimatedWaitMinutes = i * 15;
    }
    _notify();
  }

  void _reindexDoctorQueue(
    String doctorId, {
    String? queueDate,
    String? slotStart,
  }) {
    final active = _activeQueue(
      doctorId,
      queueDate: queueDate,
      slotStart: slotStart,
    );
    for (var i = 0; i < active.length; i++) {
      active[i].position = i + 1;
      active[i].estimatedWaitMinutes = i * 15;
    }
  }

  @override
  Future<void> upsertSpecialty(Specialty specialty) async {
    _specialties.removeWhere((s) => s.id == specialty.id);
    _specialties.add(specialty);
    _notify();
  }

  @override
  Future<void> deleteSpecialty(String id) async {
    _specialties.removeWhere((s) => s.id == id);
    _notify();
  }

  @override
  Future<void> upsertClinic(Clinic clinic) async {
    _clinics.removeWhere((c) => c.id == clinic.id);
    _clinics.add(clinic);
    _notify();
  }

  @override
  Future<void> deleteClinic(String id) async {
    _clinics.removeWhere((c) => c.id == id);
    _notify();
  }

  @override
  Future<void> upsertDoctor(Doctor doctor) async {
    _doctors.removeWhere((d) => d.id == doctor.id);
    _doctors.add(doctor);
    _notify();
  }

  @override
  Future<void> deleteDoctor(String id) async {
    _doctors.removeWhere((d) => d.id == id);
    _notify();
  }

  void _upsertStaffSync(UserAccount account, {String? password, String? authEmail}) {
    _staff.removeWhere((s) => s.id == account.id);
    _staff.add(account);
    if (password != null) {
      final loginKey = authEmail?.toLowerCase() ??
          (account.email != null && account.email!.isNotEmpty
              ? account.email!.toLowerCase()
              : account.phone != null
                  ? StaffAuthIdentifiers.phoneToAuthEmail(account.phone!)
                  : null);
      if (loginKey != null) {
        _staffPasswords[loginKey] = password;
      }
    }
  }

  @override
  Future<void> upsertStaff(
    UserAccount account, {
    String? password,
    String? authEmail,
  }) async {
    _upsertStaffSync(account, password: password, authEmail: authEmail);
    _notify();
  }

  @override
  Future<void> deleteStaff(String id) async {
    final account = _staff.where((s) => s.id == id).firstOrNull;
    if (account != null) {
      if (account.email != null && account.email!.isNotEmpty) {
        _staffPasswords.remove(account.email!.toLowerCase());
      }
      if (account.phone != null && account.phone!.isNotEmpty) {
        _staffPasswords.remove(
          StaffAuthIdentifiers.phoneToAuthEmail(account.phone!),
        );
      }
    }
    _staff.removeWhere((s) => s.id == id);
    _notify();
  }

  @override
  Stream<List<UserAccount>> watchStaff() async* {
    yield List.unmodifiable(_staff);
    await for (final _ in _change.stream) {
      yield List.unmodifiable(_staff);
    }
  }

  @override
  Future<UserAccount?> lookupStaffCredentials(
    String identifier,
    String password,
  ) async {
    final authEmail = StaffAuthIdentifiers.resolveAuthEmail(identifier);
    if (_staffPasswords[authEmail.toLowerCase()] != password) return null;

    final kind = StaffAuthIdentifiers.detectLoginKind(identifier);
    if (kind == StaffLoginKind.email) {
      final key = identifier.trim().toLowerCase();
      return _staff.where((s) => s.email?.toLowerCase() == key).firstOrNull;
    }
    if (kind == StaffLoginKind.phone) {
      final phone = StaffAuthIdentifiers.normalizePhone(identifier);
      return _staff
          .where(
            (s) =>
                s.phone != null &&
                StaffAuthIdentifiers.normalizePhone(s.phone!) == phone,
          )
          .firstOrNull;
    }
    return null;
  }

  @override
  Future<void> seedDemoData() async {
    _seedDemoDataSync();
  }

  void _seedDemoDataSync() {
    _specialties.clear();
    _clinics.clear();
    _doctors.clear();
    _staff.clear();
    _staffPasswords.clear();

    const specialties = [
      Specialty(
        id: 'general',
        name: LocalizedText(ku: 'پزیشکی گشتی', ar: 'طب عام', en: 'General'),
        iconName: 'medical',
      ),
      Specialty(
        id: 'dental',
        name: LocalizedText(ku: 'ددان', ar: 'أسنان', en: 'Dental'),
        iconName: 'dental',
      ),
      Specialty(
        id: 'ortho',
        name: LocalizedText(ku: 'ئێسک و جومگە', ar: 'عظام', en: 'Orthopedics'),
        iconName: 'ortho',
      ),
      Specialty(
        id: 'eye',
        name: LocalizedText(ku: 'چاو', ar: 'عيون', en: 'Eye care'),
        iconName: 'eye',
      ),
      Specialty(
        id: 'healthcare_services',
        name: LocalizedText(
          ku: 'خزمەتگوزاری تەندروستی',
          ar: 'خدمات صحية',
          en: 'Healthcare services',
        ),
        iconName: 'medical',
      ),
    ];
    _specialties.addAll(specialties);

    const clinic = Clinic(
      id: 'clinic_erbil_1',
      name: LocalizedText(
        ku: 'نۆرینگەی شەفا',
        ar: 'عيادة الشفاء',
        en: 'Shafa Clinic',
      ),
      address: LocalizedText(
        ku: 'هەولێر، شەقامی 100 مەتری',
        ar: 'أربيل، شارع 100 متر',
        en: 'Erbil, 100m Street',
      ),
      latitude: 36.1911,
      longitude: 44.0092,
      phone: '07501234567',
      subscriptionPlan: SubscriptionPlan.oneMonth,
      subscriptionActive: true,
      subscriptionStartedAt: null,
      subscriptionExpiresAt: null,
    );
    final seededClinic = clinic.copyWith(
      subscriptionStartedAt: DateTime.now().subtract(const Duration(days: 10)),
      subscriptionExpiresAt: DateTime.now().add(const Duration(days: 20)),
    );
    _clinics.add(seededClinic);

    _doctors.add(
      Doctor(
        id: 'doc_1',
        name: const LocalizedText(
          ku: 'د. ئاراس محەمەد',
          ar: 'د. أراس محمد',
          en: 'Dr. Aras Mohammed',
        ),
        specialtyId: 'general',
        specialty: specialties[0],
        clinicId: seededClinic.id,
        clinic: seededClinic,
        rating: 4.8,
        experienceYears: 12,
        bio: const LocalizedText(
          ku:
              'پزیشکی گشتی بە ئەزموونی ١٢ ساڵ. تایبەتمەند لە چارەسەری نەخۆشییە درێژخایەنەکان، پشکنینی گشتی، و چاودێری تەندروستی خێزان.',
          ar:
              'طبيب عام بخبرة 12 سنة. متخصص في علاج الأمراض المزمنة، الفحوصات الدورية، ورعاية صحة الأسرة.',
          en:
              'General practitioner with 12 years of experience. Specializes in chronic disease management, preventive check-ups, and family health care.',
        ),
        isAvailableToday: true,
        photoUrl: 'https://i.pravatar.cc/300?u=doc_1',
        academicDegree: const LocalizedText(
          ku: 'دکتۆرا لە پزیشکی – زانکۆی هەولێر',
          ar: 'دكتوراه في الطب – جامعة أربيل',
          en: 'MD – University of Erbil',
        ),
        clinicName: seededClinic.name,
        contactPhone: '07501234567',
        whatsappNumber: '07501234567',
        contactEmail: 'doctor@tabib.demo',
        workingDays: const [
          DateTime.saturday,
          DateTime.sunday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
        ],
        workingSchedule: DoctorWorkingSchedule.demoSchedule(),
        languagesSpoken: const ['Kurdish', 'Arabic', 'English'],
        latitude: seededClinic.latitude,
        longitude: seededClinic.longitude,
      ),
    );

    _upsertStaffSync(
      const UserAccount(
        id: 'demo_admin',
        name: LocalizedText(
          ku: 'د. بەڕێوەبەر',
          ar: 'د. المدير',
          en: 'Dr. Owner',
        ),
        role: UserRole.doctor,
        email: 'admin@tabib.demo',
        doctorId: 'doc_1',
        clinicId: 'clinic_erbil_1',
        isSystemOwner: true,
      ),
      password: 'demo123',
    );

    _upsertStaffSync(
      const UserAccount(
        id: 'demo_doctor',
        name: LocalizedText(
          ku: 'د. ئاراس محەمەد',
          ar: 'د. أراس محمد',
          en: 'Dr. Aras Mohammed',
        ),
        role: UserRole.doctor,
        email: 'doctor@tabib.demo',
        doctorId: 'doc_1',
        clinicId: 'clinic_erbil_1',
      ),
      password: 'demo123',
    );

    _upsertStaffSync(
      const UserAccount(
        id: 'demo_secretary',
        name: LocalizedText(
          ku: 'سکرتێر',
          ar: 'سكرتير',
          en: 'Secretary',
        ),
        role: UserRole.secretary,
        email: 'secretary@tabib.demo',
        clinicId: 'clinic_erbil_1',
        linkedDoctorId: 'doc_1',
      ),
      password: 'demo123',
    );

    _upsertStaffSync(
      const UserAccount(
        id: 'demo_business',
        name: LocalizedText(
          ku: 'سەنتەری جوانکاری ڕۆژ',
          ar: 'مركز روز للتجميل',
          en: 'Roz Beauty Center',
        ),
        role: UserRole.doctor,
        email: 'business@tabib.demo',
        doctorId: 'biz_1',
        clinicId: 'clinic_erbil_1',
      ),
      password: 'demo123',
    );

    _doctors.add(
      Doctor(
        id: 'doc_2',
        name: const LocalizedText(
          ku: 'د. سارا ئەحمەد',
          ar: 'د. سارة أحمد',
          en: 'Dr. Sara Ahmed',
        ),
        specialtyId: 'dental',
        specialty: specialties[1],
        clinicId: seededClinic.id,
        clinic: seededClinic,
        rating: 4.6,
        experienceYears: 8,
        bio: const LocalizedText(
          ku:
              'پزیشکی ددان بە ئەزموونی ٨ ساڵ. تایبەتمەند لە چارەسەری ددان، ڕاستکردنەوە، و جوانکاری ددان.',
          ar:
              'طبيبة أسنان بخبرة 8 سنوات. متخصصة في علاج الأسنان، التقويم، وتجميل الابتسامة.',
          en:
              'Dentist with 8 years of experience. Specializes in restorative dentistry, orthodontics, and cosmetic smile design.',
        ),
        isAvailableToday: true,
        photoUrl: 'https://i.pravatar.cc/300?u=doc_2',
        academicDegree: const LocalizedText(
          ku: 'ماستەر لە پزیشکی ددان',
          ar: 'ماجستير في طب الأسنان',
          en: 'MSc in Dentistry',
        ),
        clinicName: const LocalizedText(
          ku: 'نۆرینگەی ددانی سارا',
          ar: 'عيادة سارة للأسنان',
          en: 'Sara Dental Clinic',
        ),
        clinicAddress: const LocalizedText(
          ku: 'هەولێر، شەقامی 60 مەتری',
          ar: 'أربيل، شارع 60 متر',
          en: 'Erbil, 60m Street',
        ),
        contactPhone: '07507654321',
        whatsappNumber: '07507654321',
        contactEmail: 'sara@tabib.demo',
        workingDays: const [
          DateTime.sunday,
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
        ],
        workingSchedule: DoctorWorkingSchedule.fromLegacy(
          workingDays: const [
            DateTime.sunday,
            DateTime.monday,
            DateTime.tuesday,
            DateTime.wednesday,
            DateTime.thursday,
          ],
        ).days,
        languagesSpoken: const ['Kurdish', 'Arabic'],
        latitude: 36.1920,
        longitude: 44.0100,
      ),
    );

    _doctors.add(
      Doctor(
        id: 'doc_3',
        name: const LocalizedText(
          ku: 'د. کەریم ڕەشید',
          ar: 'د. كريم رشيد',
          en: 'Dr. Karim Rashid',
        ),
        specialtyId: 'ortho',
        specialty: specialties[2],
        clinicId: seededClinic.id,
        clinic: seededClinic,
        rating: 4.9,
        experienceYears: 15,
        bio: const LocalizedText(
          ku:
              'پزیشکی ئێسک و جومگە بە ئەزموونی ١٥ ساڵ. چارەسەری شکاندن، گەڕاندنەوەی جومگە، و نەخۆشییەکانی پشت.',
          ar:
              'جراح عظام بخبرة 15 سنة. علاج الكسور، إعادة تأهيل المفاصل، واضطرابات العمود الفقري.',
          en:
              'Orthopedic surgeon with 15 years of experience. Treats fractures, joint rehabilitation, and spinal conditions.',
        ),
        isAvailableToday: false,
        photoUrl: 'https://i.pravatar.cc/300?u=doc_3',
        academicDegree: const LocalizedText(
          ku: 'پسپۆڕی ئێسک و جومگە – ئەلمانیا',
          ar: 'اختصاص عظام – ألمانيا',
          en: 'Orthopedics Fellowship – Germany',
        ),
        clinicName: const LocalizedText(
          ku: 'نۆرینگەی ئێسک و جومگە',
          ar: 'عيادة العظام',
          en: 'Orthopedic Center',
        ),
        clinicAddress: const LocalizedText(
          ku: 'هەولێر، شەقامی 40 مەتری',
          ar: 'أربيل، شارع 40 متر',
          en: 'Erbil, 40m Street',
        ),
        contactPhone: '07501112233',
        whatsappNumber: '07501112233',
        contactEmail: 'karim@tabib.demo',
        workingDays: const [
          DateTime.saturday,
          DateTime.monday,
          DateTime.wednesday,
        ],
        workingSchedule: DoctorWorkingSchedule.fromLegacy(
          workingDays: const [
            DateTime.saturday,
            DateTime.monday,
            DateTime.wednesday,
          ],
        ).days,
        languagesSpoken: const ['Kurdish', 'Arabic', 'English', 'German'],
        latitude: 36.1905,
        longitude: 44.0085,
      ),
    );

    _doctors.add(
      Doctor(
        id: 'biz_1',
        name: const LocalizedText(
          ku: 'سەنتەری جوانکاری ڕۆژ',
          ar: 'مركز روز للتجميل',
          en: 'Roz Beauty Center',
        ),
        specialtyId: 'healthcare_services',
        specialty: specialties[4],
        clinicId: seededClinic.id,
        clinic: seededClinic,
        rating: 4.6,
        experienceYears: 0,
        bio: const LocalizedText(
          ku:
              'خزمەتگوزاری جوانکاری و چاودێری پێست. نۆرەیەک بۆ هەموو خزمەتگوزارییەکان.',
          ar:
              'خدمات التجميل والعناية بالبشرة. احجز موعداً لجميع الخدمات.',
          en:
              'Beauty and skincare services. Book an appointment for all treatments.',
        ),
        isAvailableToday: true,
        photoUrl: 'https://i.pravatar.cc/300?u=biz_1',
        clinicName: const LocalizedText(
          ku: 'سەنتەری جوانکاری ڕۆژ',
          ar: 'مركز روز للتجميل',
          en: 'Roz Beauty Center',
        ),
        contactPhone: '07505556677',
        whatsappNumber: '07505556677',
        contactEmail: 'beauty@tabib.demo',
        workingSchedule: DoctorWorkingSchedule.demoSchedule(),
        languagesSpoken: const ['Kurdish', 'Arabic', 'English'],
        latitude: seededClinic.latitude,
        longitude: seededClinic.longitude,
        accountType: ServiceProviderAccountType.business,
        businessCategory: BusinessCategory.beautyCenter,
      ),
    );

    _notify();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
