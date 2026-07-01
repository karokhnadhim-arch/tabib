import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/medical_ui.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/appointment.dart';
import '../../../models/doctor.dart';
import '../../../models/provider_catalog_mode.dart';
import '../../../models/service_provider_type.dart';
import '../../../services/clinic_data_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/provider_labels.dart';
import '../../../core/utils/doctor_subscription_resolver.dart';
import '../../widgets/doctor_avatar.dart';
import '../../widgets/subscription_status_badge.dart';
import '../../../widgets/common_widgets.dart';
import 'package:intl/intl.dart';

class TabibDoctorListScreen extends StatefulWidget {
  const TabibDoctorListScreen({
    super.key,
    this.embedded = false,
    this.initialSpecialtyId,
    this.catalogMode = ProviderCatalogMode.doctors,
  });

  final bool embedded;
  final String? initialSpecialtyId;
  final ProviderCatalogMode catalogMode;

  bool get isBusinessCatalog => catalogMode == ProviderCatalogMode.businesses;

  @override
  State<TabibDoctorListScreen> createState() => _TabibDoctorListScreenState();
}

class _TabibDoctorListScreenState extends State<TabibDoctorListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String? _specialtyFilter;
  BusinessCategory? _categoryFilter;

  @override
  void initState() {
    super.initState();
    _specialtyFilter = widget.isBusinessCatalog ? null : widget.initialSpecialtyId;
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = context.read<ClinicDataService>();
      await data.ensureCatalogLoaded();
      data.startRealtimeCatalog();
      await _loadInitial();
    });
  }

  Future<void> _loadInitial() async {
    final data = context.read<ClinicDataService>();
    await data.ensureCatalogLoaded();
    await data.loadDoctors(
      specialtyId: widget.isBusinessCatalog ? null : _specialtyFilter,
      catalogMode: widget.catalogMode,
      refresh: true,
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 240) {
      context.read<ClinicDataService>().loadDoctors(
            specialtyId: widget.isBusinessCatalog ? null : _specialtyFilter,
            catalogMode: widget.catalogMode,
          );
    }
  }

  Future<void> _onSpecialtyChanged(String? specialtyId) async {
    setState(() => _specialtyFilter = specialtyId);
    await context.read<ClinicDataService>().loadDoctors(
          specialtyId: specialtyId,
          catalogMode: widget.catalogMode,
          refresh: true,
        );
  }

  Future<void> _onCategoryChanged(BusinessCategory? category) async {
    setState(() => _categoryFilter = category);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Doctor> _filteredProviders(
    BuildContext context,
    ClinicDataService data,
    AppLocalizations l10n,
  ) {
    var providers = data.doctors;
    if (widget.isBusinessCatalog) {
      providers = providers.where((d) => d.isBusiness).toList();
      if (_categoryFilter != null) {
        providers = providers
            .where((d) => d.businessCategory == _categoryFilter)
            .toList();
      }
    } else {
      providers = providers.where((d) => d.isDoctorAccount).toList();
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return providers;

    return providers.where((d) {
      final name = d.name.localized(context).toLowerCase();
      final clinic = d.clinic.name.localized(context).toLowerCase();
      if (widget.isBusinessCatalog) {
        return name.contains(query) || clinic.contains(query);
      }
      final specialty =
          ProviderLabels.displayCategory(context, l10n, d).toLowerCase();
      return name.contains(query) ||
          specialty.contains(query) ||
          clinic.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = context.watch<ClinicDataService>();
    final providers = _filteredProviders(context, data, l10n);

    final body = ResponsiveBody(
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: ProviderLabels.catalogSearchHint(l10n, widget.catalogMode),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          if (!widget.isBusinessCatalog && data.specialties.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(l10n.allSpecialties),
                      selected: _specialtyFilter == null,
                      onSelected: (_) => _onSpecialtyChanged(null),
                    ),
                  ),
                  ...data.specialties.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(s.name.localized(context)),
                        selected: _specialtyFilter == s.id,
                        onSelected: (_) => _onSpecialtyChanged(s.id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (widget.isBusinessCatalog) ...[
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(l10n.allBusinessCategories),
                      selected: _categoryFilter == null,
                      onSelected: (_) => _onCategoryChanged(null),
                    ),
                  ),
                  ...BusinessCategory.values.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(ProviderLabels.businessCategoryLabel(l10n, c)),
                        selected: _categoryFilter == c,
                        onSelected: (_) => _onCategoryChanged(c),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: data.isDoctorsLoading && providers.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : providers.isEmpty
                    ? Center(
                        child: Text(
                          ProviderLabels.catalogEmptyMessage(
                            l10n,
                            widget.catalogMode,
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        itemCount:
                            providers.length + (data.hasMoreDoctors ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          if (index >= providers.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final provider = providers[index];
                          return Card(
                            child: ListTile(
                              onTap: () => context.push(
                                ProviderLabels.detailRoute(
                                  widget.catalogMode,
                                  provider.id,
                                ),
                              ),
                              isThreeLine: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: DoctorAvatar(
                                photoUrl: provider.patientVisiblePhotoUrl,
                                thumbnailUrl:
                                    provider.patientVisiblePhotoThumbnailUrl,
                                radius: 24,
                                backgroundColor:
                                    AppTheme.medicalBlue.withOpacity(0.1),
                                fallback: Icon(
                                  widget.isBusinessCatalog
                                      ? Icons.storefront_outlined
                                      : SpecialtyIcon.forName(
                                          provider.specialty.iconName,
                                        ),
                                  color: AppTheme.medicalBlue,
                                ),
                              ),
                              title: Text(
                                provider.name.localized(context),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${ProviderLabels.displayCategory(context, l10n, provider)} • ${provider.clinic.name.localized(context)}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (!widget.isBusinessCatalog &&
                                      provider.patientVisibleDegree(context) !=
                                          null)
                                    Text(
                                      provider.patientVisibleDegree(context)!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 4),
                                  SubscriptionStatusBadge(
                                    status: DoctorSubscriptionResolver.statusFor(
                                      provider,
                                      data,
                                    ),
                                    remainingDays:
                                        DoctorSubscriptionResolver.remainingDays(
                                      provider,
                                      data,
                                    ),
                                    compact: true,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (!widget.isBusinessCatalog) ...[
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        Text(' ${provider.rating}'),
                                        const SizedBox(width: 8),
                                      ],
                                      if (provider.isAvailableToday)
                                        Flexible(
                                          child: Text(
                                            l10n.available,
                                            style: const TextStyle(
                                              color: AppTheme.medicalGreen,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );

    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: AppTheme.medicalWhite,
      body: Column(
        children: [
          MedicalGradientHeader(
            height: 120,
            title: ProviderLabels.catalogTitle(l10n, widget.catalogMode),
            subtitle: l10n.appSubtitle,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class AppointmentHistoryScreen extends StatelessWidget {
  const AppointmentHistoryScreen({
    super.key,
    this.embedded = false,
    this.appointments,
  });

  final bool embedded;
  final List<Appointment>? appointments;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final list = appointments ?? [];

    final content = list.isEmpty
        ? Center(child: Text(l10n.noAppointmentsYet))
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final a = list[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            _statusColor(a.status).withOpacity(0.15),
                        child: Icon(Icons.event, color: _statusColor(a.status)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.doctorName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${a.specialty}\n${DateFormat.yMMMd().add_jm().format(a.dateTime)}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: QueueStatusChip(
                          label: _statusLabel(l10n, a.status),
                          color: _statusColor(a.status),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

    if (embedded) return content;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myAppointments),
        backgroundColor: AppTheme.patientColor,
      ),
      body: content,
    );
  }

  Color _statusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.accepted:
        return AppTheme.medicalGreen;
      case AppointmentStatus.rejected:
        return Colors.red;
      case AppointmentStatus.completed:
        return AppTheme.medicalBlue;
      case AppointmentStatus.cancelled:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(AppLocalizations l10n, AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return l10n.statusPending;
      case AppointmentStatus.accepted:
        return l10n.statusAccepted;
      case AppointmentStatus.rejected:
        return l10n.statusRejected;
      case AppointmentStatus.completed:
        return l10n.completed;
      case AppointmentStatus.cancelled:
        return l10n.statusCancelled;
      default:
        return status.name;
    }
  }
}
