import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/admin_permissions.dart';
import '../../services/auth_service.dart';

/// Protects admin-only screens — renders nothing for non-owner accounts.
class AdminGuard extends StatelessWidget {
  const AdminGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    if (!AdminPermissions.canAccessAdminPanel(auth)) {
      return const SizedBox.shrink();
    }
    return child;
  }
}
