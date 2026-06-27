import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/medical_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/doctor.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/queue_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/schedule_utils.dart';
import '../../../widgets/common_widgets.dart';
import '../../widgets/doctor_avatar.dart';
import '../../widgets/doctor_location_card.dart';
import '../../widgets/doctor_schedule_view.dart';
import '../../widgets/tabib_image.dart';

class TabibDoctorDetailScreen extends StatefulWidget {
  const TabibDoctorDetailScreen({super.key, required this.doctorId});

  final String doctorId;

  @override
  State<TabibDoctorDetailScreen> createState() =>
      _TabibDoctorDetailScreenState();
}

class _TabibDoctorDetailScreenState extends State<TabibDoctorDetailScreen> {
  Doctor? _doctor;
  bool _loadingDoctor = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QueueService>().watchDoctorQueue(widget.doctorId);
      _loadDoctor();
    });
  }

  Future<void> _loadDoctor() async {
    final data = context.read<ClinicDataService>();
    var doctor = data.doctorById(widget.doctorId);
    if (doctor == null) {
      setState(() => _loadingDoctor = true);
      doctor = await data.fetchDoctorById(widget.doctorId);
      if (mounted) setState(() => _loadingDoctor = false);
    }
    if (mounted) setState(() => _doctor = doctor);
  }

  @override
  void dispose() {
    context.read<QueueService>().stopWatchingDoctorQueue(widget.doctorId);
    super.dispose();
  }

  Future<void> _openWhatsApp(String number) async {
    final digits = number.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/${digits.replaceAll('+', '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = context.watch<ClinicDataService>();
    final queue = context.watch<QueueService>();
    final doctor = _doctor ?? data.doctorById(widget.doctorId);

    if (_loadingDoctor || (doctor == null && _doctor == null)) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.doctor)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (doctor == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.doctor)),
        body: Center(child: Text(l10n.noDoctorsFound)),
      );
    }

    final inQueue = queue.queueForDoctor(widget.doctorId).length;
    final current = queue.currentServingNumber(widget.doctorId) ?? 0;
    final degree = doctor.patientVisibleDegree(context);
    final whatsapp = doctor.patientVisibleWhatsapp;
    final showContact = doctor.patientShowsPhone ||
        doctor.patientShowsWhatsapp ||
        (doctor.contactEmail != null && doctor.contactEmail!.isNotEmpty);

    return Scaffold(
      backgroundColor: AppTheme.medicalWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: doctor.patientShowsExperience && degree != null
                ? 320
                : degree != null || doctor.patientShowsExperience
                    ? 300
                    : 280,
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (doctor.patientVisiblePhotoUrl != null)
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.6),
                                    width: 3,
                                  ),
                                ),
                                child: DoctorAvatar(
                                  photoUrl: doctor.patientVisiblePhotoUrl,
                                  thumbnailUrl:
                                      doctor.patientVisiblePhotoThumbnailUrl,
                                  radius: 48,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                  fallback: Icon(
                                    SpecialtyIcon.forName(
                                        doctor.specialty.iconName),
                                    size: 44,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            else
                              Icon(
                                SpecialtyIcon.forName(
                                    doctor.specialty.iconName),
                                size: 56,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            const SizedBox(height: 12),
                            Text(
                              doctor.name.localized(context),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doctor.specialty.name.localized(context),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 15,
                              ),
                            ),
                            if (degree != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                degree,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            if (doctor.patientShowsExperience) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  l10n.yearsExperience(doctor.experienceYears),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: doctor.isAvailableToday
                                    ? Colors.white.withOpacity(0.25)
                                    : Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: doctor.isAvailableToday
                                        ? Colors.lightGreenAccent
                                        : Colors.red.shade200,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    doctor.isAvailableToday
                                        ? l10n.availableToday
                                        : l10n.unavailable,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                if (doctor.patientShowsConsultationFee) ...[
                  InfoTile(
                    icon: Icons.payments_outlined,
                    label: l10n.consultationFee,
                    value: l10n.consultationFeeAmount(
                      doctor.consultationFee!.toStringAsFixed(0),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (doctor.patientShowsBio(context)) ...[
                  SectionHeader(title: l10n.aboutDoctor),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        doctor.bio.localized(context),
                        style: TextStyle(
                          height: 1.5,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (doctor.languagesSpoken != null &&
                    doctor.languagesSpoken!.isNotEmpty) ...[
                  SectionHeader(title: l10n.languagesSpoken),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: doctor.languagesSpoken!.map((lang) {
                      return Chip(
                        avatar: const Icon(
                          Icons.translate,
                          size: 16,
                          color: AppTheme.medicalBlue,
                        ),
                        label: Text(lang),
                        backgroundColor: AppTheme.medicalBlue.withOpacity(0.08),
                        side: BorderSide(
                          color: AppTheme.medicalBlue.withOpacity(0.2),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                if (doctor.patientShowsSchedule(context)) ...[
                  SectionHeader(title: l10n.viewWorkingSchedule),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: doctor.patientShowsStructuredSchedule
                          ? DoctorScheduleView(
                              schedule: doctor.effectiveWorkingSchedule,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (doctor.patientShowsWorkingDays) ...[
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 20,
                                        color: AppTheme.medicalGreen,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.workingDays,
                                        style:
                                            TextStyle(color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: doctor.workingDays!.map((day) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.medicalGreen
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          ScheduleUtils.weekdayLabel(l10n, day),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.medicalGreen,
                                            fontSize: 13,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                if (doctor.patientShowsWorkingHours(context))
                                  InfoTile(
                                    icon: Icons.schedule,
                                    label: l10n.workingHours,
                                    value:
                                        doctor.workingHours!.localized(context),
                                  ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                SectionHeader(title: l10n.clinicInfo),
                InfoTile(
                  icon: Icons.local_hospital_outlined,
                  label: l10n.clinic,
                  value: doctor.effectiveClinicName.localized(context),
                ),
                const SizedBox(height: 8),
                InfoTile(
                  icon: Icons.location_on_outlined,
                  label: l10n.address,
                  value: doctor.effectiveAddress.localized(context),
                ),
                if (doctor.patientShowsGpsLocation) ...[
                  const SizedBox(height: 12),
                  DoctorLocationCard(doctor: doctor),
                ],
                if (doctor.patientShowsClinicPhotos) ...[
                  const SizedBox(height: 12),
                  SectionHeader(title: l10n.clinicPhotos),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: doctor.clinicPhotos!.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final url = doctor.clinicPhotos![index];
                        final thumbs =
                            doctor.patientVisibleClinicPhotoThumbnails;
                        final thumb = thumbs != null && index < thumbs.length
                            ? thumbs[index]
                            : url;
                        return TabibImage(
                          imageUrl: url,
                          thumbnailUrl: thumb,
                          width: 160,
                          height: 120,
                          borderRadius: BorderRadius.circular(12),
                        );
                      },
                    ),
                  ),
                ],
                if (showContact) ...[
                  const SizedBox(height: 16),
                  SectionHeader(title: l10n.contactInfo),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (doctor.patientShowsPhone) ...[
                            InfoTile(
                              icon: Icons.phone_outlined,
                              label: l10n.phone,
                              value: doctor.contactPhone!,
                            ),
                          ],
                          if (doctor.patientShowsWhatsapp) ...[
                            if (doctor.patientShowsPhone)
                              const SizedBox(height: 12),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final info = InfoTile(
                                  icon: Icons.chat_outlined,
                                  label: l10n.whatsappNumber,
                                  value: whatsapp!,
                                );
                                final chip = MedicalActionChip(
                                  icon: Icons.open_in_new,
                                  label: l10n.openWhatsApp,
                                  color: const Color(0xFF25D366),
                                  onTap: () => _openWhatsApp(whatsapp),
                                );

                                if (constraints.maxWidth < 420) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [info, chip],
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(child: info),
                                    chip,
                                  ],
                                );
                              },
                            ),
                          ],
                          if (doctor.contactEmail != null &&
                              doctor.contactEmail!.isNotEmpty) ...[
                            if (doctor.patientShowsPhone ||
                                doctor.patientShowsWhatsapp)
                              const SizedBox(height: 12),
                            InfoTile(
                              icon: Icons.email_outlined,
                              label: l10n.email,
                              value: doctor.contactEmail!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    final data = context.read<ClinicDataService>();
                    if (!data.clinicAllowsAppointments(doctor.clinicId)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.subscriptionBlocked)),
                      );
                      return;
                    }
                    context.push('/doctors/${widget.doctorId}/book');
                  },
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
