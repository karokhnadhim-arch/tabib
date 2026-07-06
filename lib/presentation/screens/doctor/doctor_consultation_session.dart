import 'dart:async';

import 'package:flutter/material.dart';

import 'doctor_visit_notes_store.dart';

/// Per-patient text controllers — preserved when switching queue patients.
class DoctorConsultationSession extends ChangeNotifier {
  DoctorConsultationSession(this.notesStore);

  final DoctorVisitNotesStore notesStore;
  final Map<String, DoctorConsultationControllers> _controllers = {};
  Timer? _prescriptionDebounce;
  String? _activeKey;

  String? get activeKey => _activeKey;

  DoctorConsultationControllers controllersFor(String storageKey) {
    return _controllers.putIfAbsent(storageKey, DoctorConsultationControllers.new);
  }

  Future<void> activate(String storageKey) async {
    await notesStore.load(storageKey);
    final bundle = controllersFor(storageKey);
    if (!bundle.initialized) {
      final notes = notesStore.notesFor(storageKey);
      bundle.diagnosis.text = notes.diagnosis;
      bundle.medications.text = notes.medications;
      bundle.clinicalNotes.text = notes.clinicalNotes;
      bundle.initialized = true;
    }
    _activeKey = storageKey;
    notifyListeners();
  }

  Future<void> switchPatient({
    required String? fromKey,
    required String toKey,
  }) async {
    if (fromKey != null && fromKey != toKey) {
      _syncToStore(fromKey);
      await notesStore.flushPersist(fromKey);
      _prescriptionDebounce?.cancel();
    }
    await activate(toKey);
  }

  void _syncToStore(String storageKey) {
    final bundle = _controllers[storageKey];
    if (bundle == null) return;
    notesStore.scheduleSave(
      storageKey,
      diagnosis: bundle.diagnosis.text,
      medications: bundle.medications.text,
      clinicalNotes: bundle.clinicalNotes.text,
    );
  }

  void onFieldChanged(String storageKey) {
    _syncToStore(storageKey);
    _prescriptionDebounce?.cancel();
    _prescriptionDebounce = Timer(const Duration(seconds: 2), () {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _prescriptionDebounce?.cancel();
    for (final bundle in _controllers.values) {
      bundle.dispose();
    }
    _controllers.clear();
    super.dispose();
  }
}

class DoctorConsultationControllers {
  DoctorConsultationControllers();

  bool initialized = false;
  final diagnosis = TextEditingController();
  final medications = TextEditingController();
  final clinicalNotes = TextEditingController();

  void dispose() {
    diagnosis.dispose();
    medications.dispose();
    clinicalNotes.dispose();
  }
}

/// Which consultation block is expanded — only one at a time.
enum ConsultationFocusSection {
  medicalHistory,
  diagnosis,
  prescription,
  clinicalNotes,
}
