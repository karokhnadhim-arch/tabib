import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Captures device and OS metadata for audit entries.
class AuditDeviceContext {
  const AuditDeviceContext({
    required this.device,
    required this.operatingSystem,
    this.ipAddress,
  });

  final String device;
  final String operatingSystem;
  final String? ipAddress;

  static AuditDeviceContext capture({String? ipAddress}) {
    final platform = defaultTargetPlatform.name;
    String os = platform;
    if (!kIsWeb) {
      try {
        os = '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
      } catch (_) {
        os = platform;
      }
    } else {
      os = 'web';
    }
    return AuditDeviceContext(
      device: platform,
      operatingSystem: os,
      ipAddress: ipAddress,
    );
  }
}
