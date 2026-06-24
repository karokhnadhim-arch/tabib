import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/queue_service.dart';
import '../../../utils/localization_utils.dart';
import '../../providers/app_providers.dart';
import 'daily_schedule_screen.dart';
import 'register_patient_screen.dart';
import 'secretary_queue_management_tab.dart';
import '../../../core/widgets/medical_ui.dart';

class SecretaryDashboardScreen extends StatefulWidget {
  const SecretaryDashboardScreen({super.key});

  @override
  State<SecretaryDashboardScreen> createState() =>
      _SecretaryDashboardScreenState();
}

class _SecretaryDashboardScreenState extends State<SecretaryDashboardScreen> {
  int _tab = 0;
  String? _watchedDoctorId;
  QueueService? _queueService;

  String? get _linkedDoctorId =>
      context.read<AuthService>().currentUser?.linkedDoctorId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startWatching());
  }

  void _startWatching() {
    final doctorId = _linkedDoctorId;
    if (doctorId == null || doctorId.isEmpty) return;

    _queueService = context.read<QueueService>();
    _queueService!.watchSecretaryQueue(doctorId);
    _queueService!.watchDoctorQueue(doctorId);
    context.read<AppointmentProvider>().watchDoctor(doctorId);
    _watchedDoctorId = doctorId;
  }

  @override
  void dispose() {
    if (_watchedDoctorId != null) {
      _queueService?.stopWatchingDoctorQueue(_watchedDoctorId);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final clinicData = context.watch<ClinicDataService>();
    final linkedDoctorId = auth.currentUser?.linkedDoctorId;
    final clinicId = auth.currentUser?.clinicId ?? 'clinic_erbil_1';
    final doctor = linkedDoctorId != null
        ? clinicData.doctorById(linkedDoctorId)
        : null;

    return Scaffold(
      backgroundColor: AppTheme.medicalWhite,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: MedicalGradientHeader(
              title: l10n.secretaryDashboard,
              subtitle: doctor != null
                  ? doctor.name.localized(context)
                  : l10n.roleSecretary,
              height: 140,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppTheme.secretaryColor.withOpacity(0.15),
                      child: const Icon(
                        Icons.support_agent,
                        color: AppTheme.secretaryColor,
                      ),
                    ),
                    title: Text(auth.currentUser?.name.localized(context) ?? ''),
                    subtitle: Text(
                      doctor != null
                          ? '${l10n.roleSecretary} · ${doctor.name.localized(context)}'
                          : l10n.roleSecretary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ResponsiveSegmentedButton<int>(
                  segments: [
                    ButtonSegment(
                      value: 0,
                      label: Text(l10n.queueManagement),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: Text(l10n.registerPatient),
                    ),
                    ButtonSegment(
                      value: 2,
                      label: Text(l10n.dailySchedule),
                    ),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (v) => setState(() => _tab = v.first),
                ),
                const SizedBox(height: 16),
                if (_tab == 0)
                  linkedDoctorId != null && linkedDoctorId.isNotEmpty
                      ? SecretaryQueueManagementTab(
                          doctorId: linkedDoctorId,
                          clinicId: clinicId,
                        )
                      : SizedBox(
                          height: 200,
                          child: Center(child: Text(l10n.noAssignedDoctor)),
                        )
                else if (_tab == 1)
                  RegisterPatientScreen(clinicId: clinicId)
                else
                  linkedDoctorId != null && linkedDoctorId.isNotEmpty
                      ? SizedBox(
                          height: 500,
                          child: DailyScheduleScreen(
                            clinicId: clinicId,
                            doctorId: linkedDoctorId,
                          ),
                        )
                      : SizedBox(
                          height: 200,
                          child: Center(child: Text(l10n.noAssignedDoctor)),
                        ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
