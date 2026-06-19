import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/medical_ui.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/appointment.dart';
import '../../../models/queue_entry.dart';
import '../../../models/specialty.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/queue_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/language_picker.dart';
import '../../providers/app_providers.dart';
import 'doctor_list_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthService>();
      context.read<AppointmentProvider>().watchPatient(auth.patientId);
      context.read<NotificationProvider>().watch(auth.patientId);
      context.read<QueueService>().watchPatientQueue(auth.patientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final notifications = context.watch<NotificationProvider>();
    final appointments = context.watch<AppointmentProvider>();
    final queue = context.watch<QueueService>();
    final activeQueue = queue.activeEntryForPatient(auth.patientId);

    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: [
          _HomeTab(
            userName: auth.currentUser?.name.localized(context) ?? '',
            upcomingCount: appointments.appointments
                .where((a) => a.isPending || a.isAccepted)
                .length,
            activeQueue: activeQueue,
            onQueueTap: () => context.push('/queue'),
          ),
          const _DoctorsTab(),
          _AppointmentsTab(appointments: appointments.appointments),
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
            label: l10n.searchDoctors,
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_note_outlined),
            selectedIcon: const Icon(Icons.event_note),
            label: l10n.myAppointments,
          ),
        ],
      ),
      floatingActionButton: activeQueue != null
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/queue'),
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
    required this.upcomingCount,
    required this.activeQueue,
    required this.onQueueTap,
  });

  final String userName;
  final int upcomingCount;
  final QueueEntry? activeQueue;
  final VoidCallback onQueueTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = context.watch<ClinicDataService>();
    final auth = context.watch<AuthService>();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: MedicalGradientHeader(
            title: l10n.welcomeUser(userName),
            subtitle: l10n.appSubtitle,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () => context.push('/notifications'),
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
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (activeQueue != null)
                _ActiveQueueBanner(entry: activeQueue!, onTap: onQueueTap),
              Row(
                children: [
                  Expanded(
                    child: MedicalStatCard(
                      icon: Icons.event_available,
                      label: l10n.myAppointments,
                      value: '$upcomingCount',
                      color: AppTheme.medicalBlue,
                      onTap: () => context.push('/appointments'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MedicalStatCard(
                      icon: Icons.chat_bubble_outline,
                      label: l10n.chatWithSecretary,
                      value: '💬',
                      color: AppTheme.secretaryColor,
                      onTap: () => context.push(
                        '/chat?clinicId=clinic_erbil_1',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SectionHeader(
                title: l10n.medicalSpecialties,
                action: TextButton(
                  onPressed: () => context.push('/doctors'),
                  child: Text(l10n.searchDoctors),
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
                itemCount: data.specialties.length,
                itemBuilder: (context, index) {
                  final specialty = data.specialties[index];
                  return _SpecialtyCard(specialty: specialty);
                },
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ActiveQueueBanner extends StatelessWidget {
  const _ActiveQueueBanner({required this.entry, required this.onTap});

  final QueueEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final queue = context.watch<QueueService>();
    if (entry.doctorId.isNotEmpty) {
      context.read<QueueService>().watchDoctorQueue(entry.doctorId);
    }
    final current = queue.currentServingNumber(entry.doctorId) ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 0,
        color: AppTheme.medicalGreen.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.medicalGreen.withOpacity(0.3)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const PulseDot(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.myQueue,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${l10n.queueNumber}: ${entry.position} • ${l10n.currentQueueNumber}: $current',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.medicalGreen),
              ],
            ),
          ),
        ),
      ),
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
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorsTab extends StatelessWidget {
  const _DoctorsTab();

  @override
  Widget build(BuildContext context) {
    return const TabibDoctorListScreen(embedded: true);
  }
}

class _AppointmentsTab extends StatelessWidget {
  const _AppointmentsTab({required this.appointments});

  final List<Appointment> appointments;

  @override
  Widget build(BuildContext context) {
    return AppointmentHistoryScreen(
      embedded: true,
      appointments: appointments,
    );
  }
}
