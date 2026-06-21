import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/queue_entry.dart';
import '../../services/auth_service.dart';
import '../../services/clinic_data_service.dart';
import '../../services/queue_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/localization_utils.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/language_picker.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthService>();
      context.read<QueueService>().watchPatientQueue(auth.patientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final queueService = context.watch<QueueService>();
    final data = context.watch<ClinicDataService>();
    final myQueue = queueService.activeEntryForPatient(auth.patientId);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.patientApp),
        backgroundColor: AppTheme.patientColor,
        actions: [
          const LanguagePicker(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.welcomeUser(auth.currentUser?.name.localized(context) ?? ''),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (myQueue != null)
            _MyQueueCard(entry: myQueue, queueService: queueService)
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(l10n.noActiveQueue),
                    const SizedBox(height: 8),
                    Text(l10n.bookQueueHint, style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(l10n.medicalSpecialties, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...data.specialties.map(
            (s) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.patientColor.withOpacity(0.1),
                  child: Icon(SpecialtyIcon.forName(s.iconName), color: AppTheme.patientColor),
                ),
                title: Text(s.name.localized(context)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/patient/specialty/${s.id}'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.push('/patient/doctors'),
            icon: const Icon(Icons.search),
            label: Text(l10n.searchDoctors),
          ),
        ],
      ),
    );
  }
}

class _MyQueueCard extends StatelessWidget {
  const _MyQueueCard({required this.entry, required this.queueService});

  final QueueEntry entry;
  final QueueService queueService;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = context.read<ClinicDataService>();
    final doctor = data.doctorById(entry.doctorId);
    final ahead = queueService.peopleAhead(entry);
    final statusLabel = entry.status == QueueStatus.inProgress
        ? l10n.yourTurn
        : entry.status == QueueStatus.waiting
            ? l10n.waiting
            : l10n.completed;

    if (doctor == null) return const SizedBox.shrink();

    return Card(
      color: AppTheme.patientColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.queue, color: AppTheme.patientColor),
                const SizedBox(width: 8),
                Text(l10n.currentQueue, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                QueueStatusChip(
                  label: statusLabel,
                  color: entry.status == QueueStatus.inProgress ? Colors.green : AppTheme.patientColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            InfoTile(icon: Icons.person, label: l10n.doctor, value: doctor.name.localized(context)),
            const SizedBox(height: 6),
            InfoTile(icon: Icons.medical_information_outlined, label: l10n.specialty, value: doctor.specialty.name.localized(context)),
            const SizedBox(height: 6),
            InfoTile(icon: Icons.format_list_numbered, label: l10n.queueNumber, value: '${entry.position}'),
            const SizedBox(height: 6),
            InfoTile(icon: Icons.people_outline, label: l10n.peopleAhead, value: '$ahead'),
            const SizedBox(height: 6),
            InfoTile(
              icon: Icons.timer_outlined,
              label: l10n.waitTime,
              value: l10n.minutesShort(entry.estimatedWaitMinutes ?? ahead * 15),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/patient/map/${doctor.clinicId}'),
                    icon: const Icon(Icons.map_outlined),
                    label: Text(l10n.clinicLocationGps),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.push('/patient/my-queue'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.patientColor),
                    child: Text(l10n.details),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
