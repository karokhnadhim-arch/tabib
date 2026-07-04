import 'package:flutter/foundation.dart';

import '../../data/repositories/offline_chat_repository.dart';
import '../queue_service.dart';
import '../../presentation/providers/app_providers.dart';
import 'connectivity_service.dart';
import 'offline_appointment_cache_service.dart';
import 'offline_queue_cache_service.dart';

/// Coordinates incremental offline sync — no full re-downloads.
class OfflineSyncCoordinator {
  OfflineSyncCoordinator({
    required ConnectivityService connectivity,
    required OfflineChatRepository chatRepository,
    required OfflineQueueCacheService queueCache,
    required OfflineAppointmentCacheService appointmentCache,
  })  : _connectivity = connectivity,
        _chatRepository = chatRepository,
        _queueCache = queueCache,
        _appointmentCache = appointmentCache {
    _connectivity.addListener(_onConnectivityChanged);
  }

  final ConnectivityService _connectivity;
  final OfflineChatRepository _chatRepository;
  final OfflineQueueCacheService _queueCache;
  final OfflineAppointmentCacheService _appointmentCache;

  bool _patientAttached = false;
  String? _patientId;

  void attachPatientSession({
    required String patientId,
    required QueueService queue,
    required AppointmentProvider appointments,
  }) {
    if (_patientAttached && _patientId == patientId) return;
    _patientId = patientId;
    _patientAttached = true;
    _queueCache.attach(queue, patientId);
    appointments.watchPatient(patientId);
    _appointmentCache.attach(appointments, patientId);
  }

  Future<void> onAppOpen() async {
    await _queueCache.bindPatient(_patientId);
    await _appointmentCache.bindPatient(_patientId);
  }

  Future<void> refresh() async {
    if (_connectivity.isOnline) {
      await _chatRepository.flushPendingMessages();
    }
    await onAppOpen();
  }

  void _onConnectivityChanged() {
    if (_connectivity.isOnline) {
      _chatRepository.flushPendingMessages();
    }
  }

  void dispose() {
    _connectivity.removeListener(_onConnectivityChanged);
  }
}
