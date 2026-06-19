import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/appointment.dart';

class AppointmentService extends ChangeNotifier {
  AppointmentService({
    FirebaseFirestore? firestore,
    bool demoMode = false,
  })  : _demoMode = demoMode,
        _firestore = demoMode ? null : (firestore ?? FirebaseFirestore.instance);

  final bool _demoMode;
  final FirebaseFirestore? _firestore;
  static const _collection = 'appointments';

  List<Appointment> _appointments = [];
  String? _error;
  bool _loading = true;
  bool _watching = false;

  List<Appointment> get availableAppointments =>
      List.unmodifiable(_appointments.where((a) => a.isAvailable));

  List<Appointment> get appointments => List.unmodifiable(_appointments);

  String? get error => _error;
  bool get isLoading => _loading;

  Stream<List<Appointment>> watchAvailableAppointments() {
    final firestore = _firestore;
    if (firestore == null) return Stream.value([]);

    return firestore
        .collection(_collection)
        .where('status', isEqualTo: AppointmentStatus.available.name)
        .orderBy('dateTime')
        .snapshots()
        .map(_mapSnapshot);
  }

  Future<List<Appointment>> fetchAvailableAppointments() async {
    final firestore = _firestore;
    if (firestore == null) return [];

    final snapshot = await firestore
        .collection(_collection)
        .where('status', isEqualTo: AppointmentStatus.available.name)
        .orderBy('dateTime')
        .get();
    return _mapSnapshot(snapshot);
  }

  void startWatching() {
    if (_watching) return;
    if (_demoMode || _firestore == null) {
      _appointments = [];
      _loading = false;
      _error = null;
      notifyListeners();
      return;
    }

    _watching = true;
    watchAvailableAppointments().listen(
      (list) {
        _appointments = list;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        _loading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> refresh() async {
    if (_demoMode || _firestore == null) {
      _appointments = [];
      _loading = false;
      _error = null;
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _appointments = await fetchAvailableAppointments();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<Appointment> _mapSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .map((doc) => Appointment.fromFirestore(doc.id, doc.data()))
        .toList();
  }
}
