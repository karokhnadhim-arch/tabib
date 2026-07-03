import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;

import '../presentation/widgets/profile_photo_crop_screen.dart';
import '../services/image_storage_service.dart';
import 'image_upload_utils.dart';
import 'profile_photo_crop.dart';
import 'tabib_image_upload.dart';

/// Picks, crops, compresses, and uploads a patient profile photo.
Future<PatientPhotoPickResult> pickPatientProfilePhoto(
  BuildContext context, {
  required String patientId,
}) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    withData: true,
    allowMultiple: false,
  );
  if (result == null || result.files.isEmpty) {
    return const PatientPhotoPickResult.cancelled();
  }

  final bytes = result.files.first.bytes;
  if (bytes == null || bytes.isEmpty) {
    return const PatientPhotoPickResult.error('empty');
  }

  img.Image editorImage;
  try {
    editorImage = prepareImageForCropEditor(bytes);
  } catch (_) {
    return const PatientPhotoPickResult.error('processing_failed');
  }

  if (!context.mounted) {
    return const PatientPhotoPickResult.cancelled();
  }

  final cropped = await Navigator.of(context).push<img.Image>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ProfilePhotoCropScreen(image: editorImage),
    ),
  );

  if (cropped == null) {
    return const PatientPhotoPickResult.cancelled();
  }

  try {
    final optimized = optimizeCroppedProfileImage(cropped);
    final urls = await TabibImageUpload.uploadOptimized(
      image: optimized,
      category: ImageStorageCategory.patientProfile,
      ownerId: patientId,
    );
    return PatientPhotoPickResult.success(urls: urls);
  } on FormatException catch (error) {
    if (error.message == 'too_large') {
      return const PatientPhotoPickResult.error('too_large');
    }
    return const PatientPhotoPickResult.error('processing_failed');
  } catch (_) {
    return const PatientPhotoPickResult.error('processing_failed');
  }
}

class PatientPhotoPickResult {
  const PatientPhotoPickResult._({
    this.urls,
    this.errorCode,
  });

  const PatientPhotoPickResult.cancelled()
      : this._(urls: null, errorCode: null);

  const PatientPhotoPickResult.success({required UploadedImageUrls urls})
      : this._(urls: urls, errorCode: null);

  const PatientPhotoPickResult.error(String code)
      : this._(urls: null, errorCode: code);

  final UploadedImageUrls? urls;
  final String? errorCode;

  bool get isSuccess => urls != null;
  bool get isCancelled => urls == null && errorCode == null;
}
