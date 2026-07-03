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
import '../../../presentation/widgets/subscription_status_badge.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/queue_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/provider_labels.dart';
import '../../../utils/schedule_utils.dart';
import '../../../widgets/language_picker.dart';
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
  int _tab = 0;
  bool _recordsOnlyMode = false;

  Clinic? _clinicForUser(ClinicDataService data, AuthService auth) {
    final clinicId = auth.currentUser?.clinicId;
    if (clinicId == null || clinicId.isEmpty) return null;
    return data.clinicById(clinicId);
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
        context.read<QueueService>().watchDoctorQueue(doctorId);
      }
    });
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
    final appointments = context.watch<AppointmentProvider>();
    final doctorId = auth.currentUser?.doctorId ?? '';
    final doctor = doctorId.isEmpty ? null : data.doctorById(doctorId);
    final clinic = _clinicForUser(data, auth);
    final subscriptionStatus =
        clinic != null ? ClinicSubscriptionHelper.statusFor(clinic) : null;
    final remainingDays =
        clinic != null ? ClinicSubscriptionHelper.remainingDays(clinic) : 0;

    if (clinic != null &&
        ClinicSubscriptionHelper.isExpired(clinic) &&
        !_recordsOnlyMode) {
      return SubscriptionExpiredScreen(
        clinic: clinic,
        onViewRecords: () => setState(() {
          _recordsOnlyMode = true;
          _tab = 3;
        }),
        onRenewed: () => setState(() => _recordsOnlyMode = false),
      );
    }

    final pending = appointments.appointments
        .where((a) => a.isPending && a.doctorId == doctorId)
        .toList();
    final accepted = appointments.appointments
        .where((a) => a.isAccepted && a.doctorId == doctorId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(ProviderLabels.dashboardTitle(l10n, doctor)),
        backgroundColor: AppTheme.doctorColor,
        actions: [
          if (auth.canAccessAdminPanel)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              tooltip: l10n.adminControlPanel,
              onPressed: () => context.push('/doctor/platform'),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: ProviderLabels.editProfileTitle(l10n, doctor),
            onPressed: () => context.push('/doctor/profile'),
          ),
          const LanguagePicker(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (!context.mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
      body: ResponsiveBody(
        child: CustomScrollView(
          slivers: [
            if (subscriptionStatus == ClinicSubscriptionStatus.expiringSoon &&
                clinic != null)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF9A825)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFF9A825)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.subscriptionExpiringBanner(remainingDays),
                        ),
                      ),
                      Flexible(
                        child: SubscriptionStatusBadge(
                          status: subscriptionStatus!,
                          remainingDays: remainingDays,
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (auth.canAccessAdminPanel) ...[
                    Card(
                      color: AppTheme.primaryDark.withOpacity(0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: AppTheme.primaryDark.withOpacity(0.35),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => context.push('/doctor/platform'),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryDark.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.admin_panel_settings_outlined,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.adminControlPanel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryDark,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(l10n.adminControlPanelHint),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: AppTheme.primaryDark,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Card(
              color: AppTheme.doctorColor.withOpacity(0.06),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppTheme.doctorColor.withOpacity(0.35)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push('/doctor/profile'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.doctorColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.manage_accounts_outlined,
                          color: AppTheme.doctorColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.manageProfile,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.manageProfileHint,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppTheme.doctorColor.withOpacity(0.8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (doctor != null)
              _DoctorProfilePreview(
                doctor: doctor,
                onEdit: () => context.push('/doctor/profile'),
                onViewPublic: () => context.push('/doctors/${doctor.id}'),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor:
                                AppTheme.doctorColor.withOpacity(0.1),
                            child: const Icon(
                              Icons.medical_services,
                              color: AppTheme.doctorColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  auth.currentUser?.name.localized(context) ??
                                      '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(l10n.roleDoctor),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => context.push('/doctor/profile'),
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(ProviderLabels.editProfileTitle(l10n, doctor)),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.doctorColor,
                          minimumSize: const Size.fromHeight(44),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ResponsiveSegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(l10n.pendingRequests)),
                ButtonSegment(value: 1, label: Text(l10n.acceptedAppointments)),
                ButtonSegment(value: 2, label: Text(l10n.queueManagement)),
                ButtonSegment(value: 3, label: Text(l10n.patientRecords)),
              ],
              selected: {_tab},
              onSelectionChanged: (v) => setState(() => _tab = v.first),
            ),
            const SizedBox(height: 12),
                ],
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: true,
              child: _tab == 0
                  ? _AppointmentList(
                      appointments: pending,
                      showActions: true,
                      doctorId: doctorId,
                    )
                  : _tab == 1
                      ? _AppointmentList(
                          appointments: accepted,
                          showActions: false,
                          doctorId: doctorId,
                        )
                      : _tab == 2
                          ? DoctorQueueTab(doctorId: doctorId)
                          : const PatientRecordsScreen(),
            ),
          ],
        ),
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
                Text(a.patientPhone ?? ''),
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
