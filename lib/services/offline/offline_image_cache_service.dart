import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'connectivity_service.dart';

/// Disk cache for profile images and logos — avoids duplicate network fetches.
class OfflineImageCacheService {
  OfflineImageCacheService({required ConnectivityService connectivity})
      : _connectivity = connectivity;

  final ConnectivityService _connectivity;
  static const _indexKey = 'offline_image_index_v1';
  static const _maxEntries = 120;

  Directory? _cacheDir;

  Future<Directory> _dir() async {
    return _cacheDir ??= await _ensureDir();
  }

  Future<Directory> _ensureDir() async {
    if (kIsWeb) {
      throw UnsupportedError('Disk image cache is not used on web.');
    }
    final base = await getApplicationCacheDirectory();
    final dir = Directory('${base.path}/tabib_images');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _hashUrl(String url) => url.trim().hashCode.abs().toRadixString(16);

  Future<String?> localPathForUrl(String url) async {
    if (kIsWeb || url.trim().isEmpty || url.startsWith('data:')) return null;
    final prefs = await SharedPreferences.getInstance();
    final index = _readIndex(prefs);
    final path = index[url.trim()];
    if (path == null) return null;
    final file = File(path);
    if (await file.exists()) return path;
    index.remove(url.trim());
    await _writeIndex(prefs, index);
    return null;
  }

  Future<File?> getCachedFile(String url) async {
    final path = await localPathForUrl(url);
    if (path == null) return null;
    return File(path);
  }

  /// Returns cached file or downloads when online (non-blocking for UI).
  Future<File?> cacheUrl(String url) async {
    if (kIsWeb || url.trim().isEmpty || url.startsWith('data:')) return null;
    final existing = await getCachedFile(url);
    if (existing != null) return existing;
    if (!_connectivity.isOnline) return null;

    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url.trim()));
      final response = await request.close();
      if (response.statusCode != 200) return null;
      final bytes = await consolidateHttpClientResponseBytes(response);
      client.close();

      final dir = await _dir();
      final file = File('${dir.path}/${_hashUrl(url)}');
      await file.writeAsBytes(bytes, flush: true);
      await _remember(url.trim(), file.path);
      return file;
    } catch (_) {
      return null;
    }
  }

  Future<void> _remember(String url, String path) async {
    final prefs = await SharedPreferences.getInstance();
    final index = _readIndex(prefs);
    index.remove(url);
    index[url] = path;
    while (index.length > _maxEntries) {
      final oldest = index.keys.first;
      final oldPath = index.remove(oldest);
      if (oldPath != null) {
        try {
          await File(oldPath).delete();
        } catch (_) {}
      }
    }
    await _writeIndex(prefs, index);
  }

  Map<String, String> _readIndex(SharedPreferences prefs) {
    final raw = prefs.getString(_indexKey);
    if (raw == null) return <String, String>{};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v as String));
    } catch (_) {
      return <String, String>{};
    }
  }

  Future<void> _writeIndex(
    SharedPreferences prefs,
    Map<String, String> index,
  ) async {
    await prefs.setString(_indexKey, jsonEncode(index));
  }
}
