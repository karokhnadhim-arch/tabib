import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/admin_permissions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/admin_doctor_staff_resolver.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/doctor.dart';
import '../../../models/user_account.dart';
import '../../../presentation/widgets/admin_doctor_secretaries_section.dart';
import '../../../presentation/widgets/admin_doctor_subscription_card.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../presentation/widgets/doctor_avatar.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../utils/localization_utils.dart';

class OwnerDoctorDetailScreen extends StatefulWidget {
  const OwnerDoctorDetailScreen({super.key, required this.doctorId});

  final String doctorId;

  @override
  State<OwnerDoctorDetailScreen> createState() =>
      _OwnerDoctorDetailScreenState();
}

class _OwnerDoctorDetailScreenState extends State<OwnerDoctorDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = context.read<ClinicDataService>();
      await data.ensureCatalogLoaded();
      data.startRealtimeCatalog();
      await data.fetchDoctorById(widget.doctorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    if (!AdminPermissions.canViewAllStaff(auth)) {
      return const SizedBox.shrink();
    }

    final data = context.watch<ClinicDataService>();
    final doctor = data.doctorById(widget.doctorId);
    final backend = data.backend;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;

    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.doctorProfile),
          backgroundColor: AppTheme.primaryDark,
        ),
        body: doctor == null
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<List<UserAccount>>(
                stream: backend.watchStaff(),
                builder: (context, staffSnap) {
                  final staff = staffSnap.data ?? const <UserAccount>[];
                  final email =
                      AdminDoctorStaffResolver.emailFor(doctor, staff);
                  final phone =
                      AdminDoctorStaffResolver.phoneFor(doctor, staff);

                  final infoCard = _DoctorInfoCard(
                    doctor: doctor,
                    email: email,
                    phone: phone,
                  );
                  final subscriptionCard = AdminDoctorSubscriptionCard(
                    doctor: doctor,
                    onRenewed: () => setState(() {}),
                  );
                  final secretariesSection = AdminDoctorSecretariesSection(
                    doctorId: doctor.id,
                    staff: staff,
                  );

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: infoCard),
                            const SizedBox(width: 16),
                            Expanded(child: subscriptionCard),
                          ],
                        )
                      else ...[
                        infoCard,
                        const SizedBox(height: 16),
                        subscriptionCard,
                      ],
                      const SizedBox(height: 16),
                      secretariesSection,
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _DoctorInfoCard extends StatelessWidget {
  const _DoctorInfoCard({
    required this.doctor,
    required this.email,
    required this.phone,
  });

  final Doctor doctor;
  final String? email;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.doctorInformation,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DoctorAvatar(
                  photoUrl: doctor.photoUrl,
                  thumbnailUrl: doctor.photoThumbnailUrl,
                  radius: 40,
                  backgroundColor: AppTheme.doctorColor.withOpacity(0.12),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name.localized(context),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      _InfoRow(
                        icon: Icons.medical_services_outlined,
                        label: l10n.specialty,
                        value: doctor.specialty.name.localized(context),
                      ),
                      _InfoRow(
                        icon: Icons.local_hospital_outlined,
                        label: l10n.clinicName,
                        value: doctor.clinic.name.localized(context),
                      ),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: l10n.phoneNumber,
                        value: phone ?? l10n.notAvailable,
                      ),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: l10n.email,
                        value: email ?? l10n.notAvailable,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
