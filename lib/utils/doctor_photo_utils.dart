import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../presentation/widgets/profile_photo_crop_screen.dart';
import 'image_upload_utils.dart';
import 'profile_photo_crop.dart';

export 'image_upload_utils.dart'
    show
        ImageUploadLimits,
        ProcessedImage,
        tabibHasDisplayableImage,
        tabibImageProvider;

/// Picks a profile photo, opens the circular crop editor, then saves the crop.
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
    final processed = processCroppedProfileImage(cropped);
    return DoctorPhotoPickResult.success(
      dataUrl: processed.fullDataUrl,
      thumbnailDataUrl: processed.thumbnailDataUrl,
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

/// Picks a clinic photo, compresses to 1920x1080 max, and returns full + thumbnail URLs.
Future<DoctorPhotoPickResult> pickClinicPhotoDataUrl() async {
  return _pickAndProcessClinic(processClinicImage);
}

Future<DoctorPhotoPickResult> _pickAndProcessClinic(
  ProcessedImage Function(List<int> bytes) processor,
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
    final processed = processor(bytes);
    return DoctorPhotoPickResult.success(
      dataUrl: processed.fullDataUrl,
      thumbnailDataUrl: processed.thumbnailDataUrl,
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
