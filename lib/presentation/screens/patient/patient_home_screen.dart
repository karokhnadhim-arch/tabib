import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/provider_catalog_mode.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/patient_profile_service.dart';
import '../../../services/recently_visited_service.dart';
import '../../../services/staff_data_service.dart';
import '../../../services/queue_service.dart';
import '../../providers/app_providers.dart';
import 'doctor_list_screen.dart';
import 'my_queues_screen.dart';
import 'patient_dashboard_tab.dart';
import 'patient_profile_screen.dart';

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
      context.read<QueueService>().watchPatientQueues(auth.patientId);
      context.read<AppointmentProvider>().watchPatient(auth.patientId);
      context.read<PrescriptionProvider>().watchPatient(auth.patientId);
      context.read<InvestigationRequestProvider>().watchPatient(auth.patientId);
      await context.read<PatientProfileService>().bindUser(auth.patientId);
      await context.read<RecentlyVisitedService>().bindUser(auth.patientId);
      await data.ensureCatalogLoaded();
      data.startRealtimeCatalog();
      data.syncProviderLoginIndex(staffData.staff);
      await data.ensureFullProviderCatalog(ProviderCatalogMode.doctors);
      await data.ensureFullProviderCatalog(ProviderCatalogMode.businesses);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final queue = context.watch<QueueService>();
    final activeQueues = queue.activeQueuesForPatient(auth.patientId);

    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: [
          PatientDashboardTab(
            onQueuesTap: () => setState(() => _navIndex = 3),
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
          const MyQueuesScreen(embedded: true),
          const PatientProfileScreen(embedded: true),
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
            icon: Badge(
              isLabelVisible: activeQueues.isNotEmpty,
              label: Text('${activeQueues.length}'),
              child: const Icon(Icons.queue_play_next_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: activeQueues.isNotEmpty,
              label: Text('${activeQueues.length}'),
              child: const Icon(Icons.queue_play_next),
            ),
            label: l10n.myQueues,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.patientProfile,
          ),
        ],
      ),
      floatingActionButton: activeQueues.isNotEmpty && _navIndex != 3
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => _navIndex = 3),
              backgroundColor: AppTheme.medicalGreen,
              icon: Badge(
                isLabelVisible: activeQueues.length > 1,
                label: Text('${activeQueues.length}'),
                child: const Icon(Icons.queue_play_next),
              ),
              label: Text(
                activeQueues.length > 1 ? l10n.myQueues : l10n.myQueue,
              ),
            )
          : null,
    );
  }
}
