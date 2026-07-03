import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/auth/admin_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';

/// App bar for platform admin module screens with System Owner back navigation.
PreferredSizeWidget ownerModuleAppBar(
  BuildContext context, {
  required String title,
  List<Widget>? actions,
}) {
  final auth = context.watch<AuthService>();

  return AppBar(
    title: Text(title),
    backgroundColor: AppTheme.primaryDark,
    automaticallyImplyLeading: !auth.isSystemOwner,
    leading: auth.isSystemOwner
        ? IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => context.go(AdminRoutes.ownerHome),
          )
        : null,
    actions: actions,
  );
}
