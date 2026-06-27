import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/auth/admin_permissions.dart';
import '../../services/auth_service.dart';

/// Protects admin-only screens — redirects non-owner accounts to the doctor dashboard.
class AdminGuard extends StatelessWidget {
  const AdminGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    if (!AdminPermissions.canAccessAdminPanel(auth)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/doctor');
      });
      return const SizedBox.shrink();
    }
    return child;
  }
}
