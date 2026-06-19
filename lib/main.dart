import 'package:flutter/material.dart';

import 'app.dart';
import 'services/firebase_bootstrap.dart';

/// Entry point for Tabib — medical appointment platform.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseReady = await FirebaseBootstrap.initialize();

  runApp(TabibApp(firebaseReady: firebaseReady));
}
