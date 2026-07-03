import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/auth/admin_routes.dart';
import '../../services/auth_service.dart';

/// Blocks non-clinical accounts from doctor-only routes (queue, profile, etc.).
class ClinicalProviderGuard extends StatelessWidget {
  const ClinicalProviderGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    if (auth.isClinicalProvider) return child;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      if (auth.isSystemOwner) {
        context.go(AdminRoutes.ownerHome);
      } else if (auth.canAccessAdminPanel) {
        context.go(AdminRoutes.adminConsole);
      } else if (auth.isSecretary) {
        context.go('/secretary');
      } else {
        context.go(auth.isLoggedIn ? '/home' : '/login');
      }
    });
    return const SizedBox.shrink();
  }
}
