import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../presentation/widgets/profile_photo_crop_screen.dart';
import 'image_upload_utils.dart';
import 'profile_photo_crop.dart';

export 'image_upload_utils.dart'
    show
        ImageUploadLimits,
        OptimizedImage,
        ProcessedImage,
        tabibHasDisplayableImage,
        tabibImageProvider;

/// Picks a profile photo, crops, and adaptively compresses (local only).
Future<DoctorPhotoPickResult> pickDoctorPhotoDataUrl(
  BuildContext context,
) async {
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
    final optimized = optimizeCroppedProfileImage(cropped);
    return DoctorPhotoPickResult.success(
      dataUrl: optimized.fullDataUrl,
      thumbnailDataUrl: optimized.thumbnailDataUrl,
      optimized: optimized,
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

/// Picks a clinic photo and adaptively compresses (local only).
Future<DoctorPhotoPickResult> pickClinicPhotoDataUrl() async {
  return _pickAndProcessClinic(optimizeClinicImage);
}

Future<DoctorPhotoPickResult> _pickAndProcessClinic(
  OptimizedImage Function(List<int> bytes) optimizer,
) async {
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
    final optimized = optimizer(bytes);
    return DoctorPhotoPickResult.success(
      dataUrl: optimized.fullDataUrl,
      thumbnailDataUrl: optimized.thumbnailDataUrl,
      optimized: optimized,
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

class DoctorPhotoPickResult {
  const DoctorPhotoPickResult._({
    this.dataUrl,
    this.thumbnailDataUrl,
    this.optimized,
    this.errorCode,
  });

  const DoctorPhotoPickResult.cancelled()
      : this._(
          dataUrl: null,
          thumbnailDataUrl: null,
          optimized: null,
          errorCode: null,
        );

  const DoctorPhotoPickResult.success({
    required String dataUrl,
    required String thumbnailDataUrl,
    OptimizedImage? optimized,
  }) : this._(
          dataUrl: dataUrl,
          thumbnailDataUrl: thumbnailDataUrl,
          optimized: optimized,
          errorCode: null,
        );

  const DoctorPhotoPickResult.error(String code)
      : this._(
          dataUrl: null,
          thumbnailDataUrl: null,
          optimized: null,
          errorCode: code,
        );

  final String? dataUrl;
  final String? thumbnailDataUrl;
  final OptimizedImage? optimized;
  final String? errorCode;

  bool get isSuccess => dataUrl != null;
  bool get isCancelled => dataUrl == null && errorCode == null;
}
