import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/appointment.dart';
import '../../../models/doctor.dart';
import '../../../core/utils/clinic_subscription.dart';
import '../../../models/clinic.dart';
import '../../../presentation/screens/subscription/subscription_expired_screen.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/queue_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/provider_labels.dart';
import '../../../utils/schedule_utils.dart';
import '../../widgets/staff_patient_contact_bar.dart';
import '../../layouts/clinical_workspace_shell.dart';
import '../../widgets/desktop/clinical_shortcuts.dart';
import '../../providers/app_providers.dart';
import '../../widgets/doctor_avatar.dart';
import '../../widgets/doctor_schedule_view.dart';
import 'patient_records_screen.dart';
import 'doctor_queue_tab.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  bool _recordsOnlyMode = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openPatientRecords() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthService>();
      final data = context.read<ClinicDataService>();
      data.ensureCatalogLoaded();
      data.startRealtimeCatalog();
      final doctorId = auth.currentUser?.doctorId ?? '';
      final userId = auth.currentUser?.id;
      if (userId != null && userId.isNotEmpty) {
        context.read<NotificationProvider>().watch(userId);
      }
      if (doctorId.isNotEmpty) {
        context.read<AppointmentProvider>().watchDoctor(doctorId);
        context.read<QueueService>().watchSecretaryQueue(doctorId);
      }
    });
  }

  Clinic? _clinicForUser(ClinicDataService data, AuthService auth) {
    final clinicId = auth.currentUser?.clinicId;
    if (clinicId == null || clinicId.isEmpty) return null;
    return data.clinicById(clinicId);
  }

  @override
  void dispose() {
    final auth = context.read<AuthService>();
    final doctorId = auth.currentUser?.doctorId;
    if (doctorId != null && doctorId.isNotEmpty) {
      context.read<QueueService>().stopWatchingDoctorQueue(doctorId);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final data = context.watch<ClinicDataService>();
    final doctorId = auth.currentUser?.doctorId ?? '';
    final doctor = doctorId.isEmpty ? null : data.doctorById(doctorId);
    final clinic = _clinicForUser(data, auth);

    if (clinic != null &&
        ClinicSubscriptionHelper.isExpired(clinic) &&
        !_recordsOnlyMode) {
      return SubscriptionExpiredScreen(
        clinic: clinic,
        onViewRecords: () => setState(() => _recordsOnlyMode = true),
        onRenewed: () => setState(() => _recordsOnlyMode = false),
      );
    }

    final body = _recordsOnlyMode
        ? const PatientRecordsScreen()
        : DoctorQueueTab(doctorId: doctorId);

    final appBarActions = [
      if (!_recordsOnlyMode)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: TextButton.icon(
            onPressed: _openPatientRecords,
            icon: const Icon(Icons.folder_shared_rounded, size: 22),
            label: Text(l10n.patientRecords),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.white.withOpacity(0.18),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      if (auth.canAccessAdminPanel && !auth.isSystemOwner)
        IconButton(
          icon: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white),
          tooltip: l10n.adminControlPanel,
          onPressed: () => context.push('/owner/console'),
        ),
      IconButton(
        icon: const Icon(Icons.edit_outlined, color: Colors.white),
        tooltip: ProviderLabels.editProfileTitle(l10n, doctor),
        onPressed: () => context.push('/doctor/profile'),
      ),
      IconButton(
        icon: const Icon(Icons.settings_outlined, color: Colors.white),
        tooltip: l10n.settings,
        onPressed: () => context.push('/settings'),
      ),
      IconButton(
        icon: const Icon(Icons.logout, color: Colors.white),
        onPressed: () async {
          await auth.logout();
          if (!context.mounted) return;
          context.go('/login');
        },
      ),
    ];

    return ClinicalShortcutScope(
      shortcuts: ClinicalShortcuts.doctorMap(),
      onAction: (index) {
        if (index == 4) _openPatientRecords();
      },
      child: ClinicalWorkspaceShell(
        scaffoldKey: _scaffoldKey,
        endDrawer: _recordsOnlyMode
            ? null
            : _DoctorPatientRecordsDrawer(l10n: l10n),
        title: ProviderLabels.dashboardTitle(l10n, doctor),
        headerTitle: _recordsOnlyMode ? l10n.patientRecords : l10n.todaysQueue,
        accentColor: AppTheme.doctorColor,
        showNavigationRail: false,
        selectedIndex: 0,
        destinations: const [],
        onDestinationSelected: (_) {},
        actions: appBarActions,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox.expand(child: body),
        ),
      ),
    );
  }
}

