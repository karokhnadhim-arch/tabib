import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/clinic_department.dart';
import '../models/consultation_room.dart';

/// Owner-managed departments and consultation rooms per clinic.
class ClinicStructureService extends ChangeNotifier {
  final List<ClinicDepartment> _departments = [];
  final List<ConsultationRoom> _rooms = [];
  bool _loaded = false;

  List<ClinicDepartment> departmentsFor(String clinicId, {bool includeArchived = false}) {
    return _departments.where((d) {
      if (d.clinicId != clinicId) return false;
      return includeArchived || !d.archived;
    }).toList();
  }

  List<ConsultationRoom> roomsFor(
    String clinicId, {
    String? departmentId,
    bool includeArchived = false,
  }) {
    return _rooms.where((r) {
      if (r.clinicId != clinicId) return false;
      if (departmentId != null && r.departmentId != departmentId) return false;
      return includeArchived || !r.archived;
    }).toList();
  }

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final deptRaw = prefs.getString(_deptKey);
    final roomRaw = prefs.getString(_roomKey);
    if (deptRaw != null) {
      final list = jsonDecode(deptRaw) as List;
      _departments
        ..clear()
        ..addAll(
          list.map((e) {
            final map = Map<String, dynamic>.from(e as Map);
            final id = map.remove('id') as String;
            return ClinicDepartment.fromMap(id, map);
          }),
        );
    }
    if (roomRaw != null) {
      final list = jsonDecode(roomRaw) as List;
      _rooms
        ..clear()
        ..addAll(
          list.map((e) {
            final map = Map<String, dynamic>.from(e as Map);
            final id = map.remove('id') as String;
            return ConsultationRoom.fromMap(id, map);
          }),
        );
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> upsertDepartment({
    required String clinicId,
    String? id,
    required String name,
  }) async {
    final deptId = id ?? 'dept_${const Uuid().v4()}';
    final dept = ClinicDepartment(id: deptId, clinicId: clinicId, name: name.trim());
    final index = _departments.indexWhere((d) => d.id == deptId);
    if (index >= 0) {
      _departments[index] = dept.copyWith(archived: _departments[index].archived);
    } else {
      _departments.add(dept);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> setDepartmentArchived(String id, bool archived) async {
    final index = _departments.indexWhere((d) => d.id == id);
    if (index < 0) return;
    _departments[index] = _departments[index].copyWith(archived: archived);
    await _persist();
    notifyListeners();
  }

  Future<void> upsertRoom({
    required String clinicId,
    required String departmentId,
    String? id,
    required String name,
  }) async {
    final roomId = id ?? 'room_${const Uuid().v4()}';
    final room = ConsultationRoom(
      id: roomId,
      clinicId: clinicId,
      departmentId: departmentId,
      name: name.trim(),
    );
    final index = _rooms.indexWhere((r) => r.id == roomId);
    if (index >= 0) {
      _rooms[index] = room.copyWith(archived: _rooms[index].archived);
    } else {
      _rooms.add(room);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> setRoomArchived(String id, bool archived) async {
    final index = _rooms.indexWhere((r) => r.id == id);
    if (index < 0) return;
    _rooms[index] = _rooms[index].copyWith(archived: archived);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _deptKey,
      jsonEncode(
        _departments.map((d) => {'id': d.id, ...d.toMap()}).toList(),
      ),
    );
    await prefs.setString(
      _roomKey,
      jsonEncode(
        _rooms.map((r) => {'id': r.id, ...r.toMap()}).toList(),
      ),
    );
  }

  static const _deptKey = 'clinic_departments_v1';
  static const _roomKey = 'clinic_rooms_v1';
}
