import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/clinic.dart';
import '../../../services/clinic_data_service.dart';
import 'owner_clinic_structure_screen.dart';

/// Resolves clinic by id then shows structure admin.
class OwnerClinicStructureRouteScreen extends StatelessWidget {
  const OwnerClinicStructureRouteScreen({super.key, required this.clinicId});

  final String clinicId;

  @override
  Widget build(BuildContext context) {
    final clinics = context.watch<ClinicDataService>().clinics;
    Clinic? clinic;
    for (final c in clinics) {
      if (c.id == clinicId) {
        clinic = c;
        break;
      }
    }

    if (clinic == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: TextButton(
            onPressed: () => context.pop(),
            child: const Text('Back'),
          ),
        ),
      );
    }

    return OwnerClinicStructureScreen(clinic: clinic);
  }
}