class _DoctorPatientRecordsDrawer extends StatelessWidget {
  const _DoctorPatientRecordsDrawer({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Drawer(
      width: width >= 480 ? 400 : width * 0.92,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 8, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.doctorColor, AppTheme.medicalGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.folder_shared_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.patientRecords,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.searchPatientsHint,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: PatientRecordsScreen(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorProfilePreview extends StatelessWidget {
  const _DoctorProfilePreview({
    required this.doctor,
    required this.onEdit,
    required this.onViewPublic,
  });

  final Doctor doctor;
  final VoidCallback onEdit;
  final VoidCallback onViewPublic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final degree = doctor.academicDegree?.localized(context);
    final workingDays = doctor.workingDays ?? const <int>[];
    final hasStructuredSchedule = doctor.patientShowsStructuredSchedule;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.doctorColor.withOpacity(0.12),
                  AppTheme.medicalGreen.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DoctorAvatar(
                  photoUrl: doctor.photoUrl,
                  thumbnailUrl: doctor.photoThumbnailUrl,
                  radius: 36,
                  backgroundColor: AppTheme.doctorColor.withOpacity(0.15),
                  fallback: Icon(
                    Icons.person,
                    size: 36,
                    color: AppTheme.doctorColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name.localized(context),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialty.name.localized(context),
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      if (degree != null && degree.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          degree,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Chip(
                            visualDensity: VisualDensity.compact,
                            label: Text(
                              l10n.yearsExperience(doctor.experienceYears),
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor:
                                AppTheme.doctorColor.withOpacity(0.1),
                          ),
                          Chip(
                            visualDensity: VisualDensity.compact,
                            avatar: Icon(
                              Icons.circle,
                              size: 10,
                              color: doctor.isAvailableToday
                                  ? AppTheme.medicalGreen
                                  : Colors.red.shade400,
                            ),
                            label: Text(
                              doctor.isAvailableToday
                                  ? l10n.availableToday
                                  : l10n.unavailable,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: doctor.isAvailableToday
                                ? AppTheme.medicalGreen.withOpacity(0.12)
                                : Colors.red.shade50,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasStructuredSchedule) ...[
                  const SizedBox(height: 12),
                  DoctorScheduleView(
                    schedule: doctor.effectiveWorkingSchedule,
                    compact: true,
                  ),
                ] else if (workingDays.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: workingDays
                        .map((d) => ScheduleUtils.weekdayLabel(l10n, d))
                        .join(' · '),
                  ),
                ],
                if (doctor.effectiveContactPhone.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    text: doctor.effectiveContactPhone,
                  ),
                ],
                const SizedBox(height: 14),
                ResponsiveActionButtons(
                  spacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(l10n.editProfile),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.doctorColor,
                        minimumSize: const Size.fromHeight(44),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onViewPublic,
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: Text(
                        l10n.viewPublicProfile,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.doctorColor,
                        side: const BorderSide(color: AppTheme.doctorColor),
                        minimumSize: const Size.fromHeight(44),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.viewPublicProfileHint,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.doctorColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _AppointmentList extends StatelessWidget {
  const _AppointmentList({
    required this.appointments,
    required this.showActions,
    required this.doctorId,
  });

  final List<Appointment> appointments;
  final bool showActions;
  final String doctorId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<AppointmentProvider>();

    if (appointments.isEmpty) {
      return Center(child: Text(l10n.noAppointmentsYet));
    }

    return ListView.separated(
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final a = appointments[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.patientName ?? l10n.patientName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                StaffPatientContactBar(
                  phone: a.patientPhone ?? '',
                  patientName: a.patientName ?? l10n.patientName,
                  doctorId: doctorId,
                  doctorName: a.doctorName,
                  patientId: a.patientId,
                  compact: true,
                ),
                const SizedBox(height: 6),
                Text(DateFormat.yMMMd().add_jm().format(a.dateTime)),
                if (a.notes != null && a.notes!.isNotEmpty)
                  Text('${l10n.notesOptional}: ${a.notes}'),
                if (showActions) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () => provider.accept(a.id),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.medicalGreen,
                          ),
                          child: Text(l10n.accept),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => provider.reject(a.id),
                          child: Text(l10n.reject),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (a.patientId != null)
                    OutlinedButton.icon(
                      onPressed: () => context.push(
                        '/doctor/prescription/${a.patientId}?name=${Uri.encodeComponent(a.patientName ?? '')}',
                      ),
                      icon: const Icon(Icons.medication),
                      label: Text(l10n.writePrescription),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
