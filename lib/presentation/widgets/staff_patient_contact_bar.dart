import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/patient_contact_service.dart';

/// Phone number + Call / WhatsApp / SMS actions for authorized clinical staff.
class StaffPatientContactBar extends StatelessWidget {
  const StaffPatientContactBar({
    super.key,
    required this.phone,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    this.patientId,
    this.compact = false,
  });

  final String phone;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String? patientId;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final contact = context.read<PatientContactService>();
    if (!contact.canContactPatient(doctorId: doctorId)) {
      return const SizedBox.shrink();
    }
    if (!PatientContactService.hasValidPhone(phone)) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => contact.callPatient(
            phone: phone,
            patientName: patientName,
            doctorId: doctorId,
            doctorName: doctorName,
            patientId: patientId,
          ),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: compact ? 16 : 18,
                  color: AppTheme.medicalBlue,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    phone,
                    style: TextStyle(
                      color: AppTheme.medicalBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: compact ? 13 : 15,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.medicalBlue.withOpacity(0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: compact ? 6 : 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _ContactActionChip(
              icon: Icons.call,
              label: l10n.contactActionCall,
              color: AppTheme.medicalGreen,
              compact: compact,
              onTap: () => contact.callPatient(
                phone: phone,
                patientName: patientName,
                doctorId: doctorId,
                doctorName: doctorName,
                patientId: patientId,
              ),
            ),
            _ContactActionChip(
              icon: Icons.chat,
              label: l10n.contactActionWhatsApp,
              color: const Color(0xFF25D366),
              compact: compact,
              onTap: () => contact.openWhatsApp(
                context: context,
                phone: phone,
                patientName: patientName,
                doctorId: doctorId,
                doctorName: doctorName,
                patientId: patientId,
              ),
            ),
            _ContactActionChip(
              icon: Icons.sms_outlined,
              label: l10n.contactActionSms,
              color: AppTheme.secretaryColor,
              compact: compact,
              onTap: () => contact.openSms(
                context: context,
                phone: phone,
                patientName: patientName,
                doctorId: doctorId,
                doctorName: doctorName,
                patientId: patientId,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ContactActionChip extends StatelessWidget {
  const _ContactActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 5 : 7,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: compact ? 16 : 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 12 : 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
