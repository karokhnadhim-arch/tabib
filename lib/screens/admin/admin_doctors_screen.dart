import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../../models/doctor.dart';
import '../../models/localized_text.dart';
import '../../models/user_account.dart';
import '../../services/clinic_data_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/localization_utils.dart';

class AdminDoctorsScreen extends StatelessWidget {
  const AdminDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = context.watch<ClinicDataService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageDoctors),
        backgroundColor: AppTheme.primaryDark,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDoctorForm(context),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.doctors.length,
        itemBuilder: (context, i) {
          final d = data.doctors[i];
          return Card(
            child: ListTile(
              title: Text(d.name.localized(context)),
              subtitle: Text(d.specialty.name.localized(context)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => data.backend.deleteDoctor(d.id),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDoctorForm(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final data = context.read<ClinicDataService>();
    if (data.clinics.isEmpty || data.specialties.isEmpty) return;

    final clinicId = data.clinics.first.id;
    final specialtyId = data.specialties.first.id;
    const uuid = Uuid();
    await data.backend.upsertDoctor(
      Doctor(
        id: uuid.v4(),
        name: const LocalizedText(ku: 'دکتۆر', ar: 'طبيب', en: 'Doctor'),
        specialtyId: specialtyId,
        specialty: data.specialties.first,
        clinicId: clinicId,
        clinic: data.clinics.first,
        rating: 4.5,
        experienceYears: 5,
        bio: const LocalizedText(ku: '', ar: '', en: ''),
        isAvailableToday: true,
      ),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.savedSuccessfully)),
      );
    }
  }
}

class AdminStaffScreen extends StatelessWidget {
  const AdminStaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageStaff),
        backgroundColor: AppTheme.primaryDark,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addStaff(context),
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: Text(l10n.manageStaff),
      ),
    );
  }

  Future<void> _addStaff(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    const uuid = Uuid();
    await context.read<ClinicDataService>().backend.upsertStaff(
          UserAccount(
            id: uuid.v4(),
            name: const LocalizedText(ku: 'سکرتێر', ar: 'سكرتير', en: 'Secretary'),
            role: UserRole.secretary,
            email: 'staff@clinic.app',
            clinicId: context.read<ClinicDataService>().clinics.firstOrNull?.id,
          ),
          password: 'Staff1234!',
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.savedSuccessfully)),
      );
    }
  }
}

class AdminQueuesScreen extends StatelessWidget {
  const AdminQueuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final doctors = context.watch<ClinicDataService>().doctors;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageQueues),
        backgroundColor: AppTheme.primaryDark,
      ),
      body: ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (context, i) {
          final d = doctors[i];
          return ListTile(
            title: Text(d.name.localized(context)),
            subtitle: Text(d.clinic.name.localized(context)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          );
        },
      ),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
