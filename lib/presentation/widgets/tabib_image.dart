import 'package:flutter/material.dart';

import '../../utils/image_upload_utils.dart';

class TabibImage extends StatelessWidget {
  const TabibImage({
    super.key,
    required this.imageUrl,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.preferThumbnail = true,
    this.errorWidget,
  });

  final String imageUrl;
  final String? thumbnailUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool preferThumbnail;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final displayUrl = preferThumbnail
        ? (thumbnailUrl ?? imageUrl).trim()
        : (imageUrl).trim();
    if (displayUrl.isEmpty) {
      return _wrap(_fallback());
    }

    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth =
        width != null ? (width! * pixelRatio).round().clamp(1, 4096) : null;
    final cacheHeight =
        height != null ? (height! * pixelRatio).round().clamp(1, 4096) : null;

    Widget image;
    if (displayUrl.startsWith('data:image')) {
      final provider = tabibImageProvider(
        imageUrl,
        thumbnailUrl: thumbnailUrl,
        preferThumbnail: preferThumbnail,
      );
      if (provider == null) {
        return _wrap(_fallback());
      }
      image = Image(
        image: ResizeImage(
          provider,
          width: cacheWidth,
          height: cacheHeight,
        ),
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else {
      image = Image(
        image: ResizeImage(
          NetworkImage(displayUrl),
          width: cacheWidth,
          height: cacheHeight,
        ),
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    return _wrap(image);
  }

  Widget _wrap(Widget child) {
    if (borderRadius == null) return child;
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }

  Widget _fallback() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.grey.shade500,
          ),
        );
  }
}
