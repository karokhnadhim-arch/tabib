import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/doctor.dart';
import '../../services/clinic_data_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/localization_utils.dart';
import '../../widgets/common_widgets.dart';

class SpecialtyDoctorsScreen extends StatelessWidget {
  const SpecialtyDoctorsScreen({super.key, required this.specialtyId});

  final String specialtyId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = context.watch<ClinicDataService>();
    final specialty = data.specialties.where((s) => s.id == specialtyId).firstOrNull;
    final doctors = data.doctorsBySpecialty(specialtyId);

    return Scaffold(
      appBar: AppBar(
        title: Text(specialty?.name.localized(context) ?? l10n.searchDoctors),
        backgroundColor: AppTheme.patientColor,
      ),
      body: doctors.isEmpty
          ? Center(child: Text(l10n.noDoctorsFound))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: doctors.length,
              itemBuilder: (context, index) => DoctorCard(
                doctor: doctors[index],
                onTap: () => context.push('/patient/doctor/${doctors[index].id}'),
              ),
            ),
    );
  }
}

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final doctors = context.watch<ClinicDataService>().doctors.where((d) {
      if (_query.isEmpty) return true;
      return d.name.localized(context).contains(_query) ||
          d.specialty.name.localized(context).contains(_query) ||
          d.clinic.name.localized(context).contains(_query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.searchDoctors),
        backgroundColor: AppTheme.patientColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: doctors.length,
              itemBuilder: (context, index) => DoctorCard(
                doctor: doctors[index],
                onTap: () => context.push('/patient/doctor/${doctors[index].id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.doctor, required this.onTap});

  final Doctor doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.patientColor.withOpacity(0.1),
                child: Icon(
                  SpecialtyIcon.forName(doctor.specialty.iconName),
                  color: AppTheme.patientColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name.localized(context),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(doctor.specialty.name.localized(context)),
                    Text(
                      doctor.clinic.name.localized(context),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      Text('${doctor.rating}'),
                    ],
                  ),
                  Text(
                    doctor.isAvailableToday ? l10n.available : l10n.unavailable,
                    style: TextStyle(
                      fontSize: 11,
                      color: doctor.isAvailableToday ? Colors.green : Colors.red,
                    ),
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

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
