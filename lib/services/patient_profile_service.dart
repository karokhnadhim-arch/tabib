import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/patient_profile.dart';
import 'firebase_bootstrap.dart';

/// Patient profile fields (photo, city, gender, privacy) with optional Firestore sync.
class PatientProfileService extends ChangeNotifier {
  PatientProfile _profile = const PatientProfile();
  String? _userId;

  PatientProfile get profile => _profile;

  Future<void> bindUser(String? userId) async {
    if (_userId == userId) return;
    _userId = userId;
    _profile = const PatientProfile();
    if (userId == null || userId.isEmpty) {
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey(userId));
    if (raw != null) {
      _profile = PatientProfile.fromMap(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    }

    if (!FirebaseBootstrap.shouldUseDemoMode) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        final remote = PatientProfile.fromMap(
          doc.data()?['patientProfile'] as Map<String, dynamic>?,
        );
        _profile = remote;
        await prefs.setString(_prefsKey(userId), jsonEncode(_profile.toMap()));
      } catch (error) {
        debugPrint('PatientProfileService remote load failed: $error');
      }
    }

    notifyListeners();
  }

  Future<void> updateProfile(PatientProfile profile) async {
    _profile = profile;
    notifyListeners();
    await _persist();
  }

  Future<void> updateField(
    PatientProfile Function(PatientProfile current) transform,
  ) async {
    await updateProfile(transform(_profile));
  }

  Future<void> _persist() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey(userId), jsonEncode(_profile.toMap()));

    if (!FirebaseBootstrap.shouldUseDemoMode) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).set(
          {'patientProfile': _profile.toMap()},
          SetOptions(merge: true),
        );
      } catch (error) {
        debugPrint('PatientProfileService remote save failed: $error');
      }
    }
  }

  String _prefsKey(String userId) => 'patient_profile_$userId';
}
