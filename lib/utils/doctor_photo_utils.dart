import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Max encoded size for demo-mode base64 photos stored in [Doctor.photoUrl].
const int kDoctorPhotoMaxBytes = 512 * 1024;

ImageProvider? doctorPhotoImageProvider(String? photoUrl) {
  if (photoUrl == null || photoUrl.trim().isEmpty) return null;
  final url = photoUrl.trim();
  if (url.startsWith('data:image')) {
    try {
      final base64Str = url.contains(',') ? url.split(',').last : url;
      final bytes = base64Decode(base64Str);
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }
  return NetworkImage(url);
}

bool doctorHasDisplayablePhoto(String? photoUrl) =>
    doctorPhotoImageProvider(photoUrl) != null;

String _mimeFromExtension(String? extension) {
  switch (extension?.toLowerCase()) {
    case 'png':
      return 'image/png';
    case 'gif':
      return 'image/gif';
    case 'webp':
      return 'image/webp';
    default:
      return 'image/jpeg';
  }
}

/// Picks an image and returns a `data:image/...;base64,...` URL for web demo mode.
Future<DoctorPhotoPickResult> pickDoctorPhotoDataUrl() async {
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
  if (bytes.length > kDoctorPhotoMaxBytes) {
    return const DoctorPhotoPickResult.error('too_large');
  }

  final mime = _mimeFromExtension(file.extension);
  final dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
  return DoctorPhotoPickResult.success(dataUrl);
}

class DoctorPhotoPickResult {
  const DoctorPhotoPickResult._({
    this.dataUrl,
    this.errorCode,
  });

  const DoctorPhotoPickResult.cancelled()
      : this._(dataUrl: null, errorCode: null);

  const DoctorPhotoPickResult.success(String url)
      : this._(dataUrl: url, errorCode: null);

  const DoctorPhotoPickResult.error(String code)
      : this._(dataUrl: null, errorCode: code);

  final String? dataUrl;
  final String? errorCode;

  bool get isSuccess => dataUrl != null;
  bool get isCancelled => dataUrl == null && errorCode == null;
}
