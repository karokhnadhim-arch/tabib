import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/auth/admin_routes.dart';
import '../../services/auth_service.dart';

/// Ensures only the Super Owner can access platform-level multi-tenant routes.
class SuperOwnerGuard extends StatelessWidget {
  const SuperOwnerGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    if (!auth.isSuperOwner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.go(
          auth.isSystemOwner
              ? AdminRoutes.ownerHome
              : auth.canAccessAdminPanel
                  ? AdminRoutes.adminConsole
                  : '/login',
        );
      });
      return const SizedBox.shrink();
    }
    return child;
  }
}
