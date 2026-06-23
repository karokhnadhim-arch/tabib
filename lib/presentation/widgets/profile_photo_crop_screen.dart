import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/profile_photo_crop.dart';

class ProfilePhotoCropScreen extends StatefulWidget {
  const ProfilePhotoCropScreen({super.key, required this.image});

  final img.Image image;

  @override
  State<ProfilePhotoCropScreen> createState() => _ProfilePhotoCropScreenState();
}

class _ProfilePhotoCropScreenState extends State<ProfilePhotoCropScreen> {
  static const _minUserScale = 1.0;
  static const _maxUserScale = 4.0;
  static const _previewSize = 96.0;

  late final Uint8List _previewBytes;

  double _userScale = 1.0;
  Offset _offset = Offset.zero;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _previewBytes = encodeImageForPreview(widget.image);
  }

  double _cropSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return math.min(width - 48, 320);
  }

  double _baseScale(BuildContext context) {
    return profilePhotoBaseScale(
      image: widget.image,
      cropSize: _cropSize(context),
    );
  }

  void _ensureInitialized(BuildContext context) {
    if (_initialized) return;
    _offset = clampProfilePhotoOffset(
      image: widget.image,
      cropSize: _cropSize(context),
      baseScale: _baseScale(context),
      userScale: _userScale,
      offset: _offset,
    );
    _initialized = true;
  }

  void _setUserScale(BuildContext context, double nextScale) {
    setState(() {
      _userScale = nextScale.clamp(_minUserScale, _maxUserScale);
      _offset = clampProfilePhotoOffset(
        image: widget.image,
        cropSize: _cropSize(context),
        baseScale: _baseScale(context),
        userScale: _userScale,
        offset: _offset,
      );
    });
  }

  void _pan(BuildContext context, Offset delta) {
    setState(() {
      _offset = clampProfilePhotoOffset(
        image: widget.image,
        cropSize: _cropSize(context),
        baseScale: _baseScale(context),
        userScale: _userScale,
        offset: _offset + delta,
      );
    });
  }

  void _save(BuildContext context) {
    final cropped = extractProfilePhotoCrop(
      source: widget.image,
      cropSize: _cropSize(context),
      baseScale: _baseScale(context),
      userScale: _userScale,
      offset: _offset,
    );
    Navigator.of(context).pop(cropped);
  }

  @override
  Widget build(BuildContext context) {
    _ensureInitialized(context);
    final l10n = AppLocalizations.of(context);
    final cropSize = _cropSize(context);
    final baseScale = _baseScale(context);
    final totalScale = baseScale * _userScale;
    final displayWidth = widget.image.width * totalScale;
    final displayHeight = widget.image.height * totalScale;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l10n.cropProfilePhoto),
        actions: [
          TextButton(
            onPressed: () => _save(context),
            child: Text(
              l10n.usePhoto,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.cropProfilePhotoHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.78),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _CropCanvas(
                      cropSize: cropSize,
                      previewBytes: _previewBytes,
                      displayWidth: displayWidth,
                      displayHeight: displayHeight,
                      offset: _offset,
                      onPan: (delta) => _pan(context, delta),
                      onScale: (scaleDelta) {
                        _setUserScale(context, _userScale * scaleDelta);
                      },
                    ),
                    const SizedBox(height: 24),
                    _ZoomControls(
                      userScale: _userScale,
                      minScale: _minUserScale,
                      maxScale: _maxUserScale,
                      onZoomOut: () => _setUserScale(context, _userScale / 1.2),
                      onZoomIn: () => _setUserScale(context, _userScale * 1.2),
                      onSliderChanged: (value) => _setUserScale(context, value),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Text(
                    l10n.photoPreview,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _CropPreview(
                    cropSize: cropSize,
                    previewSize: _previewSize,
                    previewBytes: _previewBytes,
                    displayWidth: displayWidth,
                    displayHeight: displayHeight,
                    offset: _offset,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.photoPreviewHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropCanvas extends StatelessWidget {
  const _CropCanvas({
    required this.cropSize,
    required this.previewBytes,
    required this.displayWidth,
    required this.displayHeight,
    required this.offset,
    required this.onPan,
    required this.onScale,
  });

  final double cropSize;
  final Uint8List previewBytes;
  final double displayWidth;
  final double displayHeight;
  final Offset offset;
  final ValueChanged<Offset> onPan;
  final ValueChanged<double> onScale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cropSize,
      height: cropSize,
      child: GestureDetector(
        onScaleUpdate: (details) {
          if (details.scale != 1.0) {
            onScale(details.scale);
          }
          if (details.focalPointDelta != Offset.zero) {
            onPan(details.focalPointDelta);
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: SizedBox(
                width: cropSize,
                height: cropSize,
                child: _PositionedCropImage(
                  cropSize: cropSize,
                  previewBytes: previewBytes,
                  displayWidth: displayWidth,
                  displayHeight: displayHeight,
                  offset: offset,
                ),
              ),
            ),
            IgnorePointer(
              child: Container(
                width: cropSize,
                height: cropSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropPreview extends StatelessWidget {
  const _CropPreview({
    required this.cropSize,
    required this.previewSize,
    required this.previewBytes,
    required this.displayWidth,
    required this.displayHeight,
    required this.offset,
  });

  final double cropSize;
  final double previewSize;
  final Uint8List previewBytes;
  final double displayWidth;
  final double displayHeight;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final factor = previewSize / cropSize;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.doctorColor, width: 3),
      ),
      child: ClipOval(
        child: SizedBox(
          width: previewSize,
          height: previewSize,
          child: _PositionedCropImage(
            cropSize: previewSize,
            previewBytes: previewBytes,
            displayWidth: displayWidth * factor,
            displayHeight: displayHeight * factor,
            offset: Offset(offset.dx * factor, offset.dy * factor),
          ),
        ),
      ),
    );
  }
}

class _PositionedCropImage extends StatelessWidget {
  const _PositionedCropImage({
    required this.cropSize,
    required this.previewBytes,
    required this.displayWidth,
    required this.displayHeight,
    required this.offset,
  });

  final double cropSize;
  final Uint8List previewBytes;
  final double displayWidth;
  final double displayHeight;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned(
          left: cropSize / 2 - displayWidth / 2 + offset.dx,
          top: cropSize / 2 - displayHeight / 2 + offset.dy,
          width: displayWidth,
          height: displayHeight,
          child: Image.memory(
            previewBytes,
            fit: BoxFit.fill,
            gaplessPlayback: true,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ],
    );
  }
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({
    required this.userScale,
    required this.minScale,
    required this.maxScale,
    required this.onZoomOut,
    required this.onZoomIn,
    required this.onSliderChanged,
  });

  final double userScale;
  final double minScale;
  final double maxScale;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;
  final ValueChanged<double> onSliderChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          IconButton.filledTonal(
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.white12,
            ),
            onPressed: userScale > minScale ? onZoomOut : null,
            tooltip: l10n.zoomOut,
            icon: const Icon(Icons.remove),
          ),
          Expanded(
            child: Slider(
              value: userScale,
              min: minScale,
              max: maxScale,
              activeColor: AppTheme.doctorColor,
              inactiveColor: Colors.white24,
              onChanged: onSliderChanged,
            ),
          ),
          IconButton.filledTonal(
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.white12,
            ),
            onPressed: userScale < maxScale ? onZoomIn : null,
            tooltip: l10n.zoomIn,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
