import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../utils/image_upload_utils.dart';

class DoctorAvatar extends StatelessWidget {
  const DoctorAvatar({
    super.key,
    required this.photoUrl,
    this.thumbnailUrl,
    this.radius = 40,
    this.backgroundColor,
    this.fallback,
    this.border,
  });

  final String? photoUrl;
  final String? thumbnailUrl;
  final double radius;
  final Color? backgroundColor;
  final Widget? fallback;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheSize = (radius * 2 * pixelRatio).round().clamp(1, 512);
    final provider = tabibImageProvider(
      photoUrl,
      thumbnailUrl: thumbnailUrl,
      preferThumbnail: true,
    );

    Widget avatar;
    if (provider == null) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor:
            backgroundColor ?? AppTheme.medicalBlue.withOpacity(0.12),
        child: fallback ??
            Icon(
              Icons.person,
              size: radius,
              color: AppTheme.medicalBlue.withOpacity(0.7),
            ),
      );
    } else {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor:
            backgroundColor ?? AppTheme.medicalBlue.withOpacity(0.12),
        child: ClipOval(
          child: Image(
            image: ResizeImage(
              provider,
              width: cacheSize,
              height: cacheSize,
            ),
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) =>
                fallback ??
                Icon(
                  Icons.person,
                  size: radius,
                  color: AppTheme.medicalBlue.withOpacity(0.7),
                ),
          ),
        ),
      );
    }

    if (border == null) return avatar;
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, border: border),
      child: avatar,
    );
  }
}
