import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'services/firebase_bootstrap.dart';

/// Entry point for Tabib — medical appointment platform.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show visible errors instead of blank screen (helps debugging on web).
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFFF8FAFC),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            details.exceptionAsString(),
            style: const TextStyle(color: Colors.red, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  };

  runZonedGuarded(
    () async {
      final firebaseReady = await FirebaseBootstrap.initialize();
      runApp(TabibApp(firebaseReady: firebaseReady));
    },
    (error, stack) {
      debugPrint('Tabib startup error: $error\n$stack');
      runApp(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Tabib failed to start:\n$error',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
