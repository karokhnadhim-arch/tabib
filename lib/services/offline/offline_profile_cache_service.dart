import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/clinic.dart';
import '../../models/doctor.dart';
import '../../models/specialty.dart';

/// Cached doctor/business profiles for offline viewing (max 48 entries).
class OfflineProfileCacheService {
  static const _doctorPrefix = 'offline_doctor_v1_';
  static const _indexKey = 'offline_profile_index_v1';
  static const _maxDoctors = 48;

  Future<void> saveDoctor(Doctor doctor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_doctorPrefix${doctor.id}',
      jsonEncode({
        'doctor': doctor.toMap(),
        'specialtyId': doctor.specialtyId,
        'specialty': doctor.specialty.toMap(),
        'clinicId': doctor.clinicId,
        'clinic': doctor.clinic.toMap(),
      }),
    );
    await _touchIndex(doctor.id);
  }

  Future<Doctor?> getDoctor(String doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_doctorPrefix$doctorId');
    if (raw == null) return null;
    try {
      final wrapper = jsonDecode(raw) as Map<String, dynamic>;
      final specialtyId = wrapper['specialtyId'] as String? ?? '';
      final clinicId = wrapper['clinicId'] as String? ?? '';
      final specialty = Specialty.fromFirestore(
        specialtyId,
        wrapper['specialty'] as Map<String, dynamic>? ?? const {},
      );
      final clinic = Clinic.fromFirestore(
        clinicId,
        wrapper['clinic'] as Map<String, dynamic>? ?? const {},
      );
      return Doctor.fromMap(
        id: doctorId,
        data: wrapper['doctor'] as Map<String, dynamic>? ?? const {},
        specialty: specialty,
        clinic: clinic,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _touchIndex(String doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_indexKey) ?? [];
    ids.remove(doctorId);
    ids.insert(0, doctorId);
    if (ids.length > _maxDoctors) {
      final removed = ids.sublist(_maxDoctors);
      ids.removeRange(_maxDoctors, ids.length);
      for (final id in removed) {
        await prefs.remove('$_doctorPrefix$id');
      }
    }
    await prefs.setStringList(_indexKey, ids);
  }
}
