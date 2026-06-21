import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';

/// Banner shown when the app runs without Firebase (demo / offline data).
class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: AppTheme.medicalGreen,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.science_outlined, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'دۆخی تاقیکردنەوە — Firebase ڕێکنەخراوە. '
                  'بەڕێوەبەر: ${AuthService.demoAdminEmail} / ${AuthService.demoPassword} · '
                  'دکتۆر: ${AuthService.demoDoctorEmail} / ${AuthService.demoPassword}',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
