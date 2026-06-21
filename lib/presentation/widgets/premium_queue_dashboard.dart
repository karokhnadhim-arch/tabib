import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/medical_ui.dart';
import '../../l10n/app_localizations.dart';
import '../../models/doctor.dart';
import '../../models/queue_entry.dart';
import '../../utils/localization_utils.dart';
import '../../utils/queue_status_utils.dart';
import 'doctor_avatar.dart';

class PremiumQueueDashboard extends StatelessWidget {
  const PremiumQueueDashboard({
    super.key,
    required this.entry,
    required this.doctor,
    required this.currentNumber,
    required this.peopleAhead,
    required this.waitMinutes,
    required this.pulseController,
    required this.numberScaleAnimation,
  });

  final QueueEntry entry;
  final Doctor? doctor;
  final int currentNumber;
  final int peopleAhead;
  final int waitMinutes;
  final AnimationController pulseController;
  final Animation<double> numberScaleAnimation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusColor = entry.status.color();
    final isYourTurn = entry.status == QueueStatus.inProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LiveBanner(
          pulseController: pulseController,
          label: l10n.liveQueueProgress,
        ),
        const SizedBox(height: 16),
        if (doctor != null) _DoctorHeader(doctor: doctor!),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withOpacity(0.08),
                AppTheme.patientColor.withOpacity(0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: statusColor.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  entry.status.label(l10n),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isYourTurn ? l10n.yourTurn : l10n.queueNumber,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              ScaleTransition(
                scale: numberScaleAnimation,
                child: Text(
                  '${entry.position}',
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: isYourTurn
                        ? AppTheme.medicalGreen
                        : AppTheme.patientColor,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: MedicalStatCard(
                icon: Icons.confirmation_number_outlined,
                label: l10n.currentQueueNumber,
                value: '$currentNumber',
                color: AppTheme.medicalGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MedicalStatCard(
                icon: Icons.people_outline,
                label: l10n.peopleAhead,
                value: '$peopleAhead',
                color: AppTheme.medicalBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MedicalStatCard(
          icon: Icons.timer_outlined,
          label: l10n.waitTime,
          value: l10n.minutesShort(waitMinutes),
          color: Colors.orange.shade700,
        ),
      ],
    );
  }
}

class _LiveBanner extends StatelessWidget {
  const _LiveBanner({
    required this.pulseController,
    required this.label,
  });

  final AnimationController pulseController;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.medicalGreen
                .withOpacity(0.06 + pulseController.value * 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.medicalGreen
                  .withOpacity(0.25 + pulseController.value * 0.15),
            ),
          ),
          child: Row(
            children: [
              PulseDot(
                color: AppTheme.medicalGreen,
                size: 8 + pulseController.value * 2,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DoctorHeader extends StatelessWidget {
  const _DoctorHeader({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            DoctorAvatar(
              photoUrl: doctor.photoUrl,
              radius: 28,
              border: Border.all(
                color: AppTheme.medicalBlue.withOpacity(0.2),
                width: 2,
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
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.specialty.name.localized(context),
                    style: const TextStyle(
                      color: AppTheme.medicalBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.effectiveClinicName.localized(context),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.local_hospital_outlined,
                color: AppTheme.patientColor.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }
}
