import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../utils/image_upload_utils.dart';
import 'firebase_bootstrap.dart';

/// Where optimized images are stored in Firebase Storage.
enum ImageStorageCategory {
  doctorProfile('doctors/profile'),
  clinicPhoto('clinics/photos'),
  general('general');

  const ImageStorageCategory(this.pathSegment);
  final String pathSegment;
}

class UploadedImageUrls {
  const UploadedImageUrls({
    required this.fullUrl,
    required this.thumbnailUrl,
  });

  final String fullUrl;
  final String thumbnailUrl;
}

/// Uploads adaptive-compressed images to Firebase Storage (or data URLs in demo).
class ImageStorageService {
  ImageStorageService({FirebaseStorage? storage}) : _storage = storage;

  final FirebaseStorage? _storage;
  static const _uuid = Uuid();

  static ImageStorageService? _instance;
  static ImageStorageService get instance =>
      _instance ??= ImageStorageService();

  bool get _useStorage =>
      FirebaseBootstrap.initialized && !FirebaseBootstrap.shouldUseDemoMode;

  FirebaseStorage get _firebaseStorage =>
      _storage ?? FirebaseStorage.instance;

  /// Compresses (if needed) and uploads full + thumbnail images.
  Future<UploadedImageUrls> uploadOptimized({
    required OptimizedImage image,
    required ImageStorageCategory category,
    String? ownerId,
  }) async {
    if (!_useStorage) {
      return UploadedImageUrls(
        fullUrl: image.fullDataUrl,
        thumbnailUrl: image.thumbnailDataUrl,
      );
    }

    final id = _uuid.v4();
    final owner = ownerId ?? 'shared';
    final basePath = 'tabib/images/${category.pathSegment}/$owner';

    final fullRef = _firebaseStorage.ref('$basePath/${id}_full.jpg');
    final thumbRef = _firebaseStorage.ref('$basePath/${id}_thumb.jpg');

    await Future.wait([
      _putBytes(fullRef, image.fullBytes),
      _putBytes(thumbRef, image.thumbnailBytes),
    ]);

    final urls = await Future.wait([
      fullRef.getDownloadURL(),
      thumbRef.getDownloadURL(),
    ]);

    return UploadedImageUrls(
      fullUrl: urls[0],
      thumbnailUrl: urls[1],
    );
  }

  /// Pick bytes → optimize → upload in one call (runs optimization first).
  Future<UploadedImageUrls> optimizeAndUpload({
    required List<int> rawBytes,
    required ImageStorageCategory category,
    String? ownerId,
    required OptimizedImage Function(List<int> bytes) optimizer,
  }) async {
    final optimized = optimizer(rawBytes);
    return uploadOptimized(
      image: optimized,
      category: category,
      ownerId: ownerId,
    );
  }

  Future<void> _putBytes(Reference ref, Uint8List bytes) {
    return ref.putData(
      bytes,
      SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public,max-age=31536000',
      ),
    );
  }

  /// Re-uploads a data-URL image if Firebase Storage is active; otherwise passthrough.
  Future<UploadedImageUrls> ensureStorageUrls({
    required String fullUrl,
    String? thumbnailUrl,
    required ImageStorageCategory category,
    required String ownerId,
  }) async {
    if (!_useStorage || !fullUrl.trim().startsWith('data:image')) {
      return UploadedImageUrls(
        fullUrl: fullUrl,
        thumbnailUrl: thumbnailUrl ?? fullUrl,
      );
    }

    final fullBytes = decodeDataUrlBytes(fullUrl);
    if (fullBytes == null || fullBytes.isEmpty) {
      return UploadedImageUrls(
        fullUrl: fullUrl,
        thumbnailUrl: thumbnailUrl ?? fullUrl,
      );
    }

    final thumbBytes = thumbnailUrl != null
        ? decodeDataUrlBytes(thumbnailUrl)
        : null;

    return uploadOptimized(
      image: OptimizedImage(
        fullBytes: fullBytes,
        thumbnailBytes: thumbBytes ?? fullBytes,
      ),
      category: category,
      ownerId: ownerId,
    );
  }
}
