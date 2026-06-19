import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/localization_utils.dart';
import '../widgets/common_widgets.dart';
import '../widgets/language_picker.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentService>().startWatching();
    });
  }

  String _statusLabel(AppLocalizations l10n, AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.available:
        return l10n.statusAvailable;
      case AppointmentStatus.booked:
        return l10n.statusBooked;
      case AppointmentStatus.pending:
        return l10n.statusPending;
      case AppointmentStatus.accepted:
        return l10n.statusAccepted;
      case AppointmentStatus.rejected:
        return l10n.statusRejected;
      case AppointmentStatus.completed:
        return l10n.completed;
      case AppointmentStatus.cancelled:
        return l10n.statusCancelled;
    }
  }

  Color _statusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.available:
        return Colors.green;
      case AppointmentStatus.booked:
        return AppTheme.patientColor;
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.accepted:
        return AppTheme.medicalGreen;
      case AppointmentStatus.rejected:
        return Colors.red;
      case AppointmentStatus.completed:
        return Colors.grey;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final appointmentService = context.watch<AppointmentService>();
    final appointments = appointmentService.availableAppointments;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.patientDashboard),
        backgroundColor: AppTheme.patientColor,
        actions: [
          const LanguagePicker(),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.logout,
            onPressed: () async {
              await auth.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: _buildBody(
        l10n: l10n,
        auth: auth,
        appointmentService: appointmentService,
        appointments: appointments,
        locale: locale,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/patient'),
        backgroundColor: AppTheme.patientColor,
        icon: const Icon(Icons.medical_services_outlined),
        label: Text(l10n.patientApp),
      ),
    );
  }

  Widget _buildBody({
    required AppLocalizations l10n,
    required AuthService auth,
    required AppointmentService appointmentService,
    required List<Appointment> appointments,
    required String locale,
  }) {
    if (appointmentService.isLoading && appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppTheme.patientColor),
            const SizedBox(height: 16),
            Text(l10n.loading),
          ],
        ),
      );
    }

    if (appointmentService.error != null && appointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(l10n.errorGeneric, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                appointmentService.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => appointmentService.startWatching(),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: appointmentService.refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.welcomeUser(auth.currentUser?.name.localized(context) ?? ''),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.availableAppointments,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          if (appointments.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noAppointmentsAvailable,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            ...appointments.map((appointment) {
              final dateLabel = DateFormat.yMMMd(locale).add_jm().format(appointment.dateTime);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.patientColor.withOpacity(0.1),
                            child: const Icon(Icons.calendar_month, color: AppTheme.patientColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              appointment.doctorName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          QueueStatusChip(
                            label: _statusLabel(l10n, appointment.status),
                            color: _statusColor(appointment.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      InfoTile(icon: Icons.medical_information_outlined, label: l10n.specialty, value: appointment.specialty),
                      const SizedBox(height: 6),
                      InfoTile(icon: Icons.local_hospital_outlined, label: l10n.clinic, value: appointment.clinicName),
                      const SizedBox(height: 6),
                      InfoTile(icon: Icons.schedule, label: l10n.appointmentDate, value: dateLabel),
                      if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        InfoTile(icon: Icons.notes, label: l10n.info, value: appointment.notes!),
                      ],
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
