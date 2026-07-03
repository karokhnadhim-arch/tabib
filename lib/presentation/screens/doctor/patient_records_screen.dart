import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/appointment.dart';
import '../../../services/auth_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/staff_patient_contact_bar.dart';

class PatientRecordsScreen extends StatefulWidget {
  const PatientRecordsScreen({super.key});

  @override
  State<PatientRecordsScreen> createState() => _PatientRecordsScreenState();
}

class _PatientRecordsScreenState extends State<PatientRecordsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final doctorId = auth.currentUser?.doctorId ?? '';
    final query = _searchController.text.trim().toLowerCase();
    final appointments = context.watch<AppointmentProvider>().appointments
        .where((a) =>
            a.doctorId == doctorId &&
            (a.isAccepted || a.status == AppointmentStatus.completed))
        .where((a) {
          if (query.isEmpty) return true;
          final name = (a.patientName ?? '').toLowerCase();
          final phone = (a.patientPhone ?? '').toLowerCase();
          return name.contains(query) || phone.contains(query);
        })
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l10n.searchPatientsHint,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: appointments.isEmpty
              ? Center(child: Text(l10n.noPatientRecords))
              : ListView.separated(
                  itemCount: appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final a = appointments[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      AppTheme.medicalBlue.withOpacity(0.1),
                                  child: const Icon(
                                    Icons.person,
                                    color: AppTheme.medicalBlue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.patientName ?? l10n.patientName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${a.specialty} • ${a.clinicName}',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (a.patientId != null)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.medication_outlined,
                                    ),
                                    onPressed: () {
                                      context.push(
                                        '/doctor/prescription/${a.patientId}?name=${Uri.encodeComponent(a.patientName ?? '')}',
                                      );
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            StaffPatientContactBar(
                              phone: a.patientPhone ?? '',
                              patientName: a.patientName ?? l10n.patientName,
                              doctorId: doctorId,
                              doctorName: a.doctorName,
                              patientId: a.patientId,
                              compact: true,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
