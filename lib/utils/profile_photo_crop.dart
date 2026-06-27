import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import 'image_upload_utils.dart';

/// Prepares a large picked image for in-app cropping (keeps aspect ratio).
img.Image prepareImageForCropEditor(List<int> bytes) {
  final decoded = decodeImageBytes(Uint8List.fromList(bytes));
  if (decoded == null) {
    throw const FormatException('decode_failed');
  }
  return resizeToFit(
    decoded,
    maxWidth: 2048,
    maxHeight: 2048,
  );
}

/// Base scale so the image fully covers a square crop viewport (cover mode).
double profilePhotoBaseScale({
  required img.Image image,
  required double cropSize,
}) {
  return math.max(
    cropSize / image.width,
    cropSize / image.height,
  );
}

Offset clampProfilePhotoOffset({
  required img.Image image,
  required double cropSize,
  required double baseScale,
  required double userScale,
  required Offset offset,
}) {
  final totalScale = baseScale * userScale;
  final displayW = image.width * totalScale;
  final displayH = image.height * totalScale;
  final halfCrop = cropSize / 2;

  final minDx = halfCrop - displayW / 2;
  final maxDx = displayW / 2 - halfCrop;
  final minDy = halfCrop - displayH / 2;
  final maxDy = displayH / 2 - halfCrop;

  return Offset(
    offset.dx.clamp(math.min(minDx, maxDx), math.max(minDx, maxDx)),
    offset.dy.clamp(math.min(minDy, maxDy), math.max(minDy, maxDy)),
  );
}

/// Extracts the square region visible inside the circular crop viewport.
img.Image extractProfilePhotoCrop({
  required img.Image source,
  required double cropSize,
  required double baseScale,
  required double userScale,
  required Offset offset,
  int outputSize = ImageUploadLimits.profileMaxSize,
}) {
  final totalScale = baseScale * userScale;
  final displayW = source.width * totalScale;
  final displayH = source.height * totalScale;
  final left = cropSize / 2 - displayW / 2 + offset.dx;
  final top = cropSize / 2 - displayH / 2 + offset.dy;

  final srcX = (-left / totalScale);
  final srcY = (-top / totalScale);
  final srcSide = cropSize / totalScale;

  final x = srcX.round().clamp(0, source.width - 1);
  final y = srcY.round().clamp(0, source.height - 1);
  final maxSide = math.min(source.width - x, source.height - y);
  final side = math.max(1, math.min(srcSide.round(), maxSide));

  final cropped = img.copyCrop(
    source,
    x: x,
    y: y,
    width: side,
    height: side,
  );

  if (side == outputSize) return cropped;
  return img.copyResize(
    cropped,
    width: outputSize,
    height: outputSize,
    interpolation: img.Interpolation.linear,
  );
}

ProcessedImage processCroppedProfileImage(img.Image croppedSquare) =>
    ProcessedImage.fromOptimized(optimizeCroppedProfileImage(croppedSquare));

Uint8List encodeImageForPreview(img.Image image) {
  return Uint8List.fromList(img.encodeJpg(image, quality: 92));
}
