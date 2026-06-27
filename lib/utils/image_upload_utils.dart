import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// Adaptive image limits — targets WhatsApp/Facebook-style uploads.
abstract final class ImageUploadLimits {
  /// Full image target band (only compress below min when already huge).
  static const int targetMinBytes = 300 * 1024;
  static const int targetMaxBytes = 800 * 1024;

  static const int profileMaxDimension = 1200;
  static const int profileThumbDimension = 320;

  static const int clinicMaxWidth = 1920;
  static const int clinicMaxHeight = 1080;
  static const int clinicThumbWidth = 480;
  static const int clinicThumbHeight = 270;

  static const int thumbnailMaxBytes = 120 * 1024;

  static const int maxJpegQuality = 92;
  static const int minJpegQuality = 58;

  /// Legacy aliases used elsewhere.
  static const int profileMaxSize = profileMaxDimension;
  static const int profileThumbSize = profileThumbDimension;
}

/// Optimized image bytes ready for upload or demo-mode data URLs.
class OptimizedImage {
  const OptimizedImage({
    required this.fullBytes,
    required this.thumbnailBytes,
  });

  final Uint8List fullBytes;
  final Uint8List thumbnailBytes;

  int get fullSize => fullBytes.length;
  int get thumbnailSize => thumbnailBytes.length;

  String get fullDataUrl => bytesToDataUrl(fullBytes);
  String get thumbnailDataUrl => bytesToDataUrl(thumbnailBytes);
}

/// Legacy wrapper — URLs are data URLs until Firebase Storage upload completes.
class ProcessedImage {
  const ProcessedImage({
    required this.fullDataUrl,
    required this.thumbnailDataUrl,
    this.optimized,
  });

  final String fullDataUrl;
  final String thumbnailDataUrl;
  final OptimizedImage? optimized;

  factory ProcessedImage.fromOptimized(OptimizedImage image) =>
      ProcessedImage(
        fullDataUrl: image.fullDataUrl,
        thumbnailDataUrl: image.thumbnailDataUrl,
        optimized: image,
      );
}

img.Image? decodeImageBytes(Uint8List bytes) => img.decodeImage(bytes);

img.Image resizeToFit(
  img.Image source, {
  required int maxWidth,
  required int maxHeight,
}) {
  if (source.width <= maxWidth && source.height <= maxHeight) {
    return source;
  }

  final widthScale = maxWidth / source.width;
  final heightScale = maxHeight / source.height;
  final scale = math.min(widthScale, heightScale);
  final targetWidth = math.max(1, (source.width * scale).round());
  final targetHeight = math.max(1, (source.height * scale).round());

  return img.copyResize(
    source,
    width: targetWidth,
    height: targetHeight,
    interpolation: img.Interpolation.linear,
  );
}

img.Image squareThumbnail(img.Image source, int size) {
  final side = math.min(source.width, source.height);
  final x = (source.width - side) ~/ 2;
  final y = (source.height - side) ~/ 2;
  final cropped = img.copyCrop(
    source,
    x: x,
    y: y,
    width: side,
    height: side,
  );
  return img.copyResize(
    cropped,
    width: size,
    height: size,
    interpolation: img.Interpolation.linear,
  );
}

img.Image clinicThumbnail(img.Image source) {
  return resizeToFit(
    source,
    maxWidth: ImageUploadLimits.clinicThumbWidth,
    maxHeight: ImageUploadLimits.clinicThumbHeight,
  );
}

/// Adaptive JPEG encoder — preserves quality, compresses only when needed.
Uint8List encodeAdaptiveJpeg(
  img.Image image, {
  int targetMaxBytes = ImageUploadLimits.targetMaxBytes,
  int maxQuality = ImageUploadLimits.maxJpegQuality,
  int minQuality = ImageUploadLimits.minJpegQuality,
}) {
  var best = Uint8List.fromList(img.encodeJpg(image, quality: maxQuality));

  if (best.length <= targetMaxBytes) {
    return best;
  }

  var lo = minQuality;
  var hi = maxQuality;

  while (lo <= hi) {
    final mid = (lo + hi) ~/ 2;
    final bytes = Uint8List.fromList(img.encodeJpg(image, quality: mid));
    if (bytes.length <= targetMaxBytes) {
      best = bytes;
      lo = mid + 1;
    } else {
      hi = mid - 1;
    }
  }

  if (best.length <= targetMaxBytes) {
    return best;
  }

  return _encodeWithProgressiveResize(
    image,
    targetMaxBytes: targetMaxBytes,
    maxQuality: maxQuality,
    minQuality: minQuality,
  );
}

