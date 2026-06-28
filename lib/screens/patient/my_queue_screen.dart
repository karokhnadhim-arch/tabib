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

class MyQueueScreen extends StatelessWidget {
  const MyQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final queueService = context.watch<QueueService>();
    final data = context.watch<ClinicDataService>();
    final entry = queueService.activeEntryForPatient(auth.patientId);

    if (entry == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.myQueue), backgroundColor: AppTheme.patientColor),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(l10n.noActiveQueue),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/patient'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.patientColor),
                child: Text(l10n.searchDoctors),
              ),
            ],
          ),
        ),
      );
    }

    final doctor = data.doctorById(entry.doctorId);
    final ahead = queueService.peopleAhead(entry);
    if (doctor == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myQueue), backgroundColor: AppTheme.patientColor),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        entry.status == QueueStatus.inProgress ? l10n.yourTurn : l10n.queueNumber,
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${entry.position}',
                        style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: AppTheme.patientColor),
                      ),
                      const SizedBox(height: 24),
                      _StatBox(label: l10n.peopleAhead, value: '$ahead', icon: Icons.people_outline),
                      const SizedBox(height: 12),
                      _StatBox(
                        label: l10n.waitTime,
                        value: l10n.minutesShort(entry.estimatedWaitMinutes ?? ahead * 15),
                        icon: Icons.timer_outlined,
                      ),
                      const SizedBox(height: 24),
                      InfoTile(icon: Icons.person, label: l10n.doctor, value: doctor.name.localized(context)),
                      const SizedBox(height: 8),
                      InfoTile(icon: Icons.local_hospital_outlined, label: l10n.clinic, value: doctor.clinic.name.localized(context)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/patient/map/${doctor.clinicId}'),
                    icon: const Icon(Icons.navigation),
                    label: Text(l10n.gpsDirections),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await queueService.cancelEntry(entry.id, entry.doctorId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.queueCancelled)),
                        );
                        context.go('/patient');
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(l10n.cancelQueue),
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

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.patientColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.patientColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
