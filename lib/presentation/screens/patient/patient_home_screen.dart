import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/medical_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/provider_catalog_mode.dart';
import '../../../models/queue_entry.dart';
import '../../../models/specialty.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/staff_data_service.dart';
import '../../../services/queue_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/language_picker.dart';
import '../../providers/app_providers.dart';
import '../../widgets/simple_queue_circles.dart';
import 'doctor_list_screen.dart';
import 'queue_tracking_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthService>();
      final data = context.read<ClinicDataService>();
      final staffData = context.read<StaffDataService>();
      staffData.startRealtime();
      context.read<NotificationProvider>().watch(auth.patientId);
      context.read<QueueService>().watchPatientQueue(auth.patientId);
      await data.ensureCatalogLoaded();
      data.startRealtimeCatalog();
      data.syncProviderLoginIndex(staffData.staff);
      await data.ensureFullProviderCatalog(ProviderCatalogMode.doctors);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final queue = context.watch<QueueService>();
    final activeQueue = queue.activeEntryForPatient(auth.patientId);

    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: [
          _HomeTab(
            userName: auth.currentUser?.name.localized(context) ?? '',
            activeQueue: activeQueue,
            onQueueTap: () => setState(() => _navIndex = 3),
            onDoctorsTap: () => setState(() => _navIndex = 1),
            onBusinessesTap: () => setState(() => _navIndex = 2),
          ),
          const TabibDoctorListScreen(
            embedded: true,
            catalogMode: ProviderCatalogMode.doctors,
          ),
          const TabibDoctorListScreen(
            embedded: true,
            catalogMode: ProviderCatalogMode.businesses,
          ),
          const QueueTrackingScreen(embedded: true),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.medical_services_outlined),
            selectedIcon: const Icon(Icons.medical_services),
            label: l10n.doctorsSection,
          ),
          NavigationDestination(
            icon: const Icon(Icons.local_hospital_outlined),
            selectedIcon: const Icon(Icons.local_hospital),
            label: l10n.clinicsHealthcareCenters,
          ),
          NavigationDestination(
            icon: const Icon(Icons.queue_play_next_outlined),
            selectedIcon: const Icon(Icons.queue_play_next),
            label: l10n.myQueue,
          ),
        ],
      ),
      floatingActionButton: activeQueue != null && _navIndex != 3
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => _navIndex = 3),
              backgroundColor: AppTheme.medicalGreen,
              icon: const Icon(Icons.queue_play_next),
              label: Text(l10n.myQueue),
            )
          : null,
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.userName,
    required this.activeQueue,
    required this.onQueueTap,
    required this.onDoctorsTap,
    required this.onBusinessesTap,
  });

  final String userName;
  final QueueEntry? activeQueue;
  final VoidCallback onQueueTap;
  final VoidCallback onDoctorsTap;
  final VoidCallback onBusinessesTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = context.watch<ClinicDataService>();
    context.watch<StaffDataService>();
    final auth = context.watch<AuthService>();
    final visibleSpecialties = data.patientVisibleDoctorSpecialties;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: MedicalGradientHeader(
            title: l10n.welcomeUser(userName),
            subtitle: l10n.appSubtitle,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                onPressed: () => context.push('/notifications'),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                tooltip: AppLocalizations.of(context).settings,
                onPressed: () => context.push('/settings'),
              ),
              const LanguagePicker(),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: _HomeQueueDashboard(
            activeQueue: activeQueue,
            onTap: onQueueTap,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SectionHeader(title: l10n.browseHealthcare),
              const SizedBox(height: 8),
              _CatalogSectionCard(
                icon: Icons.medical_services_outlined,
                title: l10n.doctorsSection,
                subtitle: l10n.browseDoctorsHint,
                color: AppTheme.medicalBlue,
                onTap: onDoctorsTap,
              ),
              const SizedBox(height: 12),
              _CatalogSectionCard(
                icon: Icons.local_hospital_outlined,
                title: l10n.clinicsHealthcareCenters,
                subtitle: l10n.browseBusinessesHint,
                color: AppTheme.medicalGreen,
                onTap: onBusinessesTap,
              ),
              const SizedBox(height: 20),
              SectionHeader(
                title: l10n.medicalSpecialties,
                action: TextButton(
                  onPressed: () => context.push('/doctors'),
                  child: Text(l10n.doctorsSection),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridCrossAxisCount(context),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                itemCount: visibleSpecialties.length,
                itemBuilder: (context, index) {
                  final specialty = visibleSpecialties[index];
                  return _SpecialtyCard(specialty: specialty);
                },
              ),
              const SizedBox(height: 12),
              MedicalStatCard(
                icon: Icons.chat_bubble_outline,
                label: l10n.chatWithClinic,
                value: '💬',
                color: AppTheme.medicalBlue,
                onTap: () => context.push('/chat?clinicId=clinic_erbil_1'),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _CatalogSectionCard extends StatelessWidget {
  const _CatalogSectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeQueueDashboard extends StatefulWidget {
  const _HomeQueueDashboard({
    required this.activeQueue,
    required this.onTap,
  });

  final QueueEntry? activeQueue;
  final VoidCallback onTap;

  @override
  State<_HomeQueueDashboard> createState() => _HomeQueueDashboardState();
}

class _HomeQueueDashboardState extends State<_HomeQueueDashboard>
    with TickerProviderStateMixin {
  static const _demoPosition = 25;
  static const _demoCurrent = 20;
  static const _demoPeopleAhead = 5;

  late final AnimationController _pulseController;
  late final AnimationController _numberController;
  late final Animation<double> _numberScale;
  String? _watchedDoctorId;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _numberController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _numberScale = CurvedAnimation(
      parent: _numberController,
      curve: Curves.elasticOut,
    );
    _numberController.forward();
    _syncDoctorQueueWatch(widget.activeQueue?.doctorId);
  }

  @override
  void didUpdateWidget(_HomeQueueDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncDoctorQueueWatch(widget.activeQueue?.doctorId);

    final oldNumber = oldWidget.activeQueue?.position ?? _demoPosition;
    final newNumber = widget.activeQueue?.position ?? _demoPosition;
    if (oldNumber != newNumber) {
      _numberController
        ..reset()
        ..forward();
    }
  }

  void _syncDoctorQueueWatch(String? doctorId) {
    if (doctorId == null || doctorId.isEmpty) {
      if (_watchedDoctorId != null) {
        context.read<QueueService>().stopWatchingDoctorQueue(_watchedDoctorId);
        _watchedDoctorId = null;
      }
      return;
    }
    if (_watchedDoctorId == doctorId) return;
    if (_watchedDoctorId != null) {
      context.read<QueueService>().stopWatchingDoctorQueue(_watchedDoctorId);
    }
    _watchedDoctorId = doctorId;
    context.read<QueueService>().watchDoctorQueue(doctorId);
  }

  @override
  void dispose() {
    if (_watchedDoctorId != null) {
      context.read<QueueService>().stopWatchingDoctorQueue(_watchedDoctorId);
    }
    _pulseController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queue = context.watch<QueueService>();
    final entry = widget.activeQueue;
    final isDemo = entry == null;

    final int myNumber;
    final int currentNumber;
    final int peopleAhead;
    if (isDemo) {
      myNumber = _demoPosition;
      currentNumber = _demoCurrent;
      peopleAhead = _demoPeopleAhead;
    } else {
      myNumber = entry.position;
      currentNumber = queue.currentServingNumber(entry) ?? 0;
      peopleAhead = queue.peopleAhead(entry);
    }

    return SimpleQueueCircles(
      myNumber: myNumber,
      currentNumber: currentNumber,
      peopleAhead: peopleAhead,
      pulseController: _pulseController,
      numberScaleAnimation: _numberScale,
      onTap: widget.onTap,
    );
  }
}

class _SpecialtyCard extends StatelessWidget {
  const _SpecialtyCard({required this.specialty});

  final Specialty specialty;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => context.push('/doctors?specialty=${specialty.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                SpecialtyIcon.forName(specialty.iconName),
                color: AppTheme.medicalBlue,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                specialty.name.localized(context),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
