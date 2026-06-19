import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/appointment.dart';
import '../../../services/auth_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../widgets/language_picker.dart';
import '../../providers/app_providers.dart';
import 'patient_records_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthService>();
      final doctorId = auth.currentUser?.doctorId ?? '';
      if (doctorId.isNotEmpty) {
        context.read<AppointmentProvider>().watchDoctor(doctorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final appointments = context.watch<AppointmentProvider>();
    final doctorId = auth.currentUser?.doctorId ?? '';

    final pending = appointments.appointments
        .where((a) => a.isPending && a.doctorId == doctorId)
        .toList();
    final accepted = appointments.appointments
        .where((a) => a.isAccepted && a.doctorId == doctorId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.doctorDashboard),
        backgroundColor: AppTheme.doctorColor,
        actions: [
          const LanguagePicker(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: ResponsiveBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.doctorColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.medical_services,
                        color: AppTheme.doctorColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.currentUser?.name.localized(context) ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(l10n.roleDoctor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(l10n.pendingRequests)),
                ButtonSegment(value: 1, label: Text(l10n.acceptedAppointments)),
                ButtonSegment(value: 2, label: Text(l10n.patientRecords)),
              ],
              selected: {_tab},
              onSelectionChanged: (v) => setState(() => _tab = v.first),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _tab == 0
                  ? _AppointmentList(
                      appointments: pending,
                      showActions: true,
                      doctorId: doctorId,
                    )
                  : _tab == 1
                      ? _AppointmentList(
                          appointments: accepted,
                          showActions: false,
                          doctorId: doctorId,
                        )
                      : const PatientRecordsScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  const _AppointmentList({
    required this.appointments,
    required this.showActions,
    required this.doctorId,
  });

  final List<Appointment> appointments;
  final bool showActions;
  final String doctorId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<AppointmentProvider>();

    if (appointments.isEmpty) {
      return Center(child: Text(l10n.noAppointmentsYet));
    }

    return ListView.separated(
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final a = appointments[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.patientName ?? l10n.patientName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(a.patientPhone ?? ''),
                Text(DateFormat.yMMMd().add_jm().format(a.dateTime)),
                if (a.notes != null && a.notes!.isNotEmpty)
                  Text('${l10n.notesOptional}: ${a.notes}'),
                if (showActions) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () => provider.accept(a.id),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.medicalGreen,
                          ),
                          child: Text(l10n.accept),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => provider.reject(a.id),
                          child: Text(l10n.reject),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (a.patientId != null)
                    OutlinedButton.icon(
                      onPressed: () => context.push(
                        '/doctor/prescription/${a.patientId}?name=${Uri.encodeComponent(a.patientName ?? '')}',
                      ),
                      icon: const Icon(Icons.medication),
                      label: Text(l10n.writePrescription),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
