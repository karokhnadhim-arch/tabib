import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/admin_permissions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/user_account.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';

class OwnerStatsScreen extends StatelessWidget {
  const OwnerStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    if (!AdminPermissions.canViewStatistics(auth)) {
      return const SizedBox.shrink();
    }

    final data = context.watch<ClinicDataService>();
    final backend = data.backend;

    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.systemStatistics),
          backgroundColor: AppTheme.primaryDark,
        ),
        body: StreamBuilder<List<UserAccount>>(
          stream: backend.watchStaff(),
          builder: (context, snapshot) {
            final staff = snapshot.data ?? const [];
            final doctors = staff
                .where((s) =>
                    s.role == UserRole.doctor || s.role == UserRole.admin)
                .length;
            final secretaries =
                staff.where((s) => s.role == UserRole.secretary).length;
            final activeStaff = staff.where((s) => s.isActive).length;
            final clinics = data.clinics;
            final activeSubscriptions =
                clinics.where((c) => c.subscriptionActive).length;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StatCard(
                  icon: Icons.medical_services_outlined,
                  label: l10n.totalDoctors,
                  value: '$doctors',
                  color: AppTheme.doctorColor,
                ),
                _StatCard(
                  icon: Icons.support_agent_outlined,
                  label: l10n.totalSecretaries,
                  value: '$secretaries',
                  color: AppTheme.secretaryColor,
                ),
                _StatCard(
                  icon: Icons.local_hospital_outlined,
                  label: l10n.totalClinics,
                  value: '${clinics.length}',
                  color: AppTheme.primaryDark,
                ),
                _StatCard(
                  icon: Icons.verified_outlined,
                  label: l10n.activeSubscriptions,
                  value: '$activeSubscriptions / ${clinics.length}',
                  color: AppTheme.medicalGreen,
                ),
                _StatCard(
                  icon: Icons.people_outline,
                  label: l10n.activeStaffAccounts,
                  value: '$activeStaff / ${staff.length}',
                  color: AppTheme.medicalBlue,
                ),
                _StatCard(
                  icon: Icons.person_outline,
                  label: l10n.totalDoctorsListed,
                  value: '${data.doctors.length}',
                  color: AppTheme.doctorColor,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
