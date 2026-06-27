import 'package:flutter/material.dart';

import 'owner_staff_list_screen.dart';

/// All staff with activate / deactivate controls.
class OwnerUsersScreen extends StatelessWidget {
  const OwnerUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OwnerStaffListScreen(filter: OwnerStaffFilter.all);
  }
}
