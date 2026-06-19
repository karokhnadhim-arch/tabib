import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/medical_ui.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/doctor.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/queue_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../widgets/common_widgets.dart';

class TabibDoctorDetailScreen extends StatefulWidget {
  const TabibDoctorDetailScreen({super.key, required this.doctorId});

  final String doctorId;

  @override
  State<TabibDoctorDetailScreen> createState() =>
      _TabibDoctorDetailScreenState();
}

class _TabibDoctorDetailScreenState extends State<TabibDoctorDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QueueService>().watchDoctorQueue(widget.doctorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = context.watch<ClinicDataService>();
    final queue = context.watch<QueueService>();
    final doctor = data.doctorById(widget.doctorId);

    if (doctor == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.doctor)),
        body: Center(child: Text(l10n.noDoctorsFound)),
      );
    }

    final inQueue = queue.queueForDoctor(widget.doctorId).length;
    final current = queue.currentServingNumber(widget.doctorId) ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.medicalWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.patientColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.medicalBlue,
                      AppTheme.medicalBlueDark,
                      AppTheme.medicalGreen,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Icon(
                          SpecialtyIcon.forName(doctor.specialty.iconName),
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        doctor.name.localized(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        doctor.specialty.name.localized(context),
                        style: TextStyle(color: Colors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(
                      child: MedicalStatCard(
                        icon: Icons.star,
                        label: l10n.rating,
                        value: '${doctor.rating}',
                        color: Colors.amber.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MedicalStatCard(
                        icon: Icons.groups_outlined,
                        label: l10n.inQueue,
                        value: '$inQueue',
                        color: AppTheme.medicalBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                MedicalStatCard(
                  icon: Icons.confirmation_number_outlined,
                  label: l10n.currentQueueNumber,
                  value: '$current',
                  color: AppTheme.medicalGreen,
                ),
                const SizedBox(height: 20),
                SectionHeader(title: l10n.info),
                Text(doctor.bio.localized(context)),
                const SizedBox(height: 16),
                InfoTile(
                  icon: Icons.local_hospital_outlined,
                  label: l10n.clinic,
                  value: doctor.clinic.name.localized(context),
                ),
                const SizedBox(height: 8),
                InfoTile(
                  icon: Icons.location_on_outlined,
                  label: l10n.address,
                  value: doctor.clinic.address.localized(context),
                ),
                const SizedBox(height: 8),
                InfoTile(
                  icon: Icons.phone_outlined,
                  label: l10n.phone,
                  value: doctor.clinic.phone,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.push('/doctors/${widget.doctorId}/book'),
                  icon: const Icon(Icons.event_available),
                  label: Text(l10n.bookAppointment),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.medicalBlue,
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _bookQueue(context, doctor),
                  icon: const Icon(Icons.queue_play_next),
                  label: Text(l10n.bookQueue),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: AppTheme.medicalGreen,
                    side: const BorderSide(color: AppTheme.medicalGreen),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bookQueue(BuildContext context, Doctor doctor) async {
    final auth = context.read<AuthService>();
    final l10n = AppLocalizations.of(context);
    final entry = await context.read<QueueService>().bookQueue(
      doctorId: doctor.id,
      patientId: auth.patientId,
      patientName: auth.currentUser?.name.localized(context) ?? '',
      patientPhone: auth.currentUser?.phone ?? '',
    );
    if (!context.mounted) return;
    if (entry != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.bookSuccess(entry.position))),
      );
      context.push('/queue');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.alreadyHasQueue)),
      );
    }
  }
}
