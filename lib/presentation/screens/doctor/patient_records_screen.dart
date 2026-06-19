import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/appointment.dart';
import '../../../services/auth_service.dart';
import '../../providers/app_providers.dart';

class PatientRecordsScreen extends StatelessWidget {
  const PatientRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final doctorId = auth.currentUser?.doctorId ?? '';
    final appointments = context.watch<AppointmentProvider>().appointments
        .where((a) =>
            a.doctorId == doctorId &&
            (a.isAccepted || a.status == AppointmentStatus.completed))
        .toList();

    if (appointments.isEmpty) {
      return Center(child: Text(l10n.noPatientRecords));
    }

    return ListView.separated(
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final a = appointments[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.medicalBlue.withOpacity(0.1),
              child: const Icon(Icons.person, color: AppTheme.medicalBlue),
            ),
            title: Text(a.patientName ?? l10n.patientName),
            subtitle: Text('${a.specialty} • ${a.clinicName}'),
            trailing: IconButton(
              icon: const Icon(Icons.medication_outlined),
              onPressed: () {
                if (a.patientId != null) {
                  context.push(
                    '/doctor/prescription/${a.patientId}?name=${Uri.encodeComponent(a.patientName ?? '')}',
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
