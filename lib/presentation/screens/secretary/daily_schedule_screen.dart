import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/appointment.dart';
import '../../../widgets/common_widgets.dart';
import '../../providers/app_providers.dart';

class DailyScheduleScreen extends StatefulWidget {
  const DailyScheduleScreen({
    super.key,
    required this.clinicId,
    this.doctorId,
  });

  final String clinicId;
  final String? doctorId;

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
        Expanded(
          child: appointments.isEmpty
              ? Center(child: Text(l10n.noAppointmentsToday))
              : ListView.separated(
                  itemCount: appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final a = appointments[index];
                    return Card(
                      child: ListTile(
                        leading: Text(
                          DateFormat.jm().format(a.dateTime),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.medicalBlue,
                          ),
                        ),
                        title: Text('${a.doctorName} — ${a.patientName ?? ''}'),
                        subtitle: Text(a.specialty),
                        trailing: QueueStatusChip(
                          label: a.isPending ? l10n.statusPending : l10n.statusAccepted,
                          color: a.isPending ? Colors.orange : AppTheme.medicalGreen,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
