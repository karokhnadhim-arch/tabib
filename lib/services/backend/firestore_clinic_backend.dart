import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/clinic.dart';
import '../../models/doctor.dart';
import '../../models/doctor_working_schedule.dart';
import '../../models/localized_text.dart';
import '../../models/queue_entry.dart';
import '../../models/specialty.dart';
import '../../models/user_account.dart';
import '../../core/constants/firestore_limits.dart';
import '../../models/doctor_page.dart';
import 'firestore_reference_cache.dart';
import 'clinic_backend.dart';

class FirestoreClinicBackend implements ClinicBackend {
  FirestoreClinicBackend({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirestoreReferenceCache _cache = FirestoreReferenceCache();

  CollectionReference<Map<String, dynamic>> get _specialties =>
      _db.collection('specialties');
  CollectionReference<Map<String, dynamic>> get _clinics =>
      _db.collection('clinics');
  CollectionReference<Map<String, dynamic>> get _doctors =>
      _db.collection('doctors');
  CollectionReference<Map<String, dynamic>> get _queues =>
      _db.collection('queue_entries');
  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  @override
  Stream<List<Specialty>> watchSpecialties() {
    return _specialties.snapshots().map(
          (snap) => snap.docs
              .map((d) => Specialty.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Stream<List<Clinic>> watchClinics() {
    return _clinics.snapshots().map(
          (snap) => snap.docs
              .map((d) => Clinic.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  Future<void> _ensureReferenceCache() async {
    if (!_cache.hasFreshSpecialties) {
      final snap = await _specialties.get();
      _cache.setSpecialties({
        for (final d in snap.docs)
          d.id: Specialty.fromFirestore(d.id, d.data()),
      });
    }
    if (!_cache.hasFreshClinics) {
      final snap = await _clinics.get();
      _cache.setClinics({
        for (final d in snap.docs)
          d.id: Clinic.fromFirestore(d.id, d.data()),
      });
    }
  }

  Doctor _doctorFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data();
    final specId = data['specialtyId'] as String? ?? '';
    final clinId = data['clinicId'] as String? ?? '';
    final specialty = _cache.specialties[specId] ??
        Specialty(
          id: specId,
          name: const LocalizedText(ku: '', ar: '', en: ''),
          iconName: 'medical',
        );
    final clinic = _cache.clinics[clinId] ??
        Clinic(
          id: clinId,
          name: const LocalizedText(ku: '', ar: '', en: ''),
          address: const LocalizedText(ku: '', ar: '', en: ''),
          latitude: 0,
          longitude: 0,
          phone: '',
        );
    return Doctor.fromMap(
      id: d.id,
      data: data,
      specialty: specialty,
      clinic: clinic,
    );
  }

  Query<Map<String, dynamic>> _doctorsQuery({
    String? specialtyId,
    String? clinicId,
  }) {
    Query<Map<String, dynamic>> query = _doctors.orderBy(FieldPath.documentId);
    if (specialtyId != null) {
      query = query.where('specialtyId', isEqualTo: specialtyId);
    }
    if (clinicId != null) {
      query = query.where('clinicId', isEqualTo: clinicId);
    }
    return query;
  }

  @override
  Future<List<Specialty>> fetchSpecialties() async {
    if (_cache.hasFreshSpecialties) {
      return _cache.specialties.values.toList();
    }
    final snap = await _specialties.get();
    final map = {
      for (final d in snap.docs)
        d.id: Specialty.fromFirestore(d.id, d.data()),
    };
    _cache.setSpecialties(map);
    return map.values.toList();
  }

  @override
  Future<List<Clinic>> fetchClinics() async {
    if (_cache.hasFreshClinics) {
      return _cache.clinics.values.toList();
    }
    final snap = await _clinics.get();
    final map = {
      for (final d in snap.docs) d.id: Clinic.fromFirestore(d.id, d.data()),
    };
    _cache.setClinics(map);
    return map.values.toList();
  }

  @override
  Future<DoctorPage> fetchDoctorsPage({
    String? specialtyId,
    String? clinicId,
    int limit = FirestoreLimits.doctorsPageSize,
    Object? startAfterCursor,
  }) async {
    await _ensureReferenceCache();
    var query = _doctorsQuery(
      specialtyId: specialtyId,
      clinicId: clinicId,
    ).limit(limit + 1);
    if (startAfterCursor is DocumentSnapshot<Map<String, dynamic>>) {
      query = query.startAfterDocument(startAfterCursor);
    }
    final snap = await query.get();
    final docs = snap.docs;
    final hasMore = docs.length > limit;
    final pageDocs = hasMore ? docs.sublist(0, limit) : docs;
    return DoctorPage(
      doctors: pageDocs.map(_doctorFromDoc).toList(),
      hasMore: hasMore,
      nextCursor: pageDocs.isEmpty ? null : pageDocs.last,
    );
  }

  @override
  Stream<List<Doctor>> watchDoctors({String? specialtyId, String? clinicId}) {
    return Stream.fromFuture(_ensureReferenceCache()).asyncExpand((_) {
      var query = _doctorsQuery(
        specialtyId: specialtyId,
        clinicId: clinicId,
      ).limit(FirestoreLimits.maxDoctorsCatalog);
      return query.snapshots().map(
            (snap) => snap.docs.map(_doctorFromDoc).toList(),
          );
    });
  }

  @override
  Stream<List<QueueEntry>> watchQueue(String doctorId) {
    return _queues
        .where('doctorId', isEqualTo: doctorId)
        .where('status', whereIn: activeQueueStatusNames)
        .orderBy('position')
        .limit(FirestoreLimits.queueActiveMax)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => QueueEntry.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Stream<List<QueueEntry>> watchSecretaryQueue(String doctorId) {
    return _queues
        .where('doctorId', isEqualTo: doctorId)
        .where('status', whereIn: secretaryQueueStatusNames)
        .orderBy('position')
        .limit(FirestoreLimits.queueActiveMax)
        .snapshots()
        .map((snap) {
      final entries = snap.docs
          .map((d) => QueueEntry.fromFirestore(d.id, d.data()))
          .toList();
      entries.sort((a, b) {
        final aExam = a.isInExamination;
        final bExam = b.isInExamination;
        if (aExam != bExam) return aExam ? 1 : -1;
        return a.position.compareTo(b.position);
      });
      return entries;
    });
  }

  @override
  Stream<QueueEntry?> watchPatientActiveQueue(String patientId) {
    return _queues
        .where('patientId', isEqualTo: patientId)
        .where('status', whereIn: patientVisibleQueueStatusNames)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final d = snap.docs.first;
      return QueueEntry.fromFirestore(d.id, d.data());
    });
  }

  @override
  Future<Doctor?> getDoctor(String doctorId) async {
    final doc = await _doctors.doc(doctorId).get();
    if (!doc.exists || doc.data() == null) return null;
    await _ensureReferenceCache();
    final data = doc.data()!;
    final specId = data['specialtyId'] as String? ?? '';
    final clinId = data['clinicId'] as String? ?? '';
    final specialty = _cache.specialties[specId] ??
        Specialty(
          id: specId,
          name: const LocalizedText(ku: '', ar: '', en: ''),
          iconName: 'medical',
        );
    final clinic = _cache.clinics[clinId] ??
        Clinic(
          id: clinId,
          name: const LocalizedText(ku: '', ar: '', en: ''),
          address: const LocalizedText(ku: '', ar: '', en: ''),
          latitude: 0,
          longitude: 0,
          phone: '',
        );
    return Doctor.fromMap(
      id: doc.id,
      data: data,
      specialty: specialty,
      clinic: clinic,
    );
  }

  @override
  Future<Clinic?> getClinic(String clinicId) async {
    final doc = await _clinics.doc(clinicId).get();
    if (!doc.exists) return null;
    return Clinic.fromFirestore(doc.id, doc.data()!);
  }

  @override
  Future<QueueEntry?> bookQueue({
    required String doctorId,
    required String patientId,
    required String patientName,
    required String patientPhone,
  }) async {
    final existing = await _queues
        .where('patientId', isEqualTo: patientId)
        .where('status', whereIn: activeQueueStatusNames)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return null;

    final active = await _queues
        .where('doctorId', isEqualTo: doctorId)
        .where('status', whereIn: activeQueueStatusNames)
        .orderBy('position', descending: true)
        .limit(1)
        .get();

    final position = active.docs.isEmpty
        ? 1
        : ((active.docs.first.data()['position'] as num?)?.toInt() ?? 0) + 1;
    final ref = _queues.doc();
    final entry = QueueEntry(
      id: ref.id,
      patientId: patientId,
      patientName: patientName,
      patientPhone: patientPhone,
      doctorId: doctorId,
      position: position,
      status: QueueStatus.waiting,
      bookedAt: DateTime.now(),
      estimatedWaitMinutes: (position - 1) * 15,
    );
    await ref.set(entry.toMap());
    return entry;
  }

  @override
  Future<void> cancelEntry(String entryId, String doctorId) async {
    await _queues.doc(entryId).update({'status': 'cancelled'});
    await _reindexDoctorQueue(doctorId);
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
    final snap = await _queues
        .where('doctorId', isEqualTo: doctorId)
        .where('status', whereIn: activeQueueStatusNames)
        .orderBy('position')
        .get();
    final entries = snap.docs;
    final index = entries.indexWhere((d) => d.id == entryId);
    if (index == -1) return;
    final newIndex = index + direction;
    if (newIndex < 0 || newIndex >= entries.length) return;

    final posA = entries[index].data()['position'] as int;
    final posB = entries[newIndex].data()['position'] as int;
    final batch = _db.batch();
    batch.update(entries[index].reference, {'position': posB});
    batch.update(entries[newIndex].reference, {'position': posA});
    await batch.commit();
  }

  @override
  Future<void> callNext(String doctorId) async {
    final snap = await _queues
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'inProgress')
        .get();
    final batch = _db.batch();
    for (final d in snap.docs) {
      batch.update(d.reference, {'status': 'completed'});
    }
    await batch.commit();

    final waiting = await _queues
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'waiting')
        .orderBy('position')
        .limit(1)
        .get();
    if (waiting.docs.isNotEmpty) {
      await waiting.docs.first.reference.update({'status': 'inProgress'});
    }
  }

  @override
  Future<void> completeCurrent(String doctorId) async {
    final snap = await _queues
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'inProgress')
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return;
    await snap.docs.first.reference.update({'status': 'completed'});
    await _reindexDoctorQueue(doctorId);
  }

  @override
  Future<void> updateEntryStatus(
    String entryId,
    String doctorId,
    QueueStatus status,
  ) async {
    await _queues.doc(entryId).update({'status': _persistStatus(status)});
    if (status == QueueStatus.completed ||
        status == QueueStatus.absent ||
        status == QueueStatus.cancelled ||
        status == QueueStatus.examination ||
        status == QueueStatus.sentForTests) {
      await _reindexDoctorQueue(doctorId);
    }
  }

  String _persistStatus(QueueStatus status) {
    switch (status) {
      case QueueStatus.examination:
      case QueueStatus.sentForTests:
        return 'examination';
      case QueueStatus.review:
      case QueueStatus.followUp:
        return 'review';
      default:
        return status.name;
    }
  }

  @override
  Future<void> enterDoctorRoom(String entryId, String doctorId) async {
    final inProgress = await _queues
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'inProgress')
        .get();
    final batch = _db.batch();
    for (final d in inProgress.docs) {
      batch.update(d.reference, {'status': QueueStatus.completed.name});
    }
    batch.update(_queues.doc(entryId), {'status': QueueStatus.inProgress.name});
    await batch.commit();
  }

  @override
  Future<void> sendToExamination(String entryId, String doctorId) async {
    await _queues.doc(entryId).update({'status': 'examination'});
    await _reindexDoctorQueue(doctorId);
  }

  @override
  Future<void> returnToReview(String entryId, String doctorId) async {
    final entryDoc = await _queues.doc(entryId).get();
    if (!entryDoc.exists) return;
    final entry = QueueEntry.fromFirestore(entryDoc.id, entryDoc.data()!);
    if (!entry.isInExamination) return;

    final snap = await _queues
        .where('doctorId', isEqualTo: doctorId)
        .where('status', whereIn: activeQueueStatusNames)
        .orderBy('position')
        .get();

    final active = snap.docs
        .map((d) => QueueEntry.fromFirestore(d.id, d.data()))
        .toList();
    final inProgress =
        active.where((e) => e.status == QueueStatus.inProgress).toList();
    final waiting = active
        .where((e) =>
            e.status == QueueStatus.waiting ||
            e.status == QueueStatus.review)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));

    final ordered = <QueueEntry>[...inProgress, entry, ...waiting];
    final batch = _db.batch();
    for (var i = 0; i < ordered.length; i++) {
      batch.update(_queues.doc(ordered[i].id), {
        'status': ordered[i].id == entryId ? 'review' : ordered[i].status.name,
        'position': i + 1,
        'estimatedWaitMinutes': i * 15,
      });
    }
    await batch.commit();
  }

