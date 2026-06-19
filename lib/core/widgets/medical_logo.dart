import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MedicalLogo extends StatelessWidget {
  const MedicalLogo({
    super.key,
    this.size = 80,
    this.showLabel = true,
  });

  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.medicalBlue, AppTheme.medicalGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.medicalBlue.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.medical_services_rounded,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 12),
          Text(
            'Tabib',
            style: TextStyle(
              fontSize: size * 0.32,
              fontWeight: FontWeight.bold,
              color: AppTheme.medicalBlueDark,
            ),
          ),
        ],
      ],
    );
  }
}
