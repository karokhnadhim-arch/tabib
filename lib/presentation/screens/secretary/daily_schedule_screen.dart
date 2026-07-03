import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/appointment.dart';
import '../../../widgets/common_widgets.dart';
import '../../providers/app_providers.dart';
import '../../widgets/staff_patient_contact_bar.dart';

class DailyScheduleScreen extends StatefulWidget {
  const DailyScheduleScreen({
    super.key,
    required this.clinicId,
    this.doctorId,
    this.embedded = false,
  });

  final String clinicId;
  final String? doctorId;
  final bool embedded;

  @override
  State<DailyScheduleScreen> createState() => _DailyScheduleScreenState();
}

class _DailyScheduleScreenState extends State<DailyScheduleScreen> {
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().watchDailySchedule(
            widget.clinicId,
            _date,
          );
    });
  }

  void _changeDate(DateTime date) {
    setState(() => _date = date);
    context.read<AppointmentProvider>().watchDailySchedule(
          widget.clinicId,
          date,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appointments = context.watch<AppointmentProvider>().appointments
        .where((a) =>
            (a.status == AppointmentStatus.accepted ||
                a.status == AppointmentStatus.pending) &&
            (widget.doctorId == null || a.doctorId == widget.doctorId))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormat.yMMMd().format(_date),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _changeDate(_date.subtract(const Duration(days: 1))),
            ),
            IconButton(
              icon: const Icon(Icons.today),
              onPressed: () => _changeDate(DateTime.now()),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _changeDate(_date.add(const Duration(days: 1))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.embedded)
          ..._scheduleContent(context, l10n, appointments)
        else
          Expanded(
            child: appointments.isEmpty
                ? Center(child: Text(l10n.noAppointmentsToday))
                : ListView.separated(
                    itemCount: appointments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        _appointmentTile(context, l10n, appointments[index]),
                  ),
          ),
      ],
    );
  }

  List<Widget> _scheduleContent(
    BuildContext context,
    AppLocalizations l10n,
    List<Appointment> appointments,
  ) {
    if (appointments.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(child: Text(l10n.noAppointmentsToday)),
        ),
      ];
    }

    return [
      for (var i = 0; i < appointments.length; i++) ...[
        if (i > 0) const SizedBox(height: 8),
        _appointmentTile(context, l10n, appointments[i]),
      ],
    ];
  }

  Widget _appointmentTile(
    BuildContext context,
    AppLocalizations l10n,
    Appointment a,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.jm().format(a.dateTime),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.medicalBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${a.doctorName} — ${a.patientName ?? ''}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    a.specialty,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  StaffPatientContactBar(
                    phone: a.patientPhone ?? '',
                    patientName: a.patientName ?? l10n.patientName,
                    doctorId: a.doctorId ?? '',
                    doctorName: a.doctorName,
                    patientId: a.patientId,
                    compact: true,
                  ),
                ],
              ),
            ),
            QueueStatusChip(
              label: a.isPending ? l10n.statusPending : l10n.statusAccepted,
              color: a.isPending ? Colors.orange : AppTheme.medicalGreen,
            ),
          ],
        ),
      ),
    );
  }
}
