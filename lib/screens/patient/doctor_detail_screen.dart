import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/clinic_data_service.dart';
import '../../services/queue_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/localization_utils.dart';
import '../../widgets/common_widgets.dart';
import '../../presentation/widgets/queue_booking_sheet.dart';

class DoctorDetailScreen extends StatefulWidget {
  const DoctorDetailScreen({super.key, required this.doctorId});

  final String doctorId;

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QueueService>().watchDoctorQueue(widget.doctorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = context.watch<ClinicDataService>();
    final doctor = data.doctorById(widget.doctorId);
    if (doctor == null) {
      return Scaffold(body: Center(child: Text(l10n.noDoctorsFound)));
    }

    final queueService = context.watch<QueueService>();
    final queueLength = queueService.queueForDoctor(widget.doctorId).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(doctor.name.localized(context)),
        backgroundColor: AppTheme.patientColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.patientColor.withOpacity(0.1),
                      child: Icon(
                        SpecialtyIcon.forName(doctor.specialty.iconName),
                        size: 40,
                        color: AppTheme.patientColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      doctor.name.localized(context),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(doctor.specialty.name.localized(context), style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        Text(' ${doctor.rating}  •  ${l10n.yearsExperience(doctor.experienceYears)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.info, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(doctor.bio.localized(context)),
                    const SizedBox(height: 12),
                    InfoTile(icon: Icons.local_hospital_outlined, label: l10n.clinic, value: doctor.clinic.name.localized(context)),
                    const SizedBox(height: 6),
                    InfoTile(icon: Icons.location_on_outlined, label: l10n.location, value: doctor.clinic.address.localized(context)),
                    const SizedBox(height: 6),
                    InfoTile(icon: Icons.people_outline, label: l10n.inQueue, value: l10n.patientCount(queueLength)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.push('/patient/map/${doctor.clinicId}'),
              icon: const Icon(Icons.map_outlined),
              label: Text(l10n.clinicLocationGps),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: doctor.isAvailableToday ? () => _bookQueue(context, widget.doctorId) : null,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.patientColor),
              icon: const Icon(Icons.add),
              label: Text(l10n.bookQueue),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bookQueue(BuildContext context, String doctorId) async {
    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthService>();
    final queueService = context.read<QueueService>();
    final data = context.read<ClinicDataService>();

    if (queueService.activeEntryForPatient(auth.patientId) != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.alreadyHasQueue)));
      return;
    }

    final doctor = data.doctorById(doctorId);
    if (doctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.bookFailed)));
      return;
    }

    final slot = await showQueueBookingSheet(context, doctor);
    if (slot == null || !context.mounted) return;

    final entry = await queueService.bookQueue(
      doctorId: doctorId,
      patientId: auth.patientId,
      patientName: auth.currentUser?.name.localized(context) ?? l10n.patientName,
      patientPhone: auth.currentUser?.phone ?? '',
      queueDate: slot.dateKey,
      slotStart: slot.start,
      slotEnd: slot.end,
    );

    if (!context.mounted) return;
    if (entry == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.bookFailed)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.bookSuccess(entry.position))),
    );
    context.go('/patient/my-queue');
  }
}
