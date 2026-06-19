import 'package:flutter/foundation.dart';

import '../models/clinic.dart';
import '../models/doctor.dart';
import '../models/specialty.dart';
import 'backend/clinic_backend.dart';

class ClinicDataService extends ChangeNotifier {
  ClinicDataService({required ClinicBackend backend}) : _backend = backend {
    _backend.watchSpecialties().listen((data) {
      _specialties = data;
      notifyListeners();
    });
    _backend.watchClinics().listen((data) {
      _clinics = data;
      notifyListeners();
    });
    _backend.watchDoctors().listen((data) {
      _doctors = data;
      notifyListeners();
    });
  }

  final ClinicBackend _backend;

  List<Specialty> _specialties = [];
  List<Clinic> _clinics = [];
  List<Doctor> _doctors = [];

  List<Specialty> get specialties => List.unmodifiable(_specialties);
  List<Clinic> get clinics => List.unmodifiable(_clinics);
  List<Doctor> get doctors => List.unmodifiable(_doctors);

  ClinicBackend get backend => _backend;

  List<Doctor> doctorsBySpecialty(String specialtyId) =>
      _doctors.where((d) => d.specialtyId == specialtyId).toList();

  Doctor? doctorById(String id) {
    try {
      return _doctors.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  Clinic? clinicById(String id) {
    try {
      return _clinics.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
