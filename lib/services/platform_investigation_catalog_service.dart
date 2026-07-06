import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/investigation_catalog.dart';
import '../models/investigation_catalog_item.dart';
import '../models/investigation_category.dart';

/// Owner-managed investigation catalog — merges with built-in for doctors.
class PlatformInvestigationCatalogService extends ChangeNotifier {
  PlatformInvestigationCatalogService({
    FirebaseFirestore? firestore,
    bool? useFirestore,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _useFirestore = useFirestore ?? false;

  final FirebaseFirestore _db;
  final bool _useFirestore;
  final List<InvestigationCatalogItem> _custom = [];
  bool _loaded = false;

  List<InvestigationCatalogItem> get customItems =>
      List.unmodifiable(_custom);

  List<InvestigationCatalogItem> get activeCustom =>
      _custom.where((i) => !i.archived).toList();

  List<InvestigationCatalogItem> get allForSearch {
    final builtIn = InvestigationCatalog.instance.all;
    final customActive = activeCustom;
    final ids = builtIn.map((i) => i.id).toSet();
    return [
      ...builtIn,
      ...customActive.where((i) => !ids.contains(i.id)),
    ];
  }

  Future<void> load() async {
    if (_loaded) return;
    if (_useFirestore) {
      final snap = await _db.collection('platform_investigations').get();
      _custom
        ..clear()
        ..addAll(
          snap.docs.map((d) => InvestigationCatalogItem.fromMap(d.id, d.data())),
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
              return InvestigationCatalogItem.fromMap(id, map);
            }),
          );
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> upsert({
    String? id,
    required String name,
    required InvestigationCategory category,
  }) async {
    final itemId = id ?? 'inv_${const Uuid().v4()}';
    final item = InvestigationCatalogItem(
      id: itemId,
      name: name.trim(),
      category: category,
      isCustom: true,
    );

    final index = _custom.indexWhere((i) => i.id == itemId);
    if (index >= 0) {
      _custom[index] = item.copyWith(archived: _custom[index].archived);
    } else {
      _custom.add(item);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> setArchived(String id, bool archived) async {
    final index = _custom.indexWhere((i) => i.id == id);
    if (index < 0) return;
    _custom[index] = _custom[index].copyWith(archived: archived);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    if (_useFirestore) {
      final batch = _db.batch();
      for (final item in _custom) {
        batch.set(
          _db.collection('platform_investigations').doc(item.id),
          item.toMap(),
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    } else {
      final prefs = await SharedPreferences.getInstance();
      final encoded = _custom
          .map((i) => {'id': i.id, ...i.toMap()})
          .toList();
      await prefs.setString(_storageKey, jsonEncode(encoded));
    }
  }

  static const _storageKey = 'platform_investigations_v1';
}
