import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// Adaptive image limits — WhatsApp/Facebook-style compression targets.
abstract final class ImageUploadLimits {
  static const int profileMaxDimension = 1024;
  static const int profileThumbDimension = 256;

  static const int clinicMaxWidth = 1920;
  static const int clinicMaxHeight = 1080;
  static const int clinicThumbWidth = 320;
  static const int clinicThumbHeight = 180;

  /// Preferred full-image upload range (bytes).
  static const int targetMinBytes = 300 * 1024;
  static const int targetMaxBytes = 800 * 1024;
  static const int hardMaxBytes = 1024 * 1024;

  static const int thumbTargetMinBytes = 40 * 1024;
  static const int thumbTargetMaxBytes = 120 * 1024;

  static const int maxJpegQuality = 92;
  static const int minJpegQuality = 58;
  static const int thumbMaxJpegQuality = 85;
  static const int thumbMinJpegQuality = 55;
}

/// Optimized image bytes ready for Firebase Storage upload.
class ProcessedImage {
  const ProcessedImage({
    required this.fullBytes,
    required this.thumbnailBytes,
    this.fullUrl,
    this.thumbnailUrl,
  });

  final Uint8List fullBytes;
  final Uint8List thumbnailBytes;
  final String? fullUrl;
  final String? thumbnailUrl;

  String get fullDisplayUrl =>
      fullUrl ?? 'data:image/jpeg;base64,${base64Encode(fullBytes)}';

  String get thumbnailDisplayUrl =>
      thumbnailUrl ?? 'data:image/jpeg;base64,${base64Encode(thumbnailBytes)}';

  @Deprecated('Use fullDisplayUrl')
  String get fullDataUrl => fullDisplayUrl;

  @Deprecated('Use thumbnailDisplayUrl')
  String get thumbnailDataUrl => thumbnailDisplayUrl;
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
  int hardMaxBytes = ImageUploadLimits.hardMaxBytes,
  int maxQuality = ImageUploadLimits.maxJpegQuality,
  int minQuality = ImageUploadLimits.minJpegQuality,
}) {
  var working = image;

  for (var scalePass = 0; scalePass < 6; scalePass++) {
    var low = minQuality;
    var high = maxQuality;
    Uint8List? best;

    while (low <= high) {
      final quality = (low + high) ~/ 2;
      final bytes = Uint8List.fromList(img.encodeJpg(working, quality: quality));

      if (bytes.length <= targetMaxBytes) {
        best = bytes;
        low = quality + 1;
      } else {
        high = quality - 1;
      }
    }

    if (best != null) {
      return best;
    }

    final fallback = Uint8List.fromList(
      img.encodeJpg(working, quality: minQuality),
    );
    if (fallback.length <= hardMaxBytes) {
      return fallback;
    }

    if (scalePass == 5) {
      throw const FormatException('too_large');
    }

    working = img.copyResize(
      working,
      width: math.max(1, (working.width * 0.85).round()),
      height: math.max(1, (working.height * 0.85).round()),
      interpolation: img.Interpolation.linear,
    );
  }

  throw const FormatException('too_large');
}

Uint8List encodeThumbnailJpeg(img.Image image) => encodeAdaptiveJpeg(
      image,
      targetMaxBytes: ImageUploadLimits.thumbTargetMaxBytes,
      hardMaxBytes: ImageUploadLimits.thumbTargetMaxBytes * 2,
      maxQuality: ImageUploadLimits.thumbMaxJpegQuality,
      minQuality: ImageUploadLimits.thumbMinJpegQuality,
    );

ProcessedImage _buildProfileProcessed(img.Image decoded) {
  final full = resizeToFit(
    decoded,
    maxWidth: ImageUploadLimits.profileMaxDimension,
    maxHeight: ImageUploadLimits.profileMaxDimension,
  );
  final thumb = squareThumbnail(full, ImageUploadLimits.profileThumbDimension);

  return ProcessedImage(
    fullBytes: encodeAdaptiveJpeg(full),
    thumbnailBytes: encodeThumbnailJpeg(thumb),
  );
}

ProcessedImage _buildClinicProcessed(img.Image decoded) {
  final full = resizeToFit(
    decoded,
    maxWidth: ImageUploadLimits.clinicMaxWidth,
    maxHeight: ImageUploadLimits.clinicMaxHeight,
  );
  final thumb = clinicThumbnail(full);

  return ProcessedImage(
    fullBytes: encodeAdaptiveJpeg(full),
    thumbnailBytes: encodeThumbnailJpeg(thumb),
  );
}

ProcessedImage processProfileImage(List<int> bytes) {
  final decoded = decodeImageBytes(Uint8List.fromList(bytes));
  if (decoded == null) {
    throw const FormatException('decode_failed');
  }
  return _buildProfileProcessed(decoded);
}

ProcessedImage processClinicImage(List<int> bytes) {
  final decoded = decodeImageBytes(Uint8List.fromList(bytes));
  if (decoded == null) {
    throw const FormatException('decode_failed');
  }
  return _buildClinicProcessed(decoded);
}

ProcessedImage processCroppedProfileImage(img.Image croppedSquare) {
  final full = croppedSquare.width == ImageUploadLimits.profileMaxDimension &&
          croppedSquare.height == ImageUploadLimits.profileMaxDimension
      ? croppedSquare
      : img.copyResize(
          croppedSquare,
          width: ImageUploadLimits.profileMaxDimension,
          height: ImageUploadLimits.profileMaxDimension,
          interpolation: img.Interpolation.linear,
        );
  final thumb = squareThumbnail(full, ImageUploadLimits.profileThumbDimension);

  return ProcessedImage(
    fullBytes: encodeAdaptiveJpeg(full),
    thumbnailBytes: encodeThumbnailJpeg(thumb),
  );
}

@pragma('vm:entry-point')
ProcessedImage _processProfileBytesIsolate(List<int> bytes) =>
    processProfileImage(bytes);

@pragma('vm:entry-point')
ProcessedImage _processClinicBytesIsolate(List<int> bytes) =>
    processClinicImage(bytes);

@pragma('vm:entry-point')
ProcessedImage _processCroppedJpegBytesIsolate(List<int> bytes) {
  final decoded = decodeImageBytes(Uint8List.fromList(bytes));
  if (decoded == null) {
    throw const FormatException('decode_failed');
  }
  return processCroppedProfileImage(decoded);
}

Future<ProcessedImage> processProfileImageAsync(List<int> bytes) =>
    compute(_processProfileBytesIsolate, bytes);

Future<ProcessedImage> processClinicImageAsync(List<int> bytes) =>
    compute(_processClinicBytesIsolate, bytes);

Future<ProcessedImage> processCroppedProfileImageAsync(img.Image cropped) {
  final seed = Uint8List.fromList(img.encodeJpg(cropped, quality: 95));
  return compute(_processCroppedJpegBytesIsolate, seed);
}

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
  final primary = preferThumbnail ? (thumbnailUrl ?? imageUrl) : (imageUrl ?? thumbnailUrl);
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
