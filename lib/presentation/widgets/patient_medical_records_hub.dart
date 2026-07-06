import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// One-tap access to patient medical records.
class PatientMedicalRecordsHub extends StatelessWidget {
  const PatientMedicalRecordsHub({
    super.key,
    this.prescriptionCount = 0,
    this.pendingInvestigationCount = 0,
    this.completedInvestigationCount = 0,
    this.diagnosisCount = 0,
    this.sharedNotesCount = 0,
  });

  final int prescriptionCount;
  final int pendingInvestigationCount;
  final int completedInvestigationCount;
  final int diagnosisCount;
  final int sharedNotesCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final tiles = [
      _RecordTile(
        icon: Icons.medication_outlined,
        label: l10n.currentPrescription,
        badge: prescriptionCount > 0 ? '1' : null,
        onTap: () => context.push('/prescriptions'),
      ),
      _RecordTile(
        icon: Icons.history_rounded,
        label: l10n.previousPrescriptions,
        badge: prescriptionCount > 1 ? '$prescriptionCount' : null,
        onTap: () => context.push('/prescriptions'),
      ),
      _RecordTile(
        icon: Icons.medical_information_outlined,
        label: l10n.diagnosisHistory,
        badge: diagnosisCount > 0 ? '$diagnosisCount' : null,
        onTap: () => context.push('/diagnosis-history'),
      ),
      _RecordTile(
        icon: Icons.biotech_outlined,
        label: l10n.investigationRequests,
        badge: pendingInvestigationCount > 0
            ? '$pendingInvestigationCount'
            : null,
        onTap: () => context.push('/investigations?tab=pending'),
      ),
      _RecordTile(
        icon: Icons.assignment_turned_in_outlined,
        label: l10n.investigationResults,
        badge: completedInvestigationCount > 0
            ? '$completedInvestigationCount'
            : null,
        onTap: () => context.push('/investigations?tab=completed'),
      ),
      _RecordTile(
        icon: Icons.notes_outlined,
        label: l10n.sharedClinicalNotes,
        badge: sharedNotesCount > 0 ? '$sharedNotesCount' : null,
        onTap: () => context.push('/clinical-notes'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.medicalRecords,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 560 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: crossAxisCount == 3 ? 1.35 : 1.2,
              ),
              itemCount: tiles.length,
              itemBuilder: (context, index) => tiles[index],
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          l10n.medicalRecordsHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppTheme.medicalBlue, size: 22),
                  const Spacer(),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.medicalBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.medicalBlue,
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
