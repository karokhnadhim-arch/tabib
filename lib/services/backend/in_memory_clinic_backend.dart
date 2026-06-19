import 'dart:async';

import '../../models/clinic.dart';
import '../../models/doctor.dart';
import '../../models/localized_text.dart';
import '../../models/queue_entry.dart';
import '../../models/specialty.dart';
import '../../models/user_account.dart';
import 'clinic_backend.dart';

/// Local demo backend — works without Firebase.
class InMemoryClinicBackend implements ClinicBackend {
  InMemoryClinicBackend() {
    seedDemoData();
  }

  final _change = StreamController<void>.broadcast();
  final List<Specialty> _specialties = [];
  final List<Clinic> _clinics = [];
  final List<Doctor> _doctors = [];
  final List<QueueEntry> _queues = [];

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

  List<Doctor> _filteredDoctors(String? specialtyId, String? clinicId) {
    return _doctors.where((d) {
      if (specialtyId != null && d.specialtyId != specialtyId) return false;
      if (clinicId != null && d.clinicId != clinicId) return false;
      return true;
    }).toList();
  }

  @override
  Stream<List<QueueEntry>> watchQueue(String doctorId) async* {
    yield _queues.where((q) => q.doctorId == doctorId).toList();
    await for (final _ in _change.stream) {
      yield _queues.where((q) => q.doctorId == doctorId).toList();
    }
  }

  @override
  Stream<QueueEntry?> watchPatientActiveQueue(String patientId) async* {
    yield _queues
        .where((q) => q.patientId == patientId && q.isActive)
        .firstOrNull;
    await for (final _ in _change.stream) {
      yield _queues
          .where((q) => q.patientId == patientId && q.isActive)
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
  Future<QueueEntry?> bookQueue({
    required String doctorId,
    required String patientId,
    required String patientName,
    required String patientPhone,
  }) async {
    final existing = _queues.where(
      (q) =>
          q.patientId == patientId &&
          (q.status == QueueStatus.waiting || q.status == QueueStatus.inProgress),
    );
    if (existing.isNotEmpty) return null;

    final active = _queues
        .where((q) =>
            q.doctorId == doctorId &&
            (q.status == QueueStatus.waiting ||
                q.status == QueueStatus.inProgress))
        .toList();
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
    _reindexDoctorQueue(doctorId);
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
    final entries = _activeQueue(doctorId);
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
    _reindexDoctorQueue(doctorId);
    _notify();
  }

  List<QueueEntry> _activeQueue(String doctorId) {
    return _queues
        .where((q) =>
            q.doctorId == doctorId &&
            (q.status == QueueStatus.waiting ||
                q.status == QueueStatus.inProgress))
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  void _reindexDoctorQueue(String doctorId) {
    final active = _activeQueue(doctorId);
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

  @override
  Future<void> upsertStaff(UserAccount account, {String? password}) async {}

  @override
  Future<void> deleteStaff(String id) async {}

  @override
  Future<void> seedDemoData() async {
    _specialties.clear();
    _clinics.clear();
    _doctors.clear();

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
    );
    _clinics.add(clinic);

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
        clinicId: clinic.id,
        clinic: clinic,
        rating: 4.8,
        experienceYears: 12,
        bio: const LocalizedText(
          ku: 'پزیشکی گشتی',
          ar: 'طبيب عام',
          en: 'General practitioner',
        ),
        isAvailableToday: true,
      ),
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
        clinicId: clinic.id,
        clinic: clinic,
        rating: 4.6,
        experienceYears: 8,
        bio: const LocalizedText(
          ku: 'پزیشکی ددان',
          ar: 'طبيب أسنان',
          en: 'Dentist',
        ),
        isAvailableToday: true,
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
