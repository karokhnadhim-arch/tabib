import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/admin_permissions.dart';
import '../../../core/auth/admin_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/admin_doctor_staff_resolver.dart';
import '../../../core/utils/doctor_subscription_resolver.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/doctor.dart';
import '../../../models/user_account.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../presentation/widgets/owner_module_app_bar.dart';
import '../../../presentation/widgets/admin_pagination_bar.dart';
import '../../../presentation/widgets/doctor_avatar.dart';
import '../../../presentation/widgets/doctor_secretaries_summary.dart';
import '../../../presentation/widgets/subscription_status_badge.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/staff_data_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/provider_labels.dart';

class OwnerDoctorsScreen extends StatefulWidget {
  const OwnerDoctorsScreen({super.key});

  @override
  State<OwnerDoctorsScreen> createState() => _OwnerDoctorsScreenState();
}

class _OwnerDoctorsScreenState extends State<OwnerDoctorsScreen> {
  static const _pageSizes = [10, 20, 50];

  DoctorSubscriptionFilter _filter = DoctorSubscriptionFilter.all;
  final _searchController = TextEditingController();
  int _page = 0;
  int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final data = context.read<ClinicDataService>();
    final staffData = context.read<StaffDataService>();
    await data.ensureCatalogLoaded();
    data.startRealtimeCatalog();
    staffData.startRealtime();
    await data.loadDoctors(refresh: true);
  }

  Future<void> _loadMoreDoctors() async {
    final data = context.read<ClinicDataService>();
    if (!data.hasMoreDoctors || data.isDoctorsLoading) return;
    await data.loadDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Doctor> _filteredDoctors(
    ClinicDataService data,
    List<UserAccount> staff,
    AppLocalizations l10n,
  ) {
    final query = _searchController.text.trim();
    return data.doctors.where((d) {
      if (!DoctorSubscriptionResolver.matchesFilter(d, data, _filter)) {
        return false;
      }
      return AdminDoctorStaffResolver.matchesSearch(
        d,
        staff,
        query,
        (s) => s,
        l10n,
      );
    }).toList();
  }

  void _onSearchChanged() {
    setState(() => _page = 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    if (!AdminPermissions.canViewAllStaff(auth)) {
      return const SizedBox.shrink();
    }

    final data = context.watch<ClinicDataService>();
    final staffData = context.watch<StaffDataService>();
    final staff = staffData.staff;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 960;
    final filtered = _filteredDoctors(data, staff, l10n);
    final pages = pageCountFor(filtered.length, _pageSize);
    final safePage = _page.clamp(0, pages - 1);
    if (safePage != _page) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _page = safePage);
      });
    }
    final pageItems = paginateSlice(filtered, safePage, _pageSize);

    return AdminGuard(
      child: Scaffold(
        appBar: ownerModuleAppBar(context, title: l10n.doctorManagement),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _onSearchChanged(),
                decoration: InputDecoration(
                  hintText: l10n.adminDoctorSearchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: l10n.filterAll,
                    selected: _filter == DoctorSubscriptionFilter.all,
                    onTap: () => setState(() {
                      _filter = DoctorSubscriptionFilter.all;
                      _page = 0;
                    }),
                  ),
                  _FilterChip(
                    label: l10n.subscriptionStatusActive,
                    selected: _filter == DoctorSubscriptionFilter.active,
                    color: AppTheme.medicalGreen,
                    onTap: () => setState(() {
                      _filter = DoctorSubscriptionFilter.active;
                      _page = 0;
                    }),
                  ),
                  _FilterChip(
                    label: l10n.subscriptionStatusExpiringSoon,
                    selected: _filter == DoctorSubscriptionFilter.expiringSoon,
                    color: const Color(0xFFF9A825),
                    onTap: () => setState(() {
                      _filter = DoctorSubscriptionFilter.expiringSoon;
                      _page = 0;
                    }),
                  ),
                  _FilterChip(
                    label: l10n.subscriptionStatusExpired,
                    selected: _filter == DoctorSubscriptionFilter.expired,
                    color: Colors.red.shade700,
                    onTap: () => setState(() {
                      _filter = DoctorSubscriptionFilter.expired;
                      _page = 0;
                    }),
                  ),
                ],
              ),
            ),
            if (data.isDoctorsLoading && data.doctors.isEmpty)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filtered.isEmpty)
              Expanded(child: Center(child: Text(l10n.noDoctorsFound)))
            else
              Expanded(
                child: isWide
                    ? _DoctorDataTable(
                        doctors: pageItems,
                        staff: staff,
                        data: data,
                        onTap: (id) =>
                            context.push('${AdminRoutes.platformPrefix}/doctors/$id'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: pageItems.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final doctor = pageItems[index];
                          return _DoctorListCard(
                            doctor: doctor,
                            staff: staff,
                            data: data,
                            onTap: () => context.push(
                              '${AdminRoutes.platformPrefix}/doctors/${doctor.id}',
                            ),
                          );
                        },
                      ),
              ),
            if (data.hasMoreDoctors)
              Padding(
                padding: const EdgeInsets.all(8),
                child: OutlinedButton.icon(
                  onPressed: data.isDoctorsLoading ? null : _loadMoreDoctors,
                  icon: const Icon(Icons.download_outlined),
                  label: Text(l10n.loadMore),
                ),
              ),
            AdminPaginationBar(
              page: safePage,
              pageCount: pages,
              pageSize: _pageSize,
              pageSizes: _pageSizes,
              onPageChanged: (p) => setState(() => _page = p),
              onPageSizeChanged: (s) => setState(() {
                _pageSize = s;
                _page = 0;
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorListCard extends StatelessWidget {
  const _DoctorListCard({
    required this.doctor,
    required this.staff,
    required this.data,
    required this.onTap,
  });

  final Doctor doctor;
  final List<UserAccount> staff;
  final ClinicDataService data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = DoctorSubscriptionResolver.statusFor(doctor, data);
    final days = DoctorSubscriptionResolver.remainingDays(doctor, data);
    final plan = DoctorSubscriptionResolver.planFor(doctor, data);
    final email = AdminDoctorStaffResolver.emailFor(doctor, staff);
    final phone = AdminDoctorStaffResolver.phoneFor(doctor, staff);
    final secCount =
        AdminDoctorStaffResolver.secretaryCount(doctor.id, staff);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DoctorAvatar(
                    photoUrl: doctor.photoUrl,
                    thumbnailUrl: doctor.photoThumbnailUrl,
                    radius: 28,
                    backgroundColor:
                        AppTheme.doctorColor.withOpacity(0.1),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name.localized(context),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        DoctorSecretariesSummary(
                          doctorId: doctor.id,
                          staff: staff,
                        ),
                        Text(
                          ProviderLabels.displayCategory(
                            context,
                            l10n,
                            doctor,
                          ),
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          doctor.clinic.name.localized(context),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SubscriptionStatusBadge(
                      status: status,
                      remainingDays: days,
                      compact: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  _Meta(Icons.phone_outlined, phone ?? l10n.notAvailable),
                  _Meta(Icons.email_outlined, email ?? l10n.notAvailable),
                  if (plan != null)
                    _Meta(
                      Icons.card_membership_outlined,
                      subscriptionPlanLabel(l10n, plan),
                    ),
                  _Meta(
                    Icons.timer_outlined,
                    days < 0
                        ? l10n.subscriptionExpiredDaysAgo(-days)
                        : days >= 999
                            ? l10n.noExpiry
                            : l10n.subscriptionDaysRemaining(days),
                  ),
                  _Meta(
                    Icons.support_agent_outlined,
                    l10n.secretariesCount(secCount),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorDataTable extends StatelessWidget {
  const _DoctorDataTable({
    required this.doctors,
    required this.staff,
    required this.data,
    required this.onTap,
  });

  final List<Doctor> doctors;
  final List<UserAccount> staff;
  final ClinicDataService data;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            AppTheme.primaryDark.withOpacity(0.04),
          ),
          columns: [
            const DataColumn(label: SizedBox(width: 48)),
            DataColumn(label: Text(l10n.fullName)),
            DataColumn(label: Text(l10n.specialty)),
            DataColumn(label: Text(l10n.clinicName)),
            DataColumn(label: Text(l10n.phoneNumber)),
            DataColumn(label: Text(l10n.email)),
            DataColumn(label: Text(l10n.subscriptionPlan)),
            DataColumn(label: Text(l10n.status)),
            DataColumn(label: Text(l10n.subscriptionRemainingDays)),
            DataColumn(label: Text(l10n.assignedSecretaries)),
          ],
          rows: doctors.map((doctor) {
            final status = DoctorSubscriptionResolver.statusFor(doctor, data);
            final days = DoctorSubscriptionResolver.remainingDays(doctor, data);
            final plan = DoctorSubscriptionResolver.planFor(doctor, data);
            final secCount =
                AdminDoctorStaffResolver.secretaryCount(doctor.id, staff);

            return DataRow(
              onSelectChanged: (_) => onTap(doctor.id),
              cells: [
                DataCell(
                  DoctorAvatar(
                    photoUrl: doctor.photoUrl,
                    thumbnailUrl: doctor.photoThumbnailUrl,
                    radius: 18,
                    backgroundColor:
                        AppTheme.doctorColor.withOpacity(0.1),
                  ),
                ),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(doctor.name.localized(context)),
                      DoctorSecretariesSummary(
                        doctorId: doctor.id,
                        staff: staff,
                      ),
                    ],
                  ),
                ),
                DataCell(Text(doctor.specialty.name.localized(context))),
                DataCell(Text(doctor.clinic.name.localized(context))),
                DataCell(Text(
                  AdminDoctorStaffResolver.phoneFor(doctor, staff) ??
                      l10n.notAvailable,
                )),
                DataCell(Text(
                  AdminDoctorStaffResolver.emailFor(doctor, staff) ??
                      l10n.notAvailable,
                )),
                DataCell(Text(
                  plan != null
                      ? subscriptionPlanLabel(l10n, plan)
                      : l10n.notAvailable,
                )),
                DataCell(
                  SubscriptionStatusBadge(
                    status: status,
                    remainingDays: days,
                    compact: true,
                  ),
                ),
                DataCell(Text(
                  days < 0
                      ? l10n.subscriptionExpiredDaysAgo(-days)
                      : days >= 999
                          ? l10n.noExpiry
                          : l10n.subscriptionDaysRemaining(days),
                )),
                DataCell(
                  Builder(
                    builder: (context) => InkWell(
                      onTap: secCount > 0
                          ? () => context.push(
                                DoctorSecretariesSummary
                                    .doctorDetailSecretariesRoute(doctor.id),
                              )
                          : null,
                      child: Text(
                        l10n.secretariesCount(secCount),
                        style: TextStyle(
                          color: secCount > 0
                              ? AppTheme.primaryDark
                              : Colors.grey.shade700,
                          decoration: secCount > 0
                              ? TextDecoration.underline
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppTheme.primaryDark;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        selectedColor: accent.withOpacity(0.15),
        checkmarkColor: accent,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
