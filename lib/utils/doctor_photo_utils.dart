import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../presentation/widgets/profile_photo_crop_screen.dart';
import '../services/image_storage_service.dart';
import 'image_upload_utils.dart';
import 'profile_photo_crop.dart';

export 'image_upload_utils.dart'
    show
        ImageUploadLimits,
        ProcessedImage,
        tabibHasDisplayableImage,
        tabibImageProvider;

/// Picks a profile photo, crops, compresses in the background, and uploads.
Future<DoctorPhotoPickResult> pickDoctorPhotoDataUrl(
  BuildContext context, {
  ImageStorageService? imageStorage,
  String? doctorId,
}) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    withData: true,
    allowMultiple: false,
  );
  if (result == null || result.files.isEmpty) {
    return const DoctorPhotoPickResult.cancelled();
  }

  final file = result.files.first;
  final bytes = file.bytes;
  if (bytes == null || bytes.isEmpty) {
    return const DoctorPhotoPickResult.error('empty');
  }

  img.Image editorImage;
  try {
    editorImage = prepareImageForCropEditor(bytes);
  } catch (_) {
    return const DoctorPhotoPickResult.error('processing_failed');
  }

  if (!context.mounted) {
    return const DoctorPhotoPickResult.cancelled();
  }

  final cropped = await Navigator.of(context).push<img.Image>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ProfilePhotoCropScreen(image: editorImage),
    ),
  );

  if (cropped == null) {
    return const DoctorPhotoPickResult.cancelled();
  }

  try {
    final processed = await processCroppedProfileImageAsync(cropped);
    return _finalizeUpload(
      processed: processed,
      imageStorage: imageStorage,
      upload: (img) => imageStorage!.uploadDoctorProfile(
        doctorId: doctorId!,
        image: img,
      ),
      canUpload: imageStorage != null && doctorId != null && doctorId.isNotEmpty,
    );
  } on FormatException catch (error) {
    if (error.message == 'too_large') {
      return const DoctorPhotoPickResult.error('too_large');
    }
    return const DoctorPhotoPickResult.error('processing_failed');
  } catch (_) {
    return const DoctorPhotoPickResult.error('processing_failed');
  }
}

/// Picks a clinic photo, compresses in the background, and uploads.
Future<DoctorPhotoPickResult> pickClinicPhotoDataUrl({
  ImageStorageService? imageStorage,
  String? clinicId,
}) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    withData: true,
    allowMultiple: false,
  );
  if (result == null || result.files.isEmpty) {
    return const DoctorPhotoPickResult.cancelled();
  }

  final file = result.files.first;
  final bytes = file.bytes;
  if (bytes == null || bytes.isEmpty) {
    return const DoctorPhotoPickResult.error('empty');
  }

  try {
    final processed = await processClinicImageAsync(bytes);
    return _finalizeUpload(
      processed: processed,
      imageStorage: imageStorage,
      upload: (img) => imageStorage!.uploadClinicGalleryPhoto(
        clinicId: clinicId!,
        image: img,
      ),
      canUpload: imageStorage != null && clinicId != null && clinicId.isNotEmpty,
    );
  } on FormatException catch (error) {
    if (error.message == 'too_large') {
      return const DoctorPhotoPickResult.error('too_large');
    }
    return const DoctorPhotoPickResult.error('processing_failed');
  } catch (_) {
    return const DoctorPhotoPickResult.error('processing_failed');
  }
}

Future<DoctorPhotoPickResult> _finalizeUpload({
  required ProcessedImage processed,
  required ImageStorageService? imageStorage,
  required Future<UploadedImageUrls> Function(ProcessedImage) upload,
  required bool canUpload,
}) async {
  if (canUpload) {
    final urls = await upload(processed);
    return DoctorPhotoPickResult.success(
      dataUrl: urls.fullUrl,
      thumbnailDataUrl: urls.thumbnailUrl,
    );
  }

  return DoctorPhotoPickResult.success(
    dataUrl: processed.fullDisplayUrl,
    thumbnailDataUrl: processed.thumbnailDisplayUrl,
  );
}

class DoctorPhotoPickResult {
  const DoctorPhotoPickResult._({
    this.dataUrl,
    this.thumbnailDataUrl,
    this.errorCode,
  });

  const DoctorPhotoPickResult.cancelled()
      : this._(dataUrl: null, thumbnailDataUrl: null, errorCode: null);

  const DoctorPhotoPickResult.success({
    required String dataUrl,
    required String thumbnailDataUrl,
  }) : this._(
          dataUrl: dataUrl,
          thumbnailDataUrl: thumbnailDataUrl,
          errorCode: null,
        );

  const DoctorPhotoPickResult.error(String code)
      : this._(dataUrl: null, thumbnailDataUrl: null, errorCode: code);

  final String? dataUrl;
  final String? thumbnailDataUrl;
  final String? errorCode;

  bool get isSuccess => dataUrl != null;
  bool get isCancelled => dataUrl == null && errorCode == null;
}
