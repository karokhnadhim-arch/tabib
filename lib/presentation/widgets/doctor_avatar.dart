import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../utils/doctor_photo_utils.dart';

class DoctorAvatar extends StatelessWidget {
  const DoctorAvatar({
    super.key,
    required this.photoUrl,
    this.radius = 40,
    this.backgroundColor,
    this.fallback,
    this.border,
  });

  final String? photoUrl;
  final double radius;
  final Color? backgroundColor;
  final Widget? fallback;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final provider = doctorPhotoImageProvider(photoUrl);
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor:
          backgroundColor ?? AppTheme.medicalBlue.withOpacity(0.12),
      backgroundImage: provider,
      onBackgroundImageError: provider != null ? (_, __) {} : null,
      child: provider == null
          ? fallback ??
              Icon(
                Icons.person,
                size: radius,
                color: AppTheme.medicalBlue.withOpacity(0.7),
              )
          : null,
    );

    if (border == null) return avatar;
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, border: border),
      child: avatar,
    );
  }
}
