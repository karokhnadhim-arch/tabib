import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/auth/admin_routes.dart';
import '../../services/auth_service.dart';

/// Ensures only the System Owner can access a route.
class SystemOwnerGuard extends StatelessWidget {
  const SystemOwnerGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    if (!auth.isSystemOwner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.go(
          auth.canAccessAdminPanel
              ? AdminRoutes.adminConsole
              : '/login',
        );
      });
      return const SizedBox.shrink();
    }
    return child;
  }
}
