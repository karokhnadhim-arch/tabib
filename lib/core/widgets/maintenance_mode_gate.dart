import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/system_maintenance_service.dart';

/// Blocks non-owner/admin users when platform maintenance mode is enabled.
class MaintenanceModeGate extends StatelessWidget {
  const MaintenanceModeGate({super.key, required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final maintenance = context.watch<SystemMaintenanceService>();
    final auth = context.watch<AuthService>();

    if (maintenance.enabled &&
        !auth.isSystemOwner &&
        !auth.canAccessAdminPanel) {
      return ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.build_circle_outlined,
                      size: 72,
                      color: AppTheme.primaryDark.withOpacity(0.85),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      maintenance.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            height: 1.5,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return child ??
        const ColoredBox(
          color: AppTheme.medicalWhite,
          child: Center(
            child: CircularProgressIndicator(color: AppTheme.medicalBlue),
          ),
        );
  }
}
