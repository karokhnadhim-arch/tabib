import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/offline/offline_image_cache_service.dart';
import '../../utils/image_upload_utils.dart';

class TabibImage extends StatefulWidget {
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
  State<TabibImage> createState() => _TabibImageState();
}

class _TabibImageState extends State<TabibImage> {
  File? _cachedFile;

  @override
  void initState() {
    super.initState();
    _resolveCache();
  }

  @override
  void didUpdateWidget(covariant TabibImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldUrl = oldWidget.preferThumbnail
        ? (oldWidget.thumbnailUrl ?? oldWidget.imageUrl)
        : oldWidget.imageUrl;
    final newUrl = widget.preferThumbnail
        ? (widget.thumbnailUrl ?? widget.imageUrl)
        : widget.imageUrl;
    if (oldUrl != newUrl) {
      _cachedFile = null;
      _resolveCache();
    }
  }

  Future<void> _resolveCache() async {
    if (kIsWeb) return;
    final displayUrl = _displayUrl;
    if (displayUrl.isEmpty || displayUrl.startsWith('data:')) return;
    final cache = context.read<OfflineImageCacheService>();
    final local = await cache.getCachedFile(displayUrl);
    if (!mounted) return;
    if (local != null) {
      setState(() => _cachedFile = local);
      return;
    }
    final downloaded = await cache.cacheUrl(displayUrl);
    if (!mounted || downloaded == null) return;
    setState(() => _cachedFile = downloaded);
  }

  String get _displayUrl => widget.preferThumbnail
      ? (widget.thumbnailUrl ?? widget.imageUrl).trim()
      : widget.imageUrl.trim();

  @override
  Widget build(BuildContext context) {
    if (_displayUrl.isEmpty) {
      return _wrap(_fallback());
    }

    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth =
        widget.width != null ? (widget.width! * pixelRatio).round().clamp(1, 4096) : null;
    final cacheHeight = widget.height != null
        ? (widget.height! * pixelRatio).round().clamp(1, 4096)
        : null;

    Widget image;
    if (_cachedFile != null) {
      image = Image(
        image: ResizeImage(
          FileImage(_cachedFile!),
          width: cacheWidth,
          height: cacheHeight,
        ),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else if (_displayUrl.startsWith('data:image')) {
      final provider = tabibImageProvider(
        widget.imageUrl,
        thumbnailUrl: widget.thumbnailUrl,
        preferThumbnail: widget.preferThumbnail,
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
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else {
      image = Image(
        image: ResizeImage(
          NetworkImage(_displayUrl),
          width: cacheWidth,
          height: cacheHeight,
        ),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    return _wrap(image);
  }

  Widget _wrap(Widget child) {
    if (widget.borderRadius == null) return child;
    return ClipRRect(borderRadius: widget.borderRadius!, child: child);
  }

  Widget _fallback() {
    return widget.errorWidget ??
        Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.grey.shade500,
          ),
        );
  }
}