  Future<void> _reindexDoctorQueue(String doctorId) async {
    final snap = await _queues
        .where('doctorId', isEqualTo: doctorId)
        .where('status', whereIn: activeQueueStatusNames)
        .orderBy('position')
        .get();
    final batch = _db.batch();
    for (var i = 0; i < snap.docs.length; i++) {
      batch.update(snap.docs[i].reference, {
        'position': i + 1,
        'estimatedWaitMinutes': i * 15,
      });
    }
    await batch.commit();
  }

  @override
  Future<void> upsertSpecialty(Specialty specialty) async {
    await _specialties.doc(specialty.id).set(specialty.toMap(), SetOptions(merge: true));
    _cache.upsertSpecialty(specialty);
  }

  @override
  Future<void> deleteSpecialty(String id) async {
    await _specialties.doc(id).delete();
  }

  @override
  Future<void> upsertClinic(Clinic clinic) async {
    await _clinics.doc(clinic.id).set(clinic.toMap(), SetOptions(merge: true));
    _cache.upsertClinic(clinic);
  }

  @override
  Future<void> deleteClinic(String id) async {
    await _clinics.doc(id).delete();
  }

  @override
  Future<void> upsertDoctor(Doctor doctor) async {
    await _doctors.doc(doctor.id).set(doctor.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteDoctor(String id) async {
    await _doctors.doc(id).delete();
  }

  @override
  Future<void> upsertStaff(UserAccount account, {String? password}) async {
    await _users.doc(account.id).set(account.toMap(), SetOptions(merge: true));
    if (password != null && account.email != null) {
      try {
        await _auth.createUserWithEmailAndPassword(
          email: account.email!,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code != 'email-already-in-use') rethrow;
      }
    }
  }

  @override
  Future<void> deleteStaff(String id) async {
    await _users.doc(id).delete();
  }

  @override
  Stream<List<UserAccount>> watchStaff() {
    return _users
        .where('role', whereIn: ['doctor', 'secretary', 'admin'])
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => UserAccount.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<UserAccount?> lookupStaffCredentials(
    String email,
    String password,
  ) async {
    return null;
  }

  @override
  Future<void> seedDemoData() async {
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

    for (final s in specialties) {
      await upsertSpecialty(s);
    }

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
    await upsertClinic(clinic);

    final doctor = Doctor(
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
        ku: 'پزیشکی گشتی بە ئەزموونی ١٢ ساڵ',
        ar: 'طبيب عام بخبرة 12 سنة',
        en: 'General practitioner with 12 years of experience',
      ),
      isAvailableToday: true,
      photoUrl: 'https://i.pravatar.cc/300?u=doc_1',
      academicDegree: const LocalizedText(
        ku: 'دکتۆرا لە پزیشکی',
        ar: 'دكتوراه في الطب',
        en: 'MD',
      ),
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
      latitude: clinic.latitude,
      longitude: clinic.longitude,
    );
    await upsertDoctor(doctor);
  }
}
