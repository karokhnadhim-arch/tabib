import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/appointment.dart';
import '../../../services/clinic_data_service.dart';
import '../../../utils/localization_utils.dart';
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
  String? _specialtyFilter;

  @override
  void initState() {
    super.initState();
    _specialtyFilter = widget.initialSpecialtyId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = context.watch<ClinicDataService>();
    final query = _searchController.text.trim().toLowerCase();

    var doctors = data.doctors;
    if (_specialtyFilter != null) {
      doctors = doctors.where((d) => d.specialtyId == _specialtyFilter).toList();
    }
    if (query.isNotEmpty) {
      doctors = doctors.where((d) {
        final name = d.name.localized(context).toLowerCase();
        final spec = d.specialty.name.localized(context).toLowerCase();
        final clinic = d.clinic.name.localized(context).toLowerCase();
        return name.contains(query) || spec.contains(query) || clinic.contains(query);
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
                      onSelected: (_) => setState(() => _specialtyFilter = null),
                    ),
                  ),
                  ...data.specialties.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(s.name.localized(context)),
                        selected: _specialtyFilter == s.id,
                        onSelected: (_) =>
                            setState(() => _specialtyFilter = s.id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: doctors.isEmpty
                ? Center(child: Text(l10n.noDoctorsFound))
                : ListView.separated(
                    itemCount: doctors.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return Card(
                        child: ListTile(
                          onTap: () => context.push('/doctors/${doctor.id}'),
                          leading: CircleAvatar(
                            backgroundColor:
                                AppTheme.medicalBlue.withOpacity(0.1),
                            child: Icon(
                              SpecialtyIcon.forName(doctor.specialty.iconName),
                              color: AppTheme.medicalBlue,
                            ),
                          ),
                          title: Text(doctor.name.localized(context)),
                          subtitle: Text(
                            '${doctor.specialty.name.localized(context)} • ${doctor.clinic.name.localized(context)}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  Text(' ${doctor.rating}'),
                                ],
                              ),
                              if (doctor.isAvailableToday)
                                Text(
                                  l10n.available,
                                  style: TextStyle(
                                    color: AppTheme.medicalGreen,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
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
      appBar: AppBar(
        title: Text(l10n.searchDoctors),
        backgroundColor: AppTheme.patientColor,
      ),
      body: body,
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
