import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../doctor_consultation_widgets.dart';

/// Save + print actions for the doctor prescription section — Material 3.
class DoctorPrescriptionActionBar extends StatelessWidget {
  const DoctorPrescriptionActionBar({
    super.key,
    required this.onSave,
    required this.onPrint,
    required this.saving,
    required this.canPrint,
    required this.saveEnabled,
  });

  final VoidCallback? onSave;
  final VoidCallback? onPrint;
  final bool saving;
  final bool canPrint;
  final bool saveEnabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stack = constraints.maxWidth < 420;
          final children = [
            Expanded(
              child: FilledButton.icon(
                onPressed: saveEnabled && !saving ? onSave : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.doctorColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: DoctorConsultationTokens.cardRadius,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 20),
                label: Text(l10n.savePrescription),
              ),
            ),
            SizedBox(width: stack ? 0 : 12, height: stack ? 10 : 0),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: canPrint && !saving ? onPrint : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: DoctorConsultationTokens.cardRadius,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: const Icon(Icons.print_outlined, size: 20),
                label: Text(l10n.printPrescription),
              ),
            ),
          ];

          if (stack) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            );
          }
          return Row(children: children);
        },
      ),
    );
  }
}

/// True when prescription (and investigations, if any) were persisted successfully.
bool prescriptionReadyToPrint({
  required bool prescriptionSynced,
  required bool investigationSynced,
  required int investigationCount,
}) {
  if (!prescriptionSynced) return false;
  if (investigationCount > 0 && !investigationSynced) return false;
  return true;
}
