import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/medical_ui.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/appointment.dart';
import '../../../models/queue_entry.dart';
import '../../../models/visit_status.dart';
import '../../../services/auth_service.dart';
import '../../../services/queue_service.dart';
import '../../../utils/localization_utils.dart';
import '../../providers/app_providers.dart';
import 'daily_schedule_screen.dart';
import 'register_patient_screen.dart';

class SecretaryDashboardScreen extends StatefulWidget {
  const SecretaryDashboardScreen({super.key});

  @override
  State<SecretaryDashboardScreen> createState() =>
      _SecretaryDashboardScreenState();
}

class _SecretaryDashboardScreenState extends State<SecretaryDashboardScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthService>();
      final clinicId = auth.currentUser?.clinicId ?? 'clinic_erbil_1';
      context.read<AppointmentProvider>().watchDailySchedule(
            clinicId,
            DateTime.now(),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final appointments = context.watch<AppointmentProvider>();
    final clinicId = auth.currentUser?.clinicId ?? 'clinic_erbil_1';

    return Scaffold(
      backgroundColor: AppTheme.medicalWhite,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: MedicalGradientHeader(
              title: l10n.secretaryDashboard,
              subtitle: l10n.roleSecretary,
              height: 140,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.secretaryColor.withOpacity(0.15),
                      child: const Icon(Icons.support_agent, color: AppTheme.secretaryColor),
                    ),
                    title: Text(auth.currentUser?.name.localized(context) ?? ''),
                    subtitle: Text(l10n.roleSecretary),
                  ),
                ),
                const SizedBox(height: 12),
                ResponsiveSegmentedButton<int>(
                  segments: [
                    ButtonSegment(value: 0, label: Text(l10n.manageAppointments)),
                    ButtonSegment(value: 1, label: Text(l10n.registerPatient)),
                    ButtonSegment(value: 2, label: Text(l10n.dailySchedule)),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (v) => setState(() => _tab = v.first),
                ),
                const SizedBox(height: 16),
                if (_tab == 0)
                  _WorkflowAppointmentsTab(
                    appointments: appointments.appointments,
                    clinicId: clinicId,
                  )
                else if (_tab == 1)
                  RegisterPatientScreen(clinicId: clinicId)
                else
                  SizedBox(
                    height: 500,
                    child: DailyScheduleScreen(clinicId: clinicId),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkflowAppointmentsTab extends StatelessWidget {
  const _WorkflowAppointmentsTab({
    required this.appointments,
    required this.clinicId,
  });

  final List<Appointment> appointments;
  final String clinicId;

  String _visitLabel(AppLocalizations l10n, VisitStatus status) {
    switch (status) {
      case VisitStatus.arrived:
        return l10n.statusArrived;
      case VisitStatus.absent:
        return l10n.statusAbsent;
      case VisitStatus.inExamination:
        return l10n.statusInExamination;
      case VisitStatus.followUp:
        return l10n.statusFollowUp;
      case VisitStatus.scheduled:
        return l10n.statusPending;
    }
  }

  Color _visitColor(VisitStatus status) {
    switch (status) {
      case VisitStatus.arrived:
        return AppTheme.medicalBlue;
      case VisitStatus.absent:
        return Colors.red;
      case VisitStatus.inExamination:
        return AppTheme.medicalGreen;
      case VisitStatus.followUp:
        return Colors.orange;
      case VisitStatus.scheduled:
        return Colors.grey;
    }
  }

  Future<void> _syncQueueWith(
    QueueService queue,
    Appointment appointment,
    QueueStatus status,
  ) async {
    final patientId = appointment.patientId;
    final doctorId = appointment.doctorId;
    if (patientId == null || doctorId == null) return;
    await queue.syncPatientQueueStatus(
      patientId: patientId,
      doctorId: doctorId,
      status: status,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<AppointmentProvider>();
    final today = appointments
        .where((a) =>
            a.status == AppointmentStatus.accepted ||
            a.status == AppointmentStatus.pending)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    if (today.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(child: Text(l10n.noAppointmentsYet)),
      );
    }

    return Column(
      children: today.map((a) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.patientName ?? l10n.patientName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text('${a.doctorName} • ${a.specialty}'),
                          Text(DateFormat.jm().format(a.dateTime)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _visitColor(a.visitStatus).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _visitLabel(l10n, a.visitStatus),
                        style: TextStyle(
                          color: _visitColor(a.visitStatus),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    MedicalActionChip(
                      icon: Icons.login,
                      label: l10n.markEntered,
                      color: AppTheme.medicalBlue,
                      onTap: () async {
                        final queue = context.read<QueueService>();
                        await provider.markArrived(a.id);
                        if (!context.mounted) return;
                        await _syncQueueWith(queue, a, QueueStatus.inProgress);
                      },
                    ),
                    MedicalActionChip(
                      icon: Icons.person_off_outlined,
                      label: l10n.markAbsent,
                      color: Colors.red,
                      onTap: () async {
                        final queue = context.read<QueueService>();
                        await provider.markAbsent(a.id);
                        if (!context.mounted) return;
                        await _syncQueueWith(queue, a, QueueStatus.absent);
                      },
                    ),
                    MedicalActionChip(
                      icon: Icons.medical_services_outlined,
                      label: l10n.sendToExamination,
                      color: AppTheme.medicalGreen,
                      onTap: () async {
                        final queue = context.read<QueueService>();
                        await provider.sendToExamination(a.id);
                        if (!context.mounted) return;
                        await _syncQueueWith(queue, a, QueueStatus.sentForTests);
                      },
                    ),
                    MedicalActionChip(
                      icon: Icons.event_repeat,
                      label: l10n.addFollowUp,
                      color: Colors.orange,
                      onTap: () async {
                        final queue = context.read<QueueService>();
                        await provider.addFollowUp(a.id);
                        if (!context.mounted) return;
                        await _syncQueueWith(queue, a, QueueStatus.followUp);
                      },
                    ),
                    MedicalActionChip(
                      icon: Icons.arrow_upward,
                      label: l10n.moveAppointmentUp,
                      color: AppTheme.secretaryColor,
                      onTap: () => provider.moveAppointment(a.id, -1),
                    ),
                    MedicalActionChip(
                      icon: Icons.arrow_downward,
                      label: l10n.moveAppointmentDown,
                      color: AppTheme.secretaryColor,
                      onTap: () => provider.moveAppointment(a.id, 1),
                    ),
                    MedicalActionChip(
                      icon: Icons.chat_bubble_outline,
                      label: l10n.chatWithSecretary,
                      color: AppTheme.medicalBlueDark,
                      onTap: () {
                        if (a.patientId != null) {
                          context.push(
                            '/chat?clinicId=$clinicId&patientId=${a.patientId}&name=${Uri.encodeComponent(a.patientName ?? '')}',
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
