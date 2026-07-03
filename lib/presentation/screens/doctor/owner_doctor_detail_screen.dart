import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/admin_permissions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/admin_doctor_staff_resolver.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/doctor.dart';
import '../../../models/user_account.dart';
import '../../../presentation/widgets/admin_doctor_secretaries_section.dart';
import '../../../presentation/widgets/admin_doctor_subscription_card.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../presentation/widgets/owner_module_app_bar.dart';
import '../../../presentation/widgets/doctor_secretaries_summary.dart';
import '../../../presentation/widgets/doctor_avatar.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/staff_data_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/provider_labels.dart';

class OwnerDoctorDetailScreen extends StatefulWidget {
  const OwnerDoctorDetailScreen({
    super.key,
    required this.doctorId,
    this.focusSecretaries = false,
  });

  final String doctorId;
  final bool focusSecretaries;

  @override
  State<OwnerDoctorDetailScreen> createState() =>
      _OwnerDoctorDetailScreenState();
}

class _OwnerDoctorDetailScreenState extends State<OwnerDoctorDetailScreen> {
  final _secretariesSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = context.read<ClinicDataService>();
      final staffData = context.read<StaffDataService>();
      await data.ensureCatalogLoaded();
      data.startRealtimeCatalog();
      staffData.startRealtime();
      await data.fetchDoctorById(widget.doctorId);
      if (widget.focusSecretaries) {
        _scrollToSecretaries();
      }
    });
  }

  void _scrollToSecretaries() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _secretariesSectionKey.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          alignment: 0.05,
        );
      }
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
    final staff = context.watch<StaffDataService>().staff;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;

    return AdminGuard(
      child: Scaffold(
        appBar: ownerModuleAppBar(
          context,
          title: ProviderLabels.profileTitle(l10n, doctor),
        ),
        body: doctor == null
            ? const Center(child: CircularProgressIndicator())
            : Builder(
                builder: (context) {
                  final email =
                      AdminDoctorStaffResolver.emailFor(doctor, staff);
                  final phone =
                      AdminDoctorStaffResolver.phoneFor(doctor, staff);

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _DoctorInfoCard(
                                doctor: doctor,
                                email: email,
                                phone: phone,
                                staff: staff,
                                onSecretariesTap: _scrollToSecretaries,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AdminDoctorSubscriptionCard(
                                doctor: doctor,
                                onRenewed: () => setState(() {}),
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _DoctorInfoCard(
                          doctor: doctor,
                          email: email,
                          phone: phone,
                          staff: staff,
                          onSecretariesTap: _scrollToSecretaries,
                        ),
                        const SizedBox(height: 16),
                        AdminDoctorSubscriptionCard(
                          doctor: doctor,
                          onRenewed: () => setState(() {}),
                        ),
                      ],
                      const SizedBox(height: 16),
                      KeyedSubtree(
                        key: _secretariesSectionKey,
                        child: AdminDoctorSecretariesSection(
                          doctorId: doctor.id,
                          staff: staff,
                        ),
                      ),
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
    required this.staff,
    this.onSecretariesTap,
  });

  final Doctor doctor;
  final String? email;
  final String? phone;
  final List<UserAccount> staff;
  final VoidCallback? onSecretariesTap;

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
                      DoctorSecretariesSummary(
                        doctorId: doctor.id,
                        staff: staff,
                        onTap: onSecretariesTap,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Text(
                          l10n.secretariesCount(
                            AdminDoctorStaffResolver.secretaryCount(
                              doctor.id,
                              staff,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
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
      child: ResponsiveLabelValueRow(
        icon: icon,
        label: label,
        value: value,
        labelFlex: 2,
        valueFlex: 4,
      ),
    );
  }
}
