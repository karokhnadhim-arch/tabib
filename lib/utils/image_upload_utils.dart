import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// Size and quality limits for uploaded images.
abstract final class ImageUploadLimits {
  static const int profileMaxSize = 1024;
  static const int profileThumbSize = 256;

  static const int clinicMaxWidth = 1920;
  static const int clinicMaxHeight = 1080;
  static const int clinicThumbWidth = 320;
  static const int clinicThumbHeight = 180;

  static const int maxJpegQuality = 85;
  static const int minJpegQuality = 55;

  static const int profileMaxBytes = 600 * 1024;
  static const int profileThumbMaxBytes = 96 * 1024;
  static const int clinicMaxBytes = 1200 * 1024;
  static const int clinicThumbMaxBytes = 120 * 1024;
}

class ProcessedImage {
  const ProcessedImage({
    required this.fullDataUrl,
    required this.thumbnailDataUrl,
  });

  final String fullDataUrl;
  final String thumbnailDataUrl;
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

String encodeJpegDataUrl(
  img.Image image, {
  int quality = ImageUploadLimits.maxJpegQuality,
  required int maxBytes,
}) {
  var currentQuality = quality;
  Uint8List? bestBytes;

  while (currentQuality >= ImageUploadLimits.minJpegQuality) {
    final bytes = Uint8List.fromList(img.encodeJpg(image, quality: currentQuality));
    bestBytes = bytes;
    if (bytes.length <= maxBytes) {
      break;
    }
    currentQuality -= 5;
  }

  final encoded = bestBytes ?? Uint8List(0);
  if (encoded.isEmpty) {
    throw const FormatException('encode_failed');
  }
  if (encoded.length > maxBytes) {
    throw const FormatException('too_large');
  }

  return 'data:image/jpeg;base64,${base64Encode(encoded)}';
}

ProcessedImage processProfileImage(List<int> bytes) {
  final decoded = decodeImageBytes(Uint8List.fromList(bytes));
  if (decoded == null) {
    throw const FormatException('decode_failed');
  }

  final full = resizeToFit(
    decoded,
    maxWidth: ImageUploadLimits.profileMaxSize,
    maxHeight: ImageUploadLimits.profileMaxSize,
  );
  final thumb = squareThumbnail(full, ImageUploadLimits.profileThumbSize);

  return ProcessedImage(
    fullDataUrl: encodeJpegDataUrl(
      full,
      maxBytes: ImageUploadLimits.profileMaxBytes,
    ),
    thumbnailDataUrl: encodeJpegDataUrl(
      thumb,
      quality: 80,
      maxBytes: ImageUploadLimits.profileThumbMaxBytes,
    ),
  );
}

ProcessedImage processClinicImage(List<int> bytes) {
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

  return ProcessedImage(
    fullDataUrl: encodeJpegDataUrl(
      full,
      maxBytes: ImageUploadLimits.clinicMaxBytes,
    ),
    thumbnailDataUrl: encodeJpegDataUrl(
      thumb,
      quality: 80,
      maxBytes: ImageUploadLimits.clinicThumbMaxBytes,
    ),
  );
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
