import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool initialized = false;
  static String? initError;

  /// Initializes Firebase when configured. Returns false for demo/offline mode.
  static Future<bool> initialize() async {
    final options = DefaultFirebaseOptions.currentPlatform;

    if (!DefaultFirebaseOptions.isConfiguredFor(options)) {
      initialized = false;
      initError = 'Firebase options are not configured for this platform.';
      debugPrint('Tabib: demo mode — Firebase not configured.');
      return false;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: options);
      }
      await _configureFirestore();
      initialized = true;
      initError = null;
      return true;
    } catch (error, stackTrace) {
      initialized = false;
      initError = error.toString();
      debugPrint('Firebase initialization failed: $error');
      debugPrint('$stackTrace');
      // Fall back to demo mode (especially important on web).
      return false;
    }
  }

  /// True when the app should use in-memory demo data instead of Firebase.
  static bool get shouldUseDemoMode => !initialized;

  static Future<void> _configureFirestore() async {
    final firestore = FirebaseFirestore.instance;
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}
