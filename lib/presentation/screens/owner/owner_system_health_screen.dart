import 'package:flutter/material.dart';

import 'system_health/owner_system_health_dashboard.dart';

/// Platform infrastructure monitoring — System Owner only.
class OwnerSystemHealthScreen extends StatelessWidget {
  const OwnerSystemHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OwnerSystemHealthDashboard();
  }
}
