import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../utils/image_upload_utils.dart';

/// Categories for Firebase Storage paths — extensible for future uploads.
enum ImageUploadCategory {
  doctorProfile,
  clinicGallery,
  staffProfile,
}

class UploadedImageUrls {
  const UploadedImageUrls({
    required this.fullUrl,
    required this.thumbnailUrl,
  });

  final String fullUrl;
  final String thumbnailUrl;
}

/// Uploads optimized JPEG bytes to Firebase Storage (demo mode uses data URLs).
class ImageStorageService {
  ImageStorageService({
    required bool demoMode,
    FirebaseStorage? storage,
  })  : _demoMode = demoMode,
        _storage = storage ?? FirebaseStorage.instance;

  final bool _demoMode;
  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  bool get isDemoMode => _demoMode;

  Future<UploadedImageUrls> uploadDoctorProfile({
    required String doctorId,
    required ProcessedImage image,
  }) async {
    if (image.fullUrl != null && image.thumbnailUrl != null) {
      return UploadedImageUrls(
        fullUrl: image.fullUrl!,
        thumbnailUrl: image.thumbnailUrl!,
      );
    }
    if (_demoMode) {
      return UploadedImageUrls(
        fullUrl: image.fullDisplayUrl,
        thumbnailUrl: image.thumbnailDisplayUrl,
      );
    }

    final stamp = DateTime.now().millisecondsSinceEpoch;
    final fullPath = 'images/doctors/$doctorId/profile_$stamp.jpg';
    final thumbPath = 'images/doctors/$doctorId/profile_${stamp}_thumb.jpg';

    final fullUrl = await _uploadBytes(fullPath, image.fullBytes);
    final thumbUrl = await _uploadBytes(thumbPath, image.thumbnailBytes);

    return UploadedImageUrls(fullUrl: fullUrl, thumbnailUrl: thumbUrl);
  }

  Future<UploadedImageUrls> uploadClinicGalleryPhoto({
    required String clinicId,
    required ProcessedImage image,
  }) async {
    if (image.fullUrl != null && image.thumbnailUrl != null) {
      return UploadedImageUrls(
        fullUrl: image.fullUrl!,
        thumbnailUrl: image.thumbnailUrl!,
      );
    }
    if (_demoMode) {
      return UploadedImageUrls(
        fullUrl: image.fullDisplayUrl,
        thumbnailUrl: image.thumbnailDisplayUrl,
      );
    }

    final id = _uuid.v4();
    final fullPath = 'images/clinics/$clinicId/gallery/$id.jpg';
    final thumbPath = 'images/clinics/$clinicId/gallery/${id}_thumb.jpg';

    final fullUrl = await _uploadBytes(fullPath, image.fullBytes);
    final thumbUrl = await _uploadBytes(thumbPath, image.thumbnailBytes);

    return UploadedImageUrls(fullUrl: fullUrl, thumbnailUrl: thumbUrl);
  }

  /// Reserved for future staff profile uploads (secretaries use minimal accounts).
  Future<UploadedImageUrls> uploadStaffProfile({
    required String staffId,
    required ImageUploadCategory category,
    required ProcessedImage image,
  }) async {
    if (_demoMode) {
      return UploadedImageUrls(
        fullUrl: image.fullDisplayUrl,
        thumbnailUrl: image.thumbnailDisplayUrl,
      );
    }

    final folder = switch (category) {
      ImageUploadCategory.doctorProfile => 'doctors',
      ImageUploadCategory.clinicGallery => 'clinics',
      ImageUploadCategory.staffProfile => 'staff',
    };
    final id = _uuid.v4();
    final fullPath = 'images/$folder/$staffId/$id.jpg';
    final thumbPath = 'images/$folder/$staffId/${id}_thumb.jpg';

    final fullUrl = await _uploadBytes(fullPath, image.fullBytes);
    final thumbUrl = await _uploadBytes(thumbPath, image.thumbnailBytes);

    return UploadedImageUrls(fullUrl: fullUrl, thumbnailUrl: thumbUrl);
  }

  Future<String> _uploadBytes(String path, Uint8List bytes) async {
    final ref = _storage.ref(path);
    await ref.putData(
      bytes,
      SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public,max-age=31536000',
      ),
    );
    return ref.getDownloadURL();
  }
}
