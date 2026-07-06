import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/medicine_catalog.dart';
import '../models/medicine.dart';

/// Owner-managed medicine catalog — merges with built-in catalog for doctors.
class PlatformMedicineCatalogService extends ChangeNotifier {
  PlatformMedicineCatalogService({FirebaseFirestore? firestore, bool? useFirestore})
      : _db = firestore ?? FirebaseFirestore.instance,
        _useFirestore = useFirestore ?? false;

  final FirebaseFirestore _db;
  final bool _useFirestore;
  final List<Medicine> _custom = [];
  bool _loaded = false;

  List<Medicine> get customMedicines => List.unmodifiable(_custom);

  List<Medicine> get activeCustom =>
      _custom.where((m) => !m.archived).toList();

  /// Built-in + owner medicines for doctor search.
  List<Medicine> get allForSearch {
    final builtIn = MedicineCatalog.instance.all;
    final customActive = activeCustom;
    final ids = builtIn.map((m) => m.id).toSet();
    return [
      ...builtIn,
      ...customActive.where((m) => !ids.contains(m.id)),
    ];
  }

  Medicine? byId(String id) {
    for (final m in _custom) {
      if (m.id == id) return m;
    }
    return MedicineCatalog.instance.byId(id);
  }

  Future<void> load() async {
    if (_loaded) return;
    if (_useFirestore) {
      final snap = await _db.collection('platform_medicines').get();
      _custom
        ..clear()
        ..addAll(
          snap.docs.map((d) => Medicine.fromMap(d.id, d.data())),
        );
    } else {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _custom
          ..clear()
          ..addAll(
            list.map((e) {
              final map = Map<String, dynamic>.from(e as Map);
              final id = map.remove('id') as String;
              return Medicine.fromMap(id, map);
            }),
          );
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> upsert({
    String? id,
    required String genericName,
    required List<String> brandNames,
    required String strength,
    required String form,
    String? category,
  }) async {
    final medicineId = id ?? 'med_${const Uuid().v4()}';
    final medicine = Medicine(
      id: medicineId,
      genericName: genericName.trim(),
      brandNames: brandNames,
      strength: strength.trim(),
      form: form.trim(),
      category: category?.trim(),
      isCustom: true,
    );

    final index = _custom.indexWhere((m) => m.id == medicineId);
    if (index >= 0) {
      _custom[index] = medicine.copyWith(archived: _custom[index].archived);
    } else {
      _custom.add(medicine);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> setArchived(String id, bool archived) async {
    final index = _custom.indexWhere((m) => m.id == id);
    if (index < 0) return;
    _custom[index] = _custom[index].copyWith(archived: archived);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    if (_useFirestore) {
      final batch = _db.batch();
      for (final m in _custom) {
        batch.set(
          _db.collection('platform_medicines').doc(m.id),
          m.toMap(),
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    } else {
      final prefs = await SharedPreferences.getInstance();
      final encoded = _custom
          .map((m) => {'id': m.id, ...m.toMap()})
          .toList();
      await prefs.setString(_storageKey, jsonEncode(encoded));
    }
  }

  static const _storageKey = 'platform_medicines_v1';
}