Uint8List _encodeWithProgressiveResize(
  img.Image image, {
  required int targetMaxBytes,
  required int maxQuality,
  required int minQuality,
}) {
  var scaled = image;
  var best = Uint8List.fromList(img.encodeJpg(scaled, quality: minQuality));

  for (var pass = 0; pass < 8 && best.length > targetMaxBytes; pass++) {
    final nextW = math.max(320, (scaled.width * 0.88).round());
    final nextH = math.max(320, (scaled.height * 0.88).round());
    if (nextW == scaled.width && nextH == scaled.height) break;

    scaled = img.copyResize(
      scaled,
      width: nextW,
      height: nextH,
      interpolation: img.Interpolation.linear,
    );
    best = encodeAdaptiveJpeg(
      scaled,
      targetMaxBytes: targetMaxBytes,
      maxQuality: maxQuality,
      minQuality: minQuality,
    );
  }

  return best;
}

String bytesToDataUrl(Uint8List bytes) =>
    'data:image/jpeg;base64,${base64Encode(bytes)}';

@Deprecated('Use encodeAdaptiveJpeg')
String encodeJpegDataUrl(
  img.Image image, {
  int quality = ImageUploadLimits.maxJpegQuality,
  required int maxBytes,
}) => bytesToDataUrl(
      encodeAdaptiveJpeg(image, targetMaxBytes: maxBytes, maxQuality: quality),
    );

OptimizedImage optimizeProfileImage(List<int> bytes) {
  final decoded = decodeImageBytes(Uint8List.fromList(bytes));
  if (decoded == null) {
    throw const FormatException('decode_failed');
  }

  final full = resizeToFit(
    decoded,
    maxWidth: ImageUploadLimits.profileMaxDimension,
    maxHeight: ImageUploadLimits.profileMaxDimension,
  );
  final thumb = squareThumbnail(
    full,
    ImageUploadLimits.profileThumbDimension,
  );

  return OptimizedImage(
    fullBytes: encodeAdaptiveJpeg(full),
    thumbnailBytes: encodeAdaptiveJpeg(
      thumb,
      targetMaxBytes: ImageUploadLimits.thumbnailMaxBytes,
      maxQuality: 85,
    ),
  );
}

OptimizedImage optimizeClinicImage(List<int> bytes) {
  final decoded = decodeImageBytes(Uint8List.fromList(bytes));
  if (decoded == null) {
    throw const FormatException('decode_failed');
  }

  final full = resizeToFit(
    decoded,
    maxWidth: ImageUploadLimits.clinicMaxWidth,
    maxHeight: ImageUploadLimits.clinicMaxHeight,
  );
  final thumb = clinicThumbnail(full);

  return OptimizedImage(
    fullBytes: encodeAdaptiveJpeg(full),
    thumbnailBytes: encodeAdaptiveJpeg(
      thumb,
      targetMaxBytes: ImageUploadLimits.thumbnailMaxBytes,
      maxQuality: 85,
    ),
  );
}

OptimizedImage optimizeCroppedProfileImage(img.Image croppedSquare) {
  final full = croppedSquare.width == ImageUploadLimits.profileMaxDimension &&
          croppedSquare.height == ImageUploadLimits.profileMaxDimension
      ? croppedSquare
      : img.copyResize(
          croppedSquare,
          width: ImageUploadLimits.profileMaxDimension,
          height: ImageUploadLimits.profileMaxDimension,
          interpolation: img.Interpolation.linear,
        );
  final thumb = squareThumbnail(
    full,
    ImageUploadLimits.profileThumbDimension,
  );

  return OptimizedImage(
    fullBytes: encodeAdaptiveJpeg(full),
    thumbnailBytes: encodeAdaptiveJpeg(
      thumb,
      targetMaxBytes: ImageUploadLimits.thumbnailMaxBytes,
      maxQuality: 85,
    ),
  );
}

@Deprecated('Use optimizeProfileImage')
ProcessedImage processProfileImage(List<int> bytes) =>
    ProcessedImage.fromOptimized(optimizeProfileImage(bytes));

@Deprecated('Use optimizeClinicImage')
ProcessedImage processClinicImage(List<int> bytes) =>
    ProcessedImage.fromOptimized(optimizeClinicImage(bytes));

Uint8List? decodeDataUrlBytes(String dataUrl) {
  final trimmed = dataUrl.trim();
  if (!trimmed.startsWith('data:image')) return null;
  try {
    final base64Str = trimmed.contains(',') ? trimmed.split(',').last : trimmed;
    return base64Decode(base64Str);
  } catch (_) {
    return null;
  }
}

ImageProvider? tabibImageProvider(
  String? imageUrl, {
  String? thumbnailUrl,
  bool preferThumbnail = true,
}) {
  final primary =
      preferThumbnail ? (thumbnailUrl ?? imageUrl) : (imageUrl ?? thumbnailUrl);
  if (primary == null || primary.trim().isEmpty) return null;

  final url = primary.trim();
  if (url.startsWith('data:image')) {
    final bytes = decodeDataUrlBytes(url);
    if (bytes == null || bytes.isEmpty) return null;
    return MemoryImage(bytes);
  }
  return NetworkImage(url);
}

bool tabibHasDisplayableImage(String? imageUrl, {String? thumbnailUrl}) =>
    tabibImageProvider(imageUrl, thumbnailUrl: thumbnailUrl) != null;
