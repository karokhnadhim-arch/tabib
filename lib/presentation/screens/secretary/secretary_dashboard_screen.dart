import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/responsive.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../core/utils/clinic_subscription.dart';
import '../../../presentation/screens/subscription/subscription_expired_screen.dart';
import '../../../presentation/widgets/subscription_status_badge.dart';
import '../../../services/queue_service.dart';
import '../../../core/utils/account_code_resolver.dart';
import '../../../presentation/widgets/account_code_badge.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/provider_labels.dart';
import '../../layouts/clinical_workspace_shell.dart';
import '../../widgets/desktop/clinical_shortcuts.dart';
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
  bool _scheduleOnlyMode = false;
  String? _watchedDoctorId;
  QueueService? _queueService;
  final _searchFocusNode = FocusNode();

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

    final data = context.read<ClinicDataService>();
    data.ensureCatalogLoaded();
    data.startRealtimeCatalog();

    _queueService = context.read<QueueService>();
    _queueService!.watchSecretaryQueue(doctorId);
    context.read<AppointmentProvider>().watchDoctor(doctorId);
    context.read<InvestigationRequestProvider>().watchDoctor(doctorId);
    final userId = context.read<AuthService>().currentUser?.id;
    if (userId != null && userId.isNotEmpty) {
      context.read<NotificationProvider>().watch(userId);
    }
    _watchedDoctorId = doctorId;
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
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
    final doctor = linkedDoctorId != null
        ? clinicData.doctorById(linkedDoctorId)
        : null;
    final resolvedClinicId =
        doctor?.clinicId ?? auth.currentUser?.clinicId ?? 'clinic_erbil_1';
    final clinicId = resolvedClinicId;
    final clinic = clinicData.clinicById(resolvedClinicId);
    final subscriptionStatus =
        clinic != null ? ClinicSubscriptionHelper.statusFor(clinic) : null;
    final remainingDays =
        clinic != null ? ClinicSubscriptionHelper.remainingDays(clinic) : 0;

    if (clinic != null &&
        ClinicSubscriptionHelper.isExpired(clinic) &&
        !_scheduleOnlyMode) {
      return SubscriptionExpiredScreen(
        clinic: clinic,
        onViewRecords: () => setState(() {
          _scheduleOnlyMode = true;
          _tab = 2;
        }),
        onRenewed: () => setState(() => _scheduleOnlyMode = false),
      );
    }

    final desktop = isClinicalDesktop(context);
    final destinations = [
      ClinicalNavDestination(
        icon: Icons.queue_play_next_outlined,
        selectedIcon: Icons.queue_play_next,
        label: l10n.queueManagement,
      ),
      ClinicalNavDestination(
        icon: Icons.person_add_outlined,
        selectedIcon: Icons.person_add,
        label: l10n.registerPatient,
      ),
      ClinicalNavDestination(
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month,
        label: l10n.dailySchedule,
      ),
    ];

    Widget tabContent;
    if (_tab == 0) {
      tabContent = linkedDoctorId != null && linkedDoctorId.isNotEmpty
          ? SecretaryQueueManagementTab(
              doctorId: linkedDoctorId,
              clinicId: clinicId,
              expanded: desktop,
              searchFocusNode: _searchFocusNode,
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text(l10n.noAssignedDoctor)),
            );
    } else if (_tab == 1) {
      tabContent = linkedDoctorId != null && linkedDoctorId.isNotEmpty
          ? RegisterPatientScreen(
              clinicId: clinicId,
              doctorId: linkedDoctorId,
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text(l10n.noAssignedDoctor)),
            );
    } else {
      tabContent = linkedDoctorId != null && linkedDoctorId.isNotEmpty
          ? DailyScheduleScreen(
              clinicId: clinicId,
              doctorId: linkedDoctorId,
              embedded: true,
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text(l10n.noAssignedDoctor)),
            );
    }

    if (desktop) {
      return ClinicalShortcutScope(
        shortcuts: ClinicalShortcuts.secretaryMap(),
        onAction: (index) {
          if (index == 0) {
            setState(() => _tab = 0);
            _searchFocusNode.requestFocus();
          } else if (index >= 1 && index <= 3) {
            setState(() => _tab = index - 1);
          }
        },
        child: ClinicalWorkspaceShell(
          title: l10n.secretaryDashboard,
          accentColor: AppTheme.secretaryColor,
          selectedIndex: _tab,
          destinations: destinations,
          onDestinationSelected: (i) => setState(() => _tab = i),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              tooltip: l10n.settings,
              onPressed: () => context.push('/settings'),
            ),
          ],
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox.expand(child: tabContent),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.medicalWhite,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child:             MedicalGradientHeader(
              title: l10n.secretaryDashboard,
              subtitle: doctor != null
                  ? doctor.name.localized(context)
                  : l10n.roleSecretary,
              height: 140,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  tooltip: l10n.settings,
                  onPressed: () => context.push('/settings'),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (subscriptionStatus == ClinicSubscriptionStatus.expiringSoon &&
                    clinic != null)
                  ResponsiveInfoBanner(
                    margin: const EdgeInsets.only(bottom: 12),
                    icon: const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFF9A825)),
                    message: Text(
                      l10n.subscriptionExpiringBanner(remainingDays),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    backgroundColor: const Color(0xFFFFF8E1),
                    borderColor: const Color(0xFFF9A825),
                    trailing: SubscriptionStatusBadge(
                      status: subscriptionStatus!,
                      remainingDays: remainingDays,
                      compact: true,
                    ),
                  ),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(
                          Icons.link,
                          color: AppTheme.primaryDark.withOpacity(0.7),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ProviderLabels.linkedProviderLabel(
                                  l10n,
                                  doctor,
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                doctor != null
                                    ? doctor.name.localized(context)
                                    : l10n.noAssignedDoctor,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (doctor != null) ...[
                                const SizedBox(height: 8),
                                Builder(
                                  builder: (context) {
                                    final code = AccountCodeResolver.forDoctor(
                                      doctor,
                                    );
                                    if (code == null) {
                                      return const SizedBox.shrink();
                                    }
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.doctorAccountCodeLabel(code),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        AccountCodeBadge(
                                          code: code,
                                          compact: true,
                                          onCopy: () => AccountCodeBadge
                                              .copyToClipboard(context, code),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
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
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: Text(l10n.noAssignedDoctor)),
                        )
                else if (_tab == 1)
                  linkedDoctorId != null && linkedDoctorId.isNotEmpty
                      ? RegisterPatientScreen(
                          clinicId: clinicId,
                          doctorId: linkedDoctorId,
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: Text(l10n.noAssignedDoctor)),
                        )
                else
                  linkedDoctorId != null && linkedDoctorId.isNotEmpty
                      ? DailyScheduleScreen(
                          clinicId: clinicId,
                          doctorId: linkedDoctorId,
                          embedded: true,
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
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
