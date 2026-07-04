import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineRecentChatEntry {
  const OfflineRecentChatEntry({
    required this.clinicId,
    required this.patientId,
    required this.title,
    required this.openedAt,
  });

  final String clinicId;
  final String patientId;
  final String title;
  final DateTime openedAt;

  Map<String, dynamic> toMap() => {
        'clinicId': clinicId,
        'patientId': patientId,
        'title': title,
        'openedAt': openedAt.toUtc().millisecondsSinceEpoch,
      };

  factory OfflineRecentChatEntry.fromMap(Map<String, dynamic> data) {
    return OfflineRecentChatEntry(
      clinicId: data['clinicId'] as String? ?? '',
      patientId: data['patientId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      openedAt: DateTime.fromMillisecondsSinceEpoch(
        (data['openedAt'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}

/// Recently opened chat conversations (metadata only).
class OfflineRecentChatsService extends ChangeNotifier {
  static const _keyPrefix = 'offline_recent_chats_v1_';
  static const maxItems = 12;

  List<OfflineRecentChatEntry> _entries = const [];
  String? _userId;

  List<OfflineRecentChatEntry> get entries => List.unmodifiable(_entries);

  Future<void> bindUser(String? userId) async {
    _userId = userId;
    if (userId == null || userId.isEmpty) {
      _entries = const [];
      notifyListeners();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_keyPrefix$userId');
    if (raw == null) {
      _entries = const [];
    } else {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _entries = list
            .map((e) => OfflineRecentChatEntry.fromMap(e as Map<String, dynamic>))
            .toList(growable: false);
      } catch (_) {
        _entries = const [];
      }
    }
    notifyListeners();
  }

  Future<void> recordOpen({
    required String clinicId,
    required String patientId,
    required String title,
  }) async {
    final userId = _userId;
    if (userId == null) return;
    final updated = [
      OfflineRecentChatEntry(
        clinicId: clinicId,
        patientId: patientId,
        title: title,
        openedAt: DateTime.now(),
      ),
      ..._entries.where(
        (e) => !(e.clinicId == clinicId && e.patientId == patientId),
      ),
    ];
    if (updated.length > maxItems) {
      updated.removeRange(maxItems, updated.length);
    }
    _entries = List.unmodifiable(updated);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_keyPrefix$userId',
      jsonEncode(_entries.map((e) => e.toMap()).toList()),
    );
  }
}
