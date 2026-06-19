import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/queue_entry.dart';
import '../../models/user_account.dart';
import '../../services/auth_service.dart';
import '../../services/clinic_data_service.dart';
import '../../services/queue_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/localization_utils.dart';
import '../../widgets/common_widgets.dart';

class QueueManagementScreen extends StatefulWidget {
  const QueueManagementScreen({super.key, required this.doctorId});

  final String doctorId;

  @override
  State<QueueManagementScreen> createState() => _QueueManagementScreenState();
}

class _QueueManagementScreenState extends State<QueueManagementScreen> {
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
    final auth = context.watch<AuthService>();
    final queueService = context.watch<QueueService>();
    final doctor = context.watch<ClinicDataService>().doctorById(widget.doctorId);
    if (doctor == null) {
      return Scaffold(body: Center(child: Text(l10n.errorGeneric)));
    }

    final queue = queueService.queueForDoctor(widget.doctorId);
    final isDoctor = auth.currentUser?.role == UserRole.doctor;
    QueueEntry? current;
    for (final e in queue) {
      if (e.status == QueueStatus.inProgress) {
        current = e;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.queueManagement} — ${doctor.name.localized(context)}'),
        backgroundColor: AppTheme.staffColor,
      ),
      body: Column(
        children: [
          if (current != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(l10n.currentPatient, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(current.patientName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  if (isDoctor) ...[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => queueService.completeCurrent(widget.doctorId),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: Text(l10n.completeVisit),
                    ),
                  ],
                ],
              ),
            ),
          if (isDoctor && current == null && queue.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () => queueService.callNext(widget.doctorId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.staffColor,
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: const Icon(Icons.call),
                label: Text(l10n.callNext),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(l10n.queueList, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: queue.isEmpty
                ? Center(child: Text(l10n.noPatientsInQueue))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: queue.length,
                    itemBuilder: (context, index) {
                      final entry = queue[index];
                      return _QueueEntryTile(
                        entry: entry,
                        queueService: queueService,
                        doctorId: widget.doctorId,
                        canManage: auth.currentUser?.role == UserRole.secretary ||
                            auth.currentUser?.role == UserRole.doctor,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _QueueEntryTile extends StatelessWidget {
  const _QueueEntryTile({
    required this.entry,
    required this.queueService,
    required this.doctorId,
    required this.canManage,
  });

  final QueueEntry entry;
  final QueueService queueService;
  final String doctorId;
  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusColor = entry.status == QueueStatus.inProgress
        ? Colors.green
        : entry.status == QueueStatus.waiting
            ? AppTheme.staffColor
            : Colors.grey;

    final statusLabel = entry.status == QueueStatus.inProgress
        ? l10n.nowServing
        : entry.status == QueueStatus.waiting
            ? l10n.waiting
            : l10n.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.15),
          child: Text('${entry.position}', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
        ),
        title: Text(entry.patientName),
        subtitle: Text(entry.patientPhone),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            QueueStatusChip(label: statusLabel, color: statusColor),
            if (canManage && entry.status == QueueStatus.waiting) ...[
              IconButton(
                icon: const Icon(Icons.arrow_upward, size: 20),
                onPressed: () => queueService.moveUp(entry.id, doctorId),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward, size: 20),
                onPressed: () => queueService.moveDown(entry.id, doctorId),
              ),
            ],
            if (canManage)
              IconButton(
                icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
                onPressed: () => queueService.cancelEntry(entry.id, doctorId),
              ),
          ],
        ),
      ),
    );
  }
}
