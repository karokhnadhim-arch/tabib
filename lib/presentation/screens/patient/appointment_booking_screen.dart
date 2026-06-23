import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/medical_ui.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../utils/localization_utils.dart';
import '../../providers/app_providers.dart';
import '../../widgets/doctor_schedule_view.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key, required this.doctorId});

  final String doctorId;

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  final _notesController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _book() async {
    final auth = context.read<AuthService>();
    final data = context.read<ClinicDataService>();
    final doctor = data.doctorById(widget.doctorId);
    if (doctor == null || auth.currentUser == null) return;

    final l10n = AppLocalizations.of(context);
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (!doctor.isOpenOn(_selectedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.appointmentClosedDay)),
      );
      return;
    }
    if (!doctor.isDateTimeWithinSchedule(dateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.appointmentOutsideSchedule)),
      );
      return;
    }

    setState(() => _loading = true);

    final err = await context.read<AppointmentProvider>().book(
      patientId: auth.patientId,
      patientName: auth.currentUser!.name.localized(context),
      patientPhone: auth.currentUser!.phone ?? '',
      doctorId: doctor.id,
      doctorName: doctor.name.localized(context),
      specialty: doctor.specialty.name.localized(context),
      clinicName: doctor.clinic.name.localized(context),
      clinicId: doctor.clinicId,
      dateTime: dateTime,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.bookAppointmentSuccess)),
      );
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.bookAppointmentFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = context.watch<ClinicDataService>();
    final doctor = data.doctorById(widget.doctorId);

    if (doctor == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.bookAppointment)),
        body: Center(child: Text(l10n.noDoctorsFound)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.medicalWhite,
      appBar: AppBar(
        title: Text(l10n.bookAppointment),
        backgroundColor: AppTheme.patientColor,
      ),
      body: ResponsiveBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MedicalGradientHeader(
              height: 120,
              title: doctor.name.localized(context),
              subtitle: doctor.specialty.name.localized(context),
            ),
            const SizedBox(height: 20),
            if (doctor.patientShowsStructuredSchedule) ...[
              SectionHeader(title: l10n.viewWorkingSchedule),
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: DoctorScheduleView(
                    schedule: doctor.effectiveWorkingSchedule,
                  ),
                ),
              ),
            ],
            _BookingTile(
              icon: Icons.calendar_today,
              color: AppTheme.medicalBlue,
              title: l10n.selectDate,
              value: DateFormat.yMMMd().format(_selectedDate),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                  selectableDayPredicate: (date) => doctor.isOpenOn(date),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                    final firstTime =
                        doctor.effectiveWorkingSchedule.firstAvailableTimeOn(
                      picked,
                    );
                    if (firstTime != null) {
                      _selectedTime = firstTime;
                    }
                  });
                }
              },
            ),
            _BookingTile(
              icon: Icons.access_time,
              color: AppTheme.medicalGreen,
              title: l10n.selectTime,
              value: _selectedTime.format(context),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (picked != null) setState(() => _selectedTime = picked);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.notesOptional,
                hintText: l10n.notesHint,
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _loading ? null : _book,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.medicalGreen,
                minimumSize: const Size.fromHeight(54),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.confirmBooking),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
