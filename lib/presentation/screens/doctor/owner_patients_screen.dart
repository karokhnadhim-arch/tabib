import 'package:flutter/material.dart';

import 'owner_staff_list_screen.dart';

/// Patient accounts — admin status management.
class OwnerPatientsScreen extends StatelessWidget {
  const OwnerPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OwnerStaffListScreen(filter: OwnerStaffFilter.patients);
  }
}
