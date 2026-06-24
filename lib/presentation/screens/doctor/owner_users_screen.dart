import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/user_account.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../utils/localization_utils.dart';

class OwnerUsersScreen extends StatelessWidget {
  const OwnerUsersScreen({super.key});

  String _roleLabel(AppLocalizations l10n, UserRole role) {
    switch (role) {
      case UserRole.doctor:
        return l10n.roleDoctor;
      case UserRole.secretary:
        return l10n.roleSecretary;
      case UserRole.patient:
        return l10n.patientApp;
      case UserRole.admin:
        return l10n.roleAdmin;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    if (!auth.isSystemOwner) return const SizedBox.shrink();

    final backend = context.read<ClinicDataService>().backend;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageStaff),
        backgroundColor: AppTheme.primaryDark,
      ),
      body: StreamBuilder<List<UserAccount>>(
        stream: backend.watchStaff(),
        builder: (context, snapshot) {
          final staff = snapshot.data ?? const [];
          if (staff.isEmpty) {
            return Center(child: Text(l10n.manageStaff));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: staff.length,
            itemBuilder: (context, i) {
              final user = staff[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryDark.withOpacity(0.1),
                    child: Icon(
                      user.role == UserRole.doctor
                          ? Icons.medical_services_outlined
                          : Icons.support_agent_outlined,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  title: Text(user.name.localized(context)),
                  subtitle: Text(
                    [
                      _roleLabel(l10n, user.role),
                      if (user.email != null) user.email!,
                    ].join(' · '),
                  ),
                  isThreeLine: user.isSystemOwner,
                  trailing: user.isSystemOwner
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => backend.deleteStaff(user.id),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
