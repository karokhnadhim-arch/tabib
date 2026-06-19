import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/medical_ui.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/queue_entry.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/queue_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../widgets/common_widgets.dart';

class QueueTrackingScreen extends StatefulWidget {
  const QueueTrackingScreen({super.key});

  @override
  State<QueueTrackingScreen> createState() => _QueueTrackingScreenState();
}

class _QueueTrackingScreenState extends State<QueueTrackingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthService>();
      final queue = context.read<QueueService>();
      queue.watchPatientQueue(auth.patientId);
      final entry = queue.activeEntryForPatient(auth.patientId);
      if (entry != null) queue.watchDoctorQueue(entry.doctorId);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final queue = context.watch<QueueService>();
    final data = context.watch<ClinicDataService>();
    final entry = queue.activeEntryForPatient(auth.patientId);

    if (entry == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.queueTracking),
          backgroundColor: AppTheme.patientColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 72, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(l10n.noActiveQueue, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text(l10n.bookQueueHint, style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.search),
                label: Text(l10n.searchDoctors),
              ),
            ],
          ),
        ),
      );
    }

    final doctor = data.doctorById(entry.doctorId);
    final ahead = queue.peopleAhead(entry);
    final current = queue.currentServingNumber(entry.doctorId) ?? 0;
    final waitMin = queue.estimatedWaitMinutes(entry);
    final isYourTurn = entry.status == QueueStatus.inProgress;

    return Scaffold(
      backgroundColor: AppTheme.medicalWhite,
      appBar: AppBar(
        title: Text(l10n.queueTracking),
        backgroundColor: AppTheme.patientColor,
      ),
      body: ResponsiveBody(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) => Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.medicalBlue.withOpacity(
                                0.15 + _pulseController.value * 0.05,
                              ),
                              AppTheme.medicalGreen.withOpacity(
                                0.1 + _pulseController.value * 0.05,
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: child,
                      ),
                      child: Column(
                        children: [
                          if (isYourTurn) ...[
                            const PulseDot(size: 16),
                            const SizedBox(height: 12),
                            Text(
                              l10n.yourTurn,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.medicalGreen,
                              ),
                            ),
                          ],
                          AnimatedQueueNumber(
                            number: entry.position,
                            label: isYourTurn ? l10n.yourTurn : l10n.queueNumber,
                            color: isYourTurn
                                ? AppTheme.medicalGreen
                                : AppTheme.medicalBlue,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.people_outline,
                            label: l10n.peopleAhead,
                            value: '$ahead',
                            color: AppTheme.medicalBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.timer_outlined,
                            label: l10n.waitTime,
                            value: l10n.minutesShort(waitMin),
                            color: AppTheme.medicalGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _MetricTile(
                      icon: Icons.confirmation_number_outlined,
                      label: l10n.currentQueueNumber,
                      value: '$current',
                      color: AppTheme.secretaryColor,
                      fullWidth: true,
                    ),
                    const SizedBox(height: 20),
                    if (doctor != null) ...[
                      InfoTile(
                        icon: Icons.person,
                        label: l10n.doctor,
                        value: doctor.name.localized(context),
                      ),
                      const SizedBox(height: 8),
                      InfoTile(
                        icon: Icons.local_hospital_outlined,
                        label: l10n.clinic,
                        value: doctor.clinic.name.localized(context),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(
                      '/chat?clinicId=${doctor?.clinicId ?? 'clinic_erbil_1'}',
                    ),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text(l10n.chatWithSecretary),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      await queue.cancelEntry(entry.id, entry.doctorId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.queueCancelled)),
                        );
                        context.go('/home');
                      }
                    },
                    style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
