import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../services/image_storage_service.dart';
import 'image_upload_utils.dart';

/// Central entry point for Tabib image picks → optimize → upload.
///
/// Use this for any new image upload flows so compression and Firebase Storage
/// stay consistent across the app.
abstract final class TabibImageUpload {
  /// Picks an image, adaptively compresses, and uploads full + thumbnail.
  static Future<UploadedImageUrls?> pickOptimizeAndUpload({
    required ImageStorageCategory category,
    String? ownerId,
    required OptimizedImage Function(List<int> bytes) optimizer,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;

    final bytes = result.files.first.bytes;
    if (bytes == null || bytes.isEmpty) return null;

    try {
      return await ImageStorageService.instance.optimizeAndUpload(
        rawBytes: bytes,
        category: category,
        ownerId: ownerId,
        optimizer: optimizer,
      );
    } catch (error, stackTrace) {
      debugPrint('TabibImageUpload failed: $error');
      debugPrint('$stackTrace');
      return null;
    }
  }

  /// Upload already-optimized bytes (e.g. after in-app crop).
  static Future<UploadedImageUrls> uploadOptimized({
    required OptimizedImage image,
    required ImageStorageCategory category,
    String? ownerId,
  }) {
    return ImageStorageService.instance.uploadOptimized(
      image: image,
      category: category,
      ownerId: ownerId,
    );
  }
}
