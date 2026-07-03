import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/staff_communication_log.dart';
import 'auth_service.dart';
import 'patient_communication_policy.dart';
import 'staff_communication_log_service.dart';

/// Launches call / WhatsApp / SMS to patients for authorized clinical staff.
class PatientContactService {
  PatientContactService({
    required AuthService authService,
    required StaffCommunicationLogService communicationLog,
  })  : _auth = authService,
        _log = communicationLog;

  final AuthService _auth;
  final StaffCommunicationLogService _log;

  bool canContactPatient({String? doctorId}) =>
      PatientCommunicationPolicy.canViewPatientPhone(_auth, doctorId: doctorId);

  Future<void> callPatient({
    required String phone,
    required String patientName,
    required String doctorId,
    required String doctorName,
    String? patientId,
  }) async {
    if (!canContactPatient(doctorId: doctorId)) return;
    final normalized = _normalizePhone(phone);
    if (normalized.isEmpty) return;

    _record(
      type: StaffCommunicationType.call,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      patientId: patientId,
      phone: normalized,
    );

    final uri = Uri(scheme: 'tel', path: normalized);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> openWhatsApp({
    required BuildContext context,
    required String phone,
    required String patientName,
    required String doctorId,
    required String doctorName,
    String? patientId,
  }) async {
    if (!canContactPatient(doctorId: doctorId)) return;
    final normalized = _normalizePhone(phone);
    if (normalized.isEmpty) return;

    final message = await _pickMessage(context);
    if (message == null || !context.mounted) return;

    _record(
      type: StaffCommunicationType.whatsapp,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      patientId: patientId,
      phone: normalized,
    );

    final digits = normalized.replaceAll(RegExp(r'[^\d]'), '');
    final uri = Uri.parse(
      'https://wa.me/$digits?text=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> openSms({
    required BuildContext context,
    required String phone,
    required String patientName,
    required String doctorId,
    required String doctorName,
    String? patientId,
  }) async {
    if (!canContactPatient(doctorId: doctorId)) return;
    final normalized = _normalizePhone(phone);
    if (normalized.isEmpty) return;

    final message = await _pickMessage(context);
    if (message == null || !context.mounted) return;

    _record(
      type: StaffCommunicationType.sms,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      patientId: patientId,
      phone: normalized,
    );

    final uri = Uri(
      scheme: 'sms',
      path: normalized,
      queryParameters: {'body': message},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<String?> _pickMessage(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                l10n.chooseMessageTemplate,
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ListTile(
              title: Text(l10n.contactTemplateQueueReminder),
              onTap: () => Navigator.pop(ctx, l10n.contactTemplateQueueReminder),
            ),
            ListTile(
              title: Text(l10n.contactTemplateYourTurn),
              onTap: () => Navigator.pop(ctx, l10n.contactTemplateYourTurn),
            ),
            ListTile(
              title: Text(l10n.contactTemplateAppointmentReminder),
              onTap: () =>
                  Navigator.pop(ctx, l10n.contactTemplateAppointmentReminder),
            ),
            ListTile(
              title: Text(l10n.contactTemplateFollowUp),
              onTap: () => Navigator.pop(ctx, l10n.contactTemplateFollowUp),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.contactTemplateCustom),
              onTap: () => Navigator.pop(ctx, '__custom__'),
            ),
          ],
        ),
      ),
    );
    if (selected == '__custom__') {
      if (!context.mounted) return null;
      return _customMessageDialog(context);
    }
    return selected;
  }

  Future<String?> _customMessageDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.contactTemplateCustom),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: l10n.typeMessage,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.notNow),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(ctx, text);
            },
            child: Text(l10n.sendNotification),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  void _record({
    required StaffCommunicationType type,
    required String patientName,
    required String doctorId,
    required String doctorName,
    String? patientId,
    String? phone,
  }) {
    final user = _auth.currentUser;
    if (user == null) return;
    _log.record(
      type: type,
      staffUserId: user.id,
      staffName: user.name.en.isNotEmpty ? user.name.en : user.name.ar,
      patientName: patientName,
      doctorName: doctorName,
      patientId: patientId,
      doctorId: doctorId,
      phone: phone,
    );
  }

  String _normalizePhone(String phone) => phone.trim();

  static bool hasValidPhone(String? phone) =>
      phone != null && phone.trim().length >= 8;
}
