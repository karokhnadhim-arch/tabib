import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/medical_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/appointment.dart';
import '../../../models/queue_entry.dart';
import '../../../utils/localization_utils.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/queue_service.dart';
import '../../../utils/queue_status_utils.dart';
import '../../providers/app_providers.dart';
import '../../widgets/staff_patient_contact_bar.dart';

class DoctorQueueTab extends StatelessWidget {
  const DoctorQueueTab({super.key, required this.doctorId});

  final String doctorId;

  Appointment? _findAppointment(AppointmentProvider provider, QueueEntry entry) {
    for (final a in provider.appointments) {
      if (a.patientId == entry.patientId && a.doctorId == doctorId) {
        return a;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final queueService = context.watch<QueueService>();
    final data = context.watch<ClinicDataService>();
    final doctor = data.doctorById(doctorId);
    final doctorName = doctor?.name.localized(context) ?? doctorId;
    final queue = queueService.queueForDoctor(doctorId);

    if (queue.isEmpty) {
      return Center(child: Text(l10n.noPatientsInQueue));
    }

    QueueEntry? current;
    for (final e in queue) {
      if (e.status == QueueStatus.inProgress) {
        current = e;
        break;
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (current != null)
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.medicalGreen.withOpacity(0.12),
                    AppTheme.medicalGreen.withOpacity(0.04),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.currentPatient,
                    style: const TextStyle(
                      color: AppTheme.medicalGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    current.patientName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StaffPatientContactBar(
                    phone: current.patientPhone,
                    patientName: current.patientName,
                    doctorId: doctorId,
                    doctorName: doctorName,
                    patientId: current.patientId,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      MedicalActionChip(
                        icon: Icons.medical_services_outlined,
                        label: l10n.sendToExamination,
                        color: const Color(0xFF7B1FA2),
                        onTap: () async {
                          final queue = context.read<QueueService>();
                          final provider = context.read<AppointmentProvider>();
                          await queue.sendToExamination(current!.id, doctorId);
                          final appt = _findAppointment(provider, current);
                          if (appt != null) {
                            await provider.sendToExamination(appt.id);
                          }
                        },
                      ),
                      MedicalActionChip(
                        icon: Icons.check_circle_outline,
                        label: l10n.completeVisit,
                        color: AppTheme.medicalGreen,
                        onTap: () => context
                            .read<QueueService>()
                            .completeCurrent(doctorId),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (current == null && queue.any((e) => e.status == QueueStatus.waiting))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FilledButton.icon(
              onPressed: () =>
                  context.read<QueueService>().callNext(doctorId),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.doctorColor,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.call),
              label: Text(l10n.callNext),
            ),
          ),
        ...queue.map((entry) {
          final color = entry.status.color();
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.doctorColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${entry.position}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.patientName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            entry.status.label(l10n),
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        StaffPatientContactBar(
                          phone: entry.patientPhone,
                          patientName: entry.patientName,
                          doctorId: doctorId,
                          doctorName: doctorName,
                          patientId: entry.patientId,
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
