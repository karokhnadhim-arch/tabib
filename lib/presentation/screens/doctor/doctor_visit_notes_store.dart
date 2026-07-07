import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/investigation_request_item.dart';
import '../../../models/prescription_line_item.dart';
import 'prescription/prescription_formatter.dart';

/// Local auto-save for in-visit clinical notes — doctor dashboard only.
class DoctorVisitNotes {
  const DoctorVisitNotes({
    this.diagnosis = '',
    this.medications = '',
    this.clinicalNotes = '',
    this.prescriptionItems = const [],
    this.investigationItems = const [],
    this.prescriptionSynced = false,
    this.investigationSynced = false,
    this.updatedAt,
  });

  final String diagnosis;
  final String medications;
  final String clinicalNotes;
  final List<PrescriptionLineItem> prescriptionItems;
  final List<InvestigationRequestItem> investigationItems;
  final bool prescriptionSynced;
  final bool investigationSynced;
  final DateTime? updatedAt;

  DoctorVisitNotes copyWith({
    String? diagnosis,
    String? medications,
    String? clinicalNotes,
    List<PrescriptionLineItem>? prescriptionItems,
    List<InvestigationRequestItem>? investigationItems,
    bool? prescriptionSynced,
    bool? investigationSynced,
    DateTime? updatedAt,
  }) {
    return DoctorVisitNotes(
      diagnosis: diagnosis ?? this.diagnosis,
      medications: medications ?? this.medications,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
      prescriptionItems: prescriptionItems ?? this.prescriptionItems,
      investigationItems: investigationItems ?? this.investigationItems,
      prescriptionSynced: prescriptionSynced ?? this.prescriptionSynced,
      investigationSynced: investigationSynced ?? this.investigationSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'diagnosis': diagnosis,
        'medications': medications,
        'clinicalNotes': clinicalNotes,
        'prescriptionItems':
            prescriptionItems.map((e) => e.toMap()).toList(),
        'investigationItems':
            investigationItems.map((e) => e.toMap()).toList(),
        'prescriptionSynced': prescriptionSynced,
        'investigationSynced': investigationSynced,
        'updatedAt': updatedAt?.toUtc().millisecondsSinceEpoch,
      };

  factory DoctorVisitNotes.fromJson(Map<String, dynamic> json) {
    final rawItems = json['prescriptionItems'];
    final items = rawItems is List
        ? PrescriptionFormatter.parseItems(rawItems)
        : const <PrescriptionLineItem>[];

    final invItems = json['investigationItems'];
    final investigations = invItems is List
        ? invItems
            .whereType<Map>()
            .map((e) =>
                InvestigationRequestItem.fromMap(Map<String, dynamic>.from(e)))
            .toList()
        : const <InvestigationRequestItem>[];

    return DoctorVisitNotes(
      diagnosis: json['diagnosis'] as String? ?? '',
      medications: json['medications'] as String? ?? '',
      clinicalNotes: json['clinicalNotes'] as String? ?? '',
      prescriptionItems: items,
      investigationItems: investigations,
      prescriptionSynced: json['prescriptionSynced'] as bool? ?? false,
      investigationSynced: json['investigationSynced'] as bool? ?? false,
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['updatedAt'] as num).toInt(),
              isUtc: true,
            ).toLocal()
          : null,
    );
  }

  bool get canSyncPrescription =>
      diagnosis.trim().isNotEmpty &&
      (prescriptionItems.isNotEmpty || medications.trim().isNotEmpty);
}

class DoctorVisitNotesStore extends ChangeNotifier {
  DoctorVisitNotesStore();

  static const _prefix = 'doctor_visit_notes_v1_';

  final Map<String, DoctorVisitNotes> _cache = {};
  final Map<String, Timer> _debouncers = {};
  bool _loaded = false;

  DoctorVisitNotes notesFor(String storageKey) =>
      _cache[storageKey] ?? const DoctorVisitNotes();

  bool get isReady => _loaded;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
  }

  static String storageKey({
    required String doctorId,
    required String queueEntryId,
  }) =>
      '${doctorId}_$queueEntryId';

  Future<void> load(String storageKey) async {
    if (_cache.containsKey(storageKey)) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$storageKey');
    if (raw == null) {
      _cache[storageKey] = const DoctorVisitNotes();
      return;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _cache[storageKey] = DoctorVisitNotes.fromJson(map);
    } catch (_) {
      _cache[storageKey] = const DoctorVisitNotes();
    }
  }

  void scheduleSave(
    String storageKey, {
    String? diagnosis,
    String? medications,
    String? clinicalNotes,
    List<PrescriptionLineItem>? prescriptionItems,
    List<InvestigationRequestItem>? investigationItems,
  }) {
    final current = _cache[storageKey] ?? const DoctorVisitNotes();
    final items = prescriptionItems ?? current.prescriptionItems;
    final investigations = investigationItems ?? current.investigationItems;
    final meds = medications ??
        (items.isNotEmpty
            ? PrescriptionFormatter.formatItems(items)
            : current.medications);

    final resetPrescriptionSync =
        (prescriptionItems != null &&
            !listEquals(prescriptionItems, current.prescriptionItems)) ||
        (diagnosis != null &&
            diagnosis.trim() != current.diagnosis.trim()) ||
        (medications != null &&
            medications.trim() != current.medications.trim());
    final resetInvestigationSync = investigationItems != null;

    _cache[storageKey] = current.copyWith(
      diagnosis: diagnosis ?? current.diagnosis,
      medications: meds,
      clinicalNotes: clinicalNotes ?? current.clinicalNotes,
      prescriptionItems: items,
      investigationItems: investigations,
      prescriptionSynced:
          resetPrescriptionSync ? false : current.prescriptionSynced,
      investigationSynced:
          resetInvestigationSync ? false : current.investigationSynced,
    );
    notifyListeners();

    _debouncers[storageKey]?.cancel();
    _debouncers[storageKey] = Timer(const Duration(milliseconds: 450), () {
      _persist(storageKey);
    });
  }

  /// Immediate disk persist — call before switching patients.
  Future<void> flushPersist(String storageKey) async {
    _debouncers[storageKey]?.cancel();
    _debouncers.remove(storageKey);
    await _persist(storageKey);
  }

  Future<void> markInvestigationSynced(String storageKey) async {
    final current = _cache[storageKey] ?? const DoctorVisitNotes();
    _cache[storageKey] = current.copyWith(
      investigationSynced: true,
      updatedAt: DateTime.now(),
    );
    await _persist(storageKey);
    notifyListeners();
  }

  Future<void> markPrescriptionSynced(String storageKey) async {
    final current = _cache[storageKey] ?? const DoctorVisitNotes();
    _cache[storageKey] = current.copyWith(
      prescriptionSynced: true,
      updatedAt: DateTime.now(),
    );
    await _persist(storageKey);
    notifyListeners();
  }

  Future<void> _persist(String storageKey) async {
    final notes = _cache[storageKey] ?? const DoctorVisitNotes();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prefix$storageKey',
      jsonEncode(notes.copyWith(updatedAt: DateTime.now()).toJson()),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    for (final timer in _debouncers.values) {
      timer.cancel();
    }
    _debouncers.clear();
    super.dispose();
  }
}
