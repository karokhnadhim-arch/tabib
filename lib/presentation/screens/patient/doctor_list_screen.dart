import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/medical_ui.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/appointment.dart';
import '../../../services/clinic_data_service.dart';
import '../../../utils/localization_utils.dart';
import '../../widgets/doctor_avatar.dart';
import '../../../widgets/common_widgets.dart';
import 'package:intl/intl.dart';

class TabibDoctorListScreen extends StatefulWidget {
  const TabibDoctorListScreen({
    super.key,
    this.embedded = false,
    this.initialSpecialtyId,
  });

  final bool embedded;
  final String? initialSpecialtyId;

  @override
  State<TabibDoctorListScreen> createState() => _TabibDoctorListScreenState();
}

class _TabibDoctorListScreenState extends State<TabibDoctorListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String? _specialtyFilter;

  @override
  void initState() {
    super.initState();
    _specialtyFilter = widget.initialSpecialtyId;
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  Future<void> _loadInitial() async {
    final data = context.read<ClinicDataService>();
    await data.ensureCatalogLoaded();
    await data.loadDoctors(
      specialtyId: _specialtyFilter,
      refresh: true,
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 240) {
      context.read<ClinicDataService>().loadDoctors(
            specialtyId: _specialtyFilter,
          );
    }
  }

  Future<void> _onSpecialtyChanged(String? specialtyId) async {
    setState(() => _specialtyFilter = specialtyId);
    await context.read<ClinicDataService>().loadDoctors(
          specialtyId: specialtyId,
          refresh: true,
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = context.watch<ClinicDataService>();
    final query = _searchController.text.trim().toLowerCase();

    var doctors = data.doctors;
    if (query.isNotEmpty) {
      doctors = doctors.where((d) {
        final name = d.name.localized(context).toLowerCase();
        final spec = d.specialty.name.localized(context).toLowerCase();
        final clinic = d.clinic.name.localized(context).toLowerCase();
        return name.contains(query) ||
            spec.contains(query) ||
            clinic.contains(query);
      }).toList();
    }

    final body = ResponsiveBody(
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          if (data.specialties.isNotEmpty)
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
          const SizedBox(height: 12),
          Expanded(
            child: data.isDoctorsLoading && doctors.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : doctors.isEmpty
                    ? Center(child: Text(l10n.noDoctorsFound))
                    : ListView.separated(
                        controller: _scrollController,
                        itemCount:
                            doctors.length + (data.hasMoreDoctors ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          if (index >= doctors.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final doctor = doctors[index];
                          return Card(
                            child: ListTile(
                              onTap: () =>
                                  context.push('/doctors/${doctor.id}'),
                              isThreeLine: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: DoctorAvatar(
                                photoUrl: doctor.patientVisiblePhotoUrl,
                                thumbnailUrl:
                                    doctor.patientVisiblePhotoThumbnailUrl,
                                radius: 24,
                                backgroundColor:
                                    AppTheme.medicalBlue.withOpacity(0.1),
                                fallback: Icon(
                                  SpecialtyIcon.forName(
                                      doctor.specialty.iconName),
                                  color: AppTheme.medicalBlue,
                                ),
                              ),
                              title: Text(
                                doctor.name.localized(context),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${doctor.specialty.name.localized(context)} • ${doctor.clinic.name.localized(context)}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (doctor.patientVisibleDegree(context) !=
                                      null)
                                    Text(
                                      doctor.patientVisibleDegree(context)!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      Text(' ${doctor.rating}'),
                                      if (doctor.isAvailableToday) ...[
                                        const SizedBox(width: 8),
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
            title: l10n.searchDoctors,
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
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _statusColor(a.status).withOpacity(0.15),
                    child: Icon(Icons.event, color: _statusColor(a.status)),
                  ),
                  title: Text(a.doctorName),
                  subtitle: Text(
                    '${a.specialty}\n${DateFormat.yMMMd().add_jm().format(a.dateTime)}',
                  ),
                  trailing: QueueStatusChip(
                    label: _statusLabel(l10n, a.status),
                    color: _statusColor(a.status),
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
