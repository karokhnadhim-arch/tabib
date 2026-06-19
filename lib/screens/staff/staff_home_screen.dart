import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/doctor.dart';
import '../../models/queue_entry.dart';
import '../../models/user_account.dart';
import '../../services/auth_service.dart';
import '../../services/clinic_data_service.dart';
import '../../services/queue_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/localization_utils.dart';
import '../../widgets/language_picker.dart';

class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final user = auth.currentUser!;
    final isDoctor = user.role == UserRole.doctor;
    final data = context.watch<ClinicDataService>();

    final doctors = isDoctor
        ? data.doctors.where((d) => d.id == user.doctorId).toList()
        : data.doctors.where((d) => d.clinicId == user.clinicId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isDoctor ? l10n.doctorApp : l10n.secretaryApp),
        backgroundColor: AppTheme.staffColor,
        actions: [
          const LanguagePicker(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              context.go('/');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.staffColor.withOpacity(0.1),
                    child: Icon(
                      isDoctor ? Icons.medical_services : Icons.support_agent,
                      color: AppTheme.staffColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name.localized(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(isDoctor ? l10n.roleDoctor : l10n.roleSecretary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.queueManagement, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...doctors.map(
            (d) => _DoctorQueuePreview(
              doctor: d,
              onTap: () => context.push('/staff/queue/${d.id}'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorQueuePreview extends StatefulWidget {
  const _DoctorQueuePreview({required this.doctor, required this.onTap});

  final Doctor doctor;
  final VoidCallback onTap;

  @override
  State<_DoctorQueuePreview> createState() => _DoctorQueuePreviewState();
}

class _DoctorQueuePreviewState extends State<_DoctorQueuePreview> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QueueService>().watchDoctorQueue(widget.doctor.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final queueService = context.watch<QueueService>();
    final queue = queueService.queueForDoctor(widget.doctor.id);
    final waiting = queue.where((e) => e.status == QueueStatus.waiting).length;
    final inProgress = queue.any((e) => e.status == QueueStatus.inProgress);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: widget.onTap,
        leading: CircleAvatar(
          backgroundColor: AppTheme.staffColor.withOpacity(0.1),
          child: const Icon(Icons.queue, color: AppTheme.staffColor),
        ),
        title: Text(widget.doctor.name.localized(context)),
        subtitle: Text('${widget.doctor.specialty.name.localized(context)} • ${l10n.patientCount(queue.length)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              inProgress ? l10n.active : l10n.waitingCount(waiting),
              style: TextStyle(
                color: inProgress ? Colors.green : AppTheme.staffColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
