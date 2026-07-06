import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/appointment.dart';
import '../../../models/queue_entry.dart';
import '../../../services/auth_service.dart';
import '../../../services/queue_service.dart';
import '../../../services/smart_notification_service.dart';
import '../../providers/app_providers.dart';

/// Centralized secretary queue actions — keeps UI thin and logic consistent.
class SecretaryQueueActions {
  SecretaryQueueActions._();

  static Appointment? appointmentFor(
    List<Appointment> appointments,
    QueueEntry entry,
    String doctorId,
  ) {
    for (final a in appointments) {
      if (a.patientId == entry.patientId && a.doctorId == doctorId) {
        return a;
      }
    }
    return null;
  }

  static Future<void> syncVisit(
    BuildContext context,
    QueueEntry entry,
    String doctorId,
    Future<void> Function(String id) action,
  ) async {
    final provider = context.read<AppointmentProvider>();
    final appt = appointmentFor(provider.appointments, entry, doctorId);
    if (appt != null) await action(appt.id);
  }

  static Future<void> enterRoom(
    BuildContext context, {
    required QueueEntry entry,
    required String doctorId,
  }) async {
    final queue = context.read<QueueService>();
    await queue.enterDoctorRoom(entry.id, doctorId);
    if (!context.mounted) return;
    await syncVisit(context, entry, doctorId, context.read<AppointmentProvider>().markArrived);
  }

  static Future<void> markWaiting(
    BuildContext context, {
    required QueueEntry entry,
    required String doctorId,
  }) async {
    await context.read<QueueService>().updateEntryStatus(
          entry.id,
          doctorId,
          QueueStatus.waiting,
        );
  }

  static Future<void> completeVisit(
    BuildContext context, {
    required QueueEntry entry,
    required String doctorId,
  }) async {
    final queue = context.read<QueueService>();
    if (entry.status == QueueStatus.inProgress) {
      await queue.updateEntryStatus(entry.id, doctorId, QueueStatus.completed);
    } else {
      await queue.completeCurrent(doctorId);
    }
    if (!context.mounted) return;
    await syncVisit(context, entry, doctorId, context.read<AppointmentProvider>().complete);
  }

  static Future<void> markAbsent(
    BuildContext context, {
    required QueueEntry entry,
    required String doctorId,
    required String doctorName,
  }) async {
    final queue = context.read<QueueService>();
    final notifications = context.read<SmartNotificationService>();
    await queue.updateEntryStatus(entry.id, doctorId, QueueStatus.absent);
    await notifications.notifyMissedTurn(
      patientUserId: entry.patientId,
      patientName: entry.patientName,
      patientPhone: entry.patientPhone,
      doctorId: doctorId,
      doctorName: doctorName,
      queueEntryId: entry.id,
    );
    if (!context.mounted) return;
    await syncVisit(context, entry, doctorId, context.read<AppointmentProvider>().markAbsent);
  }

  static Future<void> sendToExamination(
    BuildContext context, {
    required QueueEntry entry,
    required String doctorId,
  }) async {
    await context.read<QueueService>().sendToExamination(entry.id, doctorId);
    if (!context.mounted) return;
    await syncVisit(
      context,
      entry,
      doctorId,
      context.read<AppointmentProvider>().sendToExamination,
    );
  }

  static Future<void> returnToReview(
    BuildContext context, {
    required QueueEntry entry,
    required String doctorId,
  }) async {
    await context.read<QueueService>().returnToReview(entry.id, doctorId);
  }

  static Future<void> cancelEntry(
    BuildContext context, {
    required QueueEntry entry,
    required String doctorId,
    required List<Appointment> appointments,
  }) async {
    final queue = context.read<QueueService>();
    await queue.cancelEntry(entry.id, doctorId);
    if (!context.mounted) return;
    final appt = appointmentFor(appointments, entry, doctorId);
    if (appt != null) {
      await context.read<AppointmentProvider>().cancel(appt.id);
    }
  }

  static Future<void> updatePatientContact(
    BuildContext context, {
    required QueueEntry entry,
    required String doctorId,
    required String name,
    required String phone,
  }) async {
    final auth = context.read<AuthService>();
    final queue = context.read<QueueService>();
    await auth.updatePatientByStaff(
      patientId: entry.patientId,
      name: name,
      phone: phone,
    );
    if (!context.mounted) return;
    await queue.updateQueueEntryContact(
      entry.id,
      doctorId,
      patientName: name,
      patientPhone: phone,
    );
  }
}
