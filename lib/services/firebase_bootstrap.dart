import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool initialized = false;
  static String? initError;

  /// Initializes Firebase when configured. Returns false for demo/offline mode.
  static Future<bool> initialize() async {
    if (initialized) return true;

    if (!DefaultFirebaseOptions.isConfigured) {
      initError = 'Firebase options are not configured.';
      debugPrint('Tabib: demo mode — Firebase not configured.');
      return false;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
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

  /// True when Firebase should not be used (placeholders or init failed).
  static bool get shouldUseDemoMode => !initialized && !DefaultFirebaseOptions.isConfigured;
}
