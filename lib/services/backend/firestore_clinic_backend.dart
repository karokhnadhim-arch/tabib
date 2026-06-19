import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/clinic.dart';
import '../../models/doctor.dart';
import '../../models/localized_text.dart';
import '../../models/queue_entry.dart';
import '../../models/specialty.dart';
import '../../models/user_account.dart';
import 'clinic_backend.dart';

class FirestoreClinicBackend implements ClinicBackend {
  FirestoreClinicBackend({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

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

  @override
  Stream<List<Doctor>> watchDoctors({String? specialtyId, String? clinicId}) {
    return _doctors.snapshots().asyncMap((snap) async {
      final clinics = await _clinics.get();
      final specialties = await _specialties.get();
      final clinicMap = {
        for (final d in clinics.docs)
          d.id: Clinic.fromFirestore(d.id, d.data()),
      };
      final specialtyMap = {
        for (final d in specialties.docs)
          d.id: Specialty.fromFirestore(d.id, d.data()),
      };

      var docs = snap.docs;
      if (specialtyId != null) {
        docs = docs.where((d) => d.data()['specialtyId'] == specialtyId).toList();
      }
      if (clinicId != null) {
        docs = docs.where((d) => d.data()['clinicId'] == clinicId).toList();
      }

      return docs.map((d) {
        final data = d.data();
        final specId = data['specialtyId'] as String? ?? '';
        final clinId = data['clinicId'] as String? ?? '';
        final specialty = specialtyMap[specId] ??
            Specialty(
              id: specId,
              name: const LocalizedText(ku: '', ar: '', en: ''),
              iconName: 'medical',
            );
        final clinic = clinicMap[clinId] ??
            Clinic(
              id: clinId,
              name: const LocalizedText(ku: '', ar: '', en: ''),
              address: const LocalizedText(ku: '', ar: '', en: ''),
              latitude: 0,
              longitude: 0,
              phone: '',
            );
        return Doctor(
          id: d.id,
          name: LocalizedText.fromMap(data['name'] as Map<String, dynamic>?),
          specialtyId: specId,
          specialty: specialty,
          clinicId: clinId,
          clinic: clinic,
          rating: (data['rating'] as num?)?.toDouble() ?? 0,
          experienceYears: (data['experienceYears'] as num?)?.toInt() ?? 0,
          bio: LocalizedText.fromMap(data['bio'] as Map<String, dynamic>?),
          isAvailableToday: data['isAvailableToday'] as bool? ?? false,
        );
      }).toList();
    });
  }

  @override
  Stream<List<QueueEntry>> watchQueue(String doctorId) {
    return _queues
        .where('doctorId', isEqualTo: doctorId)
        .where('status', whereIn: ['waiting', 'inProgress'])
        .orderBy('position')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => QueueEntry.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Stream<QueueEntry?> watchPatientActiveQueue(String patientId) {
    return _queues
        .where('patientId', isEqualTo: patientId)
        .where('status', whereIn: ['waiting', 'inProgress'])
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
    if (!doc.exists) return null;
    final doctors = await watchDoctors().first;
    return doctors.where((d) => d.id == doctorId).firstOrNull;
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
        .where('status', whereIn: ['waiting', 'inProgress'])
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return null;

    final active = await _queues
        .where('doctorId', isEqualTo: doctorId)
        .where('status', whereIn: ['waiting', 'inProgress'])
        .get();

    final position = active.docs.length + 1;
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
        .where('status', whereIn: ['waiting', 'inProgress'])
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

  Future<void> _reindexDoctorQueue(String doctorId) async {
    final snap = await _queues
        .where('doctorId', isEqualTo: doctorId)
        .where('status', whereIn: ['waiting', 'inProgress'])
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
  }

  @override
  Future<void> deleteSpecialty(String id) async {
    await _specialties.doc(id).delete();
  }

  @override
  Future<void> upsertClinic(Clinic clinic) async {
    await _clinics.doc(clinic.id).set(clinic.toMap(), SetOptions(merge: true));
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
        ku: 'پزیشکی گشتی',
        ar: 'طبيب عام',
        en: 'General practitioner',
      ),
      isAvailableToday: true,
    );
    await upsertDoctor(doctor);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
