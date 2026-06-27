import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/clinic.dart';
import '../../../models/localized_text.dart';
import '../../../core/auth/admin_permissions.dart';
import '../../../presentation/widgets/admin_guard.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../utils/localization_utils.dart';

class OwnerClinicsScreen extends StatefulWidget {
  const OwnerClinicsScreen({super.key});

  @override
  State<OwnerClinicsScreen> createState() => _OwnerClinicsScreenState();
}

class _OwnerClinicsScreenState extends State<OwnerClinicsScreen> {
  final _uuid = const Uuid();

  Future<void> _showForm({Clinic? existing}) async {
    final l10n = AppLocalizations.of(context);
    final nameKu = TextEditingController(text: existing?.name.ku ?? '');
    final nameAr = TextEditingController(text: existing?.name.ar ?? '');
    final nameEn = TextEditingController(text: existing?.name.en ?? '');
    final addrKu = TextEditingController(text: existing?.address.ku ?? '');
    final addrAr = TextEditingController(text: existing?.address.ar ?? '');
    final addrEn = TextEditingController(text: existing?.address.en ?? '');
    final phone = TextEditingController(text: existing?.phone ?? '');
    final lat = TextEditingController(text: '${existing?.latitude ?? 36.19}');
    final lng = TextEditingController(text: '${existing?.longitude ?? 44.01}');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? l10n.addClinic : l10n.edit),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameKu,
                decoration: InputDecoration(labelText: l10n.nameKu),
              ),
              TextField(
                controller: nameAr,
                decoration: InputDecoration(labelText: l10n.nameAr),
              ),
              TextField(
                controller: nameEn,
                decoration: InputDecoration(labelText: l10n.nameEn),
              ),
              TextField(
                controller: addrKu,
                decoration: InputDecoration(labelText: l10n.addressKu),
              ),
              TextField(
                controller: phone,
                decoration: InputDecoration(labelText: l10n.phone),
              ),
              TextField(
                controller: lat,
                decoration: InputDecoration(labelText: l10n.latitude),
              ),
              TextField(
                controller: lng,
                decoration: InputDecoration(labelText: l10n.longitude),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelQueue),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    final clinic = Clinic(
      id: existing?.id ?? _uuid.v4(),
      name: LocalizedText(ku: nameKu.text, ar: nameAr.text, en: nameEn.text),
      address: LocalizedText(
        ku: addrKu.text,
        ar: addrAr.text,
        en: addrEn.text,
      ),
      latitude: double.tryParse(lat.text) ?? 0,
      longitude: double.tryParse(lng.text) ?? 0,
      phone: phone.text,
    );
    final auth = context.read<AuthService>();
    final err = await auth.saveClinic(clinic);
    if (err != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    if (!AdminPermissions.canManageClinics(auth)) return const SizedBox.shrink();

    final clinics = context.watch<ClinicDataService>().clinics;

    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.manageClinics),
          backgroundColor: AppTheme.primaryDark,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showForm(),
          child: const Icon(Icons.add),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: clinics.length,
          itemBuilder: (context, i) {
            final c = clinics[i];
            return Card(
              child: ListTile(
                title: Text(c.name.localized(context)),
                subtitle: Text(c.address.localized(context)),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showForm(existing: c),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
